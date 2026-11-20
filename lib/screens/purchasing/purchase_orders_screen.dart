import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/purchase_order.dart';
import 'package:a2_stocks/providers/purchase_order_providers.dart';
import 'package:a2_stocks/screens/purchasing/purchase_order_detail_screen.dart';
import 'package:a2_stocks/screens/purchasing/purchase_order_form_screen.dart';

String purchaseOrderStatusLabel(AppLocalizations l10n, PurchaseOrderStatus s) {
  switch (s) {
    case PurchaseOrderStatus.open:
      return l10n.poStatusOpen;
    case PurchaseOrderStatus.partial:
      return l10n.poStatusPartial;
    case PurchaseOrderStatus.received:
      return l10n.poStatusReceived;
    case PurchaseOrderStatus.closed:
      return l10n.poStatusClosed;
    case PurchaseOrderStatus.cancelled:
      return l10n.poStatusCancelled;
  }
}

Color purchaseOrderStatusColor(PurchaseOrderStatus s) {
  switch (s) {
    case PurchaseOrderStatus.open:
      return AppColors.sky;
    case PurchaseOrderStatus.partial:
      return AppColors.amber;
    case PurchaseOrderStatus.received:
      return AppColors.teal;
    case PurchaseOrderStatus.closed:
      return AppColors.textMuted;
    case PurchaseOrderStatus.cancelled:
      return AppColors.danger;
  }
}

/// A small coloured label: Open, Partly received, Received, Closed, Cancelled.
class PurchaseOrderStatusChip extends StatelessWidget {
  const PurchaseOrderStatusChip({super.key, required this.status});

  final PurchaseOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = purchaseOrderStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
      child: Text(purchaseOrderStatusLabel(context.l10n, status), style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

/// Purchase orders: what was ordered from vendors and what has arrived of it. Admin and manager; needs a
/// connection. Nothing changes in stock or in what is owed until goods are received.
class PurchaseOrdersScreen extends ConsumerWidget {
  const PurchaseOrdersScreen({super.key});

  Future<void> _new(BuildContext context, WidgetRef ref) async {
    final String? id = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (BuildContext context) => const PurchaseOrderFormScreen()),
    );
    ref.invalidate(purchaseOrdersProvider);
    if (id != null && context.mounted) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (BuildContext context) => PurchaseOrderDetailScreen(orderId: id)),
      );
      ref.invalidate(purchaseOrdersProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PurchaseOrder>> orders = ref.watch(purchaseOrdersProvider);
    final PurchaseOrderStatus? filter = ref.watch(purchaseOrderFilterProvider);
    final DateTime now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.modulePurchaseOrders),
        actions: <Widget>[
          IconButton(tooltip: context.l10n.registerRefresh, icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(purchaseOrdersProvider)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _new(context, ref),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.poNewOrder),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: context.l10n.poSearchHint, border: const OutlineInputBorder(), isDense: true),
              onChanged: (String v) => ref.read(purchaseOrderSearchProvider.notifier).state = v,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  ChoiceChip(
                    label: Text(context.l10n.poFilterAll),
                    selected: filter == null,
                    onSelected: (bool _) => ref.read(purchaseOrderFilterProvider.notifier).state = null,
                  ),
                  for (final PurchaseOrderStatus s in PurchaseOrderStatus.values)
                    ChoiceChip(
                      label: Text(purchaseOrderStatusLabel(context.l10n, s)),
                      selected: filter == s,
                      onSelected: (bool _) => ref.read(purchaseOrderFilterProvider.notifier).state = s,
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: orders.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stack) =>
                  Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(errorMessageOf(error), textAlign: TextAlign.center))),
              data: (List<PurchaseOrder> list) => list.isEmpty
                  ? Center(child: Text(context.l10n.poNone))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      children: <Widget>[for (final PurchaseOrder po in list) _card(context, ref, po, now)],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, WidgetRef ref, PurchaseOrder po, DateTime now) {
    final bool late = po.isLate(now);
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute<void>(builder: (BuildContext context) => PurchaseOrderDetailScreen(orderId: po.id)),
          );
          ref.invalidate(purchaseOrdersProvider);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: Text(po.vendorName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                  PurchaseOrderStatusChip(status: po.status),
                ],
              ),
              const SizedBox(height: 2),
              Text('${po.poNo} · ${formatDate(po.orderDate)}', style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(child: Text(context.l10n.poReceivedOfUnits(po.receivedUnits, po.orderedUnits))),
                  Text(formatMoney(po.orderedValue), style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              if (po.orderedUnits > 0) ...<Widget>[
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: (po.receivedUnits / po.orderedUnits).clamp(0, 1).toDouble(),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                  color: purchaseOrderStatusColor(po.status),
                  backgroundColor: AppColors.mutedFill,
                ),
              ],
              if (po.expectedDate.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  late ? context.l10n.poExpectedLate(po.expectedDate) : context.l10n.poExpected(po.expectedDate),
                  style: TextStyle(color: late ? AppColors.danger : AppColors.textMuted, fontSize: 13, fontWeight: late ? FontWeight.w600 : null),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
