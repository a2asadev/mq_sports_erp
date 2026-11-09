import 'package:flutter/material.dart';
import 'package:mq_sports_erp/models/variant_model.dart';

/// Opens the variant editor. Returns the saved variant, or null when the
/// dialog was cancelled or opened read-only.
Future<VariantModel?> showVariantDialog(
  BuildContext context, {
  VariantModel? variant,
  required bool readOnly,
}) {
  return showDialog<VariantModel>(
    context: context,
    builder: (BuildContext dialogContext) =>
        _VariantDialog(variant: variant, readOnly: readOnly),
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
  const _VariantDialog({required this.variant, required this.readOnly});

  final VariantModel? variant;
  final bool readOnly;

  @override
  State<_VariantDialog> createState() => _VariantDialogState();
}

class _VariantDialogState extends State<_VariantDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _costController;
  late final TextEditingController _saleController;
  late final List<_AttributeRow> _attributes;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final VariantModel? existing = widget.variant;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _skuController = TextEditingController(text: existing?.sku ?? '');
    _barcodeController = TextEditingController(text: existing?.barcode ?? '');
    _costController = TextEditingController(
        text: (existing?.costPrice ?? 0).toStringAsFixed(2));
    _saleController = TextEditingController(
        text: (existing?.salePrice ?? 0).toStringAsFixed(2));
    _attributes = <_AttributeRow>[
      for (final MapEntry<String, String> entry
          in (existing?.attributes ?? const <String, String>{}).entries)
        _AttributeRow(entry.key, entry.value),
    ];
    _isActive = existing?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _costController.dispose();
    _saleController.dispose();
    for (final _AttributeRow row in _attributes) {
      row.dispose();
    }
    super.dispose();
  }

  String? _validatePrice(String? value) {
    final double? parsed = double.tryParse((value ?? '').trim());
    if (parsed == null || parsed < 0) {
      return 'Enter a valid price.';
    }
    return null;
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
      isActive: _isActive,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final bool readOnly = widget.readOnly;
    return AlertDialog(
      title: Text(widget.variant == null ? 'Add variant' : 'Variant'),
      content: SizedBox(
        width: 420,
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
                  decoration: const InputDecoration(labelText: 'SKU'),
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
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _costController,
                        enabled: !readOnly,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                            const InputDecoration(labelText: 'Cost price'),
                        validator: _validatePrice,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _saleController,
                        enabled: !readOnly,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                            const InputDecoration(labelText: 'Sale price'),
                        validator: _validatePrice,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Attributes', style: Theme.of(context).textTheme.titleSmall),
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
                              labelText: 'Value', hintText: 'M'),
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
