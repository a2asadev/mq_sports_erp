import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/purchase_order.dart';
import 'package:a2_stocks/providers/purchase_order_providers.dart';
import 'package:a2_stocks/screens/purchasing/purchase_detail_screen.dart';
import 'package:a2_stocks/screens/purchasing/purchase_orders_screen.dart';
import 'package:a2_stocks/screens/purchasing/receive_goods_screen.dart';

/// One purchase order: what was ordered, what has arrived and what is still to come, the receipts (each is an
/// ordinary purchase), and the actions: receive goods, cancel (nothing arrived yet) or close (give up the rest).
class PurchaseOrderDetailScreen extends ConsumerWidget {
  const PurchaseOrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  Future<void> _act(BuildContext context, WidgetRef ref, Future<PurchaseOrder> Function() action, String done, {String? confirm}) async {
    if (confirm != null) {
      final bool? yes = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: Text(confirm),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.expensesCancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.poConfirm)),
          ],
        ),
      );
      if (yes != true || !context.mounted) {
        return;
      }
    }
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      ref.invalidate(purchaseOrderProvider(orderId));
      ref.invalidate(purchaseOrdersProvider);
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
    }
  }

  Future<void> _receive(BuildContext context, WidgetRef ref, PurchaseOrder po) async {
    final bool? done = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (BuildContext context) => ReceiveGoodsScreen(order: po)),
    );
    if (done == true) {
      ref.invalidate(purchaseOrderProvider(orderId));
      ref.invalidate(purchaseOrdersProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PurchaseOrder> order = ref.watch(purchaseOrderProvider(orderId));
    return Scaffold(
      appBar: AppBar(
        title: Text(order.valueOrNull?.poNo ?? context.l10n.modulePurchaseOrders),
        actions: <Widget>[IconButton(tooltip: context.l10n.registerRefresh, icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(purchaseOrderProvider(orderId)))],
      ),
      body: order.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(errorMessageOf(error), textAlign: TextAlign.center))),
        data: (PurchaseOrder po) => _body(context, ref, po),
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, PurchaseOrder po) {
    final ThemeData theme = Theme.of(context);
    final bool late = po.isLate(DateTime.now());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(child: Text(po.vendorName, style: theme.textTheme.titleLarge)),
                    PurchaseOrderStatusChip(status: po.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(<String>[
                  formatDate(po.orderDate),
                  if (po.byName.isNotEmpty) context.l10n.orderDetailBy(po.byName),
                ].join(' · ')),
                if (po.expectedDate.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(late ? context.l10n.poExpectedLate(po.expectedDate) : context.l10n.poExpected(po.expectedDate), style: TextStyle(color: late ? AppColors.danger : null, fontWeight: late ? FontWeight.w600 : null)),
                ],
                if (po.note.isNotEmpty) ...<Widget>[const SizedBox(height: 8), Text(po.note)],
                const Divider(height: 24),
                _row(context.l10n.poOrderedValue, formatMoney(po.orderedValue)),
                _row(context.l10n.poReceivedValue, formatMoney(po.receivedValue)),
                _row(context.l10n.poReceivedOfUnits(po.receivedUnits, po.orderedUnits), ''),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (po.status.canReceive)
          FilledButton.icon(onPressed: () => _receive(context, ref, po), icon: const Icon(Icons.inventory_outlined), label: Text(context.l10n.poReceiveGoods)),
        if (po.status == PurchaseOrderStatus.open) ...<Widget>[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _act(context, ref, () => ref.read(purchaseOrdersServiceProvider).cancel(po.id), context.l10n.poCancelled, confirm: context.l10n.poCancelConfirm),
            icon: const Icon(Icons.cancel_outlined),
            label: Text(context.l10n.poCancelOrder),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
          ),
        ],
        if (po.status == PurchaseOrderStatus.partial) ...<Widget>[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _act(context, ref, () => ref.read(purchaseOrdersServiceProvider).close(po.id), context.l10n.poClosed, confirm: context.l10n.poCloseConfirm),
            icon: const Icon(Icons.done_all),
            label: Text(context.l10n.poCloseOrder),
          ),
        ],
        const SizedBox(height: 16),
        Text(context.l10n.poItems, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final PurchaseOrderItem item in po.items)
          Card(
            child: ListTile(
              title: Text('${item.productName} · ${item.variantLabel}'),
              subtitle: Text(context.l10n.poLineProgress(item.receivedQuantity, item.quantity, formatMoney(item.unitCost))),
              trailing: item.remaining > 0
                  ? Text(context.l10n.poStillToCome(item.remaining), style: const TextStyle(color: AppColors.amber, fontWeight: FontWeight.w600))
                  : const Icon(Icons.check_circle, color: AppColors.teal),
            ),
          ),
        if (po.receipts.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          Text(context.l10n.poReceipts, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final PurchaseOrderReceipt r in po.receipts)
            Card(
              child: ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(r.purchaseNo),
                subtitle: Text(<String>[formatDate(r.receivedAt), context.l10n.orderDetailReturnUnits(r.units), if (r.byName.isNotEmpty) context.l10n.orderDetailBy(r.byName)].join(' · ')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(builder: (BuildContext context) => PurchaseDetailScreen(purchaseId: r.purchaseId)),
                ),
              ),
            ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: <Widget>[Expanded(child: Text(label)), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))]),
      );
}
