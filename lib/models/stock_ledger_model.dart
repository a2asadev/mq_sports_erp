import 'package:mq_sports_erp/models/syncable_model.dart';
import 'package:uuid/uuid.dart';

enum StockMovementType {
  purchase('Purchase'),
  sale('Sale'),
  adjustment('Adjustment');

  const StockMovementType(this.label);

  final String label;

  static StockMovementType fromName(String? name) {
    for (final StockMovementType type in StockMovementType.values) {
      if (type.name == name) {
        return type;
      }
    }
    return StockMovementType.adjustment;
  }
}

/// One stock movement of one variant. Stock on hand is the sum of
/// [quantity] over all entries of the variant, so entries are only ever
/// added and never edited: two devices can never overwrite each other's
/// counts.
class StockLedgerModel implements SyncableModel {
  StockLedgerModel({
    String? id,
    required this.productId,
    required this.variantId,
    required this.sku,
    required this.quantity,
    required this.movementType,
    this.sourceId = '',
    this.unitCost = 0,
    DateTime? movementDate,
    this.note = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        movementDate = movementDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  final String id;
  final String productId;
  final String variantId;

  /// SKU at the time of the movement, for display.
  final String sku;

  /// Signed: positive adds stock, negative removes it.
  final int quantity;
  final StockMovementType movementType;

  /// Id of the document that caused the movement (for example a purchase).
  final String sourceId;
  final double unitCost;
  final DateTime movementDate;
  final String note;
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'productId': productId,
      'variantId': variantId,
      'sku': sku,
      'quantity': quantity,
      'movementType': movementType.name,
      'sourceId': sourceId,
      'unitCost': unitCost,
      'movementDate': movementDate.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StockLedgerModel.fromMap(Map<String, dynamic> map) {
    return StockLedgerModel(
      id: map['id'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      variantId: map['variantId'] as String? ?? '',
      sku: map['sku'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      movementType: StockMovementType.fromName(map['movementType'] as String?),
      sourceId: map['sourceId'] as String? ?? '',
      unitCost: (map['unitCost'] as num?)?.toDouble() ?? 0,
      movementDate: DateTime.tryParse(map['movementDate'] as String? ?? ''),
      note: map['note'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
    );
  }

  /// Returns a modified copy. `updatedAt` is bumped to now unless given.
  StockLedgerModel copyWith({
    String? note,
    DateTime? updatedAt,
  }) {
    return StockLedgerModel(
      id: id,
      productId: productId,
      variantId: variantId,
      sku: sku,
      quantity: quantity,
      movementType: movementType,
      sourceId: sourceId,
      unitCost: unitCost,
      movementDate: movementDate,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
