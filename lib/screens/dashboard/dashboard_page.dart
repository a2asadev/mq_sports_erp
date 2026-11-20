import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/erp_module.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/providers/dashboard_insights.dart';
import 'package:a2_stocks/providers/dashboard_providers.dart';
import 'package:a2_stocks/providers/module_registry_provider.dart';
import 'package:a2_stocks/providers/users_providers.dart';
import 'package:a2_stocks/screens/sales/orders_screen.dart';
import 'package:a2_stocks/screens/stock/stock_screen.dart';
import 'package:a2_stocks/widgets/photo_widgets.dart';

/// What the shell shows first. Admins and managers get the executive
/// dashboard; staff get a welcome with shortcuts to what they may open.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key, required this.onOpenModule});

  final ValueChanged<ErpModule> onOpenModule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool full = ref.watch(canViewDashboardProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: full ? const _ExecutiveDashboard() : _Shortcuts(onOpenModule: onOpenModule),
    );
  }
}

String _firstName(UserModel? user) {
  if (user == null) {
    return '';
  }
  final String name = user.displayName.isNotEmpty ? user.displayName : user.email.split('@').first;
  return name.split(' ').first;
}

String _today(BuildContext context) => formatLongDate(context, DateTime.now());

/// Lays [children] out in [columns] equal columns.
class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.children});

  final int columns;
  final List<Widget> children;
  static const double gap = 16;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double width = (box.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[for (final Widget c in children) SizedBox(width: width, child: c)],
        );
      },
    );
  }
}

class _Shortcuts extends ConsumerWidget {
  const _Shortcuts({required this.onOpenModule});

  final ValueChanged<ErpModule> onOpenModule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
    final List<ErpModule> modules = ref.watch(visibleModulesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(context.l10n.dashboardWelcome(_firstName(user)), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        Text(_today(context), style: const TextStyle(color: AppColors.textMuted)),
        const SizedBox(height: 16),
        if (modules.isEmpty)
          Text(context.l10n.dashboardNoModulesAvailableFor)
        else
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) => _Grid(
              columns: box.maxWidth >= 900 ? 4 : (box.maxWidth >= 560 ? 3 : 2),
              children: <Widget>[
                for (final ErpModule m in modules)
                  Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      onTap: () => onOpenModule(m),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(m.icon, size: 28, color: AppColors.primary),
                            ),
                            const SizedBox(height: 10),
                            Text(m.title(context.l10n), style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ExecutiveDashboard extends ConsumerWidget {
  const _ExecutiveDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DashboardStats stats = ref.watch(dashboardStatsProvider);
    final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
    final List<LowStockItem> low = ref.watch(lowStockItemsProvider);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double w = box.maxWidth;
        final int four = w >= 1100 ? 4 : (w >= 640 ? 2 : 1);
        final int three = w >= 1100 ? 3 : (w >= 760 ? 2 : 1);
        final bool split = w >= 1100;

        void openOrders() => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const OrdersScreen(initialStatus: OrderStatus.pending),
              ),
            );
        void openLowStock() => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const StockScreen(showLowStockOnly: true),
              ),
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              context.l10n.dashboardWelcome(_firstName(user)),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              context.l10n.dashboardYouHaveOrderS(stats.ordersToday, _today(context)),
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            if (low.isNotEmpty) _LowStockBanner(item: low.first, total: stats.lowStockCount, onTap: openLowStock),
            _Grid(
              columns: four,
              children: <Widget>[
                _ColorStat(
                  color: AppColors.primary,
                  icon: Icons.payments_outlined,
                  title: context.l10n.dashboardSalesToday,
                  value: formatMoney(stats.salesToday),
                  caption: context.l10n.dashboardOrderS3(stats.ordersToday),
                ),
                _ColorStat(
                  color: AppColors.navy,
                  icon: Icons.calendar_month_outlined,
                  title: context.l10n.dashboardSalesThisMonth,
                  value: formatMoney(stats.salesMonth),
                  caption: context.l10n.dashboardOrderS2(stats.ordersMonth),
                ),
                _ColorStat(
                  color: AppColors.teal,
                  icon: Icons.pending_actions_outlined,
                  title: context.l10n.dashboardPendingOrders,
                  value: '${stats.pendingOrders}',
                  caption: context.l10n.dashboardProcessingShipped(stats.processingOrders, stats.shippedOrders),
                  onTap: openOrders,
                ),
                _ColorStat(
                  color: AppColors.sky,
                  icon: Icons.notification_important_outlined,
                  title: context.l10n.dashboardLowStock,
                  value: '${stats.lowStockCount}',
                  caption: stats.lowStockCount == 0 ? context.l10n.dashboardAllAboveAlertLevel : context.l10n.dashboardAtOrBelowAlert,
                  onTap: openLowStock,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Grid(
              columns: four,
              children: <Widget>[
                _SoftStat(
                  icon: Icons.inventory_2_outlined,
                  tint: AppColors.skySoft,
                  accent: AppColors.sky,
                  value: formatMoney(stats.stockCostValue),
                  label: context.l10n.dashboardStockAtCost,
                ),
                _SoftStat(
                  icon: Icons.sell_outlined,
                  tint: AppColors.primarySoft,
                  accent: AppColors.primary,
                  value: formatMoney(stats.stockRetailValue),
                  label: context.l10n.dashboardStockAtRetail,
                ),
                _SoftStat(
                  icon: Icons.trending_up,
                  tint: AppColors.tealSoft,
                  accent: AppColors.teal,
                  value: formatMoney(stats.potentialMargin),
                  label: context.l10n.dashboardPotentialMargin,
                ),
                _SoftStat(
                  icon: Icons.layers_outlined,
                  tint: AppColors.amberSoft,
                  accent: AppColors.amber,
                  value: '${stats.stockUnits}',
                  label: context.l10n.dashboardUnitsInStock,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (split)
              const IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(flex: 2, child: _SalesChartCard()),
                    SizedBox(width: 16),
                    Expanded(child: _OverallCard()),
                  ],
                ),
              )
            else ...<Widget>[
              const _SalesChartCard(),
              const SizedBox(height: 16),
              const _OverallCard(),
            ],
            const SizedBox(height: 16),
            const _CustomerMixCard(),
            const SizedBox(height: 16),
            _Grid(
              columns: three,
              children: const <Widget>[_TopSellingCard(), _LowStockCard(), _RecentSalesCard()],
            ),
            const SizedBox(height: 16),
            _Grid(
              columns: three == 1 ? 1 : 2,
              children: const <Widget>[_TopCustomersCard(), _TopCategoriesCard()],
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _LowStockBanner extends StatefulWidget {
  const _LowStockBanner({required this.item, required this.total, required this.onTap});

  final LowStockItem item;
  final int total;
  final VoidCallback onTap;

  @override
  State<_LowStockBanner> createState() => _LowStockBannerState();
}

class _LowStockBannerState extends State<_LowStockBanner> {
  bool _closed = false;

  @override
  Widget build(BuildContext context) {
    if (_closed) {
      return const SizedBox.shrink();
    }
    final String more = widget.total > 1 ? context.l10n.dashboardAndMore(widget.total - 1) : '';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: context.l10n.dashboardRunningLow),
                  TextSpan(
                    text: '${widget.item.productName} ${widget.item.variantLabel}'.trim(),
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                  ),
                  TextSpan(text: context.l10n.dashboardHasLeft(widget.item.onHand, more)),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: InkWell(
                      onTap: widget.onTap,
                      child: Text(
                        context.l10n.dashboardViewStock,
                        style: const TextStyle(fontWeight: FontWeight.w700, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _closed = true),
          ),
        ],
      ),
    );
  }
}

class _ColorStat extends StatelessWidget {
  const _ColorStat({
    required this.color,
    required this.icon,
    required this.title,
    required this.value,
    required this.caption,
    this.onTap,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String value;
  final String caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftStat extends StatelessWidget {
  const _SoftStat({
    required this.icon,
    required this.tint,
    required this.accent,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color tint;
  final Color accent;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 2),
                  Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: accent, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

/// A white card with an icon, a title, an optional control on the right and a
/// divider before the content.
class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.accent,
    required this.tint,
    required this.title,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final Color accent;
  final Color tint;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: <Widget>[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 16, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const Divider(),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text(text, style: const TextStyle(color: AppColors.textMuted))),
      );
}

/// Small image or initial in a rounded square.
class _Thumb extends StatelessWidget {
  const _Thumb({required this.url});

  final String url;
  static const double size = 44;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: size,
        height: size,
        color: AppColors.mutedFill,
        child: NetworkPhoto(url: url, size: size, placeholder: Icons.inventory_2_outlined),
      ),
    );
  }
}

// ---- sales chart ------------------------------------------------------------

class _SalesChartCard extends ConsumerStatefulWidget {
  const _SalesChartCard();

  @override
  ConsumerState<_SalesChartCard> createState() => _SalesChartCardState();
}

class _SalesChartCardState extends ConsumerState<_SalesChartCard> {
  SalesRange _range = SalesRange.week;

  @override
  Widget build(BuildContext context) {
    final List<SalesBucket> data = ref.watch(salesSeriesProvider(_range));
    final double total = data.fold<double>(0, (double s, SalesBucket b) => s + b.amount);
    final double maxY = data.fold<double>(0, (double m, SalesBucket b) => b.amount > m ? b.amount : m);
    final double ceiling = maxY <= 0 ? 100 : maxY * 1.15;
    final bool dense = data.length > 12;

    return _Section(
      icon: Icons.bar_chart_rounded,
      accent: AppColors.primary,
      tint: AppColors.primarySoft,
      title: context.l10n.dashboardSales,
      trailing: _RangePills(value: _range, onChanged: (SalesRange r) => setState(() => _range = r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircleAvatar(radius: 4, backgroundColor: AppColors.primary),
                const SizedBox(width: 8),
                Text(context.l10n.dashboardTotalSales, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                Text(formatMoney(total), style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                maxY: ceiling,
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: _gridLine,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (double v, TitleMeta meta) => v == meta.max
                          ? const SizedBox.shrink()
                          : Text(
                              formatCompact(v),
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (double v, TitleMeta meta) {
                        final int i = v.toInt();
                        if (i < 0 || i >= data.length || (dense && data.length > 12 && i % 5 != 0)) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            data[i].label,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (BarChartGroupData g) => AppColors.navy,
                    getTooltipItem: (BarChartGroupData g, int gi, BarChartRodData rod, int ri) =>
                        BarTooltipItem(
                      '${data[gi].label}\n${formatMoney(rod.toY)}',
                      const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                barGroups: <BarChartGroupData>[
                  for (int i = 0; i < data.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: <BarChartRodData>[
                        BarChartRodData(
                          toY: data[i].amount,
                          width: dense ? 7 : 18,
                          color: AppColors.primary,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: ceiling,
                            color: AppColors.primarySoft,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

FlLine _gridLine(double value) => const FlLine(color: AppColors.border, strokeWidth: 1, dashArray: <int>[4, 4]);

/// The 1W / 1M / 1Y switch in the corner of a chart card.
class _RangePills extends StatelessWidget {
  const _RangePills({required this.value, required this.onChanged});

  final SalesRange value;
  final ValueChanged<SalesRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final SalesRange r in SalesRange.values)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => onChanged(r),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: value == r ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  r.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: value == r ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---- new vs returning customers ---------------------------------------------

class _CustomerMixCard extends ConsumerStatefulWidget {
  const _CustomerMixCard();

  @override
  ConsumerState<_CustomerMixCard> createState() => _CustomerMixCardState();
}

class _CustomerMixCardState extends ConsumerState<_CustomerMixCard> {
  SalesRange _range = SalesRange.week;

  static const Color _newColor = AppColors.teal;
  static const Color _returningColor = AppColors.navy;

  Widget _figure(String value, String label, Color color, {String caption = ''}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(radius: 4, backgroundColor: color),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          if (caption.isNotEmpty) Text(caption, style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CustomerMix mix = ref.watch(customerMixProvider(_range));
    final int peak = mix.buckets.fold<int>(
        0, (int m, CustomerMixBucket b) => <int>[m, b.newCustomers, b.returningCustomers].reduce((int a, int c) => a > c ? a : c));
    final double ceiling = peak <= 0 ? 4 : (peak + 1).toDouble();
    final bool dense = mix.buckets.length > 12;

    return _Section(
      icon: Icons.people_alt_outlined,
      accent: AppColors.teal,
      tint: const Color(0xFFE3EFEC),
      title: context.l10n.dashboardNewVsReturningCustomers,
      trailing: _RangePills(value: _range, onChanged: (SalesRange r) => setState(() => _range = r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _figure('${mix.newCustomers}', context.l10n.dashboardNewCustomers, _newColor, caption: context.l10n.dashboardFirstOrderInThis),
              _figure(
                '${mix.returningCustomers}',
                context.l10n.dashboardReturningCustomers,
                _returningColor,
                caption: mix.customers == 0 ? '' : context.l10n.dashboardOfBuyers(mix.returningPercent),
              ),
              _figure(
                '${mix.walkInOrders}',
                context.l10n.dashboardWalkInOrders,
                AppColors.amber,
                caption: mix.walkInOrders == 0 ? '' : formatMoney(mix.walkInSales),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: mix.customers == 0
                ? _Empty(context.l10n.dashboardNoNamedCustomersBought)
                : BarChart(
                    BarChartData(
                      maxY: ceiling,
                      alignment: BarChartAlignment.spaceAround,
                      gridData: const FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: _gridLine),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: ceiling <= 8 ? 1 : null,
                            getTitlesWidget: (double v, TitleMeta meta) => v == meta.max || v != v.roundToDouble()
                                ? const SizedBox.shrink()
                                : Text(
                                    '${v.toInt()}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            getTitlesWidget: (double v, TitleMeta meta) {
                              final int i = v.toInt();
                              if (i < 0 || i >= mix.buckets.length || (dense && i % 5 != 0)) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  mix.buckets[i].label,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (BarChartGroupData g) => AppColors.navy,
                          getTooltipItem: (BarChartGroupData g, int gi, BarChartRodData rod, int ri) => BarTooltipItem(
                            '${mix.buckets[gi].label}\n${ri == 0 ? 'New' : 'Returning'}: ${rod.toY.toInt()}',
                            const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      barGroups: <BarChartGroupData>[
                        for (int i = 0; i < mix.buckets.length; i++)
                          BarChartGroupData(
                            x: i,
                            barsSpace: 2,
                            barRods: <BarChartRodData>[
                              BarChartRodData(
                                toY: mix.buckets[i].newCustomers.toDouble(),
                                width: dense ? 4 : 10,
                                color: _newColor,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                              ),
                              BarChartRodData(
                                toY: mix.buckets[i].returningCustomers.toDouble(),
                                width: dense ? 4 : 10,
                                color: _returningColor,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.dashboardWalkInSalesHave,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ---- overall information ----------------------------------------------------

class _OverallCard extends ConsumerWidget {
  const _OverallCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OverallCounts c = ref.watch(overallCountsProvider);
    Widget tile(IconData icon, Color accent, Color tint, String label, int value) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: <Widget>[
                Icon(icon, color: accent),
                const SizedBox(height: 6),
                Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                Text('$value', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ],
            ),
          ),
        );
    return _Section(
      icon: Icons.info_outline,
      accent: AppColors.sky,
      tint: AppColors.skySoft,
      title: context.l10n.dashboardOverallInformation,
      child: Row(
        children: <Widget>[
          tile(Icons.local_shipping_outlined, AppColors.sky, AppColors.skySoft, context.l10n.vendorsVendors, c.vendors),
          const SizedBox(width: 10),
          tile(Icons.groups_outlined, AppColors.primary, AppColors.primarySoft, context.l10n.onboardingContentCustomers, c.customers),
          const SizedBox(width: 10),
          tile(Icons.shopping_cart_outlined, AppColors.teal, AppColors.tealSoft, context.l10n.dashboardOrders, c.orders),
        ],
      ),
    );
  }
}

// ---- lists ------------------------------------------------------------------

class _TopSellingCard extends ConsumerStatefulWidget {
  const _TopSellingCard();

  @override
  ConsumerState<_TopSellingCard> createState() => _TopSellingCardState();
}

class _TopSellingCardState extends ConsumerState<_TopSellingCard> {
  TopSellerPeriod _period = TopSellerPeriod.month;

  @override
  Widget build(BuildContext context) {
    final List<TopSeller> sellers = ref.watch(topSellersProvider(_period));
    return _Section(
      icon: Icons.emoji_events_outlined,
      accent: AppColors.primary,
      tint: AppColors.primarySoft,
      title: context.l10n.dashboardTopSelling,
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<TopSellerPeriod>(
          value: _period,
          isDense: true,
          style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppColors.text, fontWeight: FontWeight.w600),
          items: <DropdownMenuItem<TopSellerPeriod>>[
            for (final TopSellerPeriod p in TopSellerPeriod.values)
              DropdownMenuItem<TopSellerPeriod>(value: p, child: Text(p.label)),
          ],
          onChanged: (TopSellerPeriod? p) => setState(() => _period = p ?? _period),
        ),
      ),
      child: sellers.isEmpty
          ? _Empty(context.l10n.dashboardNoSalesInThis)
          : Column(
              children: <Widget>[
                for (int i = 0; i < sellers.length; i++)
                  _ListRow(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primarySoft,
                      child: Text('${i + 1}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                    ),
                    title: sellers[i].productName,
                    subtitle: formatMoney(sellers[i].revenue),
                    trailing: context.l10n.dashboardSold(sellers[i].units),
                    last: i == sellers.length - 1,
                  ),
              ],
            ),
    );
  }
}

class _LowStockCard extends ConsumerWidget {
  const _LowStockCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<LowStockItem> items = ref.watch(lowStockItemsProvider);
    return _Section(
      icon: Icons.warning_amber_rounded,
      accent: AppColors.amber,
      tint: AppColors.amberSoft,
      title: context.l10n.dashboardLowStock,
      trailing: TextButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (BuildContext context) => const StockScreen(showLowStockOnly: true)),
        ),
        child: Text(context.l10n.dashboardViewAll),
      ),
      child: items.isEmpty
          ? _Empty(context.l10n.dashboardNothingIsRunningLow)
          : Column(
              children: <Widget>[
                for (int i = 0; i < items.length; i++)
                  _ListRow(
                    leading: _Thumb(url: items[i].imageUrl),
                    title: items[i].productName,
                    subtitle: '${items[i].variantLabel} · ${items[i].sku}',
                    trailing: context.l10n.dashboardLeft(items[i].onHand),
                    trailingColor: items[i].onHand <= 0 ? AppColors.danger : AppColors.amber,
                    last: i == items.length - 1,
                  ),
              ],
            ),
    );
  }
}

class _RecentSalesCard extends ConsumerWidget {
  const _RecentSalesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<OrderModel> orders = ref.watch(recentSalesProvider);
    return _Section(
      icon: Icons.receipt_long_outlined,
      accent: AppColors.sky,
      tint: AppColors.skySoft,
      title: context.l10n.dashboardRecentSales,
      child: orders.isEmpty
          ? _Empty(context.l10n.dashboardNoSalesYet)
          : Column(
              children: <Widget>[
                for (int i = 0; i < orders.length; i++)
                  _ListRow(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.skySoft,
                      child: Icon(
                        orders[i].channel == 'pos' ? Icons.point_of_sale : Icons.shopping_bag_outlined,
                        size: 18,
                        color: AppColors.sky,
                      ),
                    ),
                    title: orders[i].customerName.isEmpty ? context.l10n.dashboardWalkInCustomer : orders[i].customerName,
                    subtitle: '${orders[i].orderNo} · ${formatDate(orders[i].orderDate)}',
                    trailing: formatMoney(orders[i].totalAmount),
                    badge: orders[i].status,
                    last: i == orders.length - 1,
                  ),
              ],
            ),
    );
  }
}

class _TopCustomersCard extends ConsumerWidget {
  const _TopCustomersCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TopCustomer> list = ref.watch(topCustomersProvider);
    return _Section(
      icon: Icons.groups_outlined,
      accent: AppColors.primary,
      tint: AppColors.primarySoft,
      title: context.l10n.dashboardTopCustomers,
      child: list.isEmpty
          ? _Empty(context.l10n.dashboardNoNamedCustomersHave)
          : Column(
              children: <Widget>[
                for (int i = 0; i < list.length; i++)
                  _ListRow(
                    leading: PhotoAvatar(url: '', label: list[i].name, radius: 18),
                    title: list[i].name,
                    subtitle: context.l10n.dashboardOrderS(list[i].orders),
                    trailing: formatMoney(list[i].total),
                    last: i == list.length - 1,
                  ),
              ],
            ),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.last,
    this.trailingColor,
    this.badge,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final String trailing;
  final Color? trailingColor;
  final OrderStatus? badge;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: AppColors.border, style: BorderStyle.solid)),
      ),
      child: Row(
        children: <Widget>[
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                trailing,
                style: TextStyle(fontWeight: FontWeight.w800, color: trailingColor, fontSize: 13),
              ),
              if (badge != null) _StatusPill(status: badge!),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      OrderStatus.pending => AppColors.amber,
      OrderStatus.processing => AppColors.violet,
      OrderStatus.shipped => AppColors.sky,
      OrderStatus.delivered => AppColors.teal,
      OrderStatus.cancelled => AppColors.danger,
    };
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status.label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

// ---- categories donut -------------------------------------------------------

class _TopCategoriesCard extends ConsumerWidget {
  const _TopCategoriesCard();

  // Not const: the first colour is the business's own accent.
  static List<Color> get _palette => <Color>[
    AppColors.primary,
    AppColors.navy,
    AppColors.sky,
    AppColors.teal,
    AppColors.amber,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CategoryShare> shares = ref.watch(categorySharesProvider);
    final double total = shares.fold<double>(0, (double s, CategoryShare c) => s + c.revenue);
    return _Section(
      icon: Icons.donut_large_outlined,
      accent: AppColors.violet,
      tint: const Color(0xFFE9E7F3),
      title: context.l10n.dashboardTopCategories,
      child: shares.isEmpty || total <= 0
          ? _Empty(context.l10n.dashboardNoCategorySalesYet)
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints box) {
                final Widget donut = SizedBox(
                  width: 170,
                  height: 170,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 46,
                      sections: <PieChartSectionData>[
                        for (int i = 0; i < shares.length; i++)
                          PieChartSectionData(
                            value: shares[i].revenue,
                            color: _palette[i % _palette.length],
                            radius: 26,
                            showTitle: false,
                          ),
                      ],
                    ),
                  ),
                );
                final Widget legend = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (int i = 0; i < shares.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _palette[i % _palette.length],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(shares[i].name, overflow: TextOverflow.ellipsis),
                            ),
                            Text(
                              '${(shares[i].revenue / total * 100).round()}%',
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
                if (box.maxWidth < 380) {
                  return Column(children: <Widget>[donut, const SizedBox(height: 12), legend]);
                }
                return Row(
                  children: <Widget>[donut, const SizedBox(width: 20), Expanded(child: legend)],
                );
              },
            ),
    );
  }
}
