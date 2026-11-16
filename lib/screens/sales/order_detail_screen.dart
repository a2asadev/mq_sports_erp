import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/utils/receipt.dart';
import 'package:mq_sports_erp/core/utils/whatsapp.dart';
import 'package:mq_sports_erp/models/payment_method.dart';
import 'package:mq_sports_erp/providers/business_provider.dart';
import 'package:mq_sports_erp/providers/pos_providers.dart';
import 'package:mq_sports_erp/widgets/receipt_actions.dart';
import 'package:mq_sports_erp/models/customer_model.dart';
import 'package:mq_sports_erp/providers/shop_name_provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
  const _PaymentDraft(this.amount, this.date, this.note, this.method, this.reference);

  final double amount;
  final DateTime date;
  final String note;
  final PaymentMethod method;
  final String reference;
}

/// One order: pipeline progress, status history, items, totals and payments.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  /// The customer's phone: from their record, else from the delivery details of a web order.
  String _phoneFor(WidgetRef ref, OrderModel order) {
    final List<CustomerModel> customers =
        ref.read(customersProvider).valueOrNull ?? <CustomerModel>[];
    for (final CustomerModel c in customers) {
      if (c.id == order.customerId && c.phone.trim().isNotEmpty) {
        return c.phone;
      }
    }
    final Match? found = RegExp(r'[+d][ds-]{8,}d').firstMatch(order.shippingAddress);
    return found?.group(0) ?? '';
  }

  /// Opens WhatsApp with a ready message; the person presses send.
  Future<void> _whatsApp(BuildContext context, WidgetRef ref, OrderModel order) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String shopName = await ref.read(shopNameProvider.future);
    final Uri? link = WhatsApp.link(_phoneFor(ref, order), WhatsApp.orderMessage(order, shopName: shopName));
    if (link == null) {
      messenger.showSnackBar(const SnackBar(
        content: Text('This customer has no usable phone number. Add one to their record.'),
      ));
      return;
    }
    bool opened = false;
    try {
      opened = await launchUrl(link, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      messenger.showSnackBar(const SnackBar(content: Text('WhatsApp could not be opened on this device.')));
    }
  }

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
          method: draft.method,
          paymentRef: draft.reference,
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
                  Text(
                      '${formatDate(order.orderDate)} · ${order.saleType.label} sale${order.isWebOrder ? ' · Online store' : ''}'),
                  if (order.shippingAddress.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(Icons.local_shipping_outlined, size: 18),
                        const SizedBox(width: 6),
                        Expanded(child: Text(order.shippingAddress)),
                      ],
                    ),
                  ],
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
                  if (order.shippingFee > 0.005)
                    _amountRow('Delivery', formatAmount(order.shippingFee)),
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
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _whatsApp(context, ref, order),
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Message on WhatsApp'),
          ),
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
          Text('Receipt', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ReceiptActions(
            receipt: ReceiptData.fromOrder(
              order,
              ledger: ledger,
              shopName: (ref.watch(shopInfoProvider).valueOrNull ?? const ShopInfo()).name,
              walkInCustomerId: ref.watch(businessProvider).walkInCustomerId,
              shopPhone: (ref.watch(shopInfoProvider).valueOrNull ?? const ShopInfo()).phone,
            ),
            phone: _phoneFor(ref, order),
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
                  subtitle: Text(<String>[
                    formatDate(payment.entryDate),
                    if (payment.paymentMethod.isNotEmpty) PaymentMethod.labelOf(payment.paymentMethod),
                    if (payment.paymentRef.isNotEmpty) payment.paymentRef,
                  ].join(' · ')),
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
  final TextEditingController _refController = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;
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
    _refController.dispose();
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
      _method,
      _refController.text.trim(),
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
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: <Widget>[
                for (final PaymentMethod m in PaymentMethod.values)
                  ChoiceChip(
                    label: Text(m.label),
                    selected: _method == m,
                    onSelected: (_) => setState(() => _method = m),
                  ),
              ],
            ),
            if (_method.hasReference)
              TextFormField(
                controller: _refController,
                decoration: InputDecoration(
                  labelText: _method == PaymentMethod.bank ? 'Bank and transaction no.' : 'Transaction no.',
                ),
                validator: (String? v) => (v == null || v.trim().isEmpty) ? 'Enter the transaction number.' : null,
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
