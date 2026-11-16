import 'package:flutter_test/flutter_test.dart';
import 'package:mq_sports_erp/core/constants/walk_in.dart';
import 'package:mq_sports_erp/models/category_model.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/providers/dashboard_insights.dart';

OrderItem _item(String productId, int qty, double price) => OrderItem(
      productId: productId,
      variantId: '$productId-v',
      productName: 'Product $productId',
      variantLabel: 'v',
      sku: productId,
      quantity: qty,
      unitPrice: price,
    );

OrderModel _order(
  DateTime date,
  List<OrderItem> items, {
  OrderStatus status = OrderStatus.delivered,
  String customerId = 'c1',
  String customerName = 'Ali',
}) =>
    OrderModel(
      orderNo: 'ORD',
      customerId: customerId,
      customerName: customerName,
      orderDate: date,
      status: status,
      items: items,
    );

void main() {
  final DateTime now = DateTime(2026, 11, 12, 15); // a Thursday

  group('computeCustomerMix', () {
    OrderModel sale(DateTime date, String customerId, {OrderStatus status = OrderStatus.delivered, double price = 100}) =>
        _order(date, <OrderItem>[_item('a', 1, price)], customerId: customerId, status: status);

    test('new = first order inside the period; returning = bought before it; walk-in kept apart', () {
      final CustomerMix mix = computeCustomerMix(
        orders: <OrderModel>[
          sale(DateTime(2026, 10, 1), 'old'), // first bought long ago
          sale(DateTime(2026, 11, 11), 'old'), // ...and again this week: returning
          sale(DateTime(2026, 11, 10), 'fresh'), // first order this week: new
          sale(DateTime(2026, 11, 12), 'fresh'), // buys again the same week: still new
          sale(DateTime(2026, 11, 12), walkInCustomerId, price: 250),
          sale(DateTime(2026, 11, 12), walkInCustomerId, price: 50),
          sale(DateTime(2026, 11, 12), 'ghost', status: OrderStatus.cancelled), // cancelled: nobody
        ],
        range: SalesRange.week,
        now: now,
      );
      expect(mix.newCustomers, 1);
      expect(mix.returningCustomers, 1);
      expect(mix.returningPercent, 50);
      expect(mix.walkInOrders, 2);
      expect(mix.walkInSales, 300);
      expect(mix.buckets.length, 7);
      // Tue 10th: fresh is new. Wed 11th: old returns. Thu 12th: fresh is back (returning on that day).
      expect(mix.buckets[4].newCustomers, 1);
      expect(mix.buckets[5].returningCustomers, 1);
      expect(mix.buckets[6].newCustomers, 0);
      expect(mix.buckets[6].returningCustomers, 1);
    });

    test('a customer whose only order was cancelled earlier is new when they really buy', () {
      final CustomerMix mix = computeCustomerMix(
        orders: <OrderModel>[
          sale(DateTime(2026, 9, 1), 'c', status: OrderStatus.cancelled),
          sale(DateTime(2026, 11, 12), 'c'),
        ],
        range: SalesRange.week,
        now: now,
      );
      expect(mix.newCustomers, 1);
      expect(mix.returningCustomers, 0);
    });

    test('year groups by month and an empty shop gives zeros', () {
      final CustomerMix year = computeCustomerMix(
        orders: <OrderModel>[sale(DateTime(2026, 3, 5), 'a'), sale(DateTime(2026, 6, 5), 'a')],
        range: SalesRange.year,
        now: now,
      );
      expect(year.buckets.length, 12);
      expect(year.newCustomers, 1);
      expect(year.buckets[2].newCustomers, 1);
      expect(year.buckets[5].returningCustomers, 1);

      final CustomerMix none = computeCustomerMix(orders: const <OrderModel>[], range: SalesRange.month, now: now);
      expect(none.customers, 0);
      expect(none.returningPercent, 0);
      expect(none.buckets.length, 30);
    });
  });

  group('computeSalesSeries', () {
    test('week: seven days ending today, cancelled orders left out', () {
      final List<SalesBucket> series = computeSalesSeries(
        orders: <OrderModel>[
          _order(DateTime(2026, 11, 12, 9), <OrderItem>[_item('a', 1, 100)]),
          _order(DateTime(2026, 11, 12, 18), <OrderItem>[_item('a', 1, 50)]),
          _order(DateTime(2026, 11, 10), <OrderItem>[_item('a', 2, 30)]),
          _order(DateTime(2026, 11, 12), <OrderItem>[_item('a', 1, 999)], status: OrderStatus.cancelled),
          _order(DateTime(2026, 11, 1), <OrderItem>[_item('a', 1, 777)]), // outside the week
        ],
        range: SalesRange.week,
        now: now,
      );
      expect(series.length, 7);
      expect(series.last.label, 'Thu');
      expect(series.last.amount, 150);
      expect(series[4].amount, 60); // Tuesday the 10th
      expect(series.fold<double>(0, (double s, SalesBucket b) => s + b.amount), 210);
    });

    test('month: thirty days; year: twelve calendar months of this year', () {
      final List<OrderModel> orders = <OrderModel>[
        _order(DateTime(2026, 11, 12), <OrderItem>[_item('a', 1, 100)]),
        _order(DateTime(2026, 3, 5), <OrderItem>[_item('a', 1, 400)]),
        _order(DateTime(2025, 3, 5), <OrderItem>[_item('a', 1, 900)]), // last year
      ];
      expect(computeSalesSeries(orders: orders, range: SalesRange.month, now: now).length, 30);
      final List<SalesBucket> year = computeSalesSeries(orders: orders, range: SalesRange.year, now: now);
      expect(year.length, 12);
      expect(year[2].label, 'Mar');
      expect(year[2].amount, 400);
      expect(year[10].amount, 100);
    });
  });

  test('computeLowStockItems lists active variants at or below their alert, emptiest first', () {
    final ProductModel p = ProductModel(
      id: 'p',
      name: 'Bat',
      categoryId: 'c',
      variants: <VariantModel>[
        VariantModel(id: 'v1', sku: 'S', name: 'Small', alertThreshold: 5),
        VariantModel(id: 'v2', sku: 'L', name: 'Large', alertThreshold: 5),
        VariantModel(id: 'v3', sku: 'X', name: 'No alert'),
      ],
    );
    final List<LowStockItem> items = computeLowStockItems(
      products: <ProductModel>[p],
      onHand: <String, int>{'v1': 4, 'v2': 1, 'v3': 0},
    );
    expect(items.map((LowStockItem i) => i.onHand), <int>[1, 4]);
    expect(items.first.sku, 'L');
  });

  test('computeTopCustomers ranks named customers and skips walk-in and cancelled sales', () {
    final List<TopCustomer> top = computeTopCustomers(orders: <OrderModel>[
      _order(now, <OrderItem>[_item('a', 1, 100)], customerId: 'c1', customerName: 'Ali'),
      _order(now, <OrderItem>[_item('a', 1, 300)], customerId: 'c2', customerName: 'Sara'),
      _order(now, <OrderItem>[_item('a', 1, 50)], customerId: 'c1', customerName: 'Ali'),
      _order(now, <OrderItem>[_item('a', 1, 9999)], customerId: walkInCustomerId, customerName: 'Walk-in'),
      _order(now, <OrderItem>[_item('a', 1, 9999)], customerId: 'c3', customerName: 'Zed', status: OrderStatus.cancelled),
    ]);
    expect(top.map((TopCustomer c) => c.name), <String>['Sara', 'Ali']);
    expect(top[1].orders, 2);
    expect(top[1].total, 150);
  });

  test('computeCategoryShares groups revenue by category and folds the tail into Other', () {
    final List<ProductModel> products = <ProductModel>[
      for (int i = 1; i <= 6; i++) ProductModel(id: 'p$i', name: 'P$i', categoryId: 'c$i'),
    ];
    final List<CategoryModel> categories = <CategoryModel>[
      for (int i = 1; i <= 6; i++) CategoryModel(id: 'c$i', name: 'Cat$i'),
    ];
    final List<CategoryShare> shares = computeCategoryShares(
      orders: <OrderModel>[
        _order(now, <OrderItem>[
          for (int i = 1; i <= 6; i++) _item('p$i', 1, i * 100),
        ]),
      ],
      products: products,
      categories: categories,
    );
    expect(shares.length, 5);
    expect(shares.first.name, 'Cat6');
    expect(shares.last.name, 'Other');
    expect(shares.last.revenue, 300); // Cat1 (100) + Cat2 (200)
  });

  test('computeRecentSales returns the newest first', () {
    final List<OrderModel> recent = computeRecentSales(
      orders: <OrderModel>[
        _order(DateTime(2026, 11, 1), <OrderItem>[], customerName: 'Old'),
        _order(DateTime(2026, 11, 12), <OrderItem>[], customerName: 'New'),
      ],
      limit: 1,
    );
    expect(recent.single.customerName, 'New');
  });
}
