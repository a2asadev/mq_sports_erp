import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/online/api_client.dart';

/// Changes that belong to the business itself (not to the online store). Needs a
/// connection: the business lives on the server.
class BusinessService {
  BusinessService(this._api);

  final ApiClient _api;

  /// Changes the currency, the accent colour and/or whether a cash register is kept; pass only what changes.
  /// [brandColor] is "#RRGGBB", or '' to go back to the default A2 Stocks theme.
  /// Admin only (the server refuses anyone else). Amounts already recorded are
  /// not converted when the currency changes. Returns the business as the server
  /// now describes it.
  Future<BusinessInfo?> update({String? currency, String? brandColor, bool? usesRegister}) async {
    final ApiResponse response = await _api.put('/v1/business', body: <String, dynamic>{
      if (currency != null) 'currency': currency,
      if (brandColor != null) 'brandColor': brandColor,
      if (usesRegister != null) 'usesRegister': usesRegister,
    });
    return BusinessInfo.tryFromMap(response.asMap);
  }

  Future<BusinessInfo?> saveUsesRegister(bool on) => update(usesRegister: on);

  Future<BusinessInfo?> saveCurrency(String code) => update(currency: code);
}
