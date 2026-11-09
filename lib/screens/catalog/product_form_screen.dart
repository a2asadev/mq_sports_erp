import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/utils/category_tree.dart';
import 'package:mq_sports_erp/models/category_model.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
import 'package:mq_sports_erp/screens/catalog/variant_dialog.dart';

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
    final VariantModel? result = await showVariantDialog(
      context,
      variant: variant,
      readOnly: readOnly,
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
          ));
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    if (succeeded) {
      Navigator.of(context).pop();
    }
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
            ? 'Product'
            : isEdit
                ? 'Edit product'
                : 'Add product'),
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
                    TextFormField(
                      controller: _nameController,
                      enabled: !locked,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Product name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (String? value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Name is required.'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: categoryValue,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        helperText: options.isEmpty
                            ? 'Create a category first.'
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
                          value == null ? 'Choose a category.' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _brandController,
                      enabled: !locked,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Brand (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      enabled: !locked,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active'),
                      value: _isActive,
                      onChanged: locked
                          ? null
                          : (bool value) => setState(() => _isActive = value),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text('Variants (${_variants.length})',
                              style: theme.textTheme.titleMedium),
                        ),
                        if (!locked)
                          TextButton.icon(
                            onPressed: () => _editVariant(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add variant'),
                          ),
                      ],
                    ),
                    if (_showVariantError)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Add at least one variant.',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    for (int i = 0; i < _variants.length; i++)
                      Card(
                        child: ListTile(
                          title: Text(_variants[i].label),
                          subtitle: Text(
                            'SKU ${_variants[i].sku}'
                            ' · Sale ${_variants[i].salePrice.toStringAsFixed(2)}'
                            '${_variants[i].isActive ? '' : ' · Inactive'}',
                          ),
                          onTap: _isSubmitting
                              ? null
                              : () => _editVariant(
                                  variant: _variants[i], index: i),
                          trailing: locked
                              ? null
                              : IconButton(
                                  tooltip: 'Remove variant',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => setState(() {
                                    _variants = <VariantModel>[
                                      for (int j = 0; j < _variants.length; j++)
                                        if (j != i) _variants[j],
                                    ];
                                  }),
                                ),
                        ),
                      ),
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
                            : Text(isEdit ? 'Save changes' : 'Create product'),
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
