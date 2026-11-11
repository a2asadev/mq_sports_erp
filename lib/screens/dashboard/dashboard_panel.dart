import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/utils/formatters.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/providers/dashboard_providers.dart';
import 'package:mq_sports_erp/screens/sales/orders_screen.dart';
import 'package:mq_sports_erp/screens/stock/stock_screen.dart';

/// Executive dashboard shown at the top of the home screen for admins and
/// managers: sales, stock value, pending orders, low stock and top sellers.
/// Everything is calculated from this device's data, so it follows local work
/// at once and other devices' work after a sync.
class DashboardPanel extends ConsumerWidget {
  const DashboardPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(canViewDashboardProvider)) {
      return const SizedBox.shrink();
    }
    final DashboardStats stats = ref.watch(dashboardStatsProvider);
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Dashboard', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double width = constraints.maxWidth;
              final int columns = width >= 900 ? 4 : (width >= 560 ? 2 : 1);
              final double tileWidth = (width - (columns - 1) * 12) / columns;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  SizedBox(
                    width: tileWidth,
                    child: _MetricCard(
                      icon: Icons.payments_outlined,
                      title: 'Sales today',
                      value: formatAmount(stats.salesToday),
                      caption: '${stats.ordersToday} order(s)',
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _MetricCard(
                      icon: Icons.calendar_month_outlined,
                      title: 'Sales this month',
                      value: formatAmount(stats.salesMonth),
                      caption: '${stats.ordersMonth} order(s)',
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _MetricCard(
                      icon: Icons.pending_actions_outlined,
                      title: 'Pending orders',
                      value: '${stats.pendingOrders}',
                      caption: '${stats.processingOrders} processing · '
                          '${stats.shippedOrders} shipped',
                      highlight: stats.pendingOrders > 0,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const OrdersScreen(
                            initialStatus: OrderStatus.pending,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _MetricCard(
                      icon: Icons.notification_important_outlined,
                      title: 'Low stock',
                      value: '${stats.lowStockCount}',
                      caption: stats.lowStockCount == 0
                          ? 'Nothing at or below its alert level'
                          : 'item(s) at or below their alert level',
                      highlight: stats.lowStockCount > 0,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              const StockScreen(showLowStockOnly: true),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          _StockValueCard(stats: stats),
          const SizedBox(height: 12),
          const _TopSellersCard(),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.caption,
    this.highlight = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final String caption;
  final bool highlight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent =
        highlight ? Colors.orange.shade800 : theme.colorScheme.primary;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: accent.withValues(alpha: 0.12),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: theme.textTheme.bodySmall),
                    Text(
                      value,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(caption, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stock valuation: what the stock on hand cost and what it would sell for.
class _StockValueCard extends StatelessWidget {
  const _StockValueCard({required this.stats});

  final DashboardStats stats;

  Widget _figure(BuildContext context, String label, String value) {
    final ThemeData theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: theme.textTheme.bodySmall),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.warehouse_outlined),
                const SizedBox(width: 8),
                Text('Stock valuation', style: theme.textTheme.titleSmall),
                const Spacer(),
                Text('${stats.stockUnits} unit(s)', style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                _figure(context, 'At cost', formatAmount(stats.stockCostValue)),
                _figure(context, 'At retail', formatAmount(stats.stockRetailValue)),
                _figure(context, 'Potential margin', formatAmount(stats.potentialMargin)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Uses the catalog cost and sale prices of items with stock on hand.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopSellersCard extends ConsumerStatefulWidget {
  const _TopSellersCard();

  @override
  ConsumerState<_TopSellersCard> createState() => _TopSellersCardState();
}

class _TopSellersCardState extends ConsumerState<_TopSellersCard> {
  TopSellerPeriod _period = TopSellerPeriod.month;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<TopSeller> sellers = ref.watch(topSellersProvider(_period));
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.emoji_events_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Top selling products', style: theme.textTheme.titleSmall),
                ),
                SegmentedButton<TopSellerPeriod>(
                  showSelectedIcon: false,
                  segments: <ButtonSegment<TopSellerPeriod>>[
                    for (final TopSellerPeriod p in TopSellerPeriod.values)
                      ButtonSegment<TopSellerPeriod>(value: p, label: Text(p.label)),
                  ],
                  selected: <TopSellerPeriod>{_period},
                  onSelectionChanged: (Set<TopSellerPeriod> v) =>
                      setState(() => _period = v.first),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (sellers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No sales in this period yet.'),
              )
            else
              for (int i = 0; i < sellers.length; i++)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(radius: 14, child: Text('${i + 1}')),
                  title: Text(sellers[i].productName),
                  subtitle: Text('Revenue ${formatAmount(sellers[i].revenue)}'),
                  trailing: Text(
                    '${sellers[i].units} sold',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
