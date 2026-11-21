import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/core/utils/web_orders.dart';
import 'package:a2_stocks/core/utils/whatsapp.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/models/customer_model.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/providers/parties_providers.dart';
import 'package:a2_stocks/providers/sales_providers.dart';
import 'package:a2_stocks/providers/shop_name_provider.dart';
import 'package:a2_stocks/screens/sales/order_detail_screen.dart';

/// The board for orders placed in the online store: one column per step (New, Packing, On the way, Delivered),
/// the order that has waited longest first, with the one action that moves an order on, a WhatsApp message to the
/// shopper and cancel. It reads the orders this device already has (they arrive by sync), so it works offline.
class WebOrdersScreen extends ConsumerWidget {
  const WebOrdersScreen({super.key});

  Future<void> _advance(BuildContext context, WidgetRef ref, OrderModel order) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool ok = await ref.read(ordersProvider.notifier).advanceStatus(order);
    if (!ok) {
      final Object? error = ref.read(ordersProvider).error;
      if (error != null) {
        messenger.showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
      }
    }
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref, OrderModel order) async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.orderDetailCancelThisOrder),
        content: Text(dialogContext.l10n.orderDetailWillBeCancelledUnit(order.orderNo, order.totalUnits, order.customerName)),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(dialogContext.l10n.orderDetailKeepOrder)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.l10n.orderDetailCancelOrder),
          ),
        ],
      ),
    );
    if (yes == true) {
      await ref.read(ordersProvider.notifier).cancelOrder(order);
    }
  }

  Future<void> _whatsApp(BuildContext context, WidgetRef ref, OrderModel order) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = context.l10n;
    final String phone = orderPhone(order, ref.read(customersProvider).valueOrNull ?? <CustomerModel>[]);
    if (WhatsApp.internationalPhone(phone).isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.orderDetailThisCustomerHasNo)));
      return;
    }
    final String shop = await ref.read(shopNameProvider.future);
    final Uri? link = WhatsApp.link(phone, WhatsApp.orderMessage(order, shopName: shop));
    bool opened = false;
    try {
      opened = link != null && await launchUrl(link, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.orderDetailWhatsappCouldNotBe)));
    }
  }

  String _age(AppLocalizations l10n, OrderModel order, DateTime now) {
    final ({AgeUnit unit, int count}) a = ageOf(order.createdAt, now);
    return switch (a.unit) {
      AgeUnit.justNow => l10n.webOrdersJustNow,
      AgeUnit.minutes => l10n.webOrdersMinutesAgo(a.count),
      AgeUnit.hours => l10n.webOrdersHoursAgo(a.count),
      AgeUnit.days => l10n.webOrdersDaysAgo(a.count),
    };
  }

  Widget _card(BuildContext context, WidgetRef ref, OrderModel order, double paid, DateTime now) {
    final AppLocalizations l10n = context.l10n;
    final bool canMove = ref.watch(canCreateOrdersProvider) && order.status.next != null;
    final bool canCancel = ref.watch(canCancelOrdersProvider) && !order.status.isFinal;
    final double due = ((order.totalAmount - paid) * 100).round() / 100;
    // A new order that has waited more than half an hour is flagged.
    final bool waiting = order.status == OrderStatus.pending && now.difference(order.createdAt).inMinutes >= 30;
    final OrderStatus? next = order.status.next;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) => OrderDetailScreen(orderId: order.id))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: Text(order.orderNo, style: const TextStyle(fontWeight: FontWeight.w700))),
                  Text(_age(l10n, order, now), style: TextStyle(fontSize: 12, color: waiting ? AppColors.danger : AppColors.textMuted, fontWeight: waiting ? FontWeight.w700 : FontWeight.w400)),
                ],
              ),
              const SizedBox(height: 4),
              Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (order.shippingAddress.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 2),
                Text(order.shippingAddress.trim(), maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  Expanded(child: Text(l10n.webOrdersItems(order.totalUnits), style: const TextStyle(fontSize: 12))),
                  Text(formatMoney(order.totalAmount), style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              if (order.status != OrderStatus.delivered && due > 0.004)
                Text(l10n.webOrdersCollect(formatMoney(due)), style: const TextStyle(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  if (canMove && next != null)
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () => _advance(context, ref, order),
                        child: Text(l10n.webOrdersMoveTo(next.label), overflow: TextOverflow.ellipsis),
                      ),
                    )
                  else
                    const Spacer(),
                  IconButton(tooltip: l10n.insightsWhatsApp, icon: const Icon(Icons.chat_outlined, color: AppColors.teal), onPressed: () => _whatsApp(context, ref, order)),
                  if (canCancel) IconButton(tooltip: l10n.orderDetailCancelOrder, icon: const Icon(Icons.cancel_outlined, color: AppColors.danger), onPressed: () => _cancel(context, ref, order)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _column(BuildContext context, WidgetRef ref, OrderStatus status, List<OrderModel> orders, Map<String, double> paid, DateTime now) {
    if (orders.isEmpty) {
      return Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(context.l10n.webOrdersNone, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted))));
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[for (final OrderModel o in orders) _card(context, ref, o, paid[o.id] ?? 0, now)],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<List<OrderModel>> async = ref.watch(ordersProvider);
    final Map<String, double> paid = ref.watch(orderPaidProvider);
    final DateTime now = DateTime.now();
    final List<OrderModel>? loaded = async.valueOrNull;
    if (loaded == null) {
      final Object? error = async.error;
      return Scaffold(
        appBar: AppBar(title: Text(l10n.moduleWebOrders)),
        body: Center(child: error != null ? Text(errorMessageOf(error)) : const CircularProgressIndicator()),
      );
    }
    final Map<OrderStatus, List<OrderModel>> board = webOrderBoard(loaded, now);
    final bool wide = MediaQuery.sizeOf(context).width >= 1000;
    if (wide) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.moduleWebOrders)),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final OrderStatus s in webOrderColumns)
              Expanded(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(children: <Widget>[
                        Text(s.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(width: 8),
                        Chip(label: Text('${board[s]!.length}'), visualDensity: VisualDensity.compact),
                      ]),
                    ),
                    Expanded(child: _column(context, ref, s, board[s]!, paid, now)),
                  ],
                ),
              ),
          ],
        ),
      );
    }
    return DefaultTabController(
      length: webOrderColumns.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.moduleWebOrders),
          bottom: TabBar(isScrollable: true, tabs: <Widget>[for (final OrderStatus s in webOrderColumns) Tab(text: '${s.label} (${board[s]!.length})')]),
        ),
        body: TabBarView(children: <Widget>[for (final OrderStatus s in webOrderColumns) _column(context, ref, s, board[s]!, paid, now)]),
      ),
    );
  }
}
