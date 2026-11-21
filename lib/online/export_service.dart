import 'package:a2_stocks/models/export_models.dart';
import 'package:a2_stocks/online/api_client.dart';

/// Taking the business's data out (`/v1/export`, admin only, needs a connection).
class ExportService {
  ExportService(this._api);

  final ApiClient _api;

  Future<ExportOverview> overview() async => ExportOverview.fromMap((await _api.get('/v1/export')).asMap);

  Future<ExportFile> file(String dataset) async => ExportFile.fromMap((await _api.get('/v1/export/$dataset')).asMap);
}
