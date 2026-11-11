import 'package:flutter/material.dart';
import 'package:mq_sports_erp/core/utils/price_warnings.dart';
import 'package:mq_sports_erp/core/utils/sku_generator.dart';
import 'package:mq_sports_erp/models/variant_model.dart';

/// Opens the variant editor. Returns the saved variant, or null when the
/// dialog was cancelled or opened read-only.
///
/// [productName] and [otherSkus] (the SKUs of the product's other variants)
/// are used by the SKU auto-create button.
Future<VariantModel?> showVariantDialog(
  BuildContext context, {
  VariantModel? variant,
  required bool readOnly,
  required String productName,
  required Set<String> otherSkus,
}) {
  return showDialog<VariantModel>(
    context: context,
    builder: (BuildContext dialogContext) => _VariantDialog(
      variant: variant,
      readOnly: readOnly,
      productName: productName,
      otherSkus: otherSkus,
    ),
  );
}

class _AttributeRow {
  _AttributeRow(String key, String value)
      : keyController = TextEditingController(text: key),
        valueController = TextEditingController(text: value);

  final TextEditingController keyController;
  final TextEditingController valueController;

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}

class _VariantDialog extends StatefulWidget {
  const _VariantDialog({
    required this.variant,
    required this.readOnly,
    required this.productName,
    required this.otherSkus,
  });

  final VariantModel? variant;
  final bool readOnly;
  final String productName;
  final Set<String> otherSkus;

  @override
  State<_VariantDialog> createState() => _VariantDialogState();
}

class _VariantDialogState extends State<_VariantDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _costController;
  late final TextEditingController _wholesaleController;
  late final TextEditingController _saleController;
  late final TextEditingController _alertController;
  late final List<_AttributeRow> _attributes;
  late bool _isActive;
  late bool _isWholesale;
  String? _skuHelper;

  @override
  void initState() {
    super.initState();
    final VariantModel? existing = widget.variant;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _skuController = TextEditingController(text: existing?.sku ?? '');
    _barcodeController = TextEditingController(text: existing?.barcode ?? '');
    _costController = TextEditingController(
        text: (existing?.costPrice ?? 0).toStringAsFixed(2));
    _wholesaleController = TextEditingController(
        text: (existing?.wholesalePrice ?? 0).toStringAsFixed(2));
    _saleController = TextEditingController(
        text: (existing?.salePrice ?? 0).toStringAsFixed(2));
    _alertController =
        TextEditingController(text: '${existing?.alertThreshold ?? 0}');
    _attributes = <_AttributeRow>[
      for (final MapEntry<String, String> entry
          in (existing?.attributes ?? const <String, String>{}).entries)
        _AttributeRow(entry.key, entry.value),
    ];
    _isActive = existing?.isActive ?? true;
    _isWholesale = existing?.isWholesale ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _costController.dispose();
    _wholesaleController.dispose();
    _saleController.dispose();
    _alertController.dispose();
    for (final _AttributeRow row in _attributes) {
      row.dispose();
    }
    super.dispose();
  }

  double _parse(TextEditingController controller) =>
      double.tryParse(controller.text.trim()) ?? 0;

  String? _validatePrice(String? value) {
    final double? parsed = double.tryParse((value ?? '').trim());
    if (parsed == null || parsed < 0) {
      return 'Enter a valid price.';
    }
    return null;
  }

  void _autoCreateSku() {
    final List<String> values = _attributes
        .map((_AttributeRow row) => row.valueController.text.trim())
        .where((String value) => value.isNotEmpty)
        .toList();
    final String sku = SkuGenerator.generate(
      productName: widget.productName,
      variantName: _nameController.text,
      attributeValues: values,
      existingSkus: widget.otherSkus,
    );
    setState(() {
      if (sku.isEmpty) {
        _skuHelper = 'Enter the product name or an attribute value first.';
      } else {
        _skuController.text = sku;
        _skuHelper = null;
      }
    });
  }

  void _save() {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    final Map<String, String> attributes = <String, String>{};
    for (final _AttributeRow row in _attributes) {
      final String key = row.keyController.text.trim();
      final String value = row.valueController.text.trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        attributes[key] = value;
      }
    }
    final VariantModel result = VariantModel(
      id: widget.variant?.id,
      sku: _skuController.text.trim(),
      name: _nameController.text.trim(),
      barcode: _barcodeController.text.trim(),
      attributes: attributes,
      costPrice: double.parse(_costController.text.trim()),
      salePrice: double.parse(_saleController.text.trim()),
      isWholesale: _isWholesale,
      wholesalePrice:
          _isWholesale ? double.parse(_wholesaleController.text.trim()) : 0,
      alertThreshold: int.parse(_alertController.text.trim()),
      isActive: _isActive,
    );
    Navigator.of(context).pop(result);
  }

  Widget _priceField({
    required TextEditingController controller,
    required String label,
    required bool readOnly,
    String? Function(String?)? validator,
  }) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        enabled: !readOnly,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
        validator: validator,
        onChanged: (String _) => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool readOnly = widget.readOnly;
    final ThemeData theme = Theme.of(context);
    final List<String> warnings = priceWarnings(
      isWholesale: _isWholesale,
      costPrice: _parse(_costController),
      wholesalePrice: _parse(_wholesaleController),
      salePrice: _parse(_saleController),
    );

    return AlertDialog(
      title: Text(widget.variant == null ? 'Add variant' : 'Variant'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _skuController,
                  enabled: !readOnly,
                  decoration: InputDecoration(
                    labelText: 'SKU',
                    helperText: _skuHelper,
                    suffixIcon: readOnly
                        ? null
                        : IconButton(
                            tooltip: 'Auto-create SKU',
                            icon: const Icon(Icons.auto_fix_high),
                            onPressed: _autoCreateSku,
                          ),
                  ),
                  validator: (String? value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'SKU is required.'
                          : null,
                ),
                TextFormField(
                  controller: _nameController,
                  enabled: !readOnly,
                  decoration: const InputDecoration(
                      labelText: 'Variant name (optional)'),
                ),
                TextFormField(
                  controller: _barcodeController,
                  enabled: !readOnly,
                  decoration:
                      const InputDecoration(labelText: 'Barcode (optional)'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Wholesale variant'),
                  subtitle: const Text('Adds a separate wholesale price'),
                  value: _isWholesale,
                  onChanged: readOnly
                      ? null
                      : (bool value) => setState(() => _isWholesale = value),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _priceField(
                      controller: _costController,
                      label: 'Cost price',
                      readOnly: readOnly,
                      validator: _validatePrice,
                    ),
                    if (_isWholesale) ...<Widget>[
                      const SizedBox(width: 12),
                      _priceField(
                        controller: _wholesaleController,
                        label: 'Wholesale price',
                        readOnly: readOnly,
                        validator: _validatePrice,
                      ),
                    ],
                    const SizedBox(width: 12),
                    _priceField(
                      controller: _saleController,
                      label: _isWholesale ? 'Retail price' : 'Sale price',
                      readOnly: readOnly,
                      validator: _validatePrice,
                    ),
                  ],
                ),
                for (final String warning in warnings)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.warning_amber_rounded,
                            size: 18, color: Colors.orange.shade700),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            warning,
                            style: TextStyle(color: Colors.orange.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _alertController,
                  enabled: !readOnly,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Low-stock alert level',
                    helperText: 'Flag this variant when stock is at or below '
                        'this number. 0 = no alert.',
                  ),
                  validator: (String? value) {
                    final int? parsed = int.tryParse((value ?? '').trim());
                    return (parsed == null || parsed < 0)
                        ? 'Enter 0 or a whole number.'
                        : null;
                  },
                ),
                const SizedBox(height: 16),
                Text('Attributes', style: theme.textTheme.titleSmall),
                for (int i = 0; i < _attributes.length; i++)
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _attributes[i].keyController,
                          enabled: !readOnly,
                          decoration: const InputDecoration(
                              labelText: 'Name', hintText: 'Size'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _attributes[i].valueController,
                          enabled: !readOnly,
                          decoration: const InputDecoration(
                              labelText: 'Value', hintText: 'Small'),
                        ),
                      ),
                      if (!readOnly)
                        IconButton(
                          tooltip: 'Remove attribute',
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() {
                            _attributes.removeAt(i).dispose();
                          }),
                        ),
                    ],
                  ),
                if (!readOnly)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () =>
                          setState(() => _attributes.add(_AttributeRow('', ''))),
                      icon: const Icon(Icons.add),
                      label: const Text('Add attribute'),
                    ),
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged:
                      readOnly ? null : (bool v) => setState(() => _isActive = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(readOnly ? 'Close' : 'Cancel'),
        ),
        if (!readOnly)
          FilledButton(onPressed: _save, child: const Text('Save variant')),
      ],
    );
  }
}
