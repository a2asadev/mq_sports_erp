import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/utils/category_tree.dart';
import 'package:mq_sports_erp/core/utils/error_text.dart';
import 'package:mq_sports_erp/models/category_model.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
import 'package:mq_sports_erp/screens/catalog/product_form_screen.dart';

enum _ProductAction { open, delete }

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _query = '';

  void _openForm({ProductModel? product}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ProductFormScreen(product: product),
      ),
    );
  }

  Future<void> _confirmDelete(ProductModel product) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete product'),
          content: Text(
              'Delete "${product.name}" and its ${product.variants.length} variant(s)?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await ref.read(productsProvider.notifier).deleteProduct(product.id);
    }
  }

  bool _matches(ProductModel product, String query) {
    if (query.isEmpty) {
      return true;
    }
    final String q = query.toLowerCase();
    if (product.name.toLowerCase().contains(q) ||
        product.brand.toLowerCase().contains(q)) {
      return true;
    }
    return product.variants.any((VariantModel v) =>
        v.sku.toLowerCase().contains(q) || v.barcode.toLowerCase().contains(q));
  }

  String _priceText(ProductModel product) {
    final String low = product.minSalePrice.toStringAsFixed(2);
    final String high = product.maxSalePrice.toStringAsFixed(2);
    return low == high ? low : '$low - $high';
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ProductModel>> async = ref.watch(productsProvider);
    final List<CategoryModel> categories =
        ref.watch(categoriesProvider).valueOrNull ?? <CategoryModel>[];
    final bool canManage = ref.watch(canManageCatalogProvider);

    ref.listen<AsyncValue<List<ProductModel>>>(productsProvider,
        (AsyncValue<List<ProductModel>>? previous,
            AsyncValue<List<ProductModel>> next) {
      final Object? error = next.error;
      if (error != null && !identical(error, previous?.error)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
      }
    });

    final List<ProductModel>? loaded = async.valueOrNull;
    Widget body;
    if (loaded == null) {
      final Object? error = async.error;
      body = Center(
        child: error != null
            ? Text(errorMessageOf(error))
            : const CircularProgressIndicator(),
      );
    } else {
      final List<ProductModel> products = loaded
          .where((ProductModel p) => _matches(p, _query.trim()))
          .toList()
        ..sort((ProductModel a, ProductModel b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      body = Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search name, brand, SKU or barcode',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (String value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Text(loaded.isEmpty
                        ? 'No products yet.'
                        : 'No products match your search.'),
                  )
                : ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final ProductModel product = products[index];
                      final String path =
                          CategoryTree.pathOf(product.categoryId, categories);
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                          '${path.isEmpty ? 'Uncategorized' : path}'
                          ' · ${product.variants.length} variant(s)'
                          ' · ${_priceText(product)}',
                        ),
                        onTap: () => _openForm(product: product),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (!product.isActive)
                              const Chip(
                                label: Text('Inactive'),
                                visualDensity: VisualDensity.compact,
                              ),
                            if (canManage)
                              PopupMenuButton<_ProductAction>(
                                onSelected: (_ProductAction action) async {
                                  switch (action) {
                                    case _ProductAction.open:
                                      _openForm(product: product);
                                    case _ProductAction.delete:
                                      await _confirmDelete(product);
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    const <PopupMenuEntry<_ProductAction>>[
                                  PopupMenuItem<_ProductAction>(
                                    value: _ProductAction.open,
                                    child: Text('Edit'),
                                  ),
                                  PopupMenuItem<_ProductAction>(
                                    value: _ProductAction.delete,
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: body,
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add product'),
            )
          : null,
    );
  }
}
