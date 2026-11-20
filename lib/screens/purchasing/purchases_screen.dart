import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/core/utils/page_stats.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/widgets/stat_strip.dart';
import 'package:a2_stocks/models/purchase_model.dart';
import 'package:a2_stocks/providers/purchasing_providers.dart';
import 'package:a2_stocks/screens/purchasing/purchase_detail_screen.dart';
import 'package:a2_stocks/screens/purchasing/purchase_form_screen.dart';
import 'package:a2_stocks/widgets/purchase_status_chip.dart';

/// Purchase history with invoice status (Paid, Partial, Pending).
class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> {
  String _query = '';
  PurchaseStatus? _status;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<PurchaseModel>> async = ref.watch(purchasesProvider);
    final Map<String, double> paid = ref.watch(purchasePaidProvider);
    final bool canManage = ref.watch(canManagePurchasesProvider);
    final ThemeData theme = Theme.of(context);

    ref.listen<AsyncValue<List<PurchaseModel>>>(purchasesProvider,
        (AsyncValue<List<PurchaseModel>>? previous,
            AsyncValue<List<PurchaseModel>> next) {
      final Object? error = next.error;
      if (error != null && !identical(error, previous?.error)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
      }
    });

    final List<PurchaseModel>? loaded = async.valueOrNull;
    Widget body;
    if (loaded == null) {
      final Object? error = async.error;
      body = Center(
        child: error != null
            ? Text(errorMessageOf(error))
            : const CircularProgressIndicator(),
      );
    } else {
      final String q = _query.trim().toLowerCase();
      final List<PurchaseModel> purchases = loaded.where((PurchaseModel p) {
        final PurchaseStatus status =
            purchaseStatusFor(p.totalAmount, paid[p.id] ?? 0);
        if (_status != null && status != _status) {
          return false;
        }
        return q.isEmpty ||
            <String>[p.purchaseNo, p.vendorName, p.invoiceNo]
                .join(' ')
                .toLowerCase()
                .contains(q);
      }).toList()
        ..sort((PurchaseModel a, PurchaseModel b) {
          final int byDate = b.purchaseDate.compareTo(a.purchaseDate);
          return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
        });

      final PurchaseStats stats = computePurchaseStats(loaded, paid);

      body = Column(
        children: <Widget>[
          StatStrip(
            items: <StatItem>[
              StatItem(
                icon: Icons.receipt_long_outlined,
                color: AppColors.sky,
                label: context.l10n.purchasesPurchases,
                value: '${stats.count}',
              ),
              StatItem(
                icon: Icons.shopping_bag_outlined,
                color: AppColors.navy,
                label: context.l10n.purchasesTotalPurchased,
                value: formatMoney(stats.total),
              ),
              StatItem(
                icon: Icons.account_balance_wallet_outlined,
                color: stats.due > 0.005 ? AppColors.danger : AppColors.textMuted,
                label: context.l10n.purchasesOwedToVendors,
                value: formatMoney(stats.due),
              ),
              StatItem(
                icon: Icons.pending_actions_outlined,
                color: AppColors.amber,
                label: context.l10n.purchasesNotFullyPaid,
                value: '${stats.unpaidCount}',
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: context.l10n.purchasesSearchPurchaseNoVendor,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (String value) => setState(() => _query = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(context.l10n.posAll),
                    selected: _status == null,
                    onSelected: (bool _) => setState(() => _status = null),
                  ),
                ),
                for (final PurchaseStatus status in PurchaseStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status.label),
                      selected: _status == status,
                      onSelected: (bool selected) =>
                          setState(() => _status = selected ? status : null),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.l10n.purchasesOfPurchaseSShown(purchases.length, loaded.length),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          Expanded(
            child: purchases.isEmpty
                ? Center(
                    child: Text(loaded.isEmpty
                        ? context.l10n.purchasesNoPurchasesYet
                        : context.l10n.purchasesNoPurchasesMatchYour),
                  )
                : ListView.separated(
                    itemCount: purchases.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final PurchaseModel purchase = purchases[index];
                      final PurchaseStatus status = purchaseStatusFor(
                          purchase.totalAmount, paid[purchase.id] ?? 0);
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.receipt_long_outlined),
                        ),
                        title: Text('${purchase.purchaseNo} · ${purchase.vendorName}'),
                        subtitle: Text(
                          <String>[
                            formatDate(purchase.purchaseDate),
                            context.l10n.purchasesItemS(purchase.items.length),
                            if (purchase.invoiceNo.isNotEmpty)
                              context.l10n.purchasesInv(purchase.invoiceNo),
                          ].join(' · '),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              formatAmount(purchase.totalAmount),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            PurchaseStatusChip(status: status),
                          ],
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                PurchaseDetailScreen(purchaseId: purchase.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.purchasesPurchases)),
      body: body,
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const PurchaseFormScreen(),
                ),
              ),
              icon: const Icon(Icons.add_shopping_cart),
              label: Text(context.l10n.purchasesNewPurchase),
            )
          : null,
    );
  }
}
