import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/customer_model.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/providers/parties_providers.dart';
import 'package:a2_stocks/providers/sales_providers.dart';
import 'package:a2_stocks/screens/customers/customer_insights_screen.dart';

class _Orders extends OrdersNotifier {
  _Orders(this.items);
  final List<OrderModel> items;
  @override
  Future<List<OrderModel>> build() async => items;
}

class _Customers extends CustomersNotifier {
  _Customers(this.items);
  final List<CustomerModel> items;
  @override
  Future<List<CustomerModel>> build() async => items;
}

OrderModel _order(String customerId, DateTime date, double price) => OrderModel(
      orderNo: 'ORD-$customerId',
      customerId: customerId,
      customerName: 'x',
      orderDate: date,
      status: OrderStatus.delivered,
      items: <OrderItem>[OrderItem(productId: 'p', variantId: 'v', productName: 'Bat', variantLabel: 'S', sku: 'B', quantity: 1, unitPrice: price)],
    );

void main() {
  final DateTime now = DateTime.now();
  final DateTime birthday = now.add(const Duration(days: 3));
  final String key = '${birthday.month.toString().padLeft(2, '0')}-${birthday.day.toString().padLeft(2, '0')}';
  final List<CustomerModel> customers = <CustomerModel>[
    CustomerModel(id: 'a', name: 'Ali Khan', phone: '0300 1234567', birthday: key),
    CustomerModel(id: 'b', name: 'Bilal Shah'),
  ];
  final List<OrderModel> orders = <OrderModel>[
    _order('a', now.subtract(const Duration(days: 100)), 500),
    _order('b', now.subtract(const Duration(days: 5)), 2500),
  ];

  Future<void> pump(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        ordersProvider.overrideWith(() => _Orders(orders)),
        customersProvider.overrideWith(() => _Customers(customers)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CustomerInsightsScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  for (final Size size in const <Size>[Size(1200, 900), Size(390, 800)]) {
    testWidgets('three lists lay out at ${size.width.toInt()} px without overflow', (WidgetTester tester) async {
      await pump(tester, size);
      // Top customers (the last 90 days): only Bilal bought in that time, and the button messages him.
      expect(find.text('Bilal Shah'), findsOneWidget);
      expect(find.text('Ali Khan'), findsNothing);
      expect(find.text('Rs 2,500'), findsOneWidget);

      await tester.tap(find.text('Not back for a while'));
      await tester.pumpAndSettle();
      expect(find.text('Ali Khan'), findsOneWidget); // last bought 100 days ago
      expect(find.text('Bilal Shah'), findsNothing);
      expect(find.text('100 days ago'), findsOneWidget);

      await tester.tap(find.text('Birthdays'));
      await tester.pumpAndSettle();
      expect(find.text('Ali Khan'), findsOneWidget);
      expect(find.text('in 3 days'), findsOneWidget);
      expect(find.byTooltip('Message on WhatsApp'), findsOneWidget);
      final Object? problem = tester.takeException();
      expect(problem, isNull, reason: '$problem');
    });
  }

  testWidgets('a customer without a phone number is told so instead of opening WhatsApp', (WidgetTester tester) async {
    await pump(tester, const Size(1200, 900));
    await tester.tap(find.byTooltip('Message on WhatsApp'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Bilal Shah has no phone number saved.'), findsOneWidget);
  });
}
