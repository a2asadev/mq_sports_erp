import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/models/report_models.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/reports_service.dart';
import 'package:a2_stocks/providers/core_providers.dart';

final Provider<ReportsService> reportsServiceProvider =
    Provider<ReportsService>((Ref ref) => ReportsService(ref.watch(apiClientProvider)));

enum ReportKind { sales, profit, stock, receivables, payables }

/// The ready-made periods of the sales and profit reports, and "custom" for any two days.
enum ReportRange { today, last7, thisMonth, lastMonth, thisYear, custom }

/// A period of whole days (both ends included).
class ReportPeriod {
  const ReportPeriod({required this.range, required this.from, required this.to});

  final ReportRange range;
  final DateTime from;
  final DateTime to;

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _key(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

  String get fromKey => _key(from);
  String get toKey => _key(to);

  /// A ready-made period as of [now]; "custom" needs its own days.
  factory ReportPeriod.preset(ReportRange range, DateTime now) {
    final DateTime today = DateTime(now.year, now.month, now.day);
    switch (range) {
      case ReportRange.today:
        return ReportPeriod(range: range, from: today, to: today);
      case ReportRange.last7:
        return ReportPeriod(range: range, from: today.subtract(const Duration(days: 6)), to: today);
      case ReportRange.thisMonth:
      case ReportRange.custom:
        return ReportPeriod(range: ReportRange.thisMonth, from: DateTime(now.year, now.month), to: today);
      case ReportRange.lastMonth:
        return ReportPeriod(range: range, from: DateTime(now.year, now.month - 1), to: DateTime(now.year, now.month, 0));
      case ReportRange.thisYear:
        return ReportPeriod(range: range, from: DateTime(now.year), to: today);
    }
  }

  @override
  bool operator ==(Object other) => other is ReportPeriod && other.fromKey == fromKey && other.toKey == toKey;

  @override
  int get hashCode => Object.hash(fromKey, toKey);
}

final StateProvider<ReportKind> reportKindProvider = StateProvider<ReportKind>((Ref ref) => ReportKind.sales);
final StateProvider<ReportPeriod> reportPeriodProvider =
    StateProvider<ReportPeriod>((Ref ref) => ReportPeriod.preset(ReportRange.thisMonth, DateTime.now()));

/// product, category, customer or cashier.
final StateProvider<String> salesGroupProvider = StateProvider<String>((Ref ref) => 'product');

/// How many days back "stock that does not sell" looks.
final StateProvider<int> stockDaysProvider = StateProvider<int>((Ref ref) => 90);

final AutoDisposeFutureProvider<SalesReport> salesReportProvider = FutureProvider.autoDispose<SalesReport>((Ref ref) {
  final ReportPeriod period = ref.watch(reportPeriodProvider);
  ref.watch(syncTickProvider);
  return ref.watch(reportsServiceProvider).sales(groupBy: ref.watch(salesGroupProvider), from: period.fromKey, to: period.toKey);
});

final AutoDisposeFutureProvider<ProfitReport> profitReportProvider = FutureProvider.autoDispose<ProfitReport>((Ref ref) {
  final ReportPeriod period = ref.watch(reportPeriodProvider);
  ref.watch(syncTickProvider);
  return ref.watch(reportsServiceProvider).profit(from: period.fromKey, to: period.toKey);
});

final AutoDisposeFutureProvider<StockReport> stockReportProvider = FutureProvider.autoDispose<StockReport>((Ref ref) {
  ref.watch(syncTickProvider);
  return ref.watch(reportsServiceProvider).stock(days: ref.watch(stockDaysProvider));
});

final AutoDisposeFutureProvider<AgeingReport> receivablesReportProvider = FutureProvider.autoDispose<AgeingReport>((Ref ref) {
  ref.watch(syncTickProvider);
  return ref.watch(reportsServiceProvider).receivables();
});

final AutoDisposeFutureProvider<AgeingReport> payablesReportProvider = FutureProvider.autoDispose<AgeingReport>((Ref ref) {
  ref.watch(syncTickProvider);
  return ref.watch(reportsServiceProvider).payables();
});
