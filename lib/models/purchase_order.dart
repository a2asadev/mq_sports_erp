/// open = nothing has arrived; partial = some has; received = all of it; closed = the rest was given up;
/// cancelled = nothing ever arrived.
enum PurchaseOrderStatus {
  open,
  partial,
  received,
  closed,
  cancelled;

  static PurchaseOrderStatus fromName(String? name) {
    for (final PurchaseOrderStatus s in PurchaseOrderStatus.values) {
      if (s.name == name) {
        return s;
      }
    }
    return PurchaseOrderStatus.open;
  }

  /// Goods can still be received.
  bool get canReceive => this == PurchaseOrderStatus.open || this == PurchaseOrderStatus.partial;
}

/// One line of a purchase order, with what has arrived of it.
class PurchaseOrderItem {
  const PurchaseOrderItem({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.variantLabel,
    required this.sku,
    required this.quantity,
    required this.unitCost,
    required this.receivedQuantity,
    required this.remaining,
  });

  final String id;
  final String productId;
  final String variantId;
  final String productName;
  final String variantLabel;
  final String sku;
  final int quantity;
  final double unitCost;
  final int receivedQuantity;
  final int remaining;

  factory PurchaseOrderItem.fromMap(Map<String, dynamic> m) {
    final int quantity = (m['quantity'] as num?)?.toInt() ?? 0;
    final int received = (m['receivedQuantity'] as num?)?.toInt() ?? 0;
    return PurchaseOrderItem(
      id: '${m['id'] ?? ''}',
      productId: '${m['productId'] ?? ''}',
      variantId: '${m['variantId'] ?? ''}',
      productName: '${m['productName'] ?? ''}',
      variantLabel: '${m['variantLabel'] ?? ''}',
      sku: '${m['sku'] ?? ''}',
      quantity: quantity,
      unitCost: (m['unitCost'] as num?)?.toDouble() ?? 0,
      receivedQuantity: received,
      remaining: (m['remaining'] as num?)?.toInt() ?? (quantity - received).clamp(0, quantity),
    );
  }
}

/// Goods that arrived against the order, and the purchase that took them into stock.
class PurchaseOrderReceipt {
  const PurchaseOrderReceipt({
    required this.id,
    required this.purchaseId,
    required this.purchaseNo,
    required this.receivedAt,
    required this.byName,
    required this.units,
  });

  final String id;
  final String purchaseId;
  final String purchaseNo;
  final DateTime receivedAt;
  final String byName;
  final int units;

  factory PurchaseOrderReceipt.fromMap(Map<String, dynamic> m) {
    final Object? items = m['items'];
    int units = 0;
    if (items is List<Object?>) {
      for (final Object? i in items) {
        if (i is Map<String, dynamic>) {
          units += (i['quantity'] as num?)?.toInt() ?? 0;
        }
      }
    }
    return PurchaseOrderReceipt(
      id: '${m['id'] ?? ''}',
      purchaseId: '${m['purchaseId'] ?? ''}',
      purchaseNo: '${m['purchaseNo'] ?? ''}',
      receivedAt: DateTime.tryParse('${m['receivedAt'] ?? ''}')?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0),
      byName: '${m['byName'] ?? ''}',
      units: units,
    );
  }
}

/// What was ordered from a vendor (`/v1/purchase-orders`). It changes neither stock nor the vendor's balance
/// until goods are received; each receipt is an ordinary purchase.
class PurchaseOrder {
  const PurchaseOrder({
    required this.id,
    required this.poNo,
    required this.vendorId,
    required this.vendorName,
    required this.orderDate,
    required this.expectedDate,
    required this.status,
    required this.note,
    required this.byName,
    required this.orderedValue,
    required this.receivedValue,
    required this.items,
    required this.receipts,
  });

  final String id;
  final String poNo;
  final String vendorId;
  final String vendorName;
  final DateTime orderDate;

  /// "YYYY-MM-DD" or ''.
  final String expectedDate;
  final PurchaseOrderStatus status;
  final String note;
  final String byName;
  final double orderedValue;
  final double receivedValue;
  final List<PurchaseOrderItem> items;
  final List<PurchaseOrderReceipt> receipts;

  int get orderedUnits => items.fold<int>(0, (int s, PurchaseOrderItem i) => s + i.quantity);
  int get receivedUnits => items.fold<int>(0, (int s, PurchaseOrderItem i) => s + i.receivedQuantity);

  /// The expected day has passed and goods can still arrive.
  bool isLate(DateTime now) {
    if (expectedDate.isEmpty || !status.canReceive) {
      return false;
    }
    final DateTime? due = DateTime.tryParse(expectedDate);
    return due != null && DateTime(now.year, now.month, now.day).isAfter(due);
  }

  factory PurchaseOrder.fromMap(Map<String, dynamic> m) {
    final Object? items = m['items'];
    final Object? receipts = m['receipts'];
    return PurchaseOrder(
      id: '${m['id'] ?? ''}',
      poNo: '${m['poNo'] ?? ''}',
      vendorId: '${m['vendorId'] ?? ''}',
      vendorName: '${m['vendorName'] ?? ''}',
      orderDate: DateTime.tryParse('${m['orderDate'] ?? ''}')?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0),
      expectedDate: '${m['expectedDate'] ?? ''}',
      status: PurchaseOrderStatus.fromName(m['status'] as String?),
      note: '${m['note'] ?? ''}',
      byName: '${m['byName'] ?? ''}',
      orderedValue: (m['orderedValue'] as num?)?.toDouble() ?? 0,
      receivedValue: (m['receivedValue'] as num?)?.toDouble() ?? 0,
      items: <PurchaseOrderItem>[
        if (items is List<Object?>)
          for (final Object? i in items)
            if (i is Map<String, dynamic>) PurchaseOrderItem.fromMap(i),
      ],
      receipts: <PurchaseOrderReceipt>[
        if (receipts is List<Object?>)
          for (final Object? r in receipts)
            if (r is Map<String, dynamic>) PurchaseOrderReceipt.fromMap(r),
      ],
    );
  }
}

/// A line of a new order, or of goods being received.
class PurchaseOrderLineRequest {
  const PurchaseOrderLineRequest({required this.productId, required this.variantId, required this.quantity, required this.unitCost});

  final String productId;
  final String variantId;
  final int quantity;
  final double unitCost;
}

/// A line of goods being received: how many of an order line arrived, and its price on the invoice.
class ReceiveLineRequest {
  const ReceiveLineRequest({required this.poItemId, required this.quantity, this.unitCost});

  final String poItemId;
  final int quantity;
  final double? unitCost;
}
