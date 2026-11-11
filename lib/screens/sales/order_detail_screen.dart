import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/utils/error_text.dart';
import 'package:mq_sports_erp/core/utils/formatters.dart';
import 'package:mq_sports_erp/models/ledger_model.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/purchase_model.dart';
import 'package:mq_sports_erp/providers/parties_providers.dart';
import 'package:mq_sports_erp/providers/sales_providers.dart';
import 'package:mq_sports_erp/widgets/order_status_chip.dart';
import 'package:mq_sports_erp/widgets/purchase_status_chip.dart';

class _PaymentDraft {
  const _PaymentDraft(this.amount, this.date, this.note);

  final double amount;
  final DateTime date;
  final String note;
}

/// One order: pipeline progress, status history, items, totals and payments.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  Future<void> _recordPayment(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
    double due,
  ) async {
    final _PaymentDraft? draft = await showDialog<_PaymentDraft>(
      context: context,
      builder: (BuildContext dialogContext) => _PaymentDialog(due: due),
    );
    if (draft == null) {
      return;
    }
    await ref.read(ordersProvider.notifier).addPayment(
          order: order,
          amount: draft.amount,
          date: draft.date,
          note: draft.note,
        );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref, OrderModel order) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancel this order?'),
          content: Text(
            '${order.orderNo} will be cancelled. ${order.totalUnits} unit(s) go '
            'back into stock and the charge on ${order.customerName}\'s ledger '
            'is reversed. Money already received stays on the ledger as '
            'customer credit.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep order'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cancel order'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await ref.read(ordersProvider.notifier).cancelOrder(order);
    }
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

  /// Pending -> Processing -> Shipped -> Delivered, with the current step
  /// highlighted and the reached ones ticked.
  Widget _pipeline(BuildContext context, OrderModel order) {
    const List<OrderStatus> steps = <OrderStatus>[
      OrderStatus.pending,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];
    final ThemeData theme = Theme.of(context);
    final bool cancelled = order.status == OrderStatus.cancelled;
    final int currentIndex = steps.indexOf(order.status);
    return Row(
      children: <Widget>[
        for (int i = 0; i < steps.length; i++) ...<Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: cancelled
                      ? theme.colorScheme.surfaceContainerHighest
                      : (i <= currentIndex
                          ? OrderStatusChip.colorOf(context, steps[i])
                          : theme.colorScheme.surfaceContainerHighest),
                  child: Icon(
                    (!cancelled && i <= currentIndex) ? Icons.check : Icons.circle_outlined,
                    size: 16,
                    color: (!cancelled && i <= currentIndex)
                        ? Colors.white
                        : theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  steps[i].label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: (!cancelled && i == currentIndex)
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool canChange = ref.watch(canCreateOrdersProvider);
    final bool canCancel = ref.watch(canCancelOrdersProvider);
    final OrderModel? order =
        (ref.watch(ordersProvider).valueOrNull ?? <OrderModel>[])
            .where((OrderModel o) => o.id == orderId)
            .firstOrNull;
    final List<LedgerModel> ledger =
        ref.watch(ledgerEntriesProvider).valueOrNull ?? <LedgerModel>[];

    ref.listen<AsyncValue<List<OrderModel>>>(ordersProvider,
        (AsyncValue<List<OrderModel>>? previous, AsyncValue<List<OrderModel>> next) {
      final Object? error = next.error;
      if (error != null && !identical(error, previous?.error)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
      }
    });

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order')),
        body: const Center(child: Text('This order no longer exists.')),
      );
    }

    final bool cancelled = order.status == OrderStatus.cancelled;
    final List<LedgerModel> payments = ledger
        .where((LedgerModel e) =>
            e.orderId == order.id &&
            e.partyType == PartyType.customer &&
            e.entryType == LedgerEntryType.payment)
        .toList()
      ..sort((LedgerModel a, LedgerModel b) => b.entryDate.compareTo(a.entryDate));
    final double paid =
        payments.fold<double>(0, (double s, LedgerModel e) => s + e.amount);
    final double total = order.totalAmount;
    final double due = (total - paid) > 0 ? total - paid : 0;
    final OrderStatus? next = order.status.next;
    final List<OrderStatusEntry> history = order.statusHistory.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: Text(order.orderNo)),
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
                        child: Text(order.customerName,
                            style: theme.textTheme.titleLarge),
                      ),
                      OrderStatusChip(status: order.status),
                      if (!cancelled) ...<Widget>[
                        const SizedBox(width: 6),
                        PurchaseStatusChip(status: purchaseStatusFor(total, paid)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${formatDate(order.orderDate)} · ${order.saleType.label} sale'),
                  if (order.notes.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(order.notes),
                  ],
                  const SizedBox(height: 16),
                  _pipeline(context, order),
                  if (cancelled)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Cancelled. The stock was returned and the ledger charge reversed.',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  const Divider(height: 24),
                  _amountRow('Subtotal', formatAmount(order.subtotal)),
                  if (order.totalDiscount > 0.005)
                    _amountRow('Discounts (lines and order)',
                        '- ${formatAmount(order.totalDiscount)}'),
                  _amountRow('Total', formatAmount(total), bold: true),
                  if (!cancelled) ...<Widget>[
                    _amountRow('Paid', formatAmount(paid)),
                    _amountRow(
                      'Due',
                      formatAmount(due),
                      bold: due > 0.005,
                      color: due > 0.005 ? theme.colorScheme.error : null,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (canChange && next != null) ...<Widget>[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(ordersProvider.notifier).advanceStatus(order),
              icon: const Icon(Icons.arrow_forward),
              label: Text('Mark as ${next.label}'),
            ),
          ],
          if (canCancel && !order.status.isFinal) ...<Widget>[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _cancel(context, ref, order),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel order'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text('Status history', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No history recorded.'),
            )
          else
            for (final OrderStatusEntry entry in history)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.circle,
                    size: 12, color: OrderStatusChip.colorOf(context, entry.status)),
                title: Text(entry.status.label),
                subtitle: Text(
                  <String>[
                    '${formatDate(entry.changedAt)} '
                        '${TimeOfDay.fromDateTime(entry.changedAt.toLocal()).format(context)}',
                    if (entry.byName.isNotEmpty) 'by ${entry.byName}',
                  ].join(' · '),
                ),
              ),
          const SizedBox(height: 16),
          Text('Items (${order.items.length} · ${order.totalUnits} units)',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final OrderItem item in order.items)
            Card(
              child: ListTile(
                title: Text('${item.productName} · ${item.variantLabel}'),
                subtitle: Text(<String>[
                  'SKU ${item.sku}',
                  if (item.discount > 0.005) 'Discount ${formatAmount(item.discount)}',
                ].join(' · ')),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text('${item.quantity} × ${formatAmount(item.unitPrice)}'),
                    Text(formatAmount(item.lineTotal),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text('Payments', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (payments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No payments recorded yet.'),
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
      floatingActionButton: (canChange && !cancelled && due > 0.005)
          ? FloatingActionButton.extended(
              onPressed: () => _recordPayment(context, ref, order, due),
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Record payment'),
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
      title: const Text('Record payment'),
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
                labelText: 'Amount',
                helperText: 'Due: ${formatAmount(widget.due)}',
              ),
              validator: (String? value) {
                final double? parsed = double.tryParse((value ?? '').trim());
                if (parsed == null || parsed <= 0) {
                  return 'Enter an amount greater than zero.';
                }
                if (parsed > widget.due + 0.005) {
                  return 'More than the amount due.';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(formatDate(_date)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDate,
            ),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save payment')),
      ],
    );
  }
}
