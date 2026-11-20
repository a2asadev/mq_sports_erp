import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/reorder.dart';
import 'package:a2_stocks/models/vendor_model.dart';
import 'package:a2_stocks/models/purchase_order.dart';
import 'package:a2_stocks/providers/purchase_order_providers.dart';
import 'package:a2_stocks/providers/report_providers.dart';
import 'package:a2_stocks/screens/purchasing/purchase_order_detail_screen.dart';
import 'package:a2_stocks/widgets/party_picker.dart';

/// One vendor's part of the suggestions: what to order from them.
class _Group {
  _Group(this.vendorId, this.vendorName);

  final String vendorId;
  final String vendorName;
  final List<ReorderSuggestion> rows = <ReorderSuggestion>[];
}

/// Reorder suggestions: what is out, low or running out, how much to order and from whom, worked out from the
/// alert levels, how fast each item sells and what is already on order. Pick what to order and "Create order" makes
/// a purchase order for each vendor (an order changes nothing in stock until the goods arrive). Admin and manager;
/// needs a connection.
class ReorderScreen extends ConsumerStatefulWidget {
  const ReorderScreen({super.key});

  @override
  ConsumerState<ReorderScreen> createState() => _ReorderScreenState();
}

class _ReorderScreenState extends ConsumerState<ReorderScreen> {
  /// What the person changed: the quantity of a row, rows left out, and a vendor chosen for rows that had none.
  final Map<String, TextEditingController> _qty = <String, TextEditingController>{};
  final Set<String> _skipped = <String>{};
  final Map<String, VendorModel> _chosenVendor = <String, VendorModel>{};
  final Set<String> _busy = <String>{};

  @override
  void dispose() {
    for (final TextEditingController c in _qty.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controller(ReorderSuggestion row) =>
      _qty.putIfAbsent(row.variantId, () => TextEditingController(text: '${row.suggestedQty}'));

  int _quantity(ReorderSuggestion row) => int.tryParse(_controller(row).text.trim()) ?? 0;

  List<_Group> _groups(List<ReorderSuggestion> rows) {
    final Map<String, _Group> byVendor = <String, _Group>{};
    for (final ReorderSuggestion r in rows) {
      final VendorModel? chosen = _chosenVendor[r.variantId];
      final String id = chosen?.id ?? r.vendorId;
      final String name = chosen?.name ?? r.vendorName;
      byVendor.putIfAbsent(id, () => _Group(id, name)).rows.add(r);
    }
    final List<_Group> groups = byVendor.values.toList()
      ..sort((_Group a, _Group b) {
        if (a.vendorId.isEmpty != b.vendorId.isEmpty) {
          return a.vendorId.isEmpty ? 1 : -1; // the ones without a vendor last
        }
        return a.vendorName.compareTo(b.vendorName);
      });
    return groups;
  }

  Iterable<ReorderSuggestion> _picked(_Group g) => g.rows.where((ReorderSuggestion r) => !_skipped.contains(r.variantId) && _quantity(r) > 0);

  double _value(_Group g) => _picked(g).fold<double>(0, (double s, ReorderSuggestion r) => s + _quantity(r) * r.unitCost);

  Future<void> _chooseVendor(_Group g) async {
    final PartyPick<VendorModel>? picked = await showVendorPicker(context, ref);
    final VendorModel? vendor = picked?.party;
    if (vendor == null || !mounted) {
      return;
    }
    setState(() {
      for (final ReorderSuggestion r in g.rows) {
        _chosenVendor[r.variantId] = vendor;
      }
    });
  }

  Future<void> _create(_Group g) async {
    final List<ReorderSuggestion> rows = _picked(g).toList();
    if (rows.isEmpty || g.vendorId.isEmpty) {
      return;
    }
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final AppLocalizations l10n = context.l10n;
    setState(() => _busy.add(g.vendorId));
    try {
      final PurchaseOrder po = await ref.read(purchaseOrdersServiceProvider).create(
            vendorId: g.vendorId,
            note: l10n.reorderNote,
            lines: <PurchaseOrderLineRequest>[
              for (final ReorderSuggestion r in rows)
                PurchaseOrderLineRequest(productId: r.productId, variantId: r.variantId, quantity: _quantity(r), unitCost: r.unitCost),
            ],
          );
      // What was just ordered counts as on order now, so it leaves the list.
      ref.invalidate(reorderProvider);
      ref.invalidate(purchaseOrdersProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.reorderCreated(po.poNo)),
          action: SnackBarAction(
            label: l10n.reorderOpen,
            onPressed: () => navigator.push<void>(MaterialPageRoute<void>(builder: (BuildContext context) => PurchaseOrderDetailScreen(orderId: po.id))),
          ),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
    } finally {
      if (mounted) {
        setState(() => _busy.remove(g.vendorId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ReorderReport> report = ref.watch(reorderProvider);
    final int days = ref.watch(reorderDaysProvider);
    final int cover = ref.watch(reorderCoverProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.moduleReorder),
        actions: <Widget>[IconButton(tooltip: context.l10n.registerRefresh, icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(reorderProvider))],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(context.l10n.reorderLookBack),
                SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: <ButtonSegment<int>>[for (final int d in const <int>[30, 60, 90]) ButtonSegment<int>(value: d, label: Text(context.l10n.reportDays(d)))],
                  selected: <int>{days},
                  onSelectionChanged: (Set<int> v) => ref.read(reorderDaysProvider.notifier).state = v.first,
                ),
                Text(context.l10n.reorderCover),
                SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: <ButtonSegment<int>>[for (final int d in const <int>[15, 30, 60]) ButtonSegment<int>(value: d, label: Text(context.l10n.reportDays(d)))],
                  selected: <int>{cover},
                  onSelectionChanged: (Set<int> v) => ref.read(reorderCoverProvider.notifier).state = v.first,
                ),
              ],
            ),
          ),
          Expanded(
            child: report.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stack) =>
                  Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(errorMessageOf(error), textAlign: TextAlign.center))),
              data: (ReorderReport data) => data.rows.isEmpty
                  ? Center(child: Text(context.l10n.reorderNone))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      children: <Widget>[for (final _Group g in _groups(data.rows)) _groupCard(context, g)],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupCard(BuildContext context, _Group g) {
    final bool noVendor = g.vendorId.isEmpty;
    final int count = _picked(g).length;
    final bool busy = _busy.contains(g.vendorId);
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(noVendor ? Icons.help_outline : Icons.local_shipping_outlined, color: noVendor ? AppColors.amber : AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(noVendor ? context.l10n.reorderNoVendor : g.vendorName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                if (!noVendor) Text(context.l10n.reorderGroupTotal(count, formatMoney(_value(g))), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            if (noVendor) Padding(padding: const EdgeInsets.only(top: 4), child: Text(context.l10n.reorderNoVendorHint, style: Theme.of(context).textTheme.bodySmall)),
            const Divider(height: 20),
            for (final ReorderSuggestion r in g.rows) _row(context, r),
            const SizedBox(height: 8),
            if (noVendor)
              FilledButton.tonalIcon(onPressed: () => _chooseVendor(g), icon: const Icon(Icons.local_shipping_outlined), label: Text(context.l10n.reorderChooseVendor))
            else
              FilledButton.icon(
                onPressed: busy || count == 0 ? null : () => _create(g),
                icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.assignment_add),
                label: Text(context.l10n.reorderCreate),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, ReorderSuggestion r) {
    final String reason;
    final Color color;
    switch (r.reason) {
      case ReorderReason.out:
        reason = context.l10n.reorderReasonOut;
        color = AppColors.danger;
      case ReorderReason.low:
        reason = context.l10n.reorderReasonLow;
        color = AppColors.amber;
      case ReorderReason.runningOut:
        reason = context.l10n.reorderReasonRunning;
        color = AppColors.sky;
    }
    final TextEditingController qty = _controller(r);
    final bool skipped = _skipped.contains(r.variantId);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Checkbox(
            value: !skipped,
            onChanged: (bool? on) => setState(() {
              if (on ?? false) {
                _skipped.remove(r.variantId);
              } else {
                _skipped.add(r.variantId);
              }
            }),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(child: Text('${r.productName} · ${r.variantLabel}', style: const TextStyle(fontWeight: FontWeight.w600))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
                      child: Text(reason, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                Text(context.l10n.reorderLine(r.onHand, r.onOrder), style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                Text(
                  r.sold == 0 ? context.l10n.reorderNoSales : (r.daysLeft == null ? context.l10n.reorderSpeed(formatRate(r.perDay), '-') : context.l10n.reorderSpeed(formatRate(r.perDay), r.daysLeft!.round().toString())),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 84,
            child: TextField(
              controller: qty,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              onChanged: (String _) => setState(() {}),
              decoration: InputDecoration(labelText: context.l10n.poQuantity, border: const OutlineInputBorder(), isDense: true),
            ),
          ),
        ],
      ),
    );
  }

  /// A rate without a useless ".0".
  static String formatRate(double v) {
    final String fixed = v.toStringAsFixed(1);
    return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
  }
}
