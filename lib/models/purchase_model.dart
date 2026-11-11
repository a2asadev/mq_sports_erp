import 'package:mq_sports_erp/models/syncable_model.dart';
import 'package:uuid/uuid.dart';

/// Payment state of a purchase, derived from what was paid so far.
enum PurchaseStatus {
  pending('Pending'),
  partial('Partial'),
  paid('Paid');

  const PurchaseStatus(this.label);

  final String label;
}

/// Pending when nothing was paid, Paid when the total is covered, otherwise
/// Partial.
PurchaseStatus purchaseStatusFor(double total, double paid) {
  if (total <= 0.005 || paid >= total - 0.005) {
    return PurchaseStatus.paid;
  }
  if (paid <= 0.005) {
    return PurchaseStatus.pending;
  }
  return PurchaseStatus.partial;
}

/// One line of a purchase. Nested inside [PurchaseModel]; it has no
/// repository of its own.
class PurchaseItem {
  PurchaseItem({
    String? id,
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.variantLabel,
    required this.sku,
    required this.quantity,
    required this.unitCost,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String productId;
  final String variantId;

  /// Names at the time of purchase, so history stays readable if the
  /// product is renamed later.
  final String productName;
  final String variantLabel;
  final String sku;
  final int quantity;

  /// Buying price per unit.
  final double unitCost;

  double get lineTotal => quantity * unitCost;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'productId': productId,
      'variantId': variantId,
      'productName': productName,
      'variantLabel': variantLabel,
      'sku': sku,
      'quantity': quantity,
      'unitCost': unitCost,
    };
  }

  factory PurchaseItem.fromMap(Map<String, dynamic> map) {
    return PurchaseItem(
      id: map['id'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      variantId: map['variantId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      variantLabel: map['variantLabel'] as String? ?? '',
      sku: map['sku'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      unitCost: (map['unitCost'] as num?)?.toDouble() ?? 0,
    );
  }

  PurchaseItem copyWith({int? quantity, double? unitCost}) {
    return PurchaseItem(
      id: id,
      productId: productId,
      variantId: variantId,
      productName: productName,
      variantLabel: variantLabel,
      sku: sku,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
    );
  }
}

/// A confirmed purchase from a vendor. Purchases are never edited after they
/// are confirmed; payments are recorded as vendor ledger entries that point
/// to the purchase, and the status is derived from them.
class PurchaseModel implements SyncableModel {
  PurchaseModel({
    String? id,
    required this.purchaseNo,
    required this.vendorId,
    required this.vendorName,
    this.invoiceNo = '',
    DateTime? purchaseDate,
    List<PurchaseItem>? items,
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        purchaseDate = purchaseDate ?? DateTime.now(),
        items = List<PurchaseItem>.unmodifiable(items ?? const <PurchaseItem>[]),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  final String id;

  /// Our own number, for example PUR-20261111-A1B2.
  final String purchaseNo;
  final String vendorId;
  final String vendorName;

  /// The supplier's invoice number, if any.
  final String invoiceNo;
  final DateTime purchaseDate;
  final List<PurchaseItem> items;
  final String notes;
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  double get totalAmount {
    final double sum =
        items.fold<double>(0, (double s, PurchaseItem i) => s + i.lineTotal);
    return (sum * 100).round() / 100;
  }

  int get totalUnits =>
      items.fold<int>(0, (int s, PurchaseItem i) => s + i.quantity);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'purchaseNo': purchaseNo,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'invoiceNo': invoiceNo,
      'purchaseDate': purchaseDate.toIso8601String(),
      'items': items.map((PurchaseItem i) => i.toMap()).toList(),
      'notes': notes,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PurchaseModel.fromMap(Map<String, dynamic> map) {
    final List<Object?> rawItems = map['items'] as List<Object?>? ?? <Object?>[];
    return PurchaseModel(
      id: map['id'] as String? ?? '',
      purchaseNo: map['purchaseNo'] as String? ?? '',
      vendorId: map['vendorId'] as String? ?? '',
      vendorName: map['vendorName'] as String? ?? '',
      invoiceNo: map['invoiceNo'] as String? ?? '',
      purchaseDate: DateTime.tryParse(map['purchaseDate'] as String? ?? ''),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(PurchaseItem.fromMap)
          .toList(),
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
    );
  }

  /// Returns a modified copy. `updatedAt` is bumped to now unless given.
  PurchaseModel copyWith({
    String? invoiceNo,
    String? notes,
    DateTime? updatedAt,
  }) {
    return PurchaseModel(
      id: id,
      purchaseNo: purchaseNo,
      vendorId: vendorId,
      vendorName: vendorName,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      purchaseDate: purchaseDate,
      items: items,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
