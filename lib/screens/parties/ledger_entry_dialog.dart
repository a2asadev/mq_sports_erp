import 'package:flutter/material.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/models/party_enums.dart';

/// Values entered in the "Add entry" dialog.
class LedgerEntryDraft {
  const LedgerEntryDraft({
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    required this.reference,
  });

  final LedgerEntryType type;
  final double amount;
  final DateTime date;
  final String description;
  final String reference;
}

Future<LedgerEntryDraft?> showLedgerEntryDialog(
  BuildContext context, {
  required PartyType partyType,
  LedgerEntryType initialType = LedgerEntryType.payment,
}) {
  return showDialog<LedgerEntryDraft>(
    context: context,
    builder: (BuildContext dialogContext) =>
        _LedgerEntryDialog(partyType: partyType, initialType: initialType),
  );
}

class _LedgerEntryDialog extends StatefulWidget {
  const _LedgerEntryDialog({required this.partyType, required this.initialType});

  final PartyType partyType;
  final LedgerEntryType initialType;

  @override
  State<_LedgerEntryDialog> createState() => _LedgerEntryDialogState();
}

class _LedgerEntryDialogState extends State<_LedgerEntryDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  late LedgerEntryType _type;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    super.dispose();
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

  void _save() {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    Navigator.of(context).pop(LedgerEntryDraft(
      type: _type,
      amount: double.parse(_amountController.text.trim()),
      date: _date,
      description: _descriptionController.text.trim(),
      reference: _referenceController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.ledgerEntryAddLedgerEntry),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SegmentedButton<LedgerEntryType>(
                  segments: <ButtonSegment<LedgerEntryType>>[
                    for (final LedgerEntryType type in LedgerEntryType.values)
                      ButtonSegment<LedgerEntryType>(
                        value: type,
                        label: Text(type.labelFor(widget.partyType)),
                      ),
                  ],
                  selected: <LedgerEntryType>{_type},
                  onSelectionChanged: (Set<LedgerEntryType> value) =>
                      setState(() => _type = value.first),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: context.l10n.ledgerEntryAmount),
                  validator: (String? value) {
                    final double? parsed = double.tryParse((value ?? '').trim());
                    return (parsed == null || parsed <= 0)
                        ? context.l10n.ledgerEntryEnterAnAmountGreater
                        : null;
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.ledgerEntryDate),
                  subtitle: Text(formatDate(_date)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _pickDate,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration:
                      InputDecoration(labelText: context.l10n.categoryFormDescriptionOptional),
                ),
                TextFormField(
                  controller: _referenceController,
                  decoration: InputDecoration(
                      labelText: context.l10n.ledgerEntryReferenceReceiptNoOptional),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.categoriesCancel),
        ),
        FilledButton(onPressed: _save, child: Text(context.l10n.ledgerEntrySaveEntry)),
      ],
    );
  }
}
