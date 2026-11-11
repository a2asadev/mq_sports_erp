import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/utils/error_text.dart';
import 'package:mq_sports_erp/core/utils/formatters.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/purchase_model.dart';
import 'package:mq_sports_erp/providers/sales_providers.dart';
import 'package:mq_sports_erp/screens/sales/order_detail_screen.dart';
import 'package:mq_sports_erp/screens/sales/order_form_screen.dart';
import 'package:mq_sports_erp/widgets/order_status_chip.dart';
import 'package:mq_sports_erp/widgets/purchase_status_chip.dart';

/// Order lifecycle list: every order with its pipeline status and payment
/// state. It reads from this device, so a status change shows up at once;
/// changes made on other devices arrive with the next sync.
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key, this.initialStatus});

  /// Opens with this status filter selected (used by the dashboard).
  final OrderStatus? initialStatus;

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String _query = '';
  late OrderStatus? _status = widget.initialStatus;
  OrderSaleType? _saleType;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<OrderModel>> async = ref.watch(ordersProvider);
    final Map<String, double> paid = ref.watch(orderPaidProvider);
    final bool canCreate = ref.watch(canCreateOrdersProvider);
    final ThemeData theme = Theme.of(context);

    ref.listen<AsyncValue<List<OrderModel>>>(ordersProvider,
        (AsyncValue<List<OrderModel>>? previous, AsyncValue<List<OrderModel>> next) {
      final Object? error = next.error;
      if (error != null && !identical(error, previous?.error)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
      }
    });

    final List<OrderModel>? loaded = async.valueOrNull;
    Widget body;
    if (loaded == null) {
      final Object? error = async.error;
      body = Center(
        child: error != null
            ? Text(errorMessageOf(error))
            : const CircularProgressIndicator(),
      );
    } else {
      final String q = _query.trim().toLowerCase();
      final List<OrderModel> orders = loaded.where((OrderModel o) {
        if (_status != null && o.status != _status) {
          return false;
        }
        if (_saleType != null && o.saleType != _saleType) {
          return false;
        }
        return q.isEmpty ||
            <String>[o.orderNo, o.customerName].join(' ').toLowerCase().contains(q);
      }).toList()
        ..sort((OrderModel a, OrderModel b) {
          final int byDate = b.orderDate.compareTo(a.orderDate);
          return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
        });

      double total = 0;
      double due = 0;
      for (final OrderModel o in orders) {
        if (o.status == OrderStatus.cancelled) {
          continue;
        }
        total += o.totalAmount;
        final double remaining = o.totalAmount - (paid[o.id] ?? 0);
        due += remaining > 0 ? remaining : 0;
      }

      body = Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search order no. or customer…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (String value) => setState(() => _query = value),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _status == null,
                    onSelected: (bool _) => setState(() => _status = null),
                  ),
                ),
                for (final OrderStatus status in OrderStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                          '${status.label} (${loaded.where((OrderModel o) => o.status == status).length})'),
                      selected: _status == status,
                      onSelected: (bool selected) =>
                          setState(() => _status = selected ? status : null),
                    ),
                  ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All types'),
                    selected: _saleType == null,
                    onSelected: (bool _) => setState(() => _saleType = null),
                  ),
                ),
                for (final OrderSaleType type in OrderSaleType.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(type.label),
                      selected: _saleType == type,
                      onSelected: (bool selected) =>
                          setState(() => _saleType = selected ? type : null),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${orders.length} order(s) · Total ${formatAmount(total)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Text(
                  'To collect ${formatAmount(due)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: due > 0.005 ? theme.colorScheme.error : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Text(loaded.isEmpty
                        ? 'No orders yet.'
                        : 'No orders match your search.'),
                  )
                : ListView.separated(
                    itemCount: orders.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final OrderModel order = orders[index];
                      final bool cancelled = order.status == OrderStatus.cancelled;
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.receipt_long_outlined),
                        ),
                        title: Text('${order.orderNo} · ${order.customerName}'),
                        subtitle: Text(
                          <String>[
                            formatDate(order.orderDate),
                            order.saleType.label,
                            '${order.items.length} item(s)',
                          ].join(' · '),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              formatAmount(order.totalAmount),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration:
                                    cancelled ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                OrderStatusChip(status: order.status),
                                if (!cancelled) ...<Widget>[
                                  const SizedBox(width: 4),
                                  PurchaseStatusChip(
                                    status: purchaseStatusFor(
                                        order.totalAmount, paid[order.id] ?? 0),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                OrderDetailScreen(orderId: order.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sales & Orders')),
      body: body,
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const OrderFormScreen(),
                ),
              ),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('New order'),
            )
          : null,
    );
  }
}
