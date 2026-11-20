import 'package:a2_stocks/models/report_models.dart';
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

  Future<ProfitReport> profit({String? from, String? to}) async {
    final ApiResponse r = await _api.get('/v1/reports/profit', query: _period(from, to));
    return ProfitReport.fromMap(r.asMap);
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
