import 'package:a2_stocks/models/report_models.dart';
import 'package:a2_stocks/models/reorder.dart';
import 'package:a2_stocks/online/api_client.dart';

/// Reports for the owner (`/v1/reports/*`, admin and manager). The server works the
/// figures out, so every device shows the same ones; they need a connection.
class ReportsService {
  ReportsService(this._api);

  final ApiClient _api;

  Map<String, String> _period(String? from, String? to) => <String, String>{
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      };

  /// [groupBy] is product, category, customer or cashier; [from] and [to] are "YYYY-MM-DD" (both included).
  Future<SalesReport> sales({required String groupBy, String? from, String? to}) async {
    final ApiResponse r = await _api.get('/v1/reports/sales', query: <String, String>{..._period(from, to), 'groupBy': groupBy});
    return SalesReport.fromMap(r.asMap);
  }

  /// Sales per person and the hours they worked, for the days [from] to [to].
  Future<StaffReport> staff({String? from, String? to}) async => StaffReport.fromMap((await _api.get('/v1/reports/staff', query: _period(from, to))).asMap);

  /// A shift log from the sales: each person's first and last sale of each day.
  Future<ShiftsReport> shifts({String? from, String? to}) async => ShiftsReport.fromMap((await _api.get('/v1/reports/shifts', query: _period(from, to))).asMap);

  Future<ProfitReport> profit({String? from, String? to}) async {
    final ApiResponse r = await _api.get('/v1/reports/profit', query: _period(from, to));
    return ProfitReport.fromMap(r.asMap);
  }

  /// What to reorder: items that are out, low or running out, how much and from whom. [days] is how far back
  /// sales are looked at; [coverDays] how many days of sales the stock should cover once the order arrives.
  Future<ReorderReport> reorder({int days = 30, int coverDays = 30}) async {
    final ApiResponse r = await _api.get('/v1/reports/reorder', query: <String, String>{'days': '$days', 'coverDays': '$coverDays'});
    return ReorderReport.fromMap(r.asMap);
  }

  /// Tax collected, given back with returns and owed, for the days [from] to [to].
  Future<TaxReport> tax({String? from, String? to}) async {
    final ApiResponse r = await _api.get('/v1/reports/tax', query: _period(from, to));
    return TaxReport.fromMap(r.asMap);
  }

  /// Stock that did not sell in the last [days] days.
  Future<StockReport> stock({int days = 90}) async {
    final ApiResponse r = await _api.get('/v1/reports/stock', query: <String, String>{'days': '$days'});
    return StockReport.fromMap(r.asMap);
  }

  Future<AgeingReport> receivables() async => AgeingReport.fromMap((await _api.get('/v1/reports/receivables')).asMap);

  Future<AgeingReport> payables() async => AgeingReport.fromMap((await _api.get('/v1/reports/payables')).asMap);
}
