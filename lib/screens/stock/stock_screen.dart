import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/utils/formatters.dart';
import 'package:mq_sports_erp/core/utils/stock_alerts.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
import 'package:mq_sports_erp/providers/stock_audit_providers.dart';
import 'package:mq_sports_erp/providers/stock_providers.dart';
import 'package:mq_sports_erp/screens/stock/stock_audit_screen.dart';

class _StockRow {
  const _StockRow(this.product, this.variant, this.onHand);

  final ProductModel product;
  final VariantModel variant;
  final int onHand;

  /// At or below its alert level (only active products and variants alert).
  bool get isLow =>
      product.isActive &&
      variant.isActive &&
      isLowStock(onHand, variant.alertThreshold);
}

enum _StockFilter { all, inStock, outOfStock, lowStock }

/// Stock on hand of every variant, counted from the stock ledger. Variants at
/// or below their alert level are highlighted and have their own filter.
class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key, this.showLowStockOnly = false});

  /// Opens with the low-stock filter selected (used by the dashboard).
  final bool showLowStockOnly;

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  String _query = '';
  late _StockFilter _filter =
      widget.showLowStockOnly ? _StockFilter.lowStock : _StockFilter.all;

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> products =
        ref.watch(productsProvider).valueOrNull ?? <ProductModel>[];
    final Map<String, int> stock = ref.watch(stockOnHandProvider);
    final ThemeData theme = Theme.of(context);
    final String q = _query.trim().toLowerCase();

    final bool canAudit = ref.watch(canAuditStockProvider);
    final List<_StockRow> allRows = <_StockRow>[
      for (final ProductModel product in products)
        for (final VariantModel variant in product.variants)
          _StockRow(product, variant, stock[variant.id] ?? 0),
    ];
    final int lowCount = allRows.where((_StockRow r) => r.isLow).length;
    final List<_StockRow> rows = allRows.where((_StockRow row) {
      switch (_filter) {
        case _StockFilter.lowStock:
          if (!row.isLow) {
            return false;
          }
        case _StockFilter.inStock:
          if (row.onHand <= 0) {
            return false;
          }
        case _StockFilter.outOfStock:
          if (row.onHand > 0) {
            return false;
          }
        case _StockFilter.all:
          break;
      }
      if (q.isEmpty) {
        return true;
      }
      return <String>[
        row.product.name,
        row.product.brand,
        row.variant.label,
        row.variant.sku,
        row.variant.barcode,
      ].join(' ').toLowerCase().contains(q);
    }).toList()
      ..sort((_StockRow a, _StockRow b) =>
          a.product.name.toLowerCase().compareTo(b.product.name.toLowerCase()));

    final int totalUnits =
        rows.fold<int>(0, (int s, _StockRow r) => s + (r.onHand > 0 ? r.onHand : 0));
    final int negativeCount = rows.where((_StockRow r) => r.onHand < 0).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock'),
        actions: <Widget>[
          if (canAudit)
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const StockAuditScreen(),
                ),
              ),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Audit'),
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search product, SKU, barcode…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (String value) => setState(() => _query = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: <Widget>[
                for (final MapEntry<_StockFilter, String> option
                    in <MapEntry<_StockFilter, String>>[
                  const MapEntry<_StockFilter, String>(_StockFilter.all, 'All'),
                  const MapEntry<_StockFilter, String>(_StockFilter.inStock, 'In stock'),
                  const MapEntry<_StockFilter, String>(
                      _StockFilter.outOfStock, 'Out of stock'),
                  MapEntry<_StockFilter, String>(
                      _StockFilter.lowStock, 'Low stock ($lowCount)'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(option.value),
                      selected: _filter == option.key,
                      onSelected: (bool _) => setState(() => _filter = option.key),
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
                '${rows.length} item(s) · $totalUnits unit(s) in stock',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          if (negativeCount > 0)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.warning_amber_rounded,
                      color: theme.colorScheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$negativeCount item(s) have negative stock. More was sold '
                      'than was in stock, for example on two devices before they '
                      'synced. Check the stock ledger and add a correction.',
                      style: TextStyle(color: theme.colorScheme.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: rows.isEmpty
                ? const Center(child: Text('No items to show.'))
                : ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final _StockRow row = rows[index];
                      return ListTile(
                        title: Text('${row.product.name} · ${row.variant.label}'),
                        tileColor: row.isLow
                            ? Colors.orange.withValues(alpha: 0.12)
                            : null,
                        subtitle: Text(
                          'SKU ${row.variant.sku} · Cost ${formatAmount(row.variant.costPrice)}'
                          '${row.variant.alertThreshold > 0 ? ' · Alert at ${row.variant.alertThreshold}' : ''}',
                        ),
                        leading: row.onHand < 0
                            ? Icon(Icons.warning_amber_rounded,
                                color: theme.colorScheme.error)
                            : (row.isLow
                                ? Icon(Icons.notification_important_outlined,
                                    color: Colors.orange.shade800)
                                : null),
                        trailing: Text(
                          '${row.onHand}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: row.onHand <= 0
                                ? theme.colorScheme.error
                                : (row.isLow ? Colors.orange.shade800 : null),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
