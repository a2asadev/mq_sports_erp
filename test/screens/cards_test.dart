import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/party_list_item.dart';
import 'package:mq_sports_erp/widgets/order_receipt_card.dart';
import 'package:mq_sports_erp/widgets/party_list_view.dart';

void main() {
  Widget host(Widget child, {double width = 340, double height = 330}) => MaterialApp(
        home: Scaffold(body: Center(child: SizedBox(width: width, height: height, child: child))),
      );

  testWidgets('a customer card shows name, contact, balance and an over-limit warning', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(host(
      height: 216,
      PartyCard(
        partyType: PartyType.customer,
        onTap: () => tapped = true,
        item: const PartyListItem(
          id: 'c1',
          title: 'Ali Khan',
          subtitle: 'Lahore',
          phone: '0300 1234567',
          typeKey: 'wholesale',
          typeLabel: 'Wholesale',
          balance: 15000,
          creditLimit: 10000,
          isActive: true,
          searchText: 'ali khan',
        ),
      ),
    ));
    expect(find.text('Ali Khan'), findsOneWidget);
    expect(find.text('Wholesale'), findsOneWidget);
    expect(find.text('0300 1234567'), findsOneWidget);
    expect(find.text('Lahore'), findsOneWidget);
    expect(find.text('Over credit limit'), findsOneWidget);
    expect(find.text('Rs 15,000'), findsOneWidget);
    await tester.tap(find.text('Ali Khan'));
    expect(tapped, isTrue);
    final Object? problem = tester.takeException();
    expect(problem, isNull, reason: '$problem');
  });

  testWidgets('a settled, inactive vendor card stays calm', (WidgetTester tester) async {
    await tester.pumpWidget(host(
      height: 216,
      PartyCard(
        partyType: PartyType.vendor,
        onTap: () {},
        item: const PartyListItem(
          id: 'v1',
          title: 'Sialkot Sports',
          subtitle: '',
          phone: '',
          typeKey: 'local',
          typeLabel: 'Local',
          balance: 0,
          creditLimit: 0,
          isActive: false,
          searchText: 'sialkot',
        ),
      ),
    ));
    expect(find.text('Inactive'), findsOneWidget);
    expect(find.text('No phone'), findsOneWidget);
    expect(find.text('Settled'), findsOneWidget);
    expect(find.text('Rs 0'), findsOneWidget);
    final Object? problem = tester.takeException();
    expect(problem, isNull, reason: '$problem');
  });

  OrderItem item(String name, int qty, double price) => OrderItem(
        productId: name,
        variantId: '$name-v',
        productName: name,
        variantLabel: 'L',
        sku: name,
        quantity: qty,
        unitPrice: price,
      );

  testWidgets('an order card reads like a receipt: items, total, payment state', (WidgetTester tester) async {
    final OrderModel order = OrderModel(
      orderNo: 'ORD-1001',
      customerId: 'c1',
      customerName: 'Ali Khan',
      channel: 'pos',
      status: OrderStatus.processing,
      items: <OrderItem>[
        item('Bat', 2, 1500),
        item('Ball', 1, 950),
        item('Gloves', 1, 700),
        item('Pads', 1, 2000),
        item('Helmet', 1, 3000),
      ],
    );
    await tester.pumpWidget(host(OrderReceiptCard(order: order, paid: 1000, onTap: () {}), height: 318));
    expect(find.text('ORD-1001'), findsOneWidget);
    expect(find.text('Processing'), findsOneWidget);
    expect(find.textContaining('2 × Bat'), findsOneWidget);
    expect(find.text('+ 2 more items'), findsOneWidget); // three lines shown, two folded
    expect(find.text('Rs 9,650'), findsOneWidget); // total
    expect(find.text('Partly paid'), findsOneWidget);
    expect(find.text('Due Rs 8,650'), findsOneWidget);
    final Object? problem = tester.takeException();
    expect(problem, isNull, reason: '$problem');
  });

  testWidgets('a cancelled order card shows no amount due', (WidgetTester tester) async {
    final OrderModel order = OrderModel(
      orderNo: 'ORD-9',
      customerId: 'c1',
      customerName: '',
      status: OrderStatus.cancelled,
      items: <OrderItem>[item('Bat', 1, 1500)],
    );
    await tester.pumpWidget(host(OrderReceiptCard(order: order, paid: 0, onTap: () {}), height: 318));
    expect(find.text('Walk-in customer'), findsOneWidget);
    expect(find.text('Cancelled'), findsWidgets);
    expect(find.textContaining('Due'), findsNothing);
    final Object? problem = tester.takeException();
    expect(problem, isNull, reason: '$problem');
  });
}
