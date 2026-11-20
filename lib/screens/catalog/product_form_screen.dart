import 'package:flutter/material.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/widgets/photo_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/utils/category_tree.dart';
import 'package:a2_stocks/core/utils/price_warnings.dart';
import 'package:a2_stocks/models/category_model.dart';
import 'package:a2_stocks/models/product_image.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';
import 'package:a2_stocks/screens/catalog/variant_dialog.dart';

/// Add, edit or (for staff) view a product with its variants.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final ProductModel? product;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _descriptionController;
  late String? _categoryId;
  late bool _isActive;
  late List<VariantModel> _variants;
  bool _isSubmitting = false;
  bool _showVariantError = false;
  List<ProductImage> _images = const <ProductImage>[];

  @override
  void initState() {
    super.initState();
    final ProductModel? existing = widget.product;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _brandController = TextEditingController(text: existing?.brand ?? '');
    _descriptionController =
        TextEditingController(text: existing?.description ?? '');
    final String? categoryId = existing?.categoryId;
    _categoryId = (categoryId == null || categoryId.isEmpty) ? null : categoryId;
    _isActive = existing?.isActive ?? true;
    _variants = <VariantModel>[...?existing?.variants];
    _images = existing?.images ?? const <ProductImage>[];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _editVariant({VariantModel? variant, int? index}) async {
    final bool readOnly = !ref.read(canManageCatalogProvider);
    final Set<String> otherSkus = <String>{
      for (int i = 0; i < _variants.length; i++)
        if (i != index) _variants[i].sku.trim().toLowerCase(),
    };
    final VariantModel? result = await showVariantDialog(
      context,
      variant: variant,
      readOnly: readOnly,
      productName: _nameController.text,
      otherSkus: otherSkus,
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() {
      _showVariantError = false;
      if (index == null) {
        _variants = <VariantModel>[..._variants, result];
      } else {
        _variants = <VariantModel>[
          for (int i = 0; i < _variants.length; i++)
            i == index ? result : _variants[i],
        ];
      }
    });
  }

  Future<void> _submit() async {
    final FormState? form = _formKey.currentState;
    final bool formValid = form != null && form.validate();
    final bool hasVariants = _variants.isNotEmpty;
    setState(() => _showVariantError = !hasVariants);
    final String? categoryId = _categoryId;
    if (!formValid || !hasVariants || categoryId == null) {
      return;
    }
    setState(() => _isSubmitting = true);
    final ProductsNotifier notifier = ref.read(productsProvider.notifier);
    final ProductModel? existing = widget.product;
    final bool succeeded = existing == null
        ? await notifier.createProduct(
            name: _nameController.text,
            categoryId: categoryId,
            brand: _brandController.text,
            description: _descriptionController.text,
            isActive: _isActive,
            variants: _variants,
          )
        : await notifier.updateProduct(existing.copyWith(
            name: _nameController.text,
            categoryId: categoryId,
            brand: _brandController.text,
            description: _descriptionController.text,
            isActive: _isActive,
            variants: _variants,
            images: _images,
          ));
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    if (succeeded) {
      Navigator.of(context).pop();
    }
  }

  Widget _variantCard(int index, bool locked) {
    final VariantModel variant = _variants[index];
    final List<String> warnings = priceWarnings(
      isWholesale: variant.isWholesale,
      costPrice: variant.costPrice,
      wholesalePrice: variant.wholesalePrice,
      salePrice: variant.salePrice,
    );
    final String cost = variant.costPrice.toStringAsFixed(2);
    final String sale = variant.salePrice.toStringAsFixed(2);
    final String prices = variant.isWholesale
        ? context.l10n.productFormCostWholesaleRetail(cost, variant.wholesalePrice.toStringAsFixed(2), sale)
        : context.l10n.productFormCostSale(cost, sale);
    return Card(
      child: ListTile(
        isThreeLine: true,
        title: Text(variant.label),
        subtitle: Text(
          '${variant.isActive ? context.l10n.productFormSku(variant.sku) : context.l10n.productFormSkuInactive(variant.sku)}\n$prices',
        ),
        onTap: _isSubmitting
            ? null
            : () => _editVariant(variant: variant, index: index),
        trailing: (warnings.isEmpty && locked)
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (warnings.isNotEmpty)
                    Tooltip(
                      message: warnings.join('\n'),
                      child: Icon(Icons.warning_amber_rounded,
                          color: Colors.orange.shade700),
                    ),
                  if (!locked)
                    IconButton(
                      tooltip: context.l10n.productFormRemoveVariant,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setState(() {
                        _variants = <VariantModel>[
                          for (int j = 0; j < _variants.length; j++)
                            if (j != index) _variants[j],
                        ];
                      }),
                    ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canManage = ref.watch(canManageCatalogProvider);
    final bool readOnly = !canManage;
    final bool isEdit = widget.product != null;
    final bool locked = readOnly || _isSubmitting;
    final List<CategoryModel> categories =
        ref.watch(categoriesProvider).valueOrNull ?? <CategoryModel>[];
    final List<MapEntry<String, String>> options =
        CategoryTree.options(categories);
    final String? categoryValue = options
            .any((MapEntry<String, String> o) => o.key == _categoryId)
        ? _categoryId
        : null;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(readOnly
            ? context.l10n.productFormProduct
            : isEdit
                ? context.l10n.productFormEditProduct
                : context.l10n.productsAddProduct),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (widget.product != null)
                      ProductPhotosEditor(
                        productId: widget.product!.id,
                        images: _images,
                        enabled: !locked,
                        onChanged: (List<ProductImage> images) => _images = images,
                      )
                    else
                      PhotoAfterSaveHint(what: context.l10n.photoWidgetsPhotos),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      enabled: !locked,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: context.l10n.productFormProductName,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (String? value) =>
                          (value == null || value.trim().isEmpty)
                              ? context.l10n.categoryFormNameIsRequired
                              : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: categoryValue,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.categoriesCategory,
                        helperText: options.isEmpty
                            ? context.l10n.productFormCreateACategoryFirst
                            : null,
                        border: const OutlineInputBorder(),
                      ),
                      items: options
                          .map((MapEntry<String, String> option) =>
                              DropdownMenuItem<String>(
                                value: option.key,
                                child: Text(option.value,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: locked
                          ? null
                          : (String? value) =>
                              setState(() => _categoryId = value),
                      validator: (String? value) =>
                          value == null ? context.l10n.productFormChooseACategory : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _brandController,
                      enabled: !locked,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: context.l10n.productFormBrandOptional,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      enabled: !locked,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: context.l10n.categoryFormDescriptionOptional,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.categoryFormActive),
                      value: _isActive,
                      onChanged: locked
                          ? null
                          : (bool value) => setState(() => _isActive = value),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(context.l10n.productFormVariants(_variants.length),
                              style: theme.textTheme.titleMedium),
                        ),
                        if (!locked)
                          TextButton.icon(
                            onPressed: () => _editVariant(),
                            icon: const Icon(Icons.add),
                            label: Text(context.l10n.productFormAddVariant),
                          ),
                      ],
                    ),
                    if (_showVariantError)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          context.l10n.productFormAddAtLeastOne,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    for (int i = 0; i < _variants.length; i++)
                      _variantCard(i, locked),
                    if (canManage) ...<Widget>[
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(isEdit ? context.l10n.categoryFormSaveChanges : context.l10n.productFormCreateProduct),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
