import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/providers/business_provider.dart';
import 'package:mq_sports_erp/core/utils/stock_alerts.dart';
import 'package:mq_sports_erp/models/business_info.dart';
import 'package:mq_sports_erp/models/category_model.dart';
import 'package:mq_sports_erp/models/customer_model.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/models/vendor_model.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
import 'package:mq_sports_erp/providers/parties_providers.dart';
import 'package:mq_sports_erp/providers/sales_providers.dart';
import 'package:mq_sports_erp/providers/stock_providers.dart';

/// How far back the sales chart looks.
enum SalesRange {
  week('1W'),
  month('1M'),
  year('1Y');

  const SalesRange(this.label);

  final String label;
}

/// One bar of the sales chart.
class SalesBucket {
  const SalesBucket({required this.label, required this.amount});

  final String label;
  final double amount;
}

/// A variant at or below its alert level.
class LowStockItem {
  const LowStockItem({
    required this.productName,
    required this.variantLabel,
    required this.sku,
    required this.imageUrl,
    required this.onHand,
  });

  final String productName;
  final String variantLabel;
  final String sku;
  final String imageUrl;
  final int onHand;
}

/// A customer with what they bought.
class TopCustomer {
  const TopCustomer({required this.name, required this.orders, required this.total});

  final String name;
  final int orders;
  final double total;
}

/// A category's share of sales.
class CategoryShare {
  const CategoryShare({required this.name, required this.revenue});

  final String name;
  final double revenue;
}

const List<String> _months = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const List<String> _weekdays = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

double _round2(double v) => (v * 100).round() / 100;

DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

/// Whether a customer id is the business's walk-in customer (a business with none has no match).
bool _isWalkIn(String walkInCustomerId, String customerId) =>
    walkInCustomerId.isNotEmpty && customerId == walkInCustomerId;

/// Sales (orders that are not cancelled, at their total) per day for the last
/// 7 or 30 days, or per month of the current year.
List<SalesBucket> computeSalesSeries({
  required List<OrderModel> orders,
  required SalesRange range,
  required DateTime now,
}) {
  final DateTime today = _dayOf(now);
  final List<SalesBucket> out = <SalesBucket>[];
  if (range == SalesRange.year) {
    final List<double> sums = List<double>.filled(12, 0);
    for (final OrderModel o in orders) {
      final DateTime d = o.orderDate.toLocal();
      if (o.status != OrderStatus.cancelled && d.year == now.year) {
        sums[d.month - 1] += o.totalAmount;
      }
    }
    for (int i = 0; i < 12; i++) {
      out.add(SalesBucket(label: _months[i], amount: _round2(sums[i])));
    }
    return out;
  }
  final int days = range == SalesRange.week ? 7 : 30;
  final Map<DateTime, double> sums = <DateTime, double>{};
  for (final OrderModel o in orders) {
    if (o.status == OrderStatus.cancelled) {
      continue;
    }
    final DateTime day = _dayOf(o.orderDate.toLocal());
    sums[day] = (sums[day] ?? 0) + o.totalAmount;
  }
  for (int i = days - 1; i >= 0; i--) {
    final DateTime day = DateTime(today.year, today.month, today.day - i);
    final String label =
        range == SalesRange.week ? _weekdays[day.weekday - 1] : '${day.day}';
    out.add(SalesBucket(label: label, amount: _round2(sums[day] ?? 0)));
  }
  return out;
}

/// Named customers who ordered in one bar of the chart, split by whether it
/// was their first order ever (new) or they had bought before (returning).
class CustomerMixBucket {
  const CustomerMixBucket({required this.label, required this.newCustomers, required this.returningCustomers});

  final String label;
  final int newCustomers;
  final int returningCustomers;
}

/// New against returning customers over a [SalesRange], plus the walk-in
/// sales, which are kept apart.
///
/// A customer is *new* in the period if their first order (never cancelled)
/// falls inside it, and *returning* if they ordered in it but had already
/// bought before it started. Walk-in sales belong to one shared record, not to
/// a person, so they cannot be new or returning: they are only counted.
class CustomerMix {
  const CustomerMix({
    required this.buckets,
    required this.newCustomers,
    required this.returningCustomers,
    required this.walkInOrders,
    required this.walkInSales,
  });

  final List<CustomerMixBucket> buckets;
  final int newCustomers;
  final int returningCustomers;
  final int walkInOrders;
  final double walkInSales;

  int get customers => newCustomers + returningCustomers;

  /// Share of this period's customers who had bought before, 0 to 100.
  int get returningPercent => customers == 0 ? 0 : (returningCustomers * 100 / customers).round();
}

CustomerMix computeCustomerMix({
  required List<OrderModel> orders,
  required SalesRange range,
  required DateTime now,
  required String walkInCustomerId,
}) {
  final DateTime today = _dayOf(now);
  final bool yearly = range == SalesRange.year;
  final int days = range == SalesRange.week ? 7 : 30;
  final DateTime start = yearly ? DateTime(now.year) : DateTime(today.year, today.month, today.day - (days - 1));
  final int size = yearly ? 12 : days;

  /// Which bar a date falls in, or null when it is outside the period.
  int? slot(DateTime date) {
    final DateTime d = date.toLocal();
    if (yearly) {
      return d.year == now.year ? d.month - 1 : null;
    }
    final int index = _dayOf(d).difference(start).inDays;
    return index >= 0 && index < size ? index : null;
  }

  final Map<String, DateTime> firstOrder = <String, DateTime>{};
  for (final OrderModel o in orders) {
    if (o.status == OrderStatus.cancelled || _isWalkIn(walkInCustomerId, o.customerId)) {
      continue;
    }
    final DateTime? known = firstOrder[o.customerId];
    if (known == null || o.orderDate.isBefore(known)) {
      firstOrder[o.customerId] = o.orderDate;
    }
  }

  final List<Set<String>> newIn = List<Set<String>>.generate(size, (int _) => <String>{});
  final List<Set<String>> returningIn = List<Set<String>>.generate(size, (int _) => <String>{});
  final Set<String> newTotal = <String>{};
  final Set<String> returningTotal = <String>{};
  int walkInOrders = 0;
  double walkInSales = 0;
  for (final OrderModel o in orders) {
    if (o.status == OrderStatus.cancelled) {
      continue;
    }
    final int? at = slot(o.orderDate);
    if (at == null) {
      continue;
    }
    if (_isWalkIn(walkInCustomerId, o.customerId)) {
      walkInOrders++;
      walkInSales += o.totalAmount;
      continue;
    }
    final bool isNew = slot(firstOrder[o.customerId]!) != null;
    if (isNew) {
      newTotal.add(o.customerId);
    } else {
      returningTotal.add(o.customerId);
    }
    // In a single bar a customer is new only on the bar of their first order.
    if (slot(firstOrder[o.customerId]!) == at) {
      newIn[at].add(o.customerId);
    } else {
      returningIn[at].add(o.customerId);
    }
  }

  String label(int i) {
    if (yearly) {
      return _months[i];
    }
    final DateTime day = DateTime(start.year, start.month, start.day + i);
    return range == SalesRange.week ? _weekdays[day.weekday - 1] : '${day.day}';
  }

  return CustomerMix(
    buckets: <CustomerMixBucket>[
      for (int i = 0; i < size; i++)
        CustomerMixBucket(label: label(i), newCustomers: newIn[i].length, returningCustomers: returningIn[i].length),
    ],
    newCustomers: newTotal.length,
    returningCustomers: returningTotal.length,
    walkInOrders: walkInOrders,
    walkInSales: _round2(walkInSales),
  );
}

/// Active variants at or below their alert level, lowest stock first.
List<LowStockItem> computeLowStockItems({
  required List<ProductModel> products,
  required Map<String, int> onHand,
  int limit = 5,
}) {
  final List<LowStockItem> items = <LowStockItem>[];
  for (final ProductModel p in products) {
    if (!p.isActive) {
      continue;
    }
    for (final VariantModel v in p.variants) {
      final int qty = onHand[v.id] ?? 0;
      if (v.isActive && isLowStock(qty, v.alertThreshold)) {
        items.add(LowStockItem(
          productName: p.name,
          variantLabel: v.label,
          sku: v.sku,
          imageUrl: p.images.isEmpty ? '' : p.images.first.mediumUrl,
          onHand: qty,
        ));
      }
    }
  }
  items.sort((LowStockItem a, LowStockItem b) => a.onHand.compareTo(b.onHand));
  return items.take(limit).toList();
}

/// Named customers by what they spent (walk-in sales are not a customer).
List<TopCustomer> computeTopCustomers({
  required List<OrderModel> orders,
  required String walkInCustomerId,
  int limit = 5,
}) {
  final Map<String, double> totals = <String, double>{};
  final Map<String, int> counts = <String, int>{};
  final Map<String, String> names = <String, String>{};
  for (final OrderModel o in orders) {
    if (o.status == OrderStatus.cancelled || _isWalkIn(walkInCustomerId, o.customerId)) {
      continue;
    }
    totals[o.customerId] = (totals[o.customerId] ?? 0) + o.totalAmount;
    counts[o.customerId] = (counts[o.customerId] ?? 0) + 1;
    names[o.customerId] = o.customerName;
  }
  final List<TopCustomer> list = <TopCustomer>[
    for (final String id in totals.keys)
      TopCustomer(name: names[id] ?? '', orders: counts[id] ?? 0, total: _round2(totals[id] ?? 0)),
  ]..sort((TopCustomer a, TopCustomer b) => b.total.compareTo(a.total));
  return list.take(limit).toList();
}

/// Revenue (line totals of orders that are not cancelled) per category: the
/// biggest [limit] and the rest together as "Other".
List<CategoryShare> computeCategoryShares({
  required List<OrderModel> orders,
  required List<ProductModel> products,
  required List<CategoryModel> categories,
  int limit = 4,
}) {
  final Map<String, String> categoryOf = <String, String>{
    for (final ProductModel p in products) p.id: p.categoryId,
  };
  final Map<String, String> categoryName = <String, String>{
    for (final CategoryModel c in categories) c.id: c.name,
  };
  final Map<String, double> revenue = <String, double>{};
  for (final OrderModel o in orders) {
    if (o.status == OrderStatus.cancelled) {
      continue;
    }
    for (final OrderItem i in o.items) {
      final String name = categoryName[categoryOf[i.productId]] ?? 'Uncategorised';
      revenue[name] = (revenue[name] ?? 0) + i.lineTotal;
    }
  }
  final List<CategoryShare> all = <CategoryShare>[
    for (final MapEntry<String, double> e in revenue.entries)
      CategoryShare(name: e.key, revenue: _round2(e.value)),
  ]..sort((CategoryShare a, CategoryShare b) => b.revenue.compareTo(a.revenue));
  if (all.length <= limit) {
    return all;
  }
  final double rest =
      all.skip(limit).fold<double>(0, (double s, CategoryShare c) => s + c.revenue);
  return <CategoryShare>[...all.take(limit), CategoryShare(name: 'Other', revenue: _round2(rest))];
}

/// The newest sales first.
List<OrderModel> computeRecentSales({required List<OrderModel> orders, int limit = 5}) {
  final List<OrderModel> sorted = List<OrderModel>.of(orders)
    ..sort((OrderModel a, OrderModel b) => b.orderDate.compareTo(a.orderDate));
  return sorted.take(limit).toList();
}

final ProviderFamily<List<SalesBucket>, SalesRange> salesSeriesProvider =
    Provider.family<List<SalesBucket>, SalesRange>((Ref ref, SalesRange range) {
  return computeSalesSeries(
    orders: ref.watch(ordersProvider).valueOrNull ?? <OrderModel>[],
    range: range,
    now: DateTime.now(),
  );
});

final ProviderFamily<CustomerMix, SalesRange> customerMixProvider =
    Provider.family<CustomerMix, SalesRange>((Ref ref, SalesRange range) {
  return computeCustomerMix(
    orders: ref.watch(ordersProvider).valueOrNull ?? <OrderModel>[],
    range: range,
    now: DateTime.now(),
    walkInCustomerId: ref.watch(businessProvider).walkInCustomerId,
  );
});

final Provider<List<LowStockItem>> lowStockItemsProvider = Provider<List<LowStockItem>>((Ref ref) {
  return computeLowStockItems(
    products: ref.watch(productsProvider).valueOrNull ?? <ProductModel>[],
    onHand: ref.watch(stockOnHandProvider),
  );
});

final Provider<List<TopCustomer>> topCustomersProvider = Provider<List<TopCustomer>>((Ref ref) {
  return computeTopCustomers(
    orders: ref.watch(ordersProvider).valueOrNull ?? <OrderModel>[],
    walkInCustomerId: ref.watch(businessProvider).walkInCustomerId,
  );
});

final Provider<List<CategoryShare>> categorySharesProvider = Provider<List<CategoryShare>>((Ref ref) {
  return computeCategoryShares(
    orders: ref.watch(ordersProvider).valueOrNull ?? <OrderModel>[],
    products: ref.watch(productsProvider).valueOrNull ?? <ProductModel>[],
    categories: ref.watch(categoriesProvider).valueOrNull ?? <CategoryModel>[],
  );
});

final Provider<List<OrderModel>> recentSalesProvider = Provider<List<OrderModel>>((Ref ref) {
  return computeRecentSales(orders: ref.watch(ordersProvider).valueOrNull ?? <OrderModel>[]);
});

/// Counts for the "Overall information" card.
class OverallCounts {
  const OverallCounts({required this.customers, required this.vendors, required this.orders});

  final int customers;
  final int vendors;
  final int orders;
}

final Provider<OverallCounts> overallCountsProvider = Provider<OverallCounts>((Ref ref) {
  final List<CustomerModel> customers = ref.watch(customersProvider).valueOrNull ?? <CustomerModel>[];
  final List<VendorModel> vendors = ref.watch(vendorsProvider).valueOrNull ?? <VendorModel>[];
  final List<OrderModel> orders = ref.watch(ordersProvider).valueOrNull ?? <OrderModel>[];
  final BusinessInfo business = ref.watch(businessProvider);
  return OverallCounts(
    customers: customers.where((CustomerModel c) => c.isActive && !business.isWalkIn(c.id)).length,
    vendors: vendors.where((VendorModel v) => v.isActive).length,
    orders: orders.length,
  );
});
