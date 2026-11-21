import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/customer_insights.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/core/utils/whatsapp.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/models/customer_model.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/party_enums.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/providers/parties_providers.dart';
import 'package:a2_stocks/providers/sales_providers.dart';
import 'package:a2_stocks/providers/shop_name_provider.dart';
import 'package:a2_stocks/screens/parties/party_detail_screen.dart';

/// Customer insights: who buys the most, who has not been back for a while, and whose birthday is coming, each
/// with a WhatsApp button that opens a ready message (the person presses send; nothing is sent by itself).
/// Worked out on the device from the customers and orders it already has, so it also works offline.
/// Admin and manager.
class CustomerInsightsScreen extends ConsumerStatefulWidget {
  const CustomerInsightsScreen({super.key});

  @override
  ConsumerState<CustomerInsightsScreen> createState() => _CustomerInsightsScreenState();
}

enum _Message { thanks, missYou, birthday }

class _CustomerInsightsScreenState extends ConsumerState<CustomerInsightsScreen> {
  /// Top customers: days to look back (0 = all time).
  int _topDays = 90;
  int _lapsedDays = 60;
  int _birthdayDays = 30;

  Future<void> _whatsApp(CustomerModel customer, _Message kind) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = context.l10n;
    final String name = customer.name.trim();
    if (WhatsApp.internationalPhone(customer.phone).isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.insightsNoPhone(name))));
      return;
    }
    final String shop = await ref.read(shopNameProvider.future);
    final String text = switch (kind) {
      _Message.thanks => l10n.insightsMessageThanks(name, shop),
      _Message.missYou => l10n.insightsMessageMissYou(name, shop),
      _Message.birthday => l10n.insightsMessageBirthday(name, shop),
    };
    final Uri? link = WhatsApp.link(customer.phone, text);
    if (link == null) {
      return;
    }
    bool opened = false;
    try {
      opened = await launchUrl(link, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.orderDetailWhatsappCouldNotBe)));
    }
  }

  void _open(CustomerModel customer) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (BuildContext context) => PartyDetailScreen(partyType: PartyType.customer, partyId: customer.id)),
    );
  }

  Widget _chips(List<int> values, int selected, String Function(int) label, void Function(int) onSelected) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: <Widget>[
          for (final int v in values) ChoiceChip(label: Text(label(v)), selected: v == selected, onSelected: (_) => onSelected(v)),
        ],
      ),
    );
  }

  Widget _row({required CustomerModel customer, required String subtitle, required String trailing, required _Message kind}) {
    final String initial = customer.name.trim().isEmpty ? '?' : customer.name.trim().substring(0, 1).toUpperCase();
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        onTap: () => _open(customer),
        leading: CircleAvatar(backgroundColor: AppColors.primarySoft, foregroundColor: AppColors.primary, child: Text(initial)),
        title: Text(customer.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (trailing.isNotEmpty) Text(trailing, style: const TextStyle(fontWeight: FontWeight.w700)),
            IconButton(
              tooltip: context.l10n.insightsWhatsApp,
              icon: const Icon(Icons.chat_outlined, color: AppColors.teal),
              onPressed: () => _whatsApp(customer, kind),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(String text) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(text, textAlign: TextAlign.center)));

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final List<CustomerModel> customers = ref.watch(customersProvider).valueOrNull ?? <CustomerModel>[];
    final List<OrderModel> orders = ref.watch(ordersProvider).valueOrNull ?? <OrderModel>[];
    final BusinessInfo business = ref.watch(businessProvider);
    final DateTime now = DateTime.now();
    final List<CustomerStat> allTime = customerStats(customers, orders, walkInCustomerId: business.walkInCustomerId);
    final List<CustomerStat> top = _topDays == 0
        ? allTime
        : customerStats(customers, orders, walkInCustomerId: business.walkInCustomerId, since: DateTime(now.year, now.month, now.day).subtract(Duration(days: _topDays)));
    final List<CustomerStat> lapsed = lapsedCustomers(allTime, now, _lapsedDays);
    final List<UpcomingBirthday> birthdays = upcomingBirthdays(customers, now, withinDays: _birthdayDays, walkInCustomerId: business.walkInCustomerId);
    final String locale = Localizations.localeOf(context).toString();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.moduleCustomerInsights),
          bottom: TabBar(tabs: <Widget>[
            Tab(text: l10n.insightsTabTop),
            Tab(text: l10n.insightsTabLapsed),
            Tab(text: l10n.insightsTabBirthdays),
          ]),
        ),
        body: TabBarView(
          children: <Widget>[
            Column(
              children: <Widget>[
                _chips(<int>[30, 90, 365, 0], _topDays, (int d) => d == 0 ? l10n.insightsAllTime : l10n.insightsLastDays(d), (int d) => setState(() => _topDays = d)),
                Expanded(
                  child: top.isEmpty
                      ? _empty(l10n.insightsNoTop)
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          children: <Widget>[
                            for (int i = 0; i < top.length && i < 50; i++)
                              _row(
                                customer: top[i].customer,
                                subtitle: '${l10n.insightsOrders(top[i].orders)} · ${l10n.insightsLastPurchase(formatShortDate(context, top[i].lastOrder))}',
                                trailing: formatMoney(top[i].spent),
                                kind: _Message.thanks,
                              ),
                          ],
                        ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                _chips(<int>[30, 60, 90, 180], _lapsedDays, (int d) => l10n.insightsNotInDays(d), (int d) => setState(() => _lapsedDays = d)),
                Expanded(
                  child: lapsed.isEmpty
                      ? _empty(l10n.insightsNoLapsed(_lapsedDays))
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          children: <Widget>[
                            for (final CustomerStat s in lapsed)
                              _row(
                                customer: s.customer,
                                subtitle: '${l10n.insightsLastPurchase(formatShortDate(context, s.lastOrder))} · ${l10n.insightsSpentTotal(formatMoney(s.spent))}',
                                trailing: l10n.insightsDaysAgo(DateTime(now.year, now.month, now.day).difference(DateTime(s.lastOrder.year, s.lastOrder.month, s.lastOrder.day)).inDays),
                                kind: _Message.missYou,
                              ),
                          ],
                        ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                _chips(<int>[7, 30, 90], _birthdayDays, (int d) => l10n.insightsNextDays(d), (int d) => setState(() => _birthdayDays = d)),
                Expanded(
                  child: birthdays.isEmpty
                      ? _empty(l10n.insightsNoBirthdays)
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          children: <Widget>[
                            for (final UpcomingBirthday b in birthdays)
                              _row(
                                customer: b.customer,
                                subtitle: DateFormat.MMMd(locale).format(b.date),
                                trailing: b.daysAway == 0 ? l10n.insightsToday : l10n.insightsInDays(b.daysAway),
                                kind: _Message.birthday,
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
