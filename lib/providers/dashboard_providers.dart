import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/utils/stock_alerts.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';
import 'package:a2_stocks/providers/sales_providers.dart';
import 'package:a2_stocks/providers/stock_providers.dart';
import 'package:a2_stocks/providers/users_providers.dart';

/// Period of the top-sellers list.
enum TopSellerPeriod {
  today,
  month;

  String get label => this == TopSellerPeriod.today ? L10n.current.dashboardToday : L10n.current.dashboardThisMonth;
}

/// One product in the top-sellers list.
class TopSeller {
  const TopSeller({
    required this.productId,
    required this.productName,
    required this.units,
    required this.revenue,
  });

  final String productId;
  final String productName;
  final int units;
  final double revenue;
}

/// Everything the executive dashboard shows, except the top sellers.
class DashboardStats {
  const DashboardStats({
    required this.salesToday,
    required this.ordersToday,
    required this.salesMonth,
    required this.ordersMonth,
    required this.pendingOrders,
    required this.processingOrders,
    required this.shippedOrders,
    required this.stockCostValue,
    required this.stockRetailValue,
    required this.stockUnits,
    required this.lowStockCount,
    this.costOfSalesMonth = 0,
  });

  final double salesToday;
  final int ordersToday;
  final double salesMonth;
  final int ordersMonth;
  final int pendingOrders;
  final int processingOrders;
  final int shippedOrders;

  /// Stock on hand at catalog cost price.
  final double stockCostValue;

  /// Stock on hand at catalog retail (sale) price.
  final double stockRetailValue;
  final int stockUnits;
  final int lowStockCount;

  /// What the goods sold this month cost, at today's catalog cost prices. An estimate: the cost
  /// price of a product may have changed since, and returned goods are not taken off yet.
  final double costOfSalesMonth;

  /// Sales less the cost of the goods sold this month, before expenses.
  double get grossProfitMonth => salesMonth - costOfSalesMonth;

  /// What the stock would earn above its cost if sold at the retail price.
  double get potentialMargin => stockRetailValue - stockCostValue;
}

double _round2(double value) => (value * 100).round() / 100;

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool _sameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

/// Pure calculation of the dashboard numbers, so it can be tested.
///
/// - Sales: orders that are not cancelled, by order date, at their total
///   after discounts.
/// - Stock value: only positive stock counts (negative stock is a
///   discrepancy, not an asset), at the catalog cost and sale price.
/// - Low stock: active variants with an alert level at or below it.
DashboardStats computeDashboardStats({
  required List<OrderModel> orders,
  required List<ProductModel> products,
  required Map<String, int> onHand,
  required DateTime now,
}) {
  double salesToday = 0;
  int ordersToday = 0;
  double salesMonth = 0;
  double costOfSalesMonth = 0;
  final Map<String, double> costOf = <String, double>{
    for (final ProductModel p in products)
      for (final VariantModel v in p.variants) v.id: v.costPrice,
  };
  int ordersMonth = 0;
  int pending = 0;
  int processing = 0;
  int shipped = 0;
  for (final OrderModel order in orders) {
    switch (order.status) {
      case OrderStatus.pending:
        pending++;
      case OrderStatus.processing:
        processing++;
      case OrderStatus.shipped:
        shipped++;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        break;
    }
    if (order.status == OrderStatus.cancelled) {
      continue;
    }
    final DateTime date = order.orderDate.toLocal();
    if (_sameMonth(date, now)) {
      // Tax is not income: sales are what was sold, before tax.
      final double sale = order.totalAmount - order.taxAmount;
      salesMonth += sale;
      for (final OrderItem item in order.items) {
        costOfSalesMonth += item.quantity * (costOf[item.variantId] ?? 0);
      }
      ordersMonth++;
      if (_sameDay(date, now)) {
        salesToday += sale;
        ordersToday++;
      }
    }
  }

  double cost = 0;
  double retail = 0;
  int units = 0;
  int low = 0;
  for (final ProductModel product in products) {
    for (final VariantModel variant in product.variants) {
      final int qty = onHand[variant.id] ?? 0;
      if (qty > 0) {
        cost += qty * variant.costPrice;
        retail += qty * variant.salePrice;
        units += qty;
      }
      if (product.isActive &&
          variant.isActive &&
          isLowStock(qty, variant.alertThreshold)) {
        low++;
      }
    }
  }

  return DashboardStats(
    salesToday: _round2(salesToday),
    ordersToday: ordersToday,
    salesMonth: _round2(salesMonth),
    ordersMonth: ordersMonth,
    pendingOrders: pending,
    processingOrders: processing,
    shippedOrders: shipped,
    stockCostValue: _round2(cost),
    stockRetailValue: _round2(retail),
    stockUnits: units,
    lowStockCount: low,
    costOfSalesMonth: _round2(costOfSalesMonth),
  );
}

/// Best selling products by units sold (revenue breaks ties), from orders that
/// are not cancelled and fall in [period]. Revenue is the sum of the line
/// totals, so order-level discounts are not included.
List<TopSeller> computeTopSellers({
  required List<OrderModel> orders,
  required TopSellerPeriod period,
  required DateTime now,
  int limit = 5,
}) {
  final Map<String, int> units = <String, int>{};
  final Map<String, double> revenue = <String, double>{};
  final Map<String, String> names = <String, String>{};
  for (final OrderModel order in orders) {
    if (order.status == OrderStatus.cancelled) {
      continue;
    }
    final DateTime date = order.orderDate.toLocal();
    final bool inPeriod = period == TopSellerPeriod.today
        ? _sameDay(date, now)
        : _sameMonth(date, now);
    if (!inPeriod) {
      continue;
    }
    for (final OrderItem item in order.items) {
      units[item.productId] = (units[item.productId] ?? 0) + item.quantity;
      revenue[item.productId] = (revenue[item.productId] ?? 0) + item.lineTotal;
      names.putIfAbsent(item.productId, () => item.productName);
    }
  }
  final List<TopSeller> sellers = <TopSeller>[
    for (final String id in units.keys)
      TopSeller(
        productId: id,
        productName: names[id] ?? '',
        units: units[id] ?? 0,
        revenue: _round2(revenue[id] ?? 0),
      ),
  ]..sort((TopSeller a, TopSeller b) {
      final int byUnits = b.units.compareTo(a.units);
      return byUnits != 0 ? byUnits : b.revenue.compareTo(a.revenue);
    });
  return sellers.take(limit).toList();
}

/// The dashboard shows sales totals and the cost value of stock, so it is for
/// admins and managers only.
final Provider<bool> canViewDashboardProvider = Provider<bool>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  return user != null &&
      user.isActive &&
      (user.role == UserRole.admin || user.role == UserRole.manager);
});

/// Computed from Hive on this device (orders, catalog and stock ledger), so it
/// needs no cloud reads and shows the data as of the last sync plus local work.
final Provider<DashboardStats> dashboardStatsProvider =
    Provider<DashboardStats>((Ref ref) {
  return computeDashboardStats(
    orders: ref.watch(ordersProvider).valueOrNull ?? <OrderModel>[],
    products: ref.watch(productsProvider).valueOrNull ?? <ProductModel>[],
    onHand: ref.watch(stockOnHandProvider),
    now: DateTime.now(),
  );
});

final ProviderFamily<List<TopSeller>, TopSellerPeriod> topSellersProvider =
    Provider.family<List<TopSeller>, TopSellerPeriod>(
        (Ref ref, TopSellerPeriod period) {
  return computeTopSellers(
    orders: ref.watch(ordersProvider).valueOrNull ?? <OrderModel>[],
    period: period,
    now: DateTime.now(),
  );
});
