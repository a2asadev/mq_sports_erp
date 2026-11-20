import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/purchase_order.dart';
import 'package:a2_stocks/models/reorder.dart';
import 'package:a2_stocks/online/purchase_orders_service.dart';
import 'package:a2_stocks/online/reports_service.dart';
import 'package:a2_stocks/providers/purchase_order_providers.dart';
import 'package:a2_stocks/providers/report_providers.dart';
import 'package:a2_stocks/screens/purchasing/reorder_screen.dart';

Map<String, dynamic> _row(String sku, {String reason = 'low', String vendorId = 'vA', String vendorName = 'Vendor A', int qty = 14, double cost = 60, int onHand = 3, int sold = 17}) =>
    <String, dynamic>{
      'variantId': 'var-$sku',
      'productId': 'prod-$sku',
      'sku': sku,
      'productName': sku,
      'variantLabel': 'Small',
      'onHand': onHand,
      'onOrder': 0,
      'alertThreshold': 5,
      'sold': sold,
      'perDay': 0.57,
      'daysLeft': 5.3,
      'suggestedQty': qty,
      'unitCost': cost,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'reason': reason,
    };

class _FakeReports implements ReportsService {
  _FakeReports(this.rows);

  List<Map<String, dynamic>> rows;
  final List<String> asked = <String>[];

  @override
  Future<ReorderReport> reorder({int days = 30, int coverDays = 30}) async {
    asked.add('$days/$coverDays');
    return ReorderReport.fromMap(<String, dynamic>{'days': days, 'coverDays': coverDays, 'rows': rows});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePos implements PurchaseOrdersService {
  final List<Map<String, Object?>> created = <Map<String, Object?>>[];

  @override
  Future<PurchaseOrder> create({required String vendorId, required List<PurchaseOrderLineRequest> lines, String expectedDate = '', String note = '', String? requestId}) async {
    created.add(<String, Object?>{
      'vendor': vendorId,
      'lines': <String>[for (final PurchaseOrderLineRequest l in lines) '${l.variantId}x${l.quantity}@${l.unitCost}'],
      'note': note,
    });
    return PurchaseOrder.fromMap(<String, dynamic>{'id': 'po1', 'poNo': 'PO-1', 'vendorId': vendorId, 'vendorName': 'x', 'status': 'open', 'items': <Object?>[], 'receipts': <Object?>[]});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('a suggestion is read from the server', () {
    final ReorderSuggestion s = ReorderSuggestion.fromMap(_row('BAT', reason: 'out'));
    expect(s.reason, ReorderReason.out);
    expect(s.suggestedQty, 14);
    expect(s.hasVendor, isTrue);
    expect(ReorderSuggestion.fromMap(_row('X', vendorId: '', vendorName: '')).hasVendor, isFalse);
    expect(ReorderSuggestion.fromMap(<String, dynamic>{'reason': 'weird'}).reason, ReorderReason.runningOut);
    expect(ReorderSuggestion.fromMap(<String, dynamic>{'daysLeft': null}).daysLeft, isNull);
  });

  group('the Reorder page', () {
    Future<(_FakeReports, _FakePos)> pump(WidgetTester tester, List<Map<String, dynamic>> rows) async {
      final _FakeReports reports = _FakeReports(rows);
      final _FakePos pos = _FakePos();
      await tester.binding.setSurfaceSize(const Size(1000, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(ProviderScope(
        overrides: <Override>[
          reportsServiceProvider.overrideWithValue(reports),
          purchaseOrdersServiceProvider.overrideWithValue(pos),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReorderScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      return (reports, pos);
    }

    testWidgets('groups the suggestions by vendor and says why and how fast each sells', (WidgetTester tester) async {
      await pump(tester, <Map<String, dynamic>>[
        _row('NET', reason: 'out', onHand: 0, qty: 10, cost: 500),
        _row('BAT'),
        _row('BALL', reason: 'running_out', vendorId: 'vB', vendorName: 'Vendor B', qty: 80, cost: 10, onHand: 10, sold: 90),
        _row('PAD', vendorId: '', vendorName: '', qty: 5, cost: 100),
      ]);
      expect(find.text('Vendor A'), findsOneWidget);
      expect(find.text('Vendor B'), findsOneWidget);
      expect(find.text('No vendor yet'), findsOneWidget);
      expect(find.text('Out of stock'), findsOneWidget);
      expect(find.text('Running out'), findsOneWidget);
      expect(find.text('2 items · Rs 5,840'), findsOneWidget); // vendor A: 10 x 500 + 14 x 60
      expect(find.textContaining('Sells 0.6 a day, about 5 days left'), findsWidgets);
      // The suggestions without a vendor ask for one instead of offering to order.
      expect(find.text('Choose vendor'), findsOneWidget);
      expect(find.text('Create order'), findsNWidgets(2));
    });

    testWidgets('creates an order for one vendor with the quantities as edited, and leaves out unticked rows', (WidgetTester tester) async {
      final (_FakeReports reports, _FakePos pos) = await pump(tester, <Map<String, dynamic>>[
        _row('NET', reason: 'out', onHand: 0, qty: 10, cost: 500),
        _row('BAT'),
        _row('BALL', reason: 'running_out', vendorId: 'vB', vendorName: 'Vendor B', qty: 80, cost: 10),
      ]);
      // Vendor A: raise the nets to 12 and leave the bats out.
      await tester.enterText(find.widgetWithText(TextField, 'Quantity').first, '12');
      await tester.tap(find.byType(Checkbox).at(1)); // the bat row
      await tester.pump();
      expect(find.text('1 items · Rs 6,000'), findsOneWidget);
      await tester.tap(find.text('Create order').first);
      await tester.pumpAndSettle();
      expect(pos.created.single, <String, Object?>{'vendor': 'vA', 'lines': <String>['var-NETx12@500.0'], 'note': 'From reorder suggestions'});
      expect(find.textContaining('Order PO-1 created'), findsOneWidget);
      // The list is read again so what was ordered leaves it.
      expect(reports.asked.length, greaterThan(1));
    });

    testWidgets('cannot order a row whose quantity is empty, and says so when nothing is picked', (WidgetTester tester) async {
      await pump(tester, <Map<String, dynamic>>[_row('BAT')]);
      await tester.enterText(find.widgetWithText(TextField, 'Quantity'), '');
      await tester.pump();
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Create order')).onPressed, isNull);
    });

    testWidgets('looks at the sales and the cover the person chooses', (WidgetTester tester) async {
      final (_FakeReports reports, _) = await pump(tester, <Map<String, dynamic>>[_row('BAT')]);
      expect(reports.asked.last, '30/30');
      await tester.tap(find.text('90 days'));
      await tester.pumpAndSettle();
      expect(reports.asked.last, '90/30');
      await tester.tap(find.text('60 days').last);
      await tester.pumpAndSettle();
      expect(reports.asked.last, '90/60');
    });

    testWidgets('says so when nothing needs ordering', (WidgetTester tester) async {
      await pump(tester, <Map<String, dynamic>>[]);
      expect(find.text('Nothing needs ordering right now.'), findsOneWidget);
    });
  });
}
