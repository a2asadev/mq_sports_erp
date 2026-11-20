import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/stock_audit_model.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';
import 'package:a2_stocks/providers/stock_audit_providers.dart';
import 'package:a2_stocks/providers/stock_providers.dart';

class _AuditLine {
  const _AuditLine(this.product, this.variant, this.onHand);

  final ProductModel product;
  final VariantModel variant;
  final int onHand;
}

/// Manual stock count. The user types what was physically counted next to the
/// system quantity; applying posts one adjustment per difference.
class StockAuditScreen extends ConsumerStatefulWidget {
  const StockAuditScreen({super.key});

  @override
  ConsumerState<StockAuditScreen> createState() => _StockAuditScreenState();
}

class _StockAuditScreenState extends ConsumerState<StockAuditScreen> {
  final TextEditingController _noteController = TextEditingController();

  /// Counted quantity per variant id. A variant that is not in the map was
  /// not counted and is left alone.
  final Map<String, int> _counted = <String, int>{};
  String _query = '';
  bool _onlyCounted = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _setCount(String variantId, int? value) {
    setState(() {
      if (value == null) {
        _counted.remove(variantId);
      } else {
        _counted[variantId] = value;
      }
    });
  }

  Future<bool> _confirmDialog(List<_AuditLine> lines) async {
    final List<_AuditLine> changed = lines
        .where((_AuditLine l) =>
            _counted.containsKey(l.variant.id) &&
            _counted[l.variant.id] != l.onHand)
        .toList();
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.stockAuditApplyStockCount),
          content: SizedBox(
            width: 420,
            child: changed.isEmpty
                ? Text(
                    context.l10n.stockAuditEveryCountedQuantityMatches)
                : ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Text(context.l10n.stockAuditItemSWillBe(changed.length)),
                      const SizedBox(height: 8),
                      for (final _AuditLine l in changed)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '${l.product.name} · ${l.variant.label}: '
                            '${l.onHand} → ${_counted[l.variant.id]} '
                            '(${_signed((_counted[l.variant.id] ?? 0) - l.onHand)})',
                          ),
                        ),
                    ],
                  ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.posPaymentBack),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.l10n.posApply),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  Future<void> _apply(List<_AuditLine> lines) async {
    if (!await _confirmDialog(lines) || !mounted) {
      return;
    }
    setState(() => _isSubmitting = true);
    final bool saved = await ref.read(stockAuditsProvider.notifier).confirmAudit(
          counts: <CountedVariant>[
            for (final MapEntry<String, int> e in _counted.entries)
              CountedVariant(variantId: e.key, countedQuantity: e.value),
          ],
          note: _noteController.text.trim(),
          auditDate: DateTime.now(),
        );
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.stockAuditStockCountApplied)),
      );
      Navigator.of(context).pop();
    }
  }

  static String _signed(int value) => value > 0 ? '+$value' : '$value';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool canAudit = ref.watch(canAuditStockProvider);
    final List<ProductModel> products =
        ref.watch(productsProvider).valueOrNull ?? <ProductModel>[];
    final Map<String, int> stock = ref.watch(stockOnHandProvider);

    ref.listen<AsyncValue<List<StockAuditModel>>>(stockAuditsProvider,
        (AsyncValue<List<StockAuditModel>>? previous,
            AsyncValue<List<StockAuditModel>> next) {
      final Object? error = next.error;
      if (error != null && !identical(error, previous?.error)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
      }
    });

    if (!canAudit) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.stockAuditStockAudit)),
        body: Center(
          child: Text(context.l10n.stockAuditOnlyAdminsAndManagers),
        ),
      );
    }

    final String q = _query.trim().toLowerCase();
    final List<_AuditLine> all = <_AuditLine>[
      for (final ProductModel product in products)
        for (final VariantModel variant in product.variants)
          _AuditLine(product, variant, stock[variant.id] ?? 0),
    ]..sort((_AuditLine a, _AuditLine b) {
        final int byProduct =
            a.product.name.toLowerCase().compareTo(b.product.name.toLowerCase());
        return byProduct != 0
            ? byProduct
            : a.variant.label.toLowerCase().compareTo(b.variant.label.toLowerCase());
      });
    final List<_AuditLine> visible = all.where((_AuditLine l) {
      if (_onlyCounted && !_counted.containsKey(l.variant.id)) {
        return false;
      }
      return q.isEmpty ||
          <String>[
            l.product.name,
            l.product.brand,
            l.variant.label,
            l.variant.sku,
            l.variant.barcode,
          ].join(' ').toLowerCase().contains(q);
    }).toList();

    final int differences = all
        .where((_AuditLine l) =>
            _counted.containsKey(l.variant.id) &&
            _counted[l.variant.id] != l.onHand)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.stockAuditStockAudit),
        actions: <Widget>[
          IconButton(
            tooltip: context.l10n.stockAuditAuditHistory,
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const StockAuditHistoryScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: context.l10n.stockAuditSearchProductSkuBarcode,
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
                FilterChip(
                  label: Text(context.l10n.stockAuditCountedOnly(_counted.length)),
                  selected: _onlyCounted,
                  onSelected: (bool v) => setState(() => _onlyCounted = v),
                ),
                const Spacer(),
                if (_counted.isNotEmpty)
                  TextButton(
                    onPressed:
                        _isSubmitting ? null : () => setState(_counted.clear),
                    child: Text(context.l10n.stockAuditClearCounts),
                  ),
              ],
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? Center(child: Text(context.l10n.stockAuditNoItemsToShow))
                : ListView.separated(
                    itemCount: visible.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final _AuditLine line = visible[index];
                      return _AuditRow(
                        key: ValueKey<String>(line.variant.id),
                        product: line.product,
                        variant: line.variant,
                        onHand: line.onHand,
                        counted: _counted[line.variant.id],
                        enabled: !_isSubmitting,
                        onChanged: (int? value) =>
                            _setCount(line.variant.id, value),
                      );
                    },
                  ),
          ),
          Material(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextField(
                      controller: _noteController,
                      enabled: !_isSubmitting,
                      decoration: InputDecoration(
                        labelText: context.l10n.stockAuditReasonNoteOptional,
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            context.l10n.stockAuditCountedDifferenceS(_counted.length, differences),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: (_isSubmitting || _counted.isEmpty)
                              ? null
                              : () => _apply(all),
                          icon: _isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.fact_check_outlined),
                          label: Text(context.l10n.stockAuditApplyCount),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.stockAuditEachDifferenceBecomesA,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One variant: system quantity, a counted field with -/+ steppers and the
/// difference. The field keeps its own text; the screen keeps the number.
class _AuditRow extends StatefulWidget {
  const _AuditRow({
    super.key,
    required this.product,
    required this.variant,
    required this.onHand,
    required this.counted,
    required this.enabled,
    required this.onChanged,
  });

  final ProductModel product;
  final VariantModel variant;
  final int onHand;
  final int? counted;
  final bool enabled;
  final ValueChanged<int?> onChanged;

  @override
  State<_AuditRow> createState() => _AuditRowState();
}

class _AuditRowState extends State<_AuditRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.counted?.toString() ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _step(int delta) {
    final int base = int.tryParse(_controller.text.trim()) ?? widget.onHand;
    final int next = base + delta < 0 ? 0 : base + delta;
    _controller.text = '$next';
    widget.onChanged(next);
  }

  void _typed(String text) {
    final int? parsed = int.tryParse(text.trim());
    widget.onChanged(parsed != null && parsed >= 0 ? parsed : null);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int? counted = widget.counted;
    final int? variance = counted == null ? null : counted - widget.onHand;
    final Color? varianceColor = variance == null || variance == 0
        ? null
        : (variance > 0 ? Colors.green.shade700 : theme.colorScheme.error);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${widget.product.name} · ${widget.variant.label}',
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  widget.variant.isActive
                      ? context.l10n.stockAuditSystemLine(widget.variant.sku, widget.onHand)
                      : context.l10n.stockAuditSystemLineInactive(widget.variant.sku, widget.onHand),
                  style: theme.textTheme.bodySmall,
                ),
                if (variance != null && variance != 0)
                  Text(
                    context.l10n.stockAuditDifference(variance > 0 ? '+$variance' : '$variance'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: varianceColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.stockAuditOneLess,
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: widget.enabled ? () => _step(-1) : null,
          ),
          SizedBox(
            width: 72,
            child: TextField(
              controller: _controller,
              enabled: widget.enabled,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '${widget.onHand}',
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: _typed,
            ),
          ),
          IconButton(
            tooltip: context.l10n.stockAuditOneMore,
            icon: const Icon(Icons.add_circle_outline),
            onPressed: widget.enabled ? () => _step(1) : null,
          ),
        ],
      ),
    );
  }
}

/// Past audits, newest first. Tapping one shows what was counted.
class StockAuditHistoryScreen extends ConsumerWidget {
  const StockAuditHistoryScreen({super.key});

  void _showDetails(BuildContext context, StockAuditModel audit) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(audit.auditNo),
          content: SizedBox(
            width: 460,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Text(<String>[
                  formatDate(audit.auditDate),
                  if (audit.countedByName.isNotEmpty) context.l10n.stockAuditBy(audit.countedByName),
                ].join(' · ')),
                if (audit.note.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(audit.note),
                ],
                const Divider(height: 24),
                for (final StockAuditItem item in audit.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      context.l10n.stockAuditItemLine(item.productName, item.variantLabel, item.sku, item.systemQuantity, item.countedQuantity,
                          '${item.variance > 0 ? '+' : ''}${item.variance}'),
                    ),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.starterPackClose),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<StockAuditModel> audits =
        (ref.watch(stockAuditsProvider).valueOrNull ?? <StockAuditModel>[]).toList()
          ..sort((StockAuditModel a, StockAuditModel b) =>
              b.auditDate.compareTo(a.auditDate));
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.stockAuditAuditHistory)),
      body: audits.isEmpty
          ? Center(child: Text(context.l10n.stockAuditNoStockAuditsYet))
          : ListView.separated(
              itemCount: audits.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                final StockAuditModel audit = audits[index];
                final int net = audit.totalVariance;
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.fact_check_outlined)),
                  title: Text(audit.auditNo),
                  subtitle: Text(<String>[
                    formatDate(audit.auditDate),
                    if (audit.countedByName.isNotEmpty) audit.countedByName,
                    context.l10n.purchasesItemS(audit.items.length),
                  ].join(' · ')),
                  trailing: Text(
                    net > 0 ? '+$net' : '$net',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onTap: () => _showDetails(context, audit),
                );
              },
            ),
    );
  }
}
