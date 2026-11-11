import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/utils/formatters.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
import 'package:mq_sports_erp/providers/stock_providers.dart';

/// A product variant chosen in the picker.
class VariantPick {
  const VariantPick(this.product, this.variant);

  final ProductModel product;
  final VariantModel variant;
}

/// Searchable list of every active variant of every active product. Picking
/// a row closes the sheet. Returns null if dismissed. With [forSale] each row
/// shows the selling price instead of the cost.
Future<VariantPick?> showVariantPicker(
  BuildContext context,
  WidgetRef ref, {
  bool forSale = false,
}) {
  final List<ProductModel> products =
      (ref.read(productsProvider).valueOrNull ?? <ProductModel>[])
          .where((ProductModel p) => p.isActive)
          .toList();
  final Map<String, int> stock = ref.read(stockOnHandProvider);
  return showModalBottomSheet<VariantPick>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext sheetContext) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (BuildContext context, ScrollController controller) {
          return _VariantPickerBody(
            products: products,
            stock: stock,
            forSale: forSale,
            controller: controller,
            onClose: () => Navigator.of(sheetContext).pop(),
            onPicked: (VariantPick pick) =>
                Navigator.of(sheetContext).pop(pick),
          );
        },
      );
    },
  );
}

class _VariantPickerBody extends StatefulWidget {
  const _VariantPickerBody({
    required this.products,
    required this.stock,
    required this.forSale,
    required this.controller,
    required this.onClose,
    required this.onPicked,
  });

  final List<ProductModel> products;
  final Map<String, int> stock;
  final bool forSale;
  final ScrollController controller;
  final VoidCallback onClose;
  final ValueChanged<VariantPick> onPicked;

  @override
  State<_VariantPickerBody> createState() => _VariantPickerBodyState();
}

class _VariantPickerBodyState extends State<_VariantPickerBody> {
  String _query = '';

  List<VariantPick> _matches() {
    final String q = _query.trim().toLowerCase();
    final List<VariantPick> result = <VariantPick>[];
    for (final ProductModel product in widget.products) {
      for (final VariantModel variant in product.variants) {
        if (!variant.isActive) {
          continue;
        }
        final String haystack = <String>[
          product.name,
          product.brand,
          variant.label,
          variant.sku,
          variant.barcode,
          ...variant.attributes.values,
        ].join(' ').toLowerCase();
        if (q.isEmpty || haystack.contains(q)) {
          result.add(VariantPick(product, variant));
        }
      }
    }
    result.sort((VariantPick a, VariantPick b) {
      final int byProduct =
          a.product.name.toLowerCase().compareTo(b.product.name.toLowerCase());
      return byProduct != 0
          ? byProduct
          : a.variant.label.toLowerCase().compareTo(b.variant.label.toLowerCase());
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final List<VariantPick> matches = _matches();
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text('Select item',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search product, SKU, barcode…',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (String value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          child: matches.isEmpty
              ? const Center(child: Text('No matching items.'))
              : ListView.separated(
                  controller: widget.controller,
                  itemCount: matches.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final VariantPick pick = matches[index];
                    final int onHand = widget.stock[pick.variant.id] ?? 0;
                    return ListTile(
                      title: Text('${pick.product.name} · ${pick.variant.label}'),
                      subtitle: Text(
                        widget.forSale
                            ? 'SKU ${pick.variant.sku} · Price ${formatAmount(pick.variant.salePrice)}'
                            : 'SKU ${pick.variant.sku} · Cost ${formatAmount(pick.variant.costPrice)}',
                      ),
                      trailing: Text('Stock $onHand'),
                      onTap: () => widget.onPicked(pick),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
