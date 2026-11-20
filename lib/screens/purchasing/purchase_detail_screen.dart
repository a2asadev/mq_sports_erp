import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/ledger_model.dart';
import 'package:a2_stocks/models/party_enums.dart';
import 'package:a2_stocks/models/purchase_model.dart';
import 'package:a2_stocks/providers/parties_providers.dart';
import 'package:a2_stocks/providers/purchasing_providers.dart';
import 'package:a2_stocks/widgets/purchase_status_chip.dart';

class _PaymentDraft {
  const _PaymentDraft(this.amount, this.date, this.note);

  final double amount;
  final DateTime date;
  final String note;
}

/// One purchase: items, totals, status and the payments made against it.
class PurchaseDetailScreen extends ConsumerWidget {
  const PurchaseDetailScreen({super.key, required this.purchaseId});

  final String purchaseId;

  Future<void> _recordPayment(
    BuildContext context,
    WidgetRef ref,
    PurchaseModel purchase,
    double due,
  ) async {
    final _PaymentDraft? draft = await showDialog<_PaymentDraft>(
      context: context,
      builder: (BuildContext dialogContext) => _PaymentDialog(due: due),
    );
    if (draft == null) {
      return;
    }
    await ref.read(purchasesProvider.notifier).addPayment(
          purchase: purchase,
          amount: draft.amount,
          date: draft.date,
          note: draft.note,
        );
  }

  Widget _amountRow(String label, String value, {bool bold = false, Color? color}) {
    final TextStyle style = TextStyle(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: color,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool canManage = ref.watch(canManagePurchasesProvider);
    final PurchaseModel? purchase =
        (ref.watch(purchasesProvider).valueOrNull ?? <PurchaseModel>[])
            .where((PurchaseModel p) => p.id == purchaseId)
            .firstOrNull;
    final List<LedgerModel> ledger =
        ref.watch(ledgerEntriesProvider).valueOrNull ?? <LedgerModel>[];

    ref.listen<AsyncValue<List<PurchaseModel>>>(purchasesProvider,
        (AsyncValue<List<PurchaseModel>>? previous,
            AsyncValue<List<PurchaseModel>> next) {
      final Object? error = next.error;
      if (error != null && !identical(error, previous?.error)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
      }
    });

    if (purchase == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.purchaseDetailPurchase)),
        body: Center(child: Text(context.l10n.purchaseDetailThisPurchaseNoLonger)),
      );
    }

    final List<LedgerModel> payments = ledger
        .where((LedgerModel e) =>
            e.purchaseId == purchase.id && e.entryType == LedgerEntryType.payment)
        .toList()
      ..sort((LedgerModel a, LedgerModel b) => b.entryDate.compareTo(a.entryDate));
    final double paid =
        payments.fold<double>(0, (double s, LedgerModel e) => s + e.amount);
    final double total = purchase.totalAmount;
    final double due = (total - paid) > 0 ? total - paid : 0;
    final PurchaseStatus status = purchaseStatusFor(total, paid);

    return Scaffold(
      appBar: AppBar(title: Text(purchase.purchaseNo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(purchase.vendorName,
                            style: theme.textTheme.titleLarge),
                      ),
                      PurchaseStatusChip(status: status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(<String>[
                    formatDate(purchase.purchaseDate),
                    if (purchase.invoiceNo.isNotEmpty) context.l10n.purchaseDetailInvoice(purchase.invoiceNo),
                  ].join(' · ')),
                  if (purchase.notes.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(purchase.notes),
                  ],
                  const Divider(height: 24),
                  _amountRow(context.l10n.orderReceiptCardTotal, formatAmount(total), bold: true),
                  _amountRow(context.l10n.purchaseDetailPaid, formatAmount(paid)),
                  _amountRow(
                    context.l10n.purchaseDetailDue2,
                    formatAmount(due),
                    bold: due > 0.005,
                    color: due > 0.005 ? theme.colorScheme.error : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(context.l10n.purchaseDetailItemsUnits(purchase.items.length, purchase.totalUnits),
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final PurchaseItem item in purchase.items)
            Card(
              child: ListTile(
                title: Text('${item.productName} · ${item.variantLabel}'),
                subtitle: Text(context.l10n.purchaseDetailSku(item.sku)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text('${item.quantity} × ${formatAmount(item.unitCost)}'),
                    Text(formatAmount(item.lineTotal),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(context.l10n.purchaseDetailPayments, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (payments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(context.l10n.purchaseDetailNoPaymentsRecordedYet),
            )
          else
            for (final LedgerModel payment in payments)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: Text(payment.description),
                  subtitle: Text(formatDate(payment.entryDate)),
                  trailing: Text(formatAmount(payment.amount),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: (canManage && due > 0.005)
          ? FloatingActionButton.extended(
              onPressed: () => _recordPayment(context, ref, purchase, due),
              icon: const Icon(Icons.payments_outlined),
              label: Text(context.l10n.purchaseDetailRecordPayment),
            )
          : null,
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.due});

  final double due;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final TextEditingController _noteController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: formatAmount(widget.due));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
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
    Navigator.of(context).pop(_PaymentDraft(
      double.parse(_amountController.text.trim()),
      _date,
      _noteController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.purchaseDetailRecordPayment),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: context.l10n.ledgerEntryAmount,
                helperText: context.l10n.purchaseDetailDue(formatAmount(widget.due)),
              ),
              validator: (String? value) {
                final double? parsed = double.tryParse((value ?? '').trim());
                if (parsed == null || parsed <= 0) {
                  return context.l10n.ledgerEntryEnterAnAmountGreater;
                }
                if (parsed > widget.due + 0.005) {
                  return context.l10n.purchaseDetailMoreThanTheAmount;
                }
                return null;
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
              controller: _noteController,
              decoration: InputDecoration(labelText: context.l10n.purchaseDetailNoteOptional),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.categoriesCancel),
        ),
        FilledButton(onPressed: _save, child: Text(context.l10n.purchaseDetailSavePayment)),
      ],
    );
  }
}
