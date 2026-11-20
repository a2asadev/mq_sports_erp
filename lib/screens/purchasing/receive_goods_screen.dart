import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/purchase_order.dart';
import 'package:a2_stocks/providers/core_providers.dart';
import 'package:a2_stocks/providers/purchase_order_providers.dart';

class _Receive {
  _Receive(this.item)
      : quantity = TextEditingController(text: '${item.remaining}'),
        cost = TextEditingController(text: item.unitCost == item.unitCost.roundToDouble() ? item.unitCost.toStringAsFixed(0) : item.unitCost.toStringAsFixed(2));

  final PurchaseOrderItem item;
  final TextEditingController quantity;
  final TextEditingController cost;

  int get qty => int.tryParse(quantity.text.trim()) ?? 0;
  double get unitCost => double.tryParse(cost.text.trim()) ?? item.unitCost;
  double get total => qty * unitCost;

  void dispose() {
    quantity.dispose();
    cost.dispose();
  }
}

/// Goods arrived against an order: say how many of each line came (all of what is left by default, or less if
/// only a part did) and the price on the invoice. It takes them into stock and charges the vendor in one step,
/// and can pay the vendor now.
class ReceiveGoodsScreen extends ConsumerStatefulWidget {
  const ReceiveGoodsScreen({super.key, required this.order});

  final PurchaseOrder order;

  @override
  ConsumerState<ReceiveGoodsScreen> createState() => _ReceiveGoodsScreenState();
}

class _ReceiveGoodsScreenState extends ConsumerState<ReceiveGoodsScreen> {
  /// One id for this screen: a double tap receives once.
  final String _requestId = const Uuid().v4();
  late final List<_Receive> _lines = <_Receive>[
    for (final PurchaseOrderItem i in widget.order.items)
      if (i.remaining > 0) _Receive(i),
  ];
  final TextEditingController _invoice = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final TextEditingController _paid = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _invoice.dispose();
    _notes.dispose();
    _paid.dispose();
    for (final _Receive l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  double get _total => ((_lines.fold<double>(0, (double s, _Receive l) => s + l.total)) * 100).round() / 100;
  double get _paidNow => double.tryParse(_paid.text.trim()) ?? 0;
  bool get _anyArrived => _lines.any((_Receive l) => l.qty > 0);
  bool get _quantitiesOk => _lines.every((_Receive l) => l.qty >= 0 && l.qty <= l.item.remaining);
  bool get _paidOk => _paidNow >= 0 && _paidNow <= _total + 0.004;

  Future<void> _submit() async {
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await ref.read(purchaseOrdersServiceProvider).receive(
            widget.order.id,
            requestId: _requestId,
            lines: <ReceiveLineRequest>[
              for (final _Receive l in _lines)
                if (l.qty > 0) ReceiveLineRequest(poItemId: l.item.id, quantity: l.qty, unitCost: (l.unitCost - l.item.unitCost).abs() > 0.004 ? l.unitCost : null),
            ],
            invoiceNo: _invoice.text,
            notes: _notes.text,
            paidNow: _paidNow,
          );
      // The stock and the vendor's balance reach this device by the normal sync; pull now.
      ref.read(syncTickProvider.notifier).increment();
      messenger.showSnackBar(SnackBar(content: Text(l10n.poReceivedDone)));
      navigator.pop(true);
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
    final bool canSubmit = !_busy && _anyArrived && _quantitiesOk && _paidOk;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.poReceiveTitle(widget.order.poNo))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(context.l10n.poReceiveHint(widget.order.vendorName), style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          for (final _Receive line in _lines)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${line.item.productName} · ${line.item.variantLabel}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(context.l10n.poStillToCome(line.item.remaining), style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: line.quantity,
                            enabled: !_busy,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                            onChanged: (String _) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: context.l10n.poArrived,
                              errorText: line.qty > line.item.remaining ? context.l10n.poMostIs(line.item.remaining) : null,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
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
                            decoration: InputDecoration(labelText: context.l10n.poInvoicePrice, border: const OutlineInputBorder(), isDense: true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: _invoice,
            enabled: !_busy,
            maxLength: 80,
            decoration: InputDecoration(labelText: context.l10n.poInvoiceNo, border: const OutlineInputBorder()),
          ),
          TextField(
            controller: _notes,
            enabled: !_busy,
            maxLength: 500,
            decoration: InputDecoration(labelText: context.l10n.poNote, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _paid,
            enabled: !_busy,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            onChanged: (String _) => setState(() {}),
            decoration: InputDecoration(
              labelText: context.l10n.poPaidNow,
              helperText: context.l10n.poPaidNowHint,
              errorText: _paidOk ? null : context.l10n.poPaidTooMuch(formatMoney(_total)),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(child: Text(context.l10n.poReceivingValue(formatMoney(_total)), style: theme.textTheme.titleMedium)),
              FilledButton.icon(
                onPressed: canSubmit ? _submit : null,
                icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.inventory_outlined),
                label: Text(context.l10n.poReceiveGoods),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
