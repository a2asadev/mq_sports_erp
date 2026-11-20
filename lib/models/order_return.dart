/// One line of a return: how many units of an order line came back.
class OrderReturnItem {
  const OrderReturnItem({
    required this.orderItemId,
    required this.productName,
    required this.variantLabel,
    required this.sku,
    required this.quantity,
    required this.value,
    required this.restocked,
  });

  final String orderItemId;
  final String productName;
  final String variantLabel;
  final String sku;
  final int quantity;

  /// What these units were worth (after discounts).
  final double value;

  /// Whether they went back into stock (false = damaged).
  final bool restocked;

  factory OrderReturnItem.fromMap(Map<String, dynamic> map) => OrderReturnItem(
        orderItemId: '${map['orderItemId'] ?? ''}',
        productName: '${map['productName'] ?? ''}',
        variantLabel: '${map['variantLabel'] ?? ''}',
        sku: '${map['sku'] ?? ''}',
        quantity: (map['quantity'] as num?)?.toInt() ?? 0,
        value: (map['value'] as num?)?.toDouble() ?? 0,
        restocked: map['restocked'] != false,
      );
}

/// Goods a customer brought back from a delivered order (`/v1/orders/:id/returns`).
/// The stock and ledger effects of a return arrive through the normal sync.
class OrderReturn {
  const OrderReturn({
    required this.id,
    required this.returnNo,
    required this.orderId,
    required this.returnDate,
    required this.totalValue,
    this.taxAmount = 0,
    this.creditAmount = 0,
    required this.refundMethod,
    required this.refundAmount,
    required this.note,
    required this.byName,
    required this.items,
  });

  final String id;
  final String returnNo;
  final String orderId;
  final DateTime returnDate;

  /// What the goods were worth.
  final double totalValue;

  /// The tax that belonged to these goods, and what the customer was credited (the goods plus the tax when
  /// it was added on top).
  final double taxAmount;
  final double creditAmount;

  /// 'credit' (kept on the customer's account) or the method the money went back by.
  final String refundMethod;
  final double refundAmount;
  final String note;
  final String byName;
  final List<OrderReturnItem> items;

  static const String creditMethod = 'credit';

  bool get handedMoneyBack => refundAmount > 0.004;

  int get totalUnits => items.fold<int>(0, (int sum, OrderReturnItem i) => sum + i.quantity);

  factory OrderReturn.fromMap(Map<String, dynamic> map) {
    final Object? items = map['items'];
    return OrderReturn(
      id: '${map['id'] ?? ''}',
      returnNo: '${map['returnNo'] ?? ''}',
      orderId: '${map['orderId'] ?? ''}',
      returnDate: DateTime.tryParse('${map['returnDate'] ?? ''}')?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0),
      totalValue: (map['totalValue'] as num?)?.toDouble() ?? 0,
      taxAmount: (map['taxAmount'] as num?)?.toDouble() ?? 0,
      creditAmount: (map['creditAmount'] as num?)?.toDouble() ?? ((map['totalValue'] as num?)?.toDouble() ?? 0),
      refundMethod: '${map['refundMethod'] ?? creditMethod}',
      refundAmount: (map['refundAmount'] as num?)?.toDouble() ?? 0,
      note: '${map['note'] ?? ''}',
      byName: '${map['byName'] ?? ''}',
      items: <OrderReturnItem>[
        if (items is List<Object?>)
          for (final Object? i in items)
            if (i is Map<String, dynamic>) OrderReturnItem.fromMap(i),
      ],
    );
  }
}
