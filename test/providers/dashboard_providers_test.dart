import 'package:flutter_test/flutter_test.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/providers/dashboard_providers.dart';

OrderModel _order(
  DateTime date,
  OrderStatus status,
  List<OrderItem> items, {
  double discount = 0,
}) {
  return OrderModel(
    orderNo: 'ORD',
    customerId: 'c',
    customerName: 'Ali',
    orderDate: date,
    status: status,
    items: items,
    discount: discount,
  );
}

OrderItem _item(String productId, int qty, double price) {
  return OrderItem(
    productId: productId,
    variantId: '$productId-v',
    productName: 'Product $productId',
    variantLabel: 'v',
    sku: productId,
    quantity: qty,
    unitPrice: price,
  );
}

ProductModel _product(String id, List<VariantModel> variants) {
  return ProductModel(
    id: id,
    name: 'Product $id',
    categoryId: 'cat',
    variants: variants,
  );
}

void main() {
  final DateTime now = DateTime(2026, 11, 12, 15);

  group('computeDashboardStats sales', () {
    test('counts today and this month, skipping cancelled and other months', () {
      final DashboardStats stats = computeDashboardStats(
        orders: <OrderModel>[
          _order(DateTime(2026, 11, 12), OrderStatus.delivered,
              <OrderItem>[_item('a', 1, 100)]),
          _order(DateTime(2026, 11, 3), OrderStatus.pending,
              <OrderItem>[_item('a', 2, 50)]),
          _order(DateTime(2026, 11, 12), OrderStatus.cancelled,
              <OrderItem>[_item('a', 1, 999)]),
          _order(DateTime(2026, 10, 30), OrderStatus.delivered,
              <OrderItem>[_item('a', 1, 500)]),
        ],
        products: const <ProductModel>[],
        onHand: const <String, int>{},
        now: now,
      );
      expect(stats.salesToday, 100);
      expect(stats.ordersToday, 1);
      expect(stats.salesMonth, 200);
      expect(stats.ordersMonth, 2);
    });

    test('uses the total after discounts', () {
      final DashboardStats stats = computeDashboardStats(
        orders: <OrderModel>[
          _order(DateTime(2026, 11, 12), OrderStatus.pending,
              <OrderItem>[_item('a', 2, 100)],
              discount: 20),
        ],
        products: const <ProductModel>[],
        onHand: const <String, int>{},
        now: now,
      );
      expect(stats.salesToday, 180);
    });

    test('counts pending, processing and shipped orders of any date', () {
      final DashboardStats stats = computeDashboardStats(
        orders: <OrderModel>[
          _order(DateTime(2026, 1, 1), OrderStatus.pending,
              <OrderItem>[_item('a', 1, 1)]),
          _order(DateTime(2026, 11, 1), OrderStatus.pending,
              <OrderItem>[_item('a', 1, 1)]),
          _order(DateTime(2026, 11, 1), OrderStatus.processing,
              <OrderItem>[_item('a', 1, 1)]),
          _order(DateTime(2026, 11, 1), OrderStatus.shipped,
              <OrderItem>[_item('a', 1, 1)]),
          _order(DateTime(2026, 11, 1), OrderStatus.cancelled,
              <OrderItem>[_item('a', 1, 1)]),
        ],
        products: const <ProductModel>[],
        onHand: const <String, int>{},
        now: now,
      );
      expect(stats.pendingOrders, 2);
      expect(stats.processingOrders, 1);
      expect(stats.shippedOrders, 1);
    });
  });

  group('computeDashboardStats stock', () {
    final VariantModel a = VariantModel(
        id: 'va', sku: 'A', costPrice: 10, salePrice: 15, alertThreshold: 5);
    final VariantModel b =
        VariantModel(id: 'vb', sku: 'B', costPrice: 100, salePrice: 150);
    final VariantModel c = VariantModel(
        id: 'vc',
        sku: 'C',
        costPrice: 1,
        salePrice: 2,
        alertThreshold: 3,
        isActive: false);

    test('values positive stock at cost and retail, ignoring negative stock', () {
      final DashboardStats stats = computeDashboardStats(
        orders: const <OrderModel>[],
        products: <ProductModel>[_product('p', <VariantModel>[a, b, c])],
        onHand: const <String, int>{'va': 4, 'vb': -2, 'vc': 10},
        now: now,
      );
      expect(stats.stockCostValue, 4 * 10 + 10 * 1);
      expect(stats.stockRetailValue, 4 * 15 + 10 * 2);
      expect(stats.stockUnits, 14);
      expect(stats.potentialMargin, stats.stockRetailValue - stats.stockCostValue);
    });

    test('low stock counts active variants at or below their alert level', () {
      final DashboardStats stats = computeDashboardStats(
        orders: const <OrderModel>[],
        products: <ProductModel>[_product('p', <VariantModel>[a, b, c])],
        // a is at 5 (alert 5), b has no alert, c is inactive.
        onHand: const <String, int>{'va': 5, 'vb': 0, 'vc': 0},
        now: now,
      );
      expect(stats.lowStockCount, 1);
    });
  });

  group('computeTopSellers', () {
    final List<OrderModel> orders = <OrderModel>[
      _order(DateTime(2026, 11, 12), OrderStatus.delivered,
          <OrderItem>[_item('a', 3, 10), _item('b', 5, 4)]),
      _order(DateTime(2026, 11, 2), OrderStatus.pending,
          <OrderItem>[_item('a', 4, 10)]),
      _order(DateTime(2026, 11, 12), OrderStatus.cancelled,
          <OrderItem>[_item('c', 99, 1)]),
      _order(DateTime(2026, 10, 12), OrderStatus.delivered,
          <OrderItem>[_item('d', 50, 1)]),
    ];

    test('ranks by units for the month, skipping cancelled orders', () {
      final List<TopSeller> sellers = computeTopSellers(
        orders: orders,
        period: TopSellerPeriod.month,
        now: DateTime(2026, 11, 12),
      );
      expect(sellers.map((TopSeller s) => s.productId), <String>['a', 'b']);
      expect(sellers.first.units, 7);
      expect(sellers.first.revenue, 70);
    });

    test('today only counts today', () {
      final List<TopSeller> sellers = computeTopSellers(
        orders: orders,
        period: TopSellerPeriod.today,
        now: DateTime(2026, 11, 12),
      );
      expect(sellers.map((TopSeller s) => s.productId), <String>['b', 'a']);
      expect(sellers.first.units, 5);
    });

    test('respects the limit', () {
      final List<TopSeller> sellers = computeTopSellers(
        orders: orders,
        period: TopSellerPeriod.month,
        now: DateTime(2026, 11, 12),
        limit: 1,
      );
      expect(sellers, hasLength(1));
    });
  });
}
