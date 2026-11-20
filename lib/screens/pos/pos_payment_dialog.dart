import 'package:flutter/material.dart';
import 'package:a2_stocks/core/utils/currency.dart';
import 'package:a2_stocks/core/utils/pos_payment_plan.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/models/payment_method.dart';

/// What the customer paid, as chosen in the payment dialog.
class PosPaymentResult {
  const PosPaymentResult({required this.lines, required this.change});

  final List<PaymentLine> lines;

  /// Cash to hand back.
  final double change;
}

/// Asks how the customer pays: one or several payments by cash, Easypaisa,
/// JazzCash or bank transfer. With [allowCredit] (a named customer) the sale
/// may be left partly or fully unpaid; a walk-in customer must pay in full.
Future<PosPaymentResult?> showPosPaymentDialog(
  BuildContext context, {
  required double total,
  required bool allowCredit,
  PaymentMethod initialMethod = PaymentMethod.cash,
}) {
  return showDialog<PosPaymentResult>(
    context: context,
    builder: (BuildContext context) =>
        _PaymentDialog(total: total, allowCredit: allowCredit, initialMethod: initialMethod),
  );
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.total, required this.allowCredit, required this.initialMethod});

  final double total;
  final bool allowCredit;
  final PaymentMethod initialMethod;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  late final PosPaymentPlan _plan = PosPaymentPlan(widget.total);
  late final TextEditingController _amount = TextEditingController(text: _fmt(widget.total));
  final TextEditingController _reference = TextEditingController();
  late PaymentMethod _method = widget.initialMethod;
  String _error = '';

  static String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  void _resetAmount() {
    _amount.text = _plan.remaining > 0 ? _fmt(_plan.remaining) : '';
    _reference.clear();
  }

  void _addPayment() {
    final double? entered = double.tryParse(_amount.text.trim());
    final String? problem = _plan.add(_method, entered ?? 0, reference: _reference.text);
    setState(() {
      _error = problem ?? '';
      if (problem == null) {
        _resetAmount();
      }
    });
  }

  void _finish() {
    Navigator.of(context).pop(PosPaymentResult(lines: _plan.lines, change: _plan.change));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool paid = _plan.isFullyPaid;
    return AlertDialog(
      title: Text(context.l10n.posPaymentPay(MoneyFormat.prefix, _fmt(widget.total))),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < _plan.lines.length; i++)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text('${_plan.lines[i].method.label}  ${MoneyFormat.prefix}${_fmt(_plan.lines[i].amount)}'),
                  subtitle: _plan.lines[i].reference.isEmpty ? null : Text(_plan.lines[i].reference),
                  trailing: IconButton(
                    tooltip: context.l10n.posPaymentRemoveThisPayment,
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _plan.removeAt(i);
                      _resetAmount();
                    }),
                  ),
                ),
              if (_plan.lines.isNotEmpty) const Divider(),
              if (!paid) ...<Widget>[
                Text(context.l10n.posPaymentLeftToPay(MoneyFormat.prefix, _fmt(_plan.remaining)), style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: <Widget>[
                    for (final PaymentMethod m in PaymentMethod.values)
                      ChoiceChip(
                        label: Text(m.label),
                        selected: _method == m,
                        onSelected: (_) => setState(() {
                          _method = m;
                          _error = '';
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: _method == PaymentMethod.cash ? context.l10n.posPaymentCashReceived : context.l10n.ledgerEntryAmount,
                    prefixText: MoneyFormat.prefix,
                    border: const OutlineInputBorder(),
                    suffixIcon: TextButton(
                      onPressed: () => setState(() => _amount.text = _fmt(_plan.remaining)),
                      child: Text(context.l10n.posPaymentExact),
                    ),
                  ),
                  onSubmitted: (_) => _addPayment(),
                ),
                if (_method.hasReference) ...<Widget>[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reference,
                    decoration: InputDecoration(
                      labelText: _method == PaymentMethod.bank ? context.l10n.posPaymentBankAndTransactionNo : context.l10n.posPaymentTransactionNo,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_error, style: TextStyle(color: theme.colorScheme.error)),
                  ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: _addPayment,
                  icon: const Icon(Icons.add),
                  label: Text(context.l10n.posPaymentAddPayment),
                ),
              ] else ...<Widget>[
                Text(context.l10n.posPaymentFullyPaid, style: theme.textTheme.titleMedium?.copyWith(color: Colors.green.shade700)),
                if (_plan.change > 0.005)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(context.l10n.posPaymentGiveChange(MoneyFormat.prefix, _fmt(_plan.change)), style: theme.textTheme.headlineSmall),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.posPaymentBack)),
        if (!paid && widget.allowCredit)
          OutlinedButton(
            onPressed: _finish,
            child: Text(_plan.lines.isEmpty ? context.l10n.posPaymentSellOnCredit : context.l10n.posPaymentSellWithDue(MoneyFormat.prefix, _fmt(_plan.remaining))),
          ),
        FilledButton(
          onPressed: paid ? _finish : null,
          child: Text(context.l10n.posPaymentCompleteSale),
        ),
      ],
    );
  }
}
