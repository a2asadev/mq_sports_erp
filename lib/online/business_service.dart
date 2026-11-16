import 'package:mq_sports_erp/models/business_info.dart';
import 'package:mq_sports_erp/online/api_client.dart';

/// Changes that belong to the business itself (not to the online store). Needs a
/// connection: the business lives on the server.
class BusinessService {
  BusinessService(this._api);

  final ApiClient _api;

  /// Sets the business's currency. Admin only (the server refuses anyone else).
  /// Amounts already recorded are not converted. Returns the business as the
  /// server now describes it.
  Future<BusinessInfo?> saveCurrency(String code) async {
    final ApiResponse response = await _api.put('/v1/business', body: <String, dynamic>{'currency': code});
    return BusinessInfo.tryFromMap(response.asMap);
  }
}
