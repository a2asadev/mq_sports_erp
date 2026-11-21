import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/customer_model.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/providers/parties_providers.dart';
import 'package:a2_stocks/providers/sales_providers.dart';
import 'package:a2_stocks/providers/users_providers.dart';
import 'package:a2_stocks/screens/sales/web_orders_screen.dart';

final List<String> advanced = <String>[];

class _Orders extends OrdersNotifier {
  _Orders(this.items);
  final List<OrderModel> items;
  @override
  Future<List<OrderModel>> build() async => items;
  @override
  Future<bool> advanceStatus(OrderModel order) async {
    advanced.add(order.orderNo);
    return true;
  }
}

class _Customers extends CustomersNotifier {
  @override
  Future<List<CustomerModel>> build() async => <CustomerModel>[];
}

class _Me extends CurrentUserNotifier {
  _Me(this.role);
  final UserRole role;
  @override
  Future<UserModel?> build() async => UserModel(id: 'u', email: 'a@b.pk', displayName: 'Asad', role: role);
}

OrderModel _order(String no, OrderStatus status, {String channel = 'web', Duration age = const Duration(minutes: 5)}) => OrderModel(
      orderNo: no,
      customerId: 'c',
      customerName: 'Customer $no',
      orderDate: DateTime.now().subtract(age),
      createdAt: DateTime.now().subtract(age),
      status: status,
      channel: channel,
      shippingAddress: 'Customer $no, 03001234567\nHouse 5, Lahore',
      items: <OrderItem>[OrderItem(productId: 'p', variantId: 'v', productName: 'Bat', variantLabel: 'S', sku: 'B', quantity: 2, unitPrice: 1000)],
    );

void main() {
  final List<OrderModel> orders = <OrderModel>[
    _order('WEB-1', OrderStatus.pending, age: const Duration(minutes: 45)),
    _order('WEB-2', OrderStatus.processing),
    _order('WEB-3', OrderStatus.shipped),
    _order('SHOP-1', OrderStatus.pending, channel: 'pos'),
  ];

  Future<void> pump(WidgetTester tester, Size size, {UserRole role = UserRole.manager}) async {
    advanced.clear();
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        currentUserProvider.overrideWith(() => _Me(role)),
        ordersProvider.overrideWith(() => _Orders(orders)),
        customersProvider.overrideWith(_Customers.new),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WebOrdersScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('wide: one column per step, only online orders, the oldest new order flagged', (WidgetTester tester) async {
    await pump(tester, const Size(1400, 900));
    expect(find.text('WEB-1'), findsOneWidget);
    expect(find.text('WEB-2'), findsOneWidget);
    expect(find.text('WEB-3'), findsOneWidget);
    expect(find.text('SHOP-1'), findsNothing);
    expect(find.text('45 minutes ago'), findsOneWidget);
    expect(find.text('Rs 2,000'), findsNWidgets(3));
    expect(find.text('Collect Rs 2,000 on delivery'), findsNWidgets(3));
    final Object? problem = tester.takeException();
    expect(problem, isNull, reason: '$problem');
  });

  testWidgets('the button moves an order one step on', (WidgetTester tester) async {
    await pump(tester, const Size(1400, 900));
    await tester.tap(find.widgetWithText(FilledButton, 'Move to Processing'));
    await tester.pump();
    expect(advanced, <String>['WEB-1']);
  });

  testWidgets('narrow: tabs with the counts, and the tab shows its orders', (WidgetTester tester) async {
    await pump(tester, const Size(390, 800));
    expect(find.text('Pending (1)'), findsOneWidget);
    expect(find.text('WEB-1'), findsOneWidget);
    await tester.ensureVisible(find.text('Shipped (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shipped (1)'));
    await tester.pumpAndSettle();
    expect(find.text('WEB-3'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Move to Delivered'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('staff can move orders on but not cancel them', (WidgetTester tester) async {
    await pump(tester, const Size(1400, 900), role: UserRole.staff);
    expect(find.widgetWithText(FilledButton, 'Move to Processing'), findsOneWidget);
    expect(find.byTooltip('Cancel order'), findsNothing);
  });

  testWidgets('a manager can cancel (with a confirmation)', (WidgetTester tester) async {
    await pump(tester, const Size(1400, 900));
    expect(find.byTooltip('Cancel order'), findsNWidgets(3));
  });
}
