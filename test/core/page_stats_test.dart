import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mq_sports_erp/core/utils/page_stats.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/party_list_item.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/purchase_model.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/user_role.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/widgets/stat_strip.dart';

void main() {
  OrderItem orderItem(double price, {int qty = 1}) => OrderItem(
        productId: 'p',
        variantId: 'v',
        productName: 'Bat',
        variantLabel: 'L',
        sku: 'B-1',
        quantity: qty,
        unitPrice: price,
      );

  OrderModel order(String id, double price, {OrderStatus status = OrderStatus.pending, DateTime? date}) =>
      OrderModel(
        id: id,
        orderNo: id,
        customerId: 'c',
        customerName: 'Ali',
        status: status,
        orderDate: date,
        items: <OrderItem>[orderItem(price)],
      );

  test('order stats skip cancelled orders and split today from earlier', () {
    final DateTime now = DateTime(2026, 11, 16, 15);
    final OrderStats stats = computeOrderStats(
      <OrderModel>[
        order('a', 1000, date: DateTime(2026, 11, 16, 9)),
        order('b', 500, status: OrderStatus.delivered, date: DateTime(2026, 11, 10)),
        order('c', 9000, status: OrderStatus.cancelled, date: DateTime(2026, 11, 16)),
      ],
      <String, double>{'a': 400, 'b': 500},
      now,
    );
    expect(stats.count, 2);
    expect(stats.openCount, 1); // delivered is finished
    expect(stats.sales, 1500);
    expect(stats.todaySales, 1000);
    expect(stats.todayCount, 1);
    expect(stats.toCollect, 600);
  });

  test('purchase stats total what is owed and count the unpaid', () {
    PurchaseModel purchase(String id, double cost) => PurchaseModel(
          id: id,
          purchaseNo: id,
          vendorId: 'v',
          vendorName: 'Sialkot',
          items: <PurchaseItem>[
            PurchaseItem(
              productId: 'p',
              variantId: 'v',
              productName: 'Bat',
              variantLabel: 'L',
              sku: 'B',
              quantity: 2,
              unitCost: cost,
            ),
          ],
        );
    final PurchaseStats stats = computePurchaseStats(
      <PurchaseModel>[purchase('a', 500), purchase('b', 250)],
      <String, double>{'a': 1000},
    );
    expect(stats.count, 2);
    expect(stats.total, 1500);
    expect(stats.due, 500);
    expect(stats.unpaidCount, 1);
  });

  VariantModel variant(String id, {double cost = 100, int alert = 0, bool active = true}) =>
      VariantModel(id: id, sku: id, costPrice: cost, alertThreshold: alert, isActive: active);

  test('product stats count active, variants and distinct brands', () {
    final ProductStats stats = computeProductStats(<ProductModel>[
      ProductModel(name: 'A', categoryId: 'c', brand: 'MQ', variants: <VariantModel>[variant('1'), variant('2')]),
      ProductModel(name: 'B', categoryId: 'c', brand: ' mq ', isActive: false),
      ProductModel(name: 'C', categoryId: 'c', brand: 'SS'),
    ]);
    expect(stats.products, 3);
    expect(stats.active, 2);
    expect(stats.variants, 2);
    expect(stats.brands, 2);
  });

  test('stock stats value units at cost and flag low and empty items', () {
    final StockStats stats = computeStockStats(
      <ProductModel>[
        ProductModel(name: 'A', categoryId: 'c', variants: <VariantModel>[
          variant('v1', cost: 100, alert: 5),
          variant('v2', cost: 50),
          variant('v3', cost: 10),
        ]),
        ProductModel(name: 'Off', categoryId: 'c', isActive: false, variants: <VariantModel>[variant('v4')]),
      ],
      <String, int>{'v1': 3, 'v2': 10, 'v3': -2, 'v4': 0},
    );
    expect(stats.items, 4);
    expect(stats.units, 13); // negative stock is not counted
    expect(stats.value, 3 * 100 + 10 * 50);
    expect(stats.lowCount, 1); // only v1 has an alert level and is at or below it
    expect(stats.outCount, 1); // v3; the inactive product does not count
  });

  test('user stats count roles and active logins', () {
    UserModel user(String id, UserRole role, {bool active = true}) =>
        UserModel(id: id, email: '$id@x.com', role: role, isActive: active);
    final UserStats stats = computeUserStats(<UserModel>[
      user('1', UserRole.admin),
      user('2', UserRole.manager),
      user('3', UserRole.staff),
      user('4', UserRole.staff, active: false),
    ]);
    expect(stats.total, 4);
    expect(stats.active, 3);
    expect(stats.admins, 1);
    expect(stats.managers, 1);
    expect(stats.staff, 2);
  });

  test('party stats sum only the positive balances', () {
    PartyListItem party(double balance, {double limit = 0, bool active = true}) => PartyListItem(
          id: '$balance',
          title: 't',
          subtitle: '',
          phone: '',
          typeKey: 'k',
          typeLabel: 'K',
          balance: balance,
          creditLimit: limit,
          isActive: active,
          searchText: 't',
        );
    final PartyStats stats = computePartyStats(<PartyListItem>[
      party(1000, limit: 500),
      party(250),
      party(-300), // advance paid, not owed
      party(0, active: false),
    ]);
    expect(stats.total, 4);
    expect(stats.active, 3);
    expect(stats.outstanding, 1250);
    expect(stats.withBalance, 2);
    expect(stats.overLimit, 1);
  });

  testWidgets('the stat strip wraps to two per row on a phone without overflowing', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: StatStrip(
          items: <StatItem>[
            StatItem(icon: Icons.today, color: Colors.red, label: 'Sales today', value: 'Rs 1,250,000', caption: '12 order(s)'),
            StatItem(icon: Icons.payments, color: Colors.teal, label: 'Total sales', value: 'Rs 86,800'),
            StatItem(icon: Icons.wallet, color: Colors.amber, label: 'To collect', value: 'Rs 0'),
            StatItem(icon: Icons.pending, color: Colors.blue, label: 'Open orders', value: '4'),
          ],
        ),
      ),
    ));
    expect(find.text('Sales today'), findsOneWidget);
    final double firstY = tester.getTopLeft(find.text('Sales today')).dy;
    final double thirdY = tester.getTopLeft(find.text('To collect')).dy;
    expect(thirdY, greaterThan(firstY), reason: 'third card starts a second row');
    final Object? problem = tester.takeException();
    expect(problem, isNull, reason: '$problem');
  });
}
