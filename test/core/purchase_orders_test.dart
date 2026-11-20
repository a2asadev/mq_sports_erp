import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/core/utils/purchase_order_text.dart';
import 'package:a2_stocks/core/utils/report_pdf.dart';
import 'package:a2_stocks/core/utils/report_table.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/purchase_order.dart';
import 'package:a2_stocks/online/purchase_orders_service.dart';
import 'package:a2_stocks/providers/purchase_order_providers.dart';
import 'package:a2_stocks/screens/purchasing/purchase_order_detail_screen.dart';
import 'package:a2_stocks/screens/purchasing/purchase_orders_screen.dart';
import 'package:a2_stocks/screens/purchasing/receive_goods_screen.dart';

Map<String, dynamic> _po({
  String id = 'po1',
  String status = 'open',
  List<List<int>> lines = const <List<int>>[<int>[10, 0], <int>[20, 0]], // [ordered, received]
  String expected = '',
}) =>
    <String, dynamic>{
      'id': id,
      'poNo': 'PO-20261128-AB12',
      'vendorId': 'v1',
      'vendorName': 'Sports Supplier',
      'orderDate': '2026-11-28T10:00:00.000Z',
      'expectedDate': expected,
      'status': status,
      'note': 'For the season',
      'byName': 'Ali',
      'orderedValue': 800,
      'receivedValue': 0,
      'items': <Object?>[
        for (int i = 0; i < lines.length; i++)
          <String, dynamic>{
            'id': 'i$i',
            'productId': 'p$i',
            'variantId': 'v$i',
            'productName': i == 0 ? 'Bat' : 'Ball',
            'variantLabel': 'Small',
            'sku': 'S$i',
            'quantity': lines[i][0],
            'unitCost': i == 0 ? 60 : 10,
            'receivedQuantity': lines[i][1],
            'remaining': lines[i][0] - lines[i][1],
          },
      ],
      'receipts': status == 'open'
          ? <Object?>[]
          : <Object?>[
              <String, dynamic>{
                'id': 'r1',
                'purchaseId': 'pu1',
                'purchaseNo': 'PUR-1',
                'receivedAt': '2026-11-29T10:00:00.000Z',
                'byName': 'Ali',
                'items': <Object?>[<String, dynamic>{'poItemId': 'i0', 'quantity': 4, 'unitCost': 60}],
              },
            ],
    };

class _FakePos implements PurchaseOrdersService {
  _FakePos(Map<String, dynamic> order) : current = PurchaseOrder.fromMap(order);

  PurchaseOrder current;
  final List<String> listed = <String>[];
  final List<Map<String, Object?>> received = <Map<String, Object?>>[];
  final List<String> actions = <String>[];

  @override
  Future<List<PurchaseOrder>> list({String? status, String? search, int limit = 100}) async {
    listed.add('${status ?? 'all'}|${search ?? ''}');
    return <PurchaseOrder>[current];
  }

  @override
  Future<PurchaseOrder> get(String id) async => current;

  @override
  Future<PurchaseOrder> create({required String vendorId, required List<PurchaseOrderLineRequest> lines, String expectedDate = '', String note = '', String? requestId}) async => current;

  @override
  Future<PurchaseOrder> receive(String orderId, {required List<ReceiveLineRequest> lines, String invoiceNo = '', String notes = '', double paidNow = 0, String? requestId}) async {
    received.add(<String, Object?>{
      'lines': <String>[for (final ReceiveLineRequest l in lines) '${l.poItemId}x${l.quantity}@${l.unitCost}'],
      'invoice': invoiceNo,
      'paid': paidNow,
    });
    return current;
  }

  @override
  Future<PurchaseOrder> cancel(String id) async {
    actions.add('cancel');
    return current;
  }

  @override
  Future<PurchaseOrder> close(String id) async {
    actions.add('close');
    return current;
  }
}

Widget _app(_FakePos service, Widget home) => ProviderScope(
      overrides: <Override>[purchaseOrdersServiceProvider.overrideWithValue(service)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );

void main() {
  group('the model', () {
    test('reads an order with what has arrived of it', () {
      final PurchaseOrder po = PurchaseOrder.fromMap(_po(status: 'partial', lines: <List<int>>[<int>[10, 4], <int>[20, 20]]));
      expect(po.status, PurchaseOrderStatus.partial);
      expect(po.orderedUnits, 30);
      expect(po.receivedUnits, 24);
      expect(po.items.first.remaining, 6);
      expect(po.receipts.single.units, 4);
      expect(po.receipts.single.purchaseNo, 'PUR-1');
    });

    test('goods can be received only while it is open or partly received', () {
      expect(PurchaseOrderStatus.open.canReceive, isTrue);
      expect(PurchaseOrderStatus.partial.canReceive, isTrue);
      for (final PurchaseOrderStatus s in <PurchaseOrderStatus>[PurchaseOrderStatus.received, PurchaseOrderStatus.closed, PurchaseOrderStatus.cancelled]) {
        expect(s.canReceive, isFalse);
      }
      expect(PurchaseOrderStatus.fromName('nonsense'), PurchaseOrderStatus.open);
    });

    test('is late when the expected day has passed and goods can still come', () {
      final DateTime now = DateTime(2026, 12, 10, 15);
      expect(PurchaseOrder.fromMap(_po(expected: '2026-12-09')).isLate(now), isTrue);
      expect(PurchaseOrder.fromMap(_po(expected: '2026-12-10')).isLate(now), isFalse); // today is not late
      expect(PurchaseOrder.fromMap(_po(expected: '')).isLate(now), isFalse);
      expect(PurchaseOrder.fromMap(_po(expected: '2026-12-01', status: 'received')).isLate(now), isFalse);
    });
  });

  group('the list', () {
    testWidgets('shows each order with its progress, and narrows by status and search', (WidgetTester tester) async {
      final _FakePos service = _FakePos(_po(status: 'partial', lines: <List<int>>[<int>[10, 4], <int>[20, 20]], expected: '2020-01-01'));
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(service, const PurchaseOrdersScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Sports Supplier'), findsOneWidget);
      expect(find.text('24 of 30 units received'), findsOneWidget);
      expect(find.text('Expected 2020-01-01: late'), findsOneWidget);
      expect(find.widgetWithText(Container, 'Partly received'), findsWidgets);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Open'));
      await tester.pumpAndSettle();
      expect(service.listed.last, 'open|');
      await tester.enterText(find.byType(TextField), 'supplier');
      await tester.pumpAndSettle();
      expect(service.listed.last, 'open|supplier');
    });
  });

  group('one order', () {
    Future<_FakePos> open(WidgetTester tester, Map<String, dynamic> order) async {
      final _FakePos service = _FakePos(order);
      await tester.binding.setSurfaceSize(const Size(900, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(service, const PurchaseOrderDetailScreen(orderId: 'po1')));
      await tester.pumpAndSettle();
      return service;
    }

    testWidgets('an open order can be received or cancelled, not closed', (WidgetTester tester) async {
      final _FakePos service = await open(tester, _po());
      expect(find.text('Receive goods'), findsOneWidget);
      expect(find.text('Cancel order'), findsOneWidget);
      expect(find.text('Close order'), findsNothing);
      expect(find.text('10 still to come'), findsOneWidget);

      await tester.tap(find.text('Cancel order'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(service.actions, <String>['cancel']);
    });

    testWidgets('a partly received order can be received more or closed, and lists its receipts', (WidgetTester tester) async {
      final _FakePos service = await open(tester, _po(status: 'partial', lines: <List<int>>[<int>[10, 4], <int>[20, 20]]));
      expect(find.text('Receive goods'), findsOneWidget);
      expect(find.text('Close order'), findsOneWidget);
      expect(find.text('Cancel order'), findsNothing);
      expect(find.text('PUR-1'), findsOneWidget);
      await tester.tap(find.text('Close order'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(service.actions, <String>['close']);
    });

    testWidgets('a finished order has no actions', (WidgetTester tester) async {
      await open(tester, _po(status: 'received', lines: <List<int>>[<int>[10, 10], <int>[20, 20]]));
      expect(find.text('Receive goods'), findsNothing);
      expect(find.text('Cancel order'), findsNothing);
      expect(find.text('Close order'), findsNothing);
    });
  });

  group('sending an order to the vendor', () {
    AppLocalizations l10n() => lookupAppLocalizations(const Locale('en'));

    test('the message lists what is ordered, the total, the note and what is asked of the vendor', () {
      final PurchaseOrder po = PurchaseOrder.fromMap(_po(expected: '2026-12-15'));
      final String text = purchaseOrderMessage(l10n(), po, shopName: 'Ali Sports', shopPhone: '0300-1');
      expect(text, contains('*Ali Sports*'));
      expect(text, contains('Purchase order PO-20261128-AB12'));
      expect(text, contains('To: Sports Supplier'));
      expect(text, contains('Expected by: 2026-12-15'));
      expect(text, contains('10 x Bat (Small) @ Rs 60 = Rs 600'));
      expect(text, contains('20 x Ball (Small) @ Rs 10 = Rs 200'));
      expect(text, contains('Total: Rs 800'));
      expect(text, contains('Note: For the season'));
      expect(text, contains('Please confirm availability and the delivery date.'));
      expect(text, isNot(contains('Still to be delivered')));
    });

    test('a partly received order asks only for what has not arrived', () {
      final PurchaseOrder po = PurchaseOrder.fromMap(_po(status: 'partial', lines: <List<int>>[<int>[10, 4], <int>[20, 20]]));
      final String text = purchaseOrderMessage(l10n(), po, shopName: 'Ali Sports');
      expect(text, contains('Still to be delivered:'));
      expect(text, contains('6 x Bat (Small) @ Rs 60 = Rs 360'));
      expect(text, isNot(contains('Ball'))); // all of it arrived
      expect(text, contains('Total: Rs 360'));
    });

    test('the PDF is the same order as a table with a total, and builds', () async {
      final PurchaseOrder po = PurchaseOrder.fromMap(_po(expected: '2026-12-15'));
      final ReportTable table = purchaseOrderTable(l10n(), po, shopName: 'Ali Sports', vendorPhone: '0300-2');
      expect(table.title, 'Purchase order PO-20261128-AB12');
      expect(table.rows.map((List<Object?> r) => r[2]), <Object?>[10, 20]);
      expect(table.totals!.last, 800);
      expect(table.summary.first.value, 'Sports Supplier · 0300-2');
      final bytes = await buildReportPdf(table, author: 'Ali Sports');
      expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
    });

    Future<void> open(WidgetTester tester, Map<String, dynamic> order) async {
      await tester.binding.setSurfaceSize(const Size(900, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(_FakePos(order), const PurchaseOrderDetailScreen(orderId: 'po1')));
      await tester.pumpAndSettle();
    }

    testWidgets('the order page offers WhatsApp, share PDF and print, unless the order was cancelled', (WidgetTester tester) async {
      await open(tester, _po());
      await tester.tap(find.text('Send to vendor'));
      await tester.pumpAndSettle();
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('Share PDF'), findsOneWidget);
      expect(find.text('Print or save PDF'), findsOneWidget);
    });

    testWidgets('a cancelled order is not sent', (WidgetTester tester) async {
      await open(tester, _po(status: 'cancelled'));
      expect(find.text('Send to vendor'), findsNothing);
    });
  });

  group('receiving goods', () {
    Future<_FakePos> open(WidgetTester tester, Map<String, dynamic> order) async {
      final _FakePos service = _FakePos(order);
      await tester.binding.setSurfaceSize(const Size(900, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(service, ReceiveGoodsScreen(order: PurchaseOrder.fromMap(order))));
      await tester.pumpAndSettle();
      return service;
    }

    testWidgets('starts with everything that is left, and receives it with one tap', (WidgetTester tester) async {
      final _FakePos service = await open(tester, _po(status: 'partial', lines: <List<int>>[<int>[10, 4], <int>[20, 20]]));
      // The ball line is complete, so only the bat line is asked about.
      expect(find.text('Bat · Small'), findsOneWidget);
      expect(find.text('Ball · Small'), findsNothing);
      expect(find.text('Receiving: Rs 360'), findsOneWidget); // 6 x 60
      await tester.tap(find.widgetWithText(FilledButton, 'Receive goods'));
      await tester.pumpAndSettle();
      expect(service.received.single, <String, Object?>{'lines': <String>['i0x6@null'], 'invoice': '', 'paid': 0.0});
    });

    testWidgets('takes a part, a different invoice price, an invoice number and a payment', (WidgetTester tester) async {
      final _FakePos service = await open(tester, _po());
      await tester.enterText(find.widgetWithText(TextField, 'Arrived').first, '4');
      await tester.enterText(find.widgetWithText(TextField, 'Price on the invoice').first, '65');
      await tester.enterText(find.widgetWithText(TextField, 'Arrived').last, '0'); // none of the balls yet
      await tester.enterText(find.widgetWithText(TextField, 'Invoice number (optional)'), 'INV-9');
      await tester.enterText(find.widgetWithText(TextField, 'Paid to the vendor now (optional)'), '100');
      await tester.pump();
      expect(find.text('Receiving: Rs 260'), findsOneWidget); // 4 x 65
      await tester.tap(find.widgetWithText(FilledButton, 'Receive goods'));
      await tester.pumpAndSettle();
      expect(service.received.single, <String, Object?>{'lines': <String>['i0x4@65.0'], 'invoice': 'INV-9', 'paid': 100.0});
    });

    testWidgets('cannot take more than is left, nothing at all, or pay more than arrived', (WidgetTester tester) async {
      await open(tester, _po());
      FilledButton button() => tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Receive goods'));
      expect(button().onPressed, isNotNull);
      await tester.enterText(find.widgetWithText(TextField, 'Arrived').first, '11');
      await tester.pump();
      expect(find.text('At most 10'), findsOneWidget);
      expect(button().onPressed, isNull);
      await tester.enterText(find.widgetWithText(TextField, 'Arrived').first, '0');
      await tester.enterText(find.widgetWithText(TextField, 'Arrived').last, '0');
      await tester.pump();
      expect(button().onPressed, isNull); // nothing arrived
      await tester.enterText(find.widgetWithText(TextField, 'Arrived').first, '1');
      await tester.enterText(find.widgetWithText(TextField, 'Paid to the vendor now (optional)'), '999');
      await tester.pump();
      expect(find.textContaining('More than the'), findsOneWidget);
      expect(button().onPressed, isNull);
    });
  });
}
