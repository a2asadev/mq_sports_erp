import 'package:uuid/uuid.dart';
import 'package:a2_stocks/models/order_return.dart';
import 'package:a2_stocks/online/api_client.dart';

/// Units of one order line coming back, and whether they can be sold again.
class ReturnLineRequest {
  const ReturnLineRequest({required this.orderItemId, required this.quantity, this.restock = true});

  final String orderItemId;
  final int quantity;
  final bool restock;
}

/// Returns and refunds (`/v1/orders/:id/returns`). A return needs a connection:
/// the server works out what the goods were worth and how much can go back, and
/// its stock and ledger entries then reach every device through the sync.
class ReturnsService {
  ReturnsService(this._api);

  final ApiClient _api;

  /// The returns of one order, oldest first.
  Future<List<OrderReturn>> forOrder(String orderId) async {
    final ApiResponse response = await _api.get('/v1/orders/$orderId/returns');
    return <OrderReturn>[
      for (final Object? item in response.asList)
        if (item is Map<String, dynamic>) OrderReturn.fromMap(item),
    ];
  }

  /// Takes the goods back. [refundMethod] is 'credit' (keep the value on the
  /// customer's account) or cash/bank/easypaisa/jazzcash with [refundAmount]
  /// (everything owed when left out). The request id doubles as the idempotency
  /// key, so a double tap cannot return the goods twice.
  Future<OrderReturn> create({
    required String orderId,
    required List<ReturnLineRequest> lines,
    String refundMethod = OrderReturn.creditMethod,
    double? refundAmount,
    String note = '',
    String? requestId,
  }) async {
    final String id = requestId ?? const Uuid().v4();
    final ApiResponse response = await _api.post(
      '/v1/orders/$orderId/returns',
      idempotencyKey: id,
      body: <String, dynamic>{
        'id': id,
        'items': <Map<String, dynamic>>[
          for (final ReturnLineRequest line in lines)
            <String, dynamic>{'orderItemId': line.orderItemId, 'quantity': line.quantity, 'restock': line.restock},
        ],
        'refund': <String, dynamic>{
          'method': refundMethod,
          if (refundMethod != OrderReturn.creditMethod && refundAmount != null)
            'amount': (refundAmount * 100).roundToDouble() / 100,
        },
        if (note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
    return OrderReturn.fromMap(response.asMap);
  }
}
