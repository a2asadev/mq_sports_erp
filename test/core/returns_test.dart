import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/core/utils/receipt.dart';
import 'package:a2_stocks/core/utils/return_plan.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/models/ledger_model.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/order_return.dart';
import 'package:a2_stocks/models/party_enums.dart';
import 'package:a2_stocks/online/returns_service.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/providers/parties_providers.dart';
import 'package:a2_stocks/providers/sales_providers.dart';
import 'package:a2_stocks/screens/sales/return_screen.dart';

OrderItem _item(String id, int qty, double price, {double discount = 0}) => OrderItem(
      id: id,
      productId: 'p',
      variantId: 'v$id',
      productName: 'Cricket Bat',
      variantLabel: 'Small',
      sku: 'BAT-$id',
      quantity: qty,
      unitPrice: price,
      discount: discount,
    );

OrderModel _order({List<OrderItem>? items, double discount = 0, String customerId = 'c1'}) => OrderModel(
      id: 'o1',
      orderNo: 'ORD-1',
      customerId: customerId,
      customerName: 'Ali',
      status: OrderStatus.delivered,
      items: items ?? <OrderItem>[_item('a', 4, 100)],
      discount: discount,
    );

LedgerModel _entry(LedgerEntryType type, double amount, {String kind = '', String method = '', String description = ''}) =>
    LedgerModel(
      partyType: PartyType.customer,
      partyId: 'c1',
      entryType: type,
      amount: amount,
      orderId: 'o1',
      kind: kind,
      paymentMethod: method,
      description: description,
    );

class _FakeLedger extends LedgerNotifier {
  @override
  Future<List<LedgerModel>> build() async => <LedgerModel>[
        _entry(LedgerEntryType.charge, 400), // the sale
        _entry(LedgerEntryType.payment, 400, method: 'cash'),
        _entry(LedgerEntryType.payment, 100, kind: 'return'),
        _entry(LedgerEntryType.charge, 100, kind: 'refund', method: 'cash'),
      ];
}

class _FakeReturns implements ReturnsService {
  final List<Map<String, Object?>> created = <Map<String, Object?>>[];
  List<OrderReturn> earlier = <OrderReturn>[];

  @override
  Future<List<OrderReturn>> forOrder(String orderId) async => earlier;

  @override
  Future<OrderReturn> create({
    required String orderId,
    required List<ReturnLineRequest> lines,
    String refundMethod = OrderReturn.creditMethod,
    double? refundAmount,
    String note = '',
    String? requestId,
  }) async {
    created.add(<String, Object?>{
      'lines': <String>[for (final ReturnLineRequest l in lines) '${l.orderItemId}x${l.quantity}${l.restock ? '' : '!'}'],
      'method': refundMethod,
      'amount': refundAmount,
      'note': note,
    });
    return OrderReturn.fromMap(<String, dynamic>{'id': 'r1', 'returnNo': 'RET-1', 'orderId': orderId, 'items': <Object?>[]});
  }
}

void main() {
  group('ReturnPlan follows the server', () {
    test('a plain line is worth its price', () {
      final ReturnPlan plan = ReturnPlan(order: _order());
      expect(plan.remaining(plan.order.items.first), 4);
      expect(plan.totalValue(<String, int>{'a': 1}), 100);
      expect(plan.totalValue(<String, int>{'a': 4}), 400);
      expect(plan.totalValue(<String, int>{}), 0);
    });

    test('the line discount and the order discount are shared out, and never add up to more than was paid', () {
      // 2 bats at 100 with Rs 20 off the line = 180; Rs 18 off the order = 162.
      final OrderModel order = _order(items: <OrderItem>[_item('a', 2, 100, discount: 20)], discount: 18);
      expect(order.totalAmount, 162);
      final ReturnPlan first = ReturnPlan(order: order);
      expect(first.totalValue(<String, int>{'a': 1}), 81);
      final ReturnPlan second = ReturnPlan(order: order, alreadyReturned: <String, int>{'a': 1});
      expect(second.remaining(order.items.first), 1);
      expect(second.totalValue(<String, int>{'a': 1}), 81);
    });

    test('odd cents land on the last unit, so every unit together is exactly the line', () {
      // 3 units at Rs 33.33 = 99.99, nothing off: 33.33 each.
      final OrderModel order = _order(items: <OrderItem>[_item('a', 3, 33.33)]);
      double sum = 0;
      Map<String, int> already = <String, int>{};
      for (int i = 0; i < 3; i++) {
        sum += ReturnPlan(order: order, alreadyReturned: already).totalValue(<String, int>{'a': 1});
        already = <String, int>{'a': i + 1};
      }
      expect((sum * 100).round(), 9999);
      // Rs 10 off 3 units of Rs 10: the thirds of 20 do not divide, but the whole does.
      final OrderModel odd = _order(items: <OrderItem>[_item('a', 3, 10)], discount: 10);
      expect(ReturnPlan(order: odd).totalValue(<String, int>{'a': 3}), 20);
    });

    test('says how much money was paid beyond what is left of the order', () {
      final ReturnPlan plan = ReturnPlan(order: _order());
      // 400 paid, goods worth 100 come back: 100 can be handed back.
      expect(plan.overpaid(settled: 400, credit: 100), 100);
      // 100 paid of 400 and goods worth 100 come back: nothing is paid beyond what is owed.
      expect(plan.overpaid(settled: 100, credit: 100), 0);
      expect(plan.overpaid(settled: 0, credit: 100), 0);
    });

    test('earlier returns leave fewer units to come back', () {
      final OrderModel order = _order();
      final ReturnPlan plan = ReturnPlan(order: order, alreadyReturned: <String, int>{'a': 4});
      expect(plan.remaining(order.items.first), 0);
    });
  });

  group('a ledger entry of a return or a refund', () {
    test('settles the order the right way, and is told apart from an ordinary entry', () {
      expect(_entry(LedgerEntryType.payment, 100).orderSettlement, 100);
      expect(_entry(LedgerEntryType.payment, 100, kind: 'return').orderSettlement, 100);
      expect(_entry(LedgerEntryType.charge, 100, kind: 'refund', method: 'cash').orderSettlement, -100);
      expect(_entry(LedgerEntryType.charge, 100).orderSettlement, 0); // the sale itself
      expect(_entry(LedgerEntryType.payment, 1, kind: 'return').isReturn, isTrue);
      expect(_entry(LedgerEntryType.charge, 1, kind: 'refund').isRefund, isTrue);
    });

    test('keeps its kind when written and read back; an older server sends none', () {
      final LedgerModel back = LedgerModel.fromMap(_entry(LedgerEntryType.charge, 5, kind: 'refund').toMap());
      expect(back.kind, 'refund');
      expect(LedgerModel.fromMap(<String, dynamic>{'id': 'x', 'entryType': 'payment', 'amount': 3}).kind, '');
      expect(back.copyWith(amount: 7).kind, 'refund');
    });

    test('what the order has settled counts returns and takes refunds away', () async {
      final ProviderContainer c = ProviderContainer(overrides: <Override>[
        ledgerEntriesProvider.overrideWith(_FakeLedger.new),
      ]);
      addTearDown(c.dispose);
      await c.read(ledgerEntriesProvider.future);
      expect(c.read(orderPaidProvider)['o1'], 400);
    });

    test('a receipt shows the goods and the money handed back next to the payments', () {
      final OrderModel order = _order();
      final ReceiptData receipt = ReceiptData.fromOrder(
        order,
        ledger: <LedgerModel>[
          _entry(LedgerEntryType.charge, 400),
          _entry(LedgerEntryType.payment, 400, method: 'cash'),
          _entry(LedgerEntryType.payment, 100, kind: 'return'),
          _entry(LedgerEntryType.charge, 100, kind: 'refund', method: 'cash'),
        ],
        shopName: 'Shop',
        walkInCustomerId: '',
      );
      expect(receipt.payments.map((ReceiptPayment p) => p.amount), <double>[400, 100, -100]);
    });
  });

  test('a return is read from the server, with and without money handed back', () {
    final OrderReturn r = OrderReturn.fromMap(<String, dynamic>{
      'id': 'r',
      'returnNo': 'RET-1',
      'orderId': 'o1',
      'returnDate': '2026-11-22T10:00:00.000Z',
      'totalValue': 100,
      'refundMethod': 'cash',
      'refundAmount': 100,
      'byName': 'Ali',
      'items': <Object?>[
        <String, dynamic>{'orderItemId': 'a', 'productName': 'Bat', 'quantity': 2, 'value': 100, 'restocked': false},
      ],
    });
    expect(r.handedMoneyBack, isTrue);
    expect(r.totalUnits, 2);
    expect(r.items.single.restocked, isFalse);
    expect(OrderReturn.fromMap(<String, dynamic>{'id': 'x'}).handedMoneyBack, isFalse);
    expect(OrderReturn.fromMap(<String, dynamic>{'id': 'x'}).refundMethod, 'credit');
  });

  group('the return screen', () {
    Future<_FakeReturns> pump(WidgetTester tester, {required double settled, String customerId = 'c1', BusinessInfo? business}) async {
      final _FakeReturns service = _FakeReturns();
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(ProviderScope(
        overrides: <Override>[
          returnsServiceProvider.overrideWithValue(service),
          orderPaidProvider.overrideWithValue(<String, double>{'o1': settled}),
          businessProvider.overrideWithValue(business ?? const BusinessInfo(id: 't', name: 'Ali', walkInCustomerId: 'walk')),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReturnScreen(order: _order(customerId: customerId)),
        ),
      ));
      await tester.pumpAndSettle();
      return service;
    }

    Future<void> add(WidgetTester tester, int times) async {
      for (int i = 0; i < times; i++) {
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pump();
      }
    }

    testWidgets('an order that was not paid: the goods just lower what is owed', (WidgetTester tester) async {
      final _FakeReturns service = await pump(tester, settled: 0);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
      await add(tester, 2);
      expect(find.text('Rs 200'), findsWidgets);
      expect(find.text('This lowers what the customer still owes.'), findsOneWidget);
      await tester.tap(find.text('Return the items'));
      await tester.pumpAndSettle();
      expect(service.created.single, <String, Object?>{'lines': <String>['ax2'], 'method': 'credit', 'amount': null, 'note': ''});
    });

    testWidgets('a paid order: hands the money back by cash, or keeps it as credit', (WidgetTester tester) async {
      final _FakeReturns service = await pump(tester, settled: 400);
      await add(tester, 1);
      expect(find.textContaining('Rs 100 was paid for goods'), findsOneWidget);
      expect(find.text('Hand the money back'), findsOneWidget);
      await tester.tap(find.text('Return the items'));
      await tester.pumpAndSettle();
      expect(service.created.single['method'], 'cash');
      expect(service.created.single['amount'], 100.0);
    });

    testWidgets('credit can be chosen, and damaged goods are flagged', (WidgetTester tester) async {
      final _FakeReturns service = await pump(tester, settled: 400);
      await add(tester, 1);
      await tester.tap(find.text('Keep it as credit on the customer\'s account'));
      await tester.pump();
      await tester.tap(find.text('Damaged: do not put it back in stock'));
      await tester.pump();
      await tester.tap(find.text('Return the items'));
      await tester.pumpAndSettle();
      expect(service.created.single['method'], 'credit');
      expect(service.created.single['lines'], <String>['ax1!']);
    });

    testWidgets('a walk-in customer cannot keep credit', (WidgetTester tester) async {
      await pump(tester, settled: 400, customerId: 'walk');
      await add(tester, 1);
      expect(find.text('A walk-in customer cannot keep credit, so the money is handed back.'), findsOneWidget);
    });

    testWidgets('the amount cannot be more than was paid for the goods', (WidgetTester tester) async {
      await pump(tester, settled: 400);
      await add(tester, 1);
      await tester.enterText(find.widgetWithText(TextField, 'Amount handed back'), '150');
      await tester.pump();
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
      await tester.enterText(find.widgetWithText(TextField, 'Amount handed back'), '60');
      await tester.pump();
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNotNull);
    });
  });
}
