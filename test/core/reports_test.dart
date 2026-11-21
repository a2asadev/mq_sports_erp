import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/core/utils/report_builders.dart';
import 'package:a2_stocks/core/utils/report_pdf.dart';
import 'package:a2_stocks/core/utils/report_table.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/reorder.dart';
import 'package:a2_stocks/models/report_models.dart';
import 'package:a2_stocks/online/reports_service.dart';
import 'package:a2_stocks/providers/report_providers.dart';
import 'package:a2_stocks/screens/reports/reports_screen.dart';

AppLocalizations get _l10n => lookupAppLocalizations(const Locale('en'));

const Map<String, dynamic> _sales = <String, dynamic>{
  'period': <String, dynamic>{'from': '2026-11-01', 'to': '2026-11-22'},
  'groupBy': 'product',
  'rows': <Object?>[
    <String, dynamic>{'key': 'p1', 'name': 'Cricket Bat, "Pro"', 'units': 5, 'orders': 2, 'revenue': 462, 'returned': 0, 'cost': 300, 'profit': 162, 'margin': 35.06},
    <String, dynamic>{'key': 'p2', 'name': 'Ball', 'units': 1, 'orders': 1, 'revenue': 25, 'returned': 0, 'cost': 10, 'profit': 15, 'margin': 60},
  ],
  'totals': <String, dynamic>{'key': '', 'name': '', 'units': 6, 'orders': 3, 'revenue': 487, 'returned': 0, 'cost': 310, 'profit': 177, 'margin': 36.3},
};

const Map<String, dynamic> _staff = <String, dynamic>{
  'period': <String, dynamic>{'from': '2026-11-01', 'to': '2026-11-22'},
  'rows': <Object?>[
    <String, dynamic>{'key': 'u1', 'name': 'Bilal', 'orders': 3, 'units': 7, 'revenue': 900, 'returned': 100, 'average': 300, 'discounts': 40, 'cancelled': 1, 'activeDays': 2, 'firstSale': '09:15', 'lastSale': '18:40'},
    <String, dynamic>{'key': '', 'name': '', 'orders': 1, 'units': 2, 'revenue': 200, 'returned': 0, 'average': 200, 'discounts': 0, 'cancelled': 0, 'activeDays': 1, 'firstSale': '', 'lastSale': ''},
  ],
  'totals': <String, dynamic>{'orders': 4, 'units': 9, 'revenue': 1100, 'returned': 100, 'discounts': 40, 'cancelled': 1},
};

const Map<String, dynamic> _shifts = <String, dynamic>{
  'period': <String, dynamic>{'from': '2026-11-01', 'to': '2026-11-22'},
  'rows': <Object?>[
    <String, dynamic>{'day': '2026-11-20', 'key': 'u1', 'name': 'Bilal', 'firstSale': '09:15', 'lastSale': '18:40', 'orders': 3, 'revenue': 900},
    <String, dynamic>{'day': '2026-11-20', 'key': '', 'name': '', 'firstSale': '11:00', 'lastSale': '11:00', 'orders': 1, 'revenue': 200},
  ],
};

class _FakeReports implements ReportsService {
  final List<String> asked = <String>[];

  @override
  Future<SalesReport> sales({required String groupBy, String? from, String? to, String? branchId}) async {
    asked.add('sales:$groupBy:$from:$to');
    return SalesReport.fromMap(<String, dynamic>{..._sales, 'groupBy': groupBy});
  }

  @override
  Future<StaffReport> staff({String? from, String? to, String? branchId}) async {
    asked.add('staff');
    return StaffReport.fromMap(_staff);
  }

  @override
  Future<ShiftsReport> shifts({String? from, String? to, String? branchId}) async {
    asked.add('shifts');
    return ShiftsReport.fromMap(_shifts);
  }

  @override
  Future<ProfitReport> profit({String? from, String? to, String? branchId}) async {
    asked.add('profit');
    return ProfitReport.fromMap(<String, dynamic>{
      'period': <String, dynamic>{'from': '2026-11-01', 'to': '2026-11-22'},
      'grossRevenue': 487,
      'returned': 100,
      'netRevenue': 387,
      'costOfGoods': 250,
      'grossProfit': 137,
      'grossMargin': 35.4,
      'expenses': 20,
      'netProfit': 117,
      'shippingFees': 0,
      'orders': 2,
      'byDay': <Object?>[<String, dynamic>{'date': '2026-11-20', 'revenue': 387, 'cost': 250, 'expenses': 20, 'profit': 117}],
    });
  }

  @override
  Future<ReorderReport> reorder({int days = 30, int coverDays = 30}) async => const ReorderReport(days: 30, coverDays: 30, rows: <ReorderSuggestion>[]);

  @override
  Future<TaxReport> tax({String? from, String? to}) async {
    asked.add('tax');
    return TaxReport.fromMap(<String, dynamic>{
      'period': <String, dynamic>{'from': '2026-11-01', 'to': '2026-11-22'},
      'enabled': true,
      'gstRate': 17,
      'vatRate': 5,
      'collected': <String, dynamic>{'gst': 51, 'vat': 15, 'total': 66},
      'returned': <String, dynamic>{'gst': 17, 'vat': 5, 'total': 22},
      'net': <String, dynamic>{'gst': 34, 'vat': 10, 'total': 44},
      'salesWithoutTax': 300,
      'orders': 1,
      'returns': 1,
    });
  }

  @override
  Future<StockReport> stock({int days = 90}) async {
    asked.add('stock:$days');
    return StockReport.fromMap(<String, dynamic>{
      'days': days,
      'rows': <Object?>[
        <String, dynamic>{'sku': 'NET', 'productName': 'Net', 'variantLabel': 'NET', 'onHand': 3, 'costValue': 1500, 'retailValue': 2400, 'sold': 0, 'lastSoldAt': null, 'daysSinceSold': null, 'status': 'dead'},
      ],
      'deadCount': 1,
      'deadValue': 1500,
      'slowCount': 0,
      'slowValue': 0,
    });
  }

  @override
  Future<AgeingReport> receivables() async {
    asked.add('receivables');
    return AgeingReport.fromMap(<String, dynamic>{
      'rows': <Object?>[
        <String, dynamic>{'partyId': 'a', 'name': 'Ali', 'phone': '0300', 'balance': 400, 'current': 200, 'd31to60': 200, 'd61to90': 0, 'over90': 0, 'oldestDays': 45},
      ],
      'totals': <String, dynamic>{'balance': 400, 'current': 200, 'd31to60': 200, 'd61to90': 0, 'over90': 0},
    });
  }

  @override
  Future<AgeingReport> payables() async => AgeingReport.fromMap(<String, dynamic>{'rows': <Object?>[], 'totals': <String, dynamic>{}});
}

void main() {
  group('the staff reports', () {
    test('staff performance lists each person with the average order, discounts, cancelled orders and hours', () {
      final ReportTable t = staffTable(_l10n, StaffReport.fromMap(_staff));
      expect(t.title, 'Staff performance');
      expect(t.rows.first, <Object?>['Bilal', 3, 7, 900.0, 100.0, 300.0, 40.0, 1, 2, '09:15 - 18:40']);
      expect(t.rows.last.first, 'Online store'); // no cashier
      expect(t.rows.last.last, ''); // no hours to show
      expect(t.totals?.sublist(0, 4), <Object?>['Total', 4, 9, 1100.0]);
      expect(t.totals?[5], 275.0); // 1100 / 4
      expect(t.toCsv(), contains('Bilal'));
    });

    test('the shift log lists each person and day with the first and last sale', () {
      final ReportTable t = shiftsTable(_l10n, ShiftsReport.fromMap(_shifts));
      expect(t.title, 'Shift log');
      expect(t.rows.first, <Object?>['2026-11-20', 'Bilal', '09:15', '18:40', 3, 900.0]);
      expect(t.rows.last[1], 'Online store');
    });

    test('the Reports page reads both from the server', () {
      expect(ReportKind.values, containsAll(<ReportKind>[ReportKind.staff, ReportKind.shifts]));
    });
  });

  group('a report table', () {
    final ReportTable table = salesTable(_l10n, SalesReport.fromMap(_sales));

    test('is drawn the way a person reads it', () {
      expect(ReportTable.show(462, ReportColumnType.money), 'Rs 462');
      expect(ReportTable.show(35.06, ReportColumnType.percent), '35.1%');
      expect(ReportTable.show(null, ReportColumnType.percent), '');
      expect(ReportTable.show(5.0, ReportColumnType.integer), '5');
    });

    test('is written to CSV with plain numbers, quotes and a byte order mark for Excel', () {
      final List<String> lines = table.toCsv().split('\r\n');
      expect(lines.first, '﻿Sales by product');
      expect(lines[1], '2026-11-01 - 2026-11-22');
      expect(lines.contains('Product,Units,Orders,Sales,Returned,Cost,Profit,Margin'), isTrue);
      // A name with a comma and quotes is quoted; money has no symbol and no thousands separator.
      expect(lines.contains('"Cricket Bat, ""Pro""",5,2,462.00,0.00,300.00,162.00,35.06'), isTrue);
      expect(lines.contains('Ball,1,1,25.00,0.00,10.00,15.00,60.00'), isTrue);
      expect(lines.contains('Total,6,3,487.00,0.00,310.00,177.00,36.30'), isTrue);
    });

    test('gets a file name with letters, digits and dashes', () {
      expect(table.fileName('csv'), 'sales-by-product-2026-11-01-2026-11-22.csv');
      expect(const ReportTable(title: '', subtitle: '', columns: <ReportColumn>[], rows: <List<Object?>>[]).fileName('pdf'), 'report.pdf');
    });

    test('a profit report has its summary above the days, and "no margin" is left empty', () {
      final ProfitReport r = ProfitReport.fromMap(<String, dynamic>{'period': <String, dynamic>{'from': 'a', 'to': 'b'}, 'netProfit': 5, 'byDay': <Object?>[]});
      final ReportTable t = profitTable(_l10n, r);
      expect(t.summary.map((ReportSummaryLine s) => s.label), contains('Net profit'));
      final String csv = t.toCsv();
      expect(csv, contains('Net profit,5.00'));
      expect(csv, contains('Gross margin,\r\n')); // null: nothing, not "null"
    });

    test('dead stock says so, and a never-sold item says never', () {
      final StockReport r = StockReport.fromMap(<String, dynamic>{
        'days': 90,
        'rows': <Object?>[
          <String, dynamic>{'sku': 'NET', 'productName': 'Net', 'variantLabel': 'NET', 'onHand': 3, 'costValue': 1500, 'status': 'dead'},
          <String, dynamic>{'sku': 'BAT', 'productName': 'Bat', 'variantLabel': 'Large', 'onHand': 1, 'status': 'new'},
        ],
        'deadCount': 1,
        'deadValue': 1500,
      });
      final ReportTable t = stockTable(_l10n, r);
      expect(t.rows[0].sublist(0, 2), <Object?>['NET', 'Net']);
      expect(t.rows[1][1], 'Bat · Large');
      expect(t.rows[0][5], 'Never');
      expect(t.rows[0][6], 'No sales');
      expect(t.rows[1][6], 'New');
    });

    test('an online-store order has no cashier name, so it gets a label', () {
      final SalesReport r = SalesReport.fromMap(<String, dynamic>{
        ..._sales,
        'groupBy': 'cashier',
        'rows': <Object?>[<String, dynamic>{'key': '', 'name': '', 'units': 1, 'orders': 1, 'revenue': 10, 'returned': 0, 'cost': 4, 'profit': 6, 'margin': 60}],
      });
      expect(salesTable(_l10n, r).rows.single.first, 'Online store');
      expect(salesTable(_l10n, r).title, 'Sales by cashier');
    });

    test('is written to a PDF', () async {
      final bytes = await buildReportPdf(table, author: 'Shop');
      expect(bytes.length, greaterThan(500));
      expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
    });
  });

  group('the periods', () {
    final DateTime now = DateTime(2026, 11, 22, 15);

    test('are whole days, ends included', () {
      expect(ReportPeriod.preset(ReportRange.today, now).fromKey, '2026-11-22');
      expect(ReportPeriod.preset(ReportRange.last7, now).fromKey, '2026-11-16');
      expect(ReportPeriod.preset(ReportRange.thisMonth, now).fromKey, '2026-11-01');
      final ReportPeriod last = ReportPeriod.preset(ReportRange.lastMonth, now);
      expect(last.fromKey, '2026-10-01');
      expect(last.toKey, '2026-10-31');
      expect(ReportPeriod.preset(ReportRange.thisYear, now).fromKey, '2026-01-01');
      expect(ReportPeriod.preset(ReportRange.lastMonth, DateTime(2026, 1, 5)).fromKey, '2025-12-01');
    });
  });

  group('the Reports page', () {
    Future<_FakeReports> pump(WidgetTester tester) async {
      final _FakeReports service = _FakeReports();
      await tester.binding.setSurfaceSize(const Size(1000, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(ProviderScope(
        overrides: <Override>[reportsServiceProvider.overrideWithValue(service)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReportsScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      return service;
    }

    testWidgets('opens on sales by product for this month, and regroups when asked', (WidgetTester tester) async {
      final _FakeReports service = await pump(tester);
      expect(service.asked.first, startsWith('sales:product:'));
      expect(find.text('Ball'), findsOneWidget);
      expect(find.text('Rs 487'), findsOneWidget); // the total

      await tester.tap(find.text('Customer'));
      await tester.pumpAndSettle();
      expect(service.asked.last, startsWith('sales:customer:'));

      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();
      final String today = ReportPeriod.preset(ReportRange.today, DateTime.now()).fromKey;
      expect(service.asked.last, 'sales:customer:$today:$today');
    });

    testWidgets('shows the other reports', (WidgetTester tester) async {
      final _FakeReports service = await pump(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Profit'));
      await tester.pumpAndSettle();
      expect(find.text('Net profit'), findsOneWidget);
      expect(find.text('Rs 117'), findsWidgets);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Tax'));
      await tester.pumpAndSettle();
      expect(find.text('Rs 44'), findsOneWidget); // the tax to pay
      expect(find.text('VAT'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Stock that does not sell'));
      await tester.pumpAndSettle();
      expect(find.text('No sales'), findsOneWidget);
      await tester.tap(find.text('30 days'));
      await tester.pumpAndSettle();
      expect(service.asked.last, 'stock:30');

      await tester.tap(find.widgetWithText(ChoiceChip, 'Customers who owe'));
      await tester.pumpAndSettle();
      expect(find.text('Ali'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Vendors owed'));
      await tester.pumpAndSettle();
      expect(find.text('Nothing to show for this report.'), findsOneWidget);
    });
  });
}
