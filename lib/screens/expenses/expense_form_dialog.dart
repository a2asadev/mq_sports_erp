import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/models/expense.dart';
import 'package:a2_stocks/models/payment_method.dart';
import 'package:a2_stocks/providers/expense_providers.dart';

/// Records one expense. Pops `true` once the server has it.
class ExpenseFormDialog extends ConsumerStatefulWidget {
  const ExpenseFormDialog({super.key});

  @override
  ConsumerState<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends ConsumerState<ExpenseFormDialog> {
  /// One id for this dialog: a double tap sends the same request, which the server recognises.
  final String _requestId = const Uuid().v4();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _payee = TextEditingController();
  final TextEditingController _note = TextEditingController();
  final TextEditingController _reference = TextEditingController();
  String? _categoryId;
  PaymentMethod _method = PaymentMethod.cash;
  DateTime _date = DateTime.now();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    _payee.dispose();
    _note.dispose();
    _reference.dispose();
    super.dispose();
  }

  double? get _value => double.tryParse(_amount.text.trim());

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    final String? category = _categoryId;
    final double? amount = _value;
    if (category == null || amount == null || amount <= 0) {
      return;
    }
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = context.l10n;
    setState(() => _busy = true);
    try {
      // A date without a time means "that day": keep the current time of day.
      final DateTime now = DateTime.now();
      final DateTime when = DateTime(_date.year, _date.month, _date.day, now.hour, now.minute, now.second);
      await ref.read(expensesServiceProvider).create(
            categoryId: category,
            amount: amount,
            date: when.isAfter(now) ? now : when,
            paymentMethod: _method.name,
            paymentRef: _method.hasReference ? _reference.text : '',
            payee: _payee.text,
            note: _note.text,
            requestId: _requestId,
          );
      messenger.showSnackBar(SnackBar(content: Text(l10n.expensesSaved)));
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
    final AsyncValue<List<ExpenseCategory>> categories = ref.watch(expenseCategoriesProvider);
    final List<ExpenseCategory> active = (categories.valueOrNull ?? <ExpenseCategory>[]).where((ExpenseCategory c) => c.isActive).toList();
    final bool amountOk = (_value ?? 0) > 0;
    return AlertDialog(
      title: Text(context.l10n.expenseFormTitle),
      content: SizedBox(
        width: 440,
        child: categories.when(
          loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
          error: (Object error, StackTrace stack) => Text(errorMessageOf(error)),
          data: (List<ExpenseCategory> _) => active.isEmpty
              ? Text(context.l10n.expenseFormNoCategories)
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      DropdownButtonFormField<String>(
                        initialValue: _categoryId,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: context.l10n.expenseFormCategory, border: const OutlineInputBorder()),
                        items: <DropdownMenuItem<String>>[
                          for (final ExpenseCategory c in active) DropdownMenuItem<String>(value: c.id, child: Text(c.name)),
                        ],
                        onChanged: _busy ? null : (String? id) => setState(() => _categoryId = id),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _amount,
                        enabled: !_busy,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                        decoration: InputDecoration(
                          labelText: context.l10n.expenseFormAmount,
                          errorText: _amount.text.isNotEmpty && !amountOk ? context.l10n.expenseFormEnterAmount : null,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: DropdownButtonFormField<PaymentMethod>(
                              initialValue: _method,
                              isExpanded: true,
                              decoration: InputDecoration(labelText: context.l10n.expenseFormMethod, border: const OutlineInputBorder()),
                              items: <DropdownMenuItem<PaymentMethod>>[
                                for (final PaymentMethod m in PaymentMethod.values) DropdownMenuItem<PaymentMethod>(value: m, child: Text(m.label)),
                              ],
                              onChanged: _busy ? null : (PaymentMethod? m) => setState(() => _method = m ?? _method),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _busy ? null : _pickDate,
                              icon: const Icon(Icons.calendar_today_outlined, size: 18),
                              label: Text(formatDate(_date)),
                              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                            ),
                          ),
                        ],
                      ),
                      if (_method.hasReference) ...<Widget>[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _reference,
                          enabled: !_busy,
                          decoration: InputDecoration(labelText: context.l10n.expenseFormReference, border: const OutlineInputBorder()),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextField(
                        controller: _payee,
                        enabled: !_busy,
                        decoration: InputDecoration(labelText: context.l10n.expenseFormPayee, border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _note,
                        enabled: !_busy,
                        maxLength: 500,
                        decoration: InputDecoration(labelText: context.l10n.expenseFormNote, border: const OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context, false), child: Text(context.l10n.expensesCancel)),
        FilledButton(
          onPressed: _busy || _categoryId == null || !amountOk ? null : _save,
          child: _busy
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(context.l10n.expenseFormSave),
        ),
      ],
    );
  }
}
