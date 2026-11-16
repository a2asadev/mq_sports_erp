import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/core/utils/page_stats.dart';
import 'package:a2_stocks/widgets/stat_strip.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/providers/sales_providers.dart';
import 'package:a2_stocks/screens/sales/order_detail_screen.dart';
import 'package:a2_stocks/screens/sales/order_form_screen.dart';
import 'package:a2_stocks/widgets/order_receipt_card.dart';

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

      final OrderStats stats = computeOrderStats(loaded, paid, DateTime.now());

      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          StatStrip(
            items: <StatItem>[
              StatItem(
                icon: Icons.today_outlined,
                color: AppColors.primary,
                label: 'Sales today',
                value: formatMoney(stats.todaySales),
                caption: '${stats.todayCount} order(s)',
              ),
              StatItem(
                icon: Icons.payments_outlined,
                color: AppColors.teal,
                label: 'Total sales',
                value: formatMoney(stats.sales),
                caption: '${stats.count} order(s)',
              ),
              StatItem(
                icon: Icons.account_balance_wallet_outlined,
                color: stats.toCollect > 0.005 ? AppColors.amber : AppColors.textMuted,
                label: 'To collect',
                value: formatMoney(stats.toCollect),
              ),
              StatItem(
                icon: Icons.pending_actions_outlined,
                color: AppColors.sky,
                label: 'Open orders',
                value: '${stats.openCount}',
                caption: 'not yet delivered',
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              '${orders.length} of ${loaded.length} order(s) shown',
              style: theme.textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Text(loaded.isEmpty
                        ? 'No orders yet.'
                        : 'No orders match your search.'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 360,
                      mainAxisExtent: 318,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                    ),
                    itemCount: orders.length,
                    itemBuilder: (BuildContext context, int index) {
                      final OrderModel order = orders[index];
                      return OrderReceiptCard(
                        order: order,
                        paid: paid[order.id] ?? 0,
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
