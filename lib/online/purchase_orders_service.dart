import 'package:uuid/uuid.dart';
import 'package:a2_stocks/models/purchase_order.dart';
import 'package:a2_stocks/online/api_client.dart';

/// Purchase orders and the receipt of goods (`/v1/purchase-orders`, admin and manager). They need a connection:
/// receiving goods is one step on the server (the purchase, the stock and the vendor's balance), and the stock
/// and ledger changes then reach every device through the normal sync.
class PurchaseOrdersService {
  PurchaseOrdersService(this._api);

  final ApiClient _api;

  Future<List<PurchaseOrder>> list({String? status, String? search, int limit = 100}) async {
    final ApiResponse r = await _api.get('/v1/purchase-orders', query: <String, String>{
      if (status != null) 'status': status,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      'limit': '$limit',
    });
    final Object? items = r.asMap['items'];
    return <PurchaseOrder>[
      if (items is List<Object?>)
        for (final Object? i in items)
          if (i is Map<String, dynamic>) PurchaseOrder.fromMap(i),
    ];
  }

  Future<PurchaseOrder> get(String id) async => PurchaseOrder.fromMap((await _api.get('/v1/purchase-orders/$id')).asMap);

  /// Orders goods from a vendor. The id doubles as the idempotency key, so a double tap orders once.
  Future<PurchaseOrder> create({
    required String vendorId,
    required List<PurchaseOrderLineRequest> lines,
    String expectedDate = '',
    String note = '',
    String? requestId,
  }) async {
    final String id = requestId ?? const Uuid().v4();
    final ApiResponse r = await _api.post(
      '/v1/purchase-orders',
      idempotencyKey: id,
      body: <String, dynamic>{
        'id': id,
        'vendorId': vendorId,
        if (expectedDate.isNotEmpty) 'expectedDate': expectedDate,
        if (note.trim().isNotEmpty) 'note': note.trim(),
        'items': <Map<String, dynamic>>[
          for (final PurchaseOrderLineRequest l in lines)
            <String, dynamic>{'productId': l.productId, 'variantId': l.variantId, 'quantity': l.quantity, 'unitCost': _round2(l.unitCost)},
        ],
      },
    );
    return PurchaseOrder.fromMap(r.asMap);
  }

  /// Goods arrived: takes them into stock and charges the vendor (one purchase), optionally paying now.
  Future<PurchaseOrder> receive(
    String orderId, {
    required List<ReceiveLineRequest> lines,
    String invoiceNo = '',
    String notes = '',
    double paidNow = 0,
    String? requestId,
  }) async {
    final String id = requestId ?? const Uuid().v4();
    final ApiResponse r = await _api.post(
      '/v1/purchase-orders/$orderId/receive',
      idempotencyKey: id,
      body: <String, dynamic>{
        'id': id,
        'items': <Map<String, dynamic>>[
          for (final ReceiveLineRequest l in lines)
            <String, dynamic>{'poItemId': l.poItemId, 'quantity': l.quantity, if (l.unitCost != null) 'unitCost': _round2(l.unitCost!)},
        ],
        if (invoiceNo.trim().isNotEmpty) 'invoiceNo': invoiceNo.trim(),
        if (notes.trim().isNotEmpty) 'notes': notes.trim(),
        if (paidNow > 0) 'paidNow': _round2(paidNow),
      },
    );
    return PurchaseOrder.fromMap(r.asMap);
  }

  /// Cancels an order nothing has arrived for.
  Future<PurchaseOrder> cancel(String id) async => PurchaseOrder.fromMap((await _api.post('/v1/purchase-orders/$id/cancel')).asMap);

  /// Gives up what has not arrived of a partly received order.
  Future<PurchaseOrder> close(String id) async => PurchaseOrder.fromMap((await _api.post('/v1/purchase-orders/$id/close')).asMap);

  static double _round2(double v) => (v * 100).roundToDouble() / 100;
}
