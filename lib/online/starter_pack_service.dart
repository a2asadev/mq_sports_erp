import 'package:mq_sports_erp/models/starter_pack.dart';
import 'package:mq_sports_erp/online/api_client.dart';

/// Starter category packs from the server. Needs a connection; admins and
/// managers only (the server refuses anyone else).
class StarterPackService {
  StarterPackService({required ApiClient api, required Future<void> Function() refresh})
      : _api = api,
        _refresh = refresh;

  final ApiClient _api;

  /// Brings the new categories onto this device (the web copy is refreshed; the
  /// others pull).
  final Future<void> Function() _refresh;

  Future<List<StarterPack>> list() async {
    final ApiResponse response = await _api.get('/v1/starter-packs');
    return <StarterPack>[
      for (final Object? item in response.asList)
        if (StarterPack.tryFromMap(item) case final StarterPack pack) pack,
    ];
  }

  /// Adds the pack's categories. [groups] are the top-level names to add; null
  /// adds the whole pack. Safe to repeat: what the business already has is left alone.
  Future<StarterPackResult> apply(String packId, {List<String>? groups}) async {
    final ApiResponse response = await _api.post(
      '/v1/starter-packs/$packId/apply',
      body: <String, dynamic>{if (groups != null) 'groups': groups},
    );
    await _refresh();
    return StarterPackResult.fromMap(response.asMap);
  }
}
