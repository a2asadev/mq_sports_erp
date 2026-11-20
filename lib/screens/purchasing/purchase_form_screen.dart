import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/purchase_model.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/models/vendor_model.dart';
import 'package:a2_stocks/providers/purchasing_providers.dart';
import 'package:a2_stocks/providers/stock_providers.dart';
import 'package:a2_stocks/widgets/party_picker.dart';
import 'package:a2_stocks/widgets/purchase_status_chip.dart';
import 'package:a2_stocks/widgets/variant_picker.dart';

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
          title: Text(context.l10n.purchaseFormConfirmPurchase),
          content: Text(
            context.l10n.purchaseFormVendorItemSUnit(vendor.name, _lines.length, units, formatAmount(_total), formatAmount(_paid), formatAmount(due)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.posPaymentBack),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.l10n.purchaseFormConfirm),
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
      appBar: AppBar(title: Text(context.l10n.purchasesNewPurchase)),
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
                    _stepTitle(context, '1', context.l10n.purchaseFormVendor),
                    VendorPickerField(
                      vendorId: _vendor?.id,
                      enabled: !locked,
                      errorText: (_showErrors && _vendor == null)
                          ? context.l10n.purchaseFormChooseAVendor
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
                            decoration: InputDecoration(
                              labelText: context.l10n.purchaseFormSupplierInvoiceNoOptional,
                              border: const OutlineInputBorder(),
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
                    _stepTitle(context, '2', context.l10n.purchaseFormItemsAndQuantities),
                    if (_showErrors && _lines.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          context.l10n.purchaseFormAddAtLeastOne,
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
                                    tooltip: context.l10n.purchaseFormRemoveItem,
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
                                context.l10n.purchaseFormSkuInStock(_lines[i].variant.sku, stock[_lines[i].variant.id] ?? 0),
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
                                      decoration: InputDecoration(
                                        labelText: context.l10n.purchaseFormQuantity,
                                        isDense: true,
                                        border: const OutlineInputBorder(),
                                      ),
                                      onChanged: (String _) => setState(() {}),
                                      validator: (String? value) {
                                        final int? parsed =
                                            int.tryParse((value ?? '').trim());
                                        return (parsed == null || parsed < 1)
                                            ? context.l10n.purchaseFormAtLeast1
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
                                        labelText: context.l10n.purchaseFormBuyingPrice,
                                        helperText:
                                            context.l10n.purchaseFormCatalog(formatAmount(_lines[i].variant.costPrice)),
                                        isDense: true,
                                        border: const OutlineInputBorder(),
                                      ),
                                      onChanged: (String _) => setState(() {}),
                                      validator: (String? value) {
                                        final double? parsed =
                                            double.tryParse((value ?? '').trim());
                                        return (parsed == null || parsed < 0)
                                            ? context.l10n.purchaseFormInvalidPrice
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
                                    context.l10n.purchaseFormLineTotal(formatAmount(_lines[i].total)),
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
                        label: Text(context.l10n.purchaseFormAddItem),
                      ),
                    ),
                    _stepTitle(context, '3', context.l10n.posPayment),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(context.l10n.purchaseFormTotal(formatAmount(total)),
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
                        labelText: context.l10n.purchaseFormPaidNow,
                        helperText: context.l10n.purchaseDetailDue(formatAmount(due)),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (String _) => setState(() {}),
                      validator: (String? value) {
                        final double? parsed = double.tryParse((value ?? '').trim());
                        if (parsed == null || parsed < 0) {
                          return context.l10n.partyFormEnterAValidAmount;
                        }
                        if (parsed > total + 0.005) {
                          return context.l10n.purchaseFormMoreThanThePurchase;
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
                          child: Text(context.l10n.purchaseFormPaidInFull),
                        ),
                        TextButton(
                          onPressed: locked
                              ? null
                              : () => setState(() => _paidController.text = '0.00'),
                          child: Text(context.l10n.purchaseFormPayLater),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      enabled: !locked,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: context.l10n.partyFormNotesOptional,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    _stepTitle(context, '4', context.l10n.purchaseFormConfirm),
                    FilledButton.icon(
                      onPressed: locked ? null : _submit,
                      icon: locked
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(context.l10n.purchaseFormConfirmPurchase),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.purchaseFormConfirmingAddsTheQuantities,
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
