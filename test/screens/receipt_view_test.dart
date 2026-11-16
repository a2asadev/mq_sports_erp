import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/core/utils/receipt.dart';
import 'package:a2_stocks/widgets/receipt_view.dart';

void main() {
  final ReceiptData receipt = ReceiptData(
    shopName: 'MQ Sports',
    shopPhone: '0300 1234567',
    orderNo: 'ORD-20261112-A1B2',
    date: DateTime(2026, 11, 12, 15, 30),
    cashier: 'Asad',
    customerName: '',
    lines: const <ReceiptLine>[
      ReceiptLine(name: 'Cricket Bat', label: 'Large', quantity: 2, unitPrice: 1500, discount: 100, total: 2900),
      ReceiptLine(name: 'Leather Ball', label: '', quantity: 1, unitPrice: 950, discount: 0, total: 950),
    ],
    subtotal: 3850,
    discount: 150,
    shippingFee: 0,
    total: 3700,
    payments: const <ReceiptPayment>[
      ReceiptPayment(label: 'Cash', amount: 4000),
    ],
    change: 300,
  );

  testWidgets('the receipt shows the shop, items, totals and receipt number', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: Center(child: ReceiptView(receipt: receipt)))),
    ));
    expect(find.text('MQ Sports'), findsOneWidget);
    expect(find.text('Sales Receipt'), findsOneWidget);
    expect(find.textContaining('Walk-in customer'), findsOneWidget);
    expect(find.textContaining('1. Cricket Bat (Large)'), findsOneWidget);
    expect(find.text('Rs 3700'), findsOneWidget); // Total Payable
    expect(find.text('Total Payable'), findsOneWidget);
    expect(find.text('Rs 300'), findsOneWidget); // change
    expect(find.text('ORD-20261112-A1B2'), findsWidgets);
    final Object? problem = tester.takeException();
    expect(problem, isNull, reason: "$problem");
  });
}
