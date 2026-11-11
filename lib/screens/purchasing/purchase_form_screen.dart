import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/utils/formatters.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/purchase_model.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/models/vendor_model.dart';
import 'package:mq_sports_erp/providers/purchasing_providers.dart';
import 'package:mq_sports_erp/providers/stock_providers.dart';
import 'package:mq_sports_erp/widgets/party_picker.dart';
import 'package:mq_sports_erp/widgets/purchase_status_chip.dart';
import 'package:mq_sports_erp/widgets/variant_picker.dart';

/// One editable line of the purchase being entered.
class _Line {
  _Line({required this.product, required this.variant})
      : quantityController = TextEditingController(text: '1'),
        costController =
            TextEditingController(text: variant.costPrice.toStringAsFixed(2));

  final ProductModel product;
  final VariantModel variant;
  final TextEditingController quantityController;
  final TextEditingController costController;

  int get quantity => int.tryParse(quantityController.text.trim()) ?? 0;
  double get unitCost => double.tryParse(costController.text.trim()) ?? 0;
  double get total => quantity * unitCost;

  void dispose() {
    quantityController.dispose();
    costController.dispose();
  }
}

/// Purchase entry: 1 Vendor -> 2 Items and quantities -> 3 Buying prices ->
/// 4 Payment -> Confirm.
class PurchaseFormScreen extends ConsumerStatefulWidget {
  const PurchaseFormScreen({super.key});

  @override
  ConsumerState<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends ConsumerState<PurchaseFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _invoiceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _paidController = TextEditingController(text: '0.00');
  final List<_Line> _lines = <_Line>[];
  VendorModel? _vendor;
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;
  bool _showErrors = false;

  @override
  void dispose() {
    _invoiceController.dispose();
    _notesController.dispose();
    _paidController.dispose();
    for (final _Line line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  double get _total {
    final double sum = _lines.fold<double>(0, (double s, _Line l) => s + l.total);
    return (sum * 100).round() / 100;
  }

  double get _paid => double.tryParse(_paidController.text.trim()) ?? 0;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  Future<void> _addItem() async {
    final VariantPick? pick = await showVariantPicker(context, ref);
    if (pick == null || !mounted) {
      return;
    }
    setState(() {
      final _Line? existing = _lines
          .where((_Line l) => l.variant.id == pick.variant.id)
          .firstOrNull;
      if (existing != null) {
        existing.quantityController.text = '${existing.quantity + 1}';
      } else {
        _lines.add(_Line(product: pick.product, variant: pick.variant));
      }
    });
  }

  Future<bool> _confirmDialog(VendorModel vendor) async {
    final double due = (_total - _paid) > 0 ? _total - _paid : 0;
    final int units = _lines.fold<int>(0, (int s, _Line l) => s + l.quantity);
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm purchase'),
          content: Text(
            'Vendor: ${vendor.name}\n'
            '${_lines.length} item(s), $units unit(s) will be added to stock.\n\n'
            'Total: ${formatAmount(_total)}\n'
            'Paid now: ${formatAmount(_paid)}\n'
            'Due: ${formatAmount(due)}',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Back'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  Future<void> _submit() async {
    setState(() => _showErrors = true);
    final FormState? form = _formKey.currentState;
    final VendorModel? vendor = _vendor;
    if (form == null || !form.validate() || vendor == null || _lines.isEmpty) {
      return;
    }
    if (!await _confirmDialog(vendor) || !mounted) {
      return;
    }
    setState(() => _isSubmitting = true);
    final bool saved = await ref.read(purchasesProvider.notifier).confirmPurchase(
          vendor: vendor,
          purchaseDate: _date,
          invoiceNo: _invoiceController.text.trim(),
          notes: _notesController.text.trim(),
          items: <PurchaseItem>[
            for (final _Line line in _lines)
              PurchaseItem(
                productId: line.product.id,
                variantId: line.variant.id,
                productName: line.product.name,
                variantLabel: line.variant.label,
                sku: line.variant.sku,
                quantity: line.quantity,
                unitCost: line.unitCost,
              ),
          ],
          paidNow: _paid,
        );
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    if (saved) {
      Navigator.of(context).pop();
    }
  }

  Widget _stepTitle(BuildContext context, String number, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Row(
        children: <Widget>[
          CircleAvatar(radius: 12, child: Text(number, style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Map<String, int> stock = ref.watch(stockOnHandProvider);
    final bool locked = _isSubmitting;
    final double total = _total;
    final double due = (total - _paid) > 0 ? total - _paid : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('New purchase')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _stepTitle(context, '1', 'Vendor'),
                    VendorPickerField(
                      vendorId: _vendor?.id,
                      enabled: !locked,
                      errorText: (_showErrors && _vendor == null)
                          ? 'Choose a vendor.'
                          : null,
                      onChanged: (VendorModel? vendor) =>
                          setState(() => _vendor = vendor),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            controller: _invoiceController,
                            enabled: !locked,
                            decoration: const InputDecoration(
                              labelText: 'Supplier invoice no. (optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: locked ? null : _pickDate,
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(formatDate(_date)),
                        ),
                      ],
                    ),
                    _stepTitle(context, '2', 'Items and quantities'),
                    if (_showErrors && _lines.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Add at least one item.',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    for (int i = 0; i < _lines.length; i++)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      '${_lines[i].product.name} · ${_lines[i].variant.label}',
                                      style: theme.textTheme.titleSmall,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Remove item',
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: locked
                                        ? null
                                        : () => setState(() {
                                              _lines.removeAt(i).dispose();
                                            }),
                                  ),
                                ],
                              ),
                              Text(
                                'SKU ${_lines[i].variant.sku} · In stock now: '
                                '${stock[_lines[i].variant.id] ?? 0}',
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: TextFormField(
                                      controller: _lines[i].quantityController,
                                      enabled: !locked,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Quantity',
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (String _) => setState(() {}),
                                      validator: (String? value) {
                                        final int? parsed =
                                            int.tryParse((value ?? '').trim());
                                        return (parsed == null || parsed < 1)
                                            ? 'At least 1'
                                            : null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _lines[i].costController,
                                      enabled: !locked,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      decoration: InputDecoration(
                                        labelText: 'Buying price',
                                        helperText:
                                            'Catalog ${formatAmount(_lines[i].variant.costPrice)}',
                                        isDense: true,
                                        border: const OutlineInputBorder(),
                                      ),
                                      onChanged: (String _) => setState(() {}),
                                      validator: (String? value) {
                                        final double? parsed =
                                            double.tryParse((value ?? '').trim());
                                        return (parsed == null || parsed < 0)
                                            ? 'Invalid price'
                                            : null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Line total ${formatAmount(_lines[i].total)}',
                                    style: theme.textTheme.titleSmall,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: locked ? null : _addItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add item'),
                      ),
                    ),
                    _stepTitle(context, '3', 'Payment'),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text('Total ${formatAmount(total)}',
                              style: theme.textTheme.titleLarge),
                        ),
                        PurchaseStatusChip(
                          status: purchaseStatusFor(total, _paid),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _paidController,
                      enabled: !locked,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Paid now',
                        helperText: 'Due: ${formatAmount(due)}',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (String _) => setState(() {}),
                      validator: (String? value) {
                        final double? parsed = double.tryParse((value ?? '').trim());
                        if (parsed == null || parsed < 0) {
                          return 'Enter a valid amount.';
                        }
                        if (parsed > total + 0.005) {
                          return 'More than the purchase total.';
                        }
                        return null;
                      },
                    ),
                    Row(
                      children: <Widget>[
                        TextButton(
                          onPressed: locked
                              ? null
                              : () => setState(
                                  () => _paidController.text = formatAmount(total)),
                          child: const Text('Paid in full'),
                        ),
                        TextButton(
                          onPressed: locked
                              ? null
                              : () => setState(() => _paidController.text = '0.00'),
                          child: const Text('Pay later'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      enabled: !locked,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    _stepTitle(context, '4', 'Confirm'),
                    FilledButton.icon(
                      onPressed: locked ? null : _submit,
                      icon: locked
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: const Text('Confirm purchase'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Confirming adds the quantities to stock and posts the '
                      'purchase to the vendor ledger. It is uploaded to the '
                      'cloud as one atomic change when you sync.',
                      style: theme.textTheme.bodySmall,
                    ),
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
