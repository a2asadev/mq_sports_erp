import 'package:uuid/uuid.dart';
import 'package:a2_stocks/models/stock_transfer.dart';
import 'package:a2_stocks/online/api_client.dart';

/// Moving stock between branches (`/v1/stock-transfers`; needs a connection). The stock movements it makes come back
/// through the sync.
class TransfersService {
  TransfersService(this._api);

  final ApiClient _api;

  Future<List<StockTransfer>> list() async => <StockTransfer>[
        for (final Object? t in ((await _api.get('/v1/stock-transfers', query: <String, String>{'limit': '100'})).asMap['items'] as List<Object?>? ?? <Object?>[]))
          if (t is Map<String, dynamic>) StockTransfer.fromMap(t),
      ];

  /// [quantities] is variant id -> units. The id makes a retry after a dropped connection the same transfer.
  Future<StockTransfer> create({required String fromBranchId, required String toBranchId, required Map<String, int> quantities, String note = '', String? id}) async {
    final ApiResponse r = await _api.post('/v1/stock-transfers', body: <String, dynamic>{
      'id': id ?? const Uuid().v4(),
      'fromBranchId': fromBranchId,
      'toBranchId': toBranchId,
      'note': note.trim(),
      'items': <Map<String, dynamic>>[for (final MapEntry<String, int> e in quantities.entries) <String, dynamic>{'variantId': e.key, 'quantity': e.value}],
    });
    return StockTransfer.fromMap(r.asMap);
  }
}
