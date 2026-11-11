import 'package:mq_sports_erp/models/syncable_model.dart';
import 'package:uuid/uuid.dart';

double _round2(double value) => (value * 100).round() / 100;

/// Fulfilment pipeline of an order: Pending -> Processing -> Shipped ->
/// Delivered. A not yet delivered order can be Cancelled.
enum OrderStatus {
  pending('Pending'),
  processing('Processing'),
  shipped('Shipped'),
  delivered('Delivered'),
  cancelled('Cancelled');

  const OrderStatus(this.label);

  final String label;

  static OrderStatus fromName(String? name) {
    for (final OrderStatus status in OrderStatus.values) {
      if (status.name == name) {
        return status;
      }
    }
    return OrderStatus.pending;
  }

  /// The next step of the pipeline, or null for Delivered and Cancelled.
  OrderStatus? get next {
    switch (this) {
      case OrderStatus.pending:
        return OrderStatus.processing;
      case OrderStatus.processing:
        return OrderStatus.shipped;
      case OrderStatus.shipped:
        return OrderStatus.delivered;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return null;
    }
  }

  /// Delivered and Cancelled orders cannot change status any more.
  bool get isFinal =>
      this == OrderStatus.delivered || this == OrderStatus.cancelled;
}

/// Whether an order is a retail or a wholesale sale. It is a tag chosen when
/// the order is made (it starts from the customer's type); orders saved before
/// this existed count as retail.
enum OrderSaleType {
  retail('Retail'),
  wholesale('Wholesale');

  const OrderSaleType(this.label);

  final String label;

  static OrderSaleType fromName(String? name) {
    for (final OrderSaleType type in OrderSaleType.values) {
      if (type.name == name) {
        return type;
      }
    }
    return OrderSaleType.retail;
  }
}

/// One line of an order. Nested inside [OrderModel]; it has no repository of
/// its own.
class OrderItem {
  OrderItem({
    String? id,
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.variantLabel,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String productId;
  final String variantId;

  /// Names at the time of the sale, so history stays readable if the product
  /// is renamed later.
  final String productName;
  final String variantLabel;
  final String sku;
  final int quantity;

  /// Selling price per unit.
  final double unitPrice;

  /// Discount on the whole line, as an amount (never a percent).
  final double discount;

  double get grossAmount => quantity * unitPrice;

  double get lineTotal {
    final double net = grossAmount - discount;
    return _round2(net > 0 ? net : 0);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'productId': productId,
      'variantId': variantId,
      'productName': productName,
      'variantLabel': variantLabel,
      'sku': sku,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discount': discount,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      variantId: map['variantId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      variantLabel: map['variantLabel'] as String? ?? '',
      sku: map['sku'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// One step in the life of an order, kept inside the order.
class OrderStatusEntry {
  OrderStatusEntry({
    required this.status,
    DateTime? changedAt,
    this.byUserId = '',
    this.byName = '',
  }) : changedAt = changedAt ?? DateTime.now();

  final OrderStatus status;
  final DateTime changedAt;
  final String byUserId;
  final String byName;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status.name,
      'changedAt': changedAt.toIso8601String(),
      'byUserId': byUserId,
      'byName': byName,
    };
  }

  factory OrderStatusEntry.fromMap(Map<String, dynamic> map) {
    return OrderStatusEntry(
      status: OrderStatus.fromName(map['status'] as String?),
      changedAt: DateTime.tryParse(map['changedAt'] as String? ?? ''),
      byUserId: map['byUserId'] as String? ?? '',
      byName: map['byName'] as String? ?? '',
    );
  }
}

/// A customer sale. Stock leaves and the customer ledger is charged when the
/// order is confirmed; payments are customer ledger entries that point to the
/// order. Only the status (and its history) changes afterwards.
class OrderModel implements SyncableModel {
  OrderModel({
    String? id,
    required this.orderNo,
    required this.customerId,
    required this.customerName,
    DateTime? orderDate,
    this.status = OrderStatus.pending,
    this.saleType = OrderSaleType.retail,
    List<OrderItem>? items,
    this.discount = 0,
    this.notes = '',
    List<OrderStatusEntry>? statusHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        orderDate = orderDate ?? DateTime.now(),
        items = List<OrderItem>.unmodifiable(items ?? const <OrderItem>[]),
        statusHistory = List<OrderStatusEntry>.unmodifiable(
            statusHistory ?? const <OrderStatusEntry>[]),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  final String id;

  /// Our own number, for example ORD-20261112-A1B2.
  final String orderNo;
  final String customerId;
  final String customerName;
  final DateTime orderDate;
  final OrderStatus status;
  final OrderSaleType saleType;
  final List<OrderItem> items;

  /// Discount on the whole order, as an amount, applied after line discounts.
  final double discount;
  final String notes;
  final List<OrderStatusEntry> statusHistory;
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  double get subtotal {
    final double sum =
        items.fold<double>(0, (double s, OrderItem i) => s + i.lineTotal);
    return _round2(sum);
  }

  double get totalAmount {
    final double net = subtotal - discount;
    return _round2(net > 0 ? net : 0);
  }

  /// Line discounts plus the order discount.
  double get totalDiscount {
    final double lines =
        items.fold<double>(0, (double s, OrderItem i) => s + i.discount);
    return _round2(lines + discount);
  }

  int get totalUnits =>
      items.fold<int>(0, (int s, OrderItem i) => s + i.quantity);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'orderNo': orderNo,
      'customerId': customerId,
      'customerName': customerName,
      'orderDate': orderDate.toIso8601String(),
      'status': status.name,
      'saleType': saleType.name,
      'items': items.map((OrderItem i) => i.toMap()).toList(),
      'discount': discount,
      'notes': notes,
      'statusHistory':
          statusHistory.map((OrderStatusEntry e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    final List<Object?> rawItems = map['items'] as List<Object?>? ?? <Object?>[];
    final List<Object?> rawHistory =
        map['statusHistory'] as List<Object?>? ?? <Object?>[];
    return OrderModel(
      id: map['id'] as String? ?? '',
      orderNo: map['orderNo'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      orderDate: DateTime.tryParse(map['orderDate'] as String? ?? ''),
      status: OrderStatus.fromName(map['status'] as String?),
      saleType: OrderSaleType.fromName(map['saleType'] as String?),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(OrderItem.fromMap)
          .toList(),
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      notes: map['notes'] as String? ?? '',
      statusHistory: rawHistory
          .whereType<Map<String, dynamic>>()
          .map(OrderStatusEntry.fromMap)
          .toList(),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
    );
  }

  /// Returns a modified copy. `updatedAt` is bumped to now unless given.
  OrderModel copyWith({
    OrderStatus? status,
    List<OrderStatusEntry>? statusHistory,
    String? notes,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id,
      orderNo: orderNo,
      customerId: customerId,
      customerName: customerName,
      orderDate: orderDate,
      status: status ?? this.status,
      saleType: saleType,
      items: items,
      discount: discount,
      notes: notes ?? this.notes,
      statusHistory: statusHistory ?? this.statusHistory,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
