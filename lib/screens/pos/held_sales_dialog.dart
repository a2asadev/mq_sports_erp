import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/providers/pos_holds.dart';
import 'package:a2_stocks/providers/pos_providers.dart';

/// Lists the sales on hold. Resuming one closes the dialog and returns it;
/// the caller puts it back on the counter.
Future<HeldSale?> showHeldSalesDialog(BuildContext context) {
  return showDialog<HeldSale>(
    context: context,
    builder: (BuildContext context) => const _HeldSalesDialog(),
  );
}

String _ago(BuildContext context, DateTime when) {
  final Duration d = DateTime.now().difference(when);
  if (d.inMinutes < 1) {
    return context.l10n.heldSalesJustNow;
  }
  if (d.inMinutes < 60) {
    return context.l10n.heldSalesMinAgo(d.inMinutes);
  }
  if (d.inHours < 24) {
    return context.l10n.heldSalesHAgo(d.inHours);
  }
  return context.l10n.heldSalesDAgo(d.inDays);
}

String _clock(DateTime when) {
  String two(int n) => n.toString().padLeft(2, '0');
  final DateTime l = when.toLocal();
  return '${two(l.hour)}:${two(l.minute)}';
}

class _HeldSalesDialog extends ConsumerWidget {
  const _HeldSalesDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<HeldSale> held = ref.watch(heldSalesProvider);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(context.l10n.heldSalesHeldSales, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            const Divider(),
            if (held.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text(context.l10n.heldSalesNoSalesOnHold, style: const TextStyle(color: AppColors.textMuted)),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: held.length,
                  separatorBuilder: (BuildContext context, int i) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int i) => _HeldTile(
                    sale: held[i],
                    onResume: () => Navigator.of(context).pop(held[i]),
                    onDelete: () => ref.read(heldSalesProvider.notifier).remove(held[i].id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeldTile extends StatelessWidget {
  const _HeldTile({required this.sale, required this.onResume, required this.onDelete});

  final HeldSale sale;
  final VoidCallback onResume;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final PosCart cart = sale.cart;
    final String names = cart.lines.take(3).map((PosLine l) => '${l.quantity} × ${l.productName}').join(', ');
    final int more = cart.lines.length - 3;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.pause_circle_outline, size: 18, color: AppColors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cart.customer?.name ?? context.l10n.dashboardWalkInCustomer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${_clock(sale.heldAt)} · ${_ago(context, sale.heldAt)}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            more > 0 ? context.l10n.heldSalesAndMore(names, more) : names,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  context.l10n.heldSalesItemsTotal(cart.units, formatMoney(cart.total)),
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
              ),
              TextButton(onPressed: onDelete, child: Text(context.l10n.categoriesDelete)),
              const SizedBox(width: 4),
              FilledButton(
                onPressed: onResume,
                style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
                child: Text(context.l10n.heldSalesResume),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
