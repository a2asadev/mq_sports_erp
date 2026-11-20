import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/core/utils/tax.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/core/utils/tax_text.dart';
import 'package:a2_stocks/core/utils/price_warnings.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/models/customer_model.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/party_enums.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/purchase_model.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/providers/sales_providers.dart';
import 'package:a2_stocks/providers/stock_providers.dart';
import 'package:a2_stocks/widgets/party_picker.dart';
import 'package:a2_stocks/widgets/purchase_status_chip.dart';
import 'package:a2_stocks/widgets/variant_picker.dart';

/// One editable line of the order being entered.
class _Line {
  _Line({required this.product, required this.variant, required double price})
      : quantityController = TextEditingController(text: '1'),
        priceController = TextEditingController(text: price.toStringAsFixed(2)),
        discountController = TextEditingController(text: '0');

  final ProductModel product;
  final VariantModel variant;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final TextEditingController discountController;
  bool discountIsPercent = false;

  int get quantity => int.tryParse(quantityController.text.trim()) ?? 0;
  double get unitPrice => double.tryParse(priceController.text.trim()) ?? 0;
  double get gross => quantity * unitPrice;
  double get discountValue => double.tryParse(discountController.text.trim()) ?? 0;

  /// The discount as an amount, whichever way it was typed.
  double get discountAmount =>
      discountIsPercent ? gross * discountValue / 100 : discountValue;

  double get total {
    final double net = gross - discountAmount;
    return net > 0 ? net : 0;
  }

  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    discountController.dispose();
  }
}

/// Discount input with an "amount / percent" switch.
class _DiscountField extends StatelessWidget {
  const _DiscountField({
    required this.controller,
    required this.isPercent,
    required this.enabled,
    required this.maxAmount,
    required this.onChanged,
    required this.onModeChanged,
    this.label,
  });

  final TextEditingController controller;
  final bool isPercent;
  final bool enabled;
  final double maxAmount;
  final String? label;
  final VoidCallback onChanged;
  final ValueChanged<bool> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: label ?? context.l10n.posDiscount,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            onChanged: (String _) => onChanged(),
            validator: (String? value) {
              final double? parsed = double.tryParse((value ?? '').trim());
              if (parsed == null || parsed < 0) {
                return context.l10n.orderFormInvalidDiscount;
              }
              if (isPercent && parsed > 100) {
                return context.l10n.orderFormMax100;
              }
              if (!isPercent && parsed > maxAmount + 0.005) {
                return context.l10n.orderFormMoreThanTheAmount;
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 8),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: <ButtonSegment<bool>>[
            ButtonSegment<bool>(value: false, label: Text(context.l10n.orderFormAmt)),
            const ButtonSegment<bool>(value: true, label: Text('%')),
          ],
          selected: <bool>{isPercent},
          onSelectionChanged:
              enabled ? (Set<bool> v) => onModeChanged(v.first) : null,
        ),
      ],
    );
  }
}

/// Sale entry: 1 Customer -> 2 Items and prices -> 3 Discounts -> 4 Payment
/// -> Confirm.
class OrderFormScreen extends ConsumerStatefulWidget {
  const OrderFormScreen({super.key});

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _discountController =
      TextEditingController(text: '0');
  final TextEditingController _paidController = TextEditingController(text: '0.00');
  final List<_Line> _lines = <_Line>[];
  CustomerModel? _customer;
  OrderSaleType _saleType = OrderSaleType.retail;
  DateTime _date = DateTime.now();
  bool _discountIsPercent = false;
  bool _isSubmitting = false;
  bool _showErrors = false;

  @override
  void dispose() {
    _notesController.dispose();
    _discountController.dispose();
    _paidController.dispose();
    for (final _Line line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  double get _subtotal {
    final double sum = _lines.fold<double>(0, (double s, _Line l) => s + l.total);
    return (sum * 100).round() / 100;
  }

  double get _orderDiscountValue =>
      double.tryParse(_discountController.text.trim()) ?? 0;

  double get _orderDiscount {
    final double amount = _discountIsPercent
        ? _subtotal * _orderDiscountValue / 100
        : _orderDiscountValue;
    return (amount * 100).round() / 100;
  }

  /// The goods after discounts, before any tax.
  double get _goods {
    final double net = _subtotal - _orderDiscount;
    return ((net > 0 ? net : 0) * 100).round() / 100;
  }

  /// The tax of the business on this sale.
  TaxResult get _tax => computeTax(_goods, TaxSettings.of(ref.read(businessProvider)));

  /// What the customer owes: the goods plus the tax when it is added on top.
  double get _total => ((_goods + _tax.added) * 100).round() / 100;

  double get _paid => double.tryParse(_paidController.text.trim()) ?? 0;

  /// Units of one variant requested over all lines.
  int _requested(String variantId) => _lines
      .where((_Line l) => l.variant.id == variantId)
      .fold<int>(0, (int s, _Line l) => s + l.quantity);

  /// Catalog price of [variant] for a sale of [type]: the wholesale price for
  /// a wholesale sale of a wholesale variant, otherwise the sale price.
  double _priceFor(VariantModel variant, OrderSaleType type) {
    final bool wholesale = type == OrderSaleType.wholesale &&
        variant.isWholesale &&
        variant.wholesalePrice > 0;
    return wholesale ? variant.wholesalePrice : variant.salePrice;
  }

  double _defaultPrice(VariantModel variant) => _priceFor(variant, _saleType);

  /// Changes the retail/wholesale tag. Lines whose price is still the
  /// catalog price of the old tag move to the catalog price of the new one;
  /// prices the user typed are kept.
  void _setSaleType(OrderSaleType type) {
    if (type == _saleType) {
      return;
    }
    final OrderSaleType old = _saleType;
    _saleType = type;
    for (final _Line line in _lines) {
      final String oldDefault = _priceFor(line.variant, old).toStringAsFixed(2);
      if (line.priceController.text.trim() == oldDefault) {
        line.priceController.text = _priceFor(line.variant, type).toStringAsFixed(2);
      }
    }
  }

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
    final VariantPick? pick =
        await showVariantPicker(context, ref, forSale: true);
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
        _lines.add(_Line(
          product: pick.product,
          variant: pick.variant,
          price: _defaultPrice(pick.variant),
        ));
      }
    });
  }

  Future<bool> _confirmDialog(CustomerModel customer) async {
    final double due = (_total - _paid) > 0 ? _total - _paid : 0;
    final int units = _lines.fold<int>(0, (int s, _Line l) => s + l.quantity);
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.orderFormConfirmOrder),
          content: Text(
            context.l10n.orderFormCustomerSaleTypeItem(customer.name, _saleType.label, _lines.length, units, formatAmount(_total), formatAmount(_paid), formatAmount(due)),
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
    final CustomerModel? customer = _customer;
    if (form == null || !form.validate() || customer == null || _lines.isEmpty) {
      return;
    }
    if (!await _confirmDialog(customer) || !mounted) {
      return;
    }
    setState(() => _isSubmitting = true);
    final bool saved = await ref.read(ordersProvider.notifier).confirmOrder(
          customer: customer,
          saleType: _saleType,
          orderDate: _date,
          notes: _notesController.text.trim(),
          items: <OrderItem>[
            for (final _Line line in _lines)
              OrderItem(
                productId: line.product.id,
                variantId: line.variant.id,
                productName: line.product.name,
                variantLabel: line.variant.label,
                sku: line.variant.sku,
                quantity: line.quantity,
                unitPrice: line.unitPrice,
                discount: (line.discountAmount * 100).round() / 100,
              ),
          ],
          orderDiscount: _orderDiscount,
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

  Widget _lineCard(BuildContext context, int i, Map<String, int> stock, bool locked) {
    final ThemeData theme = Theme.of(context);
    final _Line line = _lines[i];
    final int onHand = stock[line.variant.id] ?? 0;
    final int requested = _requested(line.variant.id);
    final bool short = requested > onHand;
    final List<String> warnings = priceWarnings(
      isWholesale: line.variant.isWholesale,
      costPrice: line.variant.costPrice,
      wholesalePrice: line.variant.wholesalePrice,
      salePrice: line.variant.salePrice,
    );
    final bool belowCost = line.unitPrice > 0 &&
        line.quantity > 0 &&
        (line.total / line.quantity) < line.variant.costPrice;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${line.product.name} · ${line.variant.label}',
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
              short
                  ? context.l10n.orderFormSkuOnlyInStock(line.variant.sku, onHand, requested)
                  : context.l10n.orderFormSkuInStock(line.variant.sku, onHand),
              style: theme.textTheme.bodySmall?.copyWith(
                color: short ? theme.colorScheme.error : null,
                fontWeight: short ? FontWeight.w600 : null,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: line.quantityController,
                    enabled: !locked,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.l10n.purchaseFormQuantity,
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (String _) => setState(() {}),
                    validator: (String? value) {
                      final int? parsed = int.tryParse((value ?? '').trim());
                      return (parsed == null || parsed < 1) ? context.l10n.purchaseFormAtLeast1 : null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: line.priceController,
                    enabled: !locked,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: context.l10n.orderFormSellingPrice,
                      helperText: context.l10n.purchaseFormCatalog(formatAmount(line.variant.salePrice)),
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (String _) => setState(() {}),
                    validator: (String? value) {
                      final double? parsed = double.tryParse((value ?? '').trim());
                      return (parsed == null || parsed < 0) ? context.l10n.purchaseFormInvalidPrice : null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _DiscountField(
              controller: line.discountController,
              isPercent: line.discountIsPercent,
              enabled: !locked,
              maxAmount: line.gross,
              label: context.l10n.orderFormLineDiscount,
              onChanged: () => setState(() {}),
              onModeChanged: (bool percent) => setState(() {
                line.discountIsPercent = percent;
              }),
            ),
            if (warnings.isNotEmpty || belowCost)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  belowCost
                      ? context.l10n.orderFormSellingBelowTheCost(formatAmount(line.variant.costPrice))
                      : warnings.first,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.orange.shade800),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  context.l10n.purchaseFormLineTotal(formatAmount(line.total)),
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ),
          ],
        ),
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
      appBar: AppBar(title: Text(context.l10n.ordersNewOrder)),
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
                    _stepTitle(context, '1', context.l10n.posCustomer),
                    CustomerPickerField(
                      customerId: _customer?.id,
                      allowWalkIn: false,
                      enabled: !locked,
                      errorText: (_showErrors && _customer == null)
                          ? context.l10n.orderFormChooseACustomer
                          : null,
                      onChanged: (CustomerModel? customer) => setState(() {
                        _customer = customer;
                        // The tag starts from the customer's type; it can
                        // still be changed below.
                        if (customer != null) {
                          _setSaleType(customer.type == CustomerType.wholesale
                              ? OrderSaleType.wholesale
                              : OrderSaleType.retail);
                        }
                      }),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Text(context.l10n.orderFormSaleType, style: theme.textTheme.bodyMedium),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SegmentedButton<OrderSaleType>(
                            showSelectedIcon: false,
                            segments: <ButtonSegment<OrderSaleType>>[
                              for (final OrderSaleType type in OrderSaleType.values)
                                ButtonSegment<OrderSaleType>(
                                  value: type,
                                  label: Text(type.label),
                                ),
                            ],
                            selected: <OrderSaleType>{_saleType},
                            onSelectionChanged: locked
                                ? null
                                : (Set<OrderSaleType> v) =>
                                    setState(() => _setSaleType(v.first)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: locked ? null : _pickDate,
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(formatDate(_date)),
                      ),
                    ),
                    _stepTitle(context, '2', context.l10n.orderFormItemsQuantitiesAndPrices),
                    if (_showErrors && _lines.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          context.l10n.purchaseFormAddAtLeastOne,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    for (int i = 0; i < _lines.length; i++)
                      _lineCard(context, i, stock, locked),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: locked ? null : _addItem,
                        icon: const Icon(Icons.add),
                        label: Text(context.l10n.purchaseFormAddItem),
                      ),
                    ),
                    _stepTitle(context, '3', context.l10n.orderFormOrderDiscount),
                    _DiscountField(
                      controller: _discountController,
                      isPercent: _discountIsPercent,
                      enabled: !locked,
                      maxAmount: _subtotal,
                      label: context.l10n.orderFormDiscountOnTheWhole,
                      onChanged: () => setState(() {}),
                      onModeChanged: (bool percent) =>
                          setState(() => _discountIsPercent = percent),
                    ),
                    const SizedBox(height: 12),
                    _summaryRow(context.l10n.orderDetailSubtotal, formatAmount(_subtotal)),
                    _summaryRow(context.l10n.orderFormOrderDiscount, '- ${formatAmount(_orderDiscount)}'),
                    for (final MapEntry<String, double> line in taxLabels(context.l10n, _tax)) _summaryRow(line.key, formatAmount(line.value)),
                    _stepTitle(context, '4', context.l10n.posPayment),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(context.l10n.purchaseFormTotal(formatAmount(total)),
                              style: theme.textTheme.titleLarge),
                        ),
                        PurchaseStatusChip(status: purchaseStatusFor(total, _paid)),
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
                          return context.l10n.orderFormMoreThanTheOrder;
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
                    _stepTitle(context, '5', context.l10n.settingsSave),
                    FilledButton.icon(
                      onPressed: locked ? null : _submit,
                      icon: locked
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(context.l10n.orderFormConfirmOrder),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.orderFormConfirmingTakesTheQuantities,
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

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(value),
        ],
      ),
    );
  }
}
