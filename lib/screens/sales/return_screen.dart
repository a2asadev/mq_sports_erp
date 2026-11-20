import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/core/utils/return_plan.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/order_return.dart';
import 'package:a2_stocks/models/payment_method.dart';
import 'package:a2_stocks/online/returns_service.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/providers/core_providers.dart';
import 'package:a2_stocks/providers/sales_providers.dart';

/// Goods coming back from a delivered order: pick the units, say whether they can
/// be sold again, and say what happens to the money (kept as credit on the
/// customer's account, or handed back). Needs a connection; the server works out
/// the amounts, this screen shows what it is going to do.
class ReturnScreen extends ConsumerStatefulWidget {
  const ReturnScreen({super.key, required this.order});

  final OrderModel order;

  @override
  ConsumerState<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends ConsumerState<ReturnScreen> {
  /// One id for this screen: tapping twice sends the same request, which the server recognises.
  final String _requestId = const Uuid().v4();
  final Map<String, int> _units = <String, int>{};
  final Set<String> _damaged = <String>{};
  final TextEditingController _note = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  bool _handBack = true;
  bool _amountEdited = false;
  PaymentMethod _method = PaymentMethod.cash;
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    _amount.dispose();
    super.dispose();
  }

  static String _text(double value) => value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(2);

  int get _chosen => _units.values.fold<int>(0, (int sum, int n) => sum + n);

  void _step(OrderItem item, int by, int max) {
    final int next = ((_units[item.id] ?? 0) + by).clamp(0, max).toInt();
    setState(() {
      _units[item.id] = next;
      if (next == 0) {
        _damaged.remove(item.id);
      }
      _amountEdited = false;
    });
  }

  Future<void> _submit(double overpaid) async {
    final AppLocalizations l10n = context.l10n;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      final bool money = overpaid > 0.004 && _handBack;
      final OrderReturn done = await ref.read(returnsServiceProvider).create(
            orderId: widget.order.id,
            requestId: _requestId,
            lines: <ReturnLineRequest>[
              for (final OrderItem item in widget.order.items)
                if ((_units[item.id] ?? 0) > 0)
                  ReturnLineRequest(orderItemId: item.id, quantity: _units[item.id]!, restock: !_damaged.contains(item.id)),
            ],
            refundMethod: money ? _method.name : OrderReturn.creditMethod,
            refundAmount: money ? (double.tryParse(_amount.text.trim()) ?? overpaid) : null,
            note: _note.text,
          );
      // The stock and the ledger arrive by the normal sync; pull now so the person sees them.
      ref.read(syncTickProvider.notifier).increment();
      messenger.showSnackBar(SnackBar(content: Text(l10n.returnDone(done.returnNo))));
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
    final OrderModel order = widget.order;
    final AsyncValue<List<OrderReturn>> earlier = ref.watch(orderReturnsProvider(order.id));
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.returnTitle(order.orderNo))),
      body: earlier.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) =>
            Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(errorMessageOf(error), textAlign: TextAlign.center))),
        data: (List<OrderReturn> returns) => _form(context, returns),
      ),
    );
  }

  Widget _form(BuildContext context, List<OrderReturn> returns) {
    final OrderModel order = widget.order;
    final ThemeData theme = Theme.of(context);
    final bool isWalkIn = ref.watch(businessProvider).isWalkIn(order.customerId);
    final double settled = ref.watch(orderPaidProvider)[order.id] ?? 0;

    final Map<String, int> already = <String, int>{};
    for (final OrderReturn r in returns) {
      for (final OrderReturnItem i in r.items) {
        already[i.orderItemId] = (already[i.orderItemId] ?? 0) + i.quantity;
      }
    }
    final ReturnPlan plan = ReturnPlan(order: order, alreadyReturned: already);
    final double value = plan.totalValue(_units);
    final double overpaid = plan.overpaid(settled: settled, returnedValue: value);
    final bool handBack = overpaid > 0.004 && (isWalkIn || _handBack);
    if (!_amountEdited) {
      final String suggested = overpaid > 0.004 ? _text(overpaid) : '';
      if (_amount.text != suggested) {
        _amount.text = suggested;
      }
    }
    final double? typed = double.tryParse(_amount.text.trim());
    final bool amountOk = !handBack || (typed != null && typed > 0 && typed <= overpaid + 0.004);
    final bool canSubmit = !_busy && _chosen > 0 && amountOk;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        for (final OrderItem item in order.items) _line(context, plan, item),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _row(context.l10n.returnGoodsValue, formatMoney(value), bold: true),
                _row(context.l10n.returnSettledSoFar, formatMoney(settled)),
                if (value > 0 && overpaid <= 0.004) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(context.l10n.returnLowersDue, style: theme.textTheme.bodySmall),
                ],
                if (overpaid > 0.004) ...<Widget>[
                  const Divider(height: 24),
                  Text(context.l10n.returnMoneyTitle(formatMoney(overpaid)), style: theme.textTheme.titleSmall),
                  RadioGroup<bool>(
                    groupValue: handBack,
                    onChanged: (bool? v) => setState(() => _handBack = v ?? true),
                    child: Column(
                      children: <Widget>[
                        RadioListTile<bool>(
                          contentPadding: EdgeInsets.zero,
                          value: true,
                          enabled: !_busy,
                          title: Text(context.l10n.returnHandBack),
                        ),
                        RadioListTile<bool>(
                          contentPadding: EdgeInsets.zero,
                          value: false,
                          enabled: !_busy && !isWalkIn,
                          title: Text(context.l10n.returnKeepCredit),
                          subtitle: isWalkIn ? Text(context.l10n.returnWalkInHint) : null,
                        ),
                      ],
                    ),
                  ),
                  if (handBack) ...<Widget>[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<PaymentMethod>(
                      initialValue: _method,
                      decoration: InputDecoration(labelText: context.l10n.returnMethod, border: const OutlineInputBorder()),
                      items: <DropdownMenuItem<PaymentMethod>>[
                        for (final PaymentMethod m in PaymentMethod.values) DropdownMenuItem<PaymentMethod>(value: m, child: Text(m.label)),
                      ],
                      onChanged: _busy ? null : (PaymentMethod? m) => setState(() => _method = m ?? _method),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amount,
                      enabled: !_busy,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      onChanged: (String _) => setState(() => _amountEdited = true),
                      decoration: InputDecoration(
                        labelText: context.l10n.returnAmount,
                        helperText: context.l10n.returnUpTo(formatMoney(overpaid)),
                        errorText: amountOk ? null : context.l10n.returnUpTo(formatMoney(overpaid)),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _note,
          enabled: !_busy,
          maxLength: 500,
          decoration: InputDecoration(labelText: context.l10n.returnNote, border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 4),
        FilledButton.icon(
          onPressed: canSubmit ? () => _submit(overpaid) : null,
          icon: _busy
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.assignment_return_outlined),
          label: Text(_chosen == 0 ? context.l10n.returnNothingChosen : context.l10n.returnConfirm),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(label)),
            Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      );

  Widget _line(BuildContext context, ReturnPlan plan, OrderItem item) {
    final int left = plan.remaining(item);
    final int units = _units[item.id] ?? 0;
    final int back = item.quantity - left;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${item.productName} · ${item.variantLabel}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        left == 0 ? context.l10n.returnFullyReturned : context.l10n.returnSold(item.quantity, back),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                if (left > 0) ...<Widget>[
                  IconButton(
                    onPressed: _busy || units == 0 ? null : () => _step(item, -1, left),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  SizedBox(width: 28, child: Text('$units', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700))),
                  IconButton(
                    onPressed: _busy || units >= left ? null : () => _step(item, 1, left),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ],
            ),
            if (units > 0)
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _damaged.contains(item.id),
                onChanged: _busy
                    ? null
                    : (bool? on) => setState(() {
                          if (on ?? false) {
                            _damaged.add(item.id);
                          } else {
                            _damaged.remove(item.id);
                          }
                        }),
                title: Text(context.l10n.returnDamaged),
              ),
          ],
        ),
      ),
    );
  }
}
