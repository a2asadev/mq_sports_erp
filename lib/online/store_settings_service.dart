import 'package:mq_sports_erp/models/store_settings_model.dart';
import 'package:mq_sports_erp/online/api_client.dart';

/// Reads and saves the online store's settings. Needs a connection (the settings
/// live only on the server).
class StoreSettingsService {
  StoreSettingsService(this._api);

  final ApiClient _api;

  Future<StoreSettingsModel> load() async {
    final ApiResponse response = await _api.get('/v1/store-settings');
    return StoreSettingsModel.fromMap(response.asMap);
  }

  /// Admin only (the server refuses anyone else).
  Future<StoreSettingsModel> save(StoreSettingsModel settings) async {
    final ApiResponse response = await _api.put('/v1/store-settings', body: <String, dynamic>{
      ...settings.toMap(),
      'deliveryFee': (settings.deliveryFee * 100).round() / 100,
      'freeDeliveryAbove': (settings.freeDeliveryAbove * 100).round() / 100,
    });
    return StoreSettingsModel.fromMap(response.asMap);
  }

  Future<TestEmailResult> sendTestEmail(String to) async {
    final ApiResponse response =
        await _api.post('/v1/store-settings/test-email', body: <String, dynamic>{'to': to});
    return TestEmailResult.fromMap(response.asMap);
  }
}
