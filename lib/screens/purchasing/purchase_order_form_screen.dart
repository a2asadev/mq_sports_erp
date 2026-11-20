import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/purchase_order.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/models/vendor_model.dart';
import 'package:a2_stocks/providers/purchase_order_providers.dart';
import 'package:a2_stocks/widgets/party_picker.dart';
import 'package:a2_stocks/widgets/variant_picker.dart';

class _Line {
  _Line({required this.product, required this.variant})
      : quantity = TextEditingController(text: '1'),
        cost = TextEditingController(text: variant.costPrice == variant.costPrice.roundToDouble() ? variant.costPrice.toStringAsFixed(0) : variant.costPrice.toStringAsFixed(2));

  final ProductModel product;
  final VariantModel variant;
  final TextEditingController quantity;
  final TextEditingController cost;

  int get qty => int.tryParse(quantity.text.trim()) ?? 0;
  double get unitCost => double.tryParse(cost.text.trim()) ?? 0;
  double get total => qty * unitCost;

  void dispose() {
    quantity.dispose();
    cost.dispose();
  }
}

/// A new purchase order: the vendor, what is wanted and at what price, when it is expected. It orders only:
/// stock and the vendor's balance change when the goods are received. Pops the new order's id.
class PurchaseOrderFormScreen extends ConsumerStatefulWidget {
  const PurchaseOrderFormScreen({super.key});

  @override
  ConsumerState<PurchaseOrderFormScreen> createState() => _PurchaseOrderFormScreenState();
}

class _PurchaseOrderFormScreenState extends ConsumerState<PurchaseOrderFormScreen> {
  /// One id for this screen: a double tap orders once.
  final String _requestId = const Uuid().v4();
  final TextEditingController _note = TextEditingController();
  final List<_Line> _lines = <_Line>[];
  VendorModel? _vendor;
  DateTime? _expected;
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    for (final _Line l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  double get _total => ((_lines.fold<double>(0, (double s, _Line l) => s + l.total)) * 100).round() / 100;
  bool get _valid => _vendor != null && _lines.isNotEmpty && _lines.every((_Line l) => l.qty > 0);

  static String _key(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickVendor() async {
    final PartyPick<VendorModel>? picked = await showVendorPicker(context, ref, selectedId: _vendor?.id);
    if (picked != null && picked.party != null && mounted) {
      setState(() => _vendor = picked.party);
    }
  }

  Future<void> _addItem() async {
    final VariantPick? pick = await showVariantPicker(context, ref);
    if (pick == null || !mounted) {
      return;
    }
    setState(() {
      final _Line? same = _lines.where((_Line l) => l.variant.id == pick.variant.id).firstOrNull;
      if (same != null) {
        same.quantity.text = '${same.qty + 1}';
      } else {
        _lines.add(_Line(product: pick.product, variant: pick.variant));
      }
    });
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expected ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked != null && mounted) {
      setState(() => _expected = picked);
    }
  }

  Future<void> _save() async {
    final VendorModel? vendor = _vendor;
    if (vendor == null || !_valid) {
      return;
    }
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final PurchaseOrder po = await ref.read(purchaseOrdersServiceProvider).create(
            vendorId: vendor.id,
            expectedDate: _expected == null ? '' : _key(_expected!),
            note: _note.text,
            requestId: _requestId,
            lines: <PurchaseOrderLineRequest>[
              for (final _Line l in _lines)
                PurchaseOrderLineRequest(productId: l.product.id, variantId: l.variant.id, quantity: l.qty, unitCost: l.unitCost),
            ],
          );
      messenger.showSnackBar(SnackBar(content: Text(l10n.poCreated(po.poNo))));
      navigator.pop(po.id);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.poNewOrder)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(context.l10n.poFormHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_shipping_outlined),
              title: Text(_vendor?.name ?? context.l10n.poChooseVendor),
              trailing: const Icon(Icons.chevron_right),
              onTap: _busy ? null : _pickVendor,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.event_outlined),
              title: Text(_expected == null ? context.l10n.poExpectedOptional : context.l10n.poExpected(_key(_expected!))),
              trailing: _expected == null ? const Icon(Icons.chevron_right) : IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _expected = null)),
              onTap: _busy ? null : _pickDate,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(child: Text(context.l10n.poItems, style: theme.textTheme.titleMedium)),
              FilledButton.tonalIcon(onPressed: _busy ? null : _addItem, icon: const Icon(Icons.add), label: Text(context.l10n.poAddItem)),
            ],
          ),
          if (_lines.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(context.l10n.poNoItemsYet))),
          for (final _Line line in _lines)
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(child: Text('${line.product.name} · ${line.variant.label}', style: const TextStyle(fontWeight: FontWeight.w600))),
                        IconButton(
                          tooltip: context.l10n.poRemoveItem,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: _busy
                              ? null
                              : () => setState(() {
                                    _lines.remove(line);
                                    line.dispose();
                                  }),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: line.quantity,
                            enabled: !_busy,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                            onChanged: (String _) => setState(() {}),
                            decoration: InputDecoration(labelText: context.l10n.poQuantity, border: const OutlineInputBorder(), isDense: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: line.cost,
                            enabled: !_busy,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                            onChanged: (String _) => setState(() {}),
                            decoration: InputDecoration(labelText: context.l10n.poUnitCost, border: const OutlineInputBorder(), isDense: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(width: 90, child: Text(formatMoney(line.total), textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: _note,
            enabled: !_busy,
            maxLength: 1000,
            decoration: InputDecoration(labelText: context.l10n.poNote, border: const OutlineInputBorder()),
          ),
          Row(
            children: <Widget>[
              Expanded(child: Text(context.l10n.poOrderTotal(formatMoney(_total)), style: theme.textTheme.titleMedium)),
              FilledButton.icon(
                onPressed: _busy || !_valid ? null : _save,
                icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_outlined),
                label: Text(context.l10n.poPlaceOrder),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
