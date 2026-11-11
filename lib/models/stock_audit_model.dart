import 'package:mq_sports_erp/models/syncable_model.dart';
import 'package:uuid/uuid.dart';

/// One counted variant inside a [StockAuditModel]. Nested in the audit; it has
/// no repository of its own.
class StockAuditItem {
  const StockAuditItem({
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.variantLabel,
    required this.sku,
    required this.systemQuantity,
    required this.countedQuantity,
  });

  final String productId;
  final String variantId;

  /// Names at the time of the count, so history stays readable if the product
  /// is renamed later.
  final String productName;
  final String variantLabel;
  final String sku;

  /// Stock on hand according to the ledger when the audit was confirmed.
  final int systemQuantity;

  /// What was physically counted.
  final int countedQuantity;

  /// Positive when more was found than the system had, negative when less.
  int get variance => countedQuantity - systemQuantity;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'variantId': variantId,
      'productName': productName,
      'variantLabel': variantLabel,
      'sku': sku,
      'systemQuantity': systemQuantity,
      'countedQuantity': countedQuantity,
    };
  }

  factory StockAuditItem.fromMap(Map<String, dynamic> map) {
    return StockAuditItem(
      productId: map['productId'] as String? ?? '',
      variantId: map['variantId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      variantLabel: map['variantLabel'] as String? ?? '',
      sku: map['sku'] as String? ?? '',
      systemQuantity: (map['systemQuantity'] as num?)?.toInt() ?? 0,
      countedQuantity: (map['countedQuantity'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A confirmed stock count. It is never edited: the adjustments it caused are
/// stock ledger entries (type adjustment) whose `sourceId` is this audit's id.
class StockAuditModel implements SyncableModel {
  StockAuditModel({
    String? id,
    required this.auditNo,
    DateTime? auditDate,
    List<StockAuditItem>? items,
    this.note = '',
    this.countedById = '',
    this.countedByName = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        auditDate = auditDate ?? DateTime.now(),
        items = List<StockAuditItem>.unmodifiable(
            items ?? const <StockAuditItem>[]),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  final String id;

  /// Our own number, for example AUD-20261112-A1B2.
  final String auditNo;
  final DateTime auditDate;
  final List<StockAuditItem> items;
  final String note;
  final String countedById;
  final String countedByName;
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  /// Net change in units over all items.
  int get totalVariance =>
      items.fold<int>(0, (int s, StockAuditItem i) => s + i.variance);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'auditNo': auditNo,
      'auditDate': auditDate.toIso8601String(),
      'items': items.map((StockAuditItem i) => i.toMap()).toList(),
      'note': note,
      'countedById': countedById,
      'countedByName': countedByName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StockAuditModel.fromMap(Map<String, dynamic> map) {
    final List<Object?> rawItems = map['items'] as List<Object?>? ?? <Object?>[];
    return StockAuditModel(
      id: map['id'] as String? ?? '',
      auditNo: map['auditNo'] as String? ?? '',
      auditDate: DateTime.tryParse(map['auditDate'] as String? ?? ''),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(StockAuditItem.fromMap)
          .toList(),
      note: map['note'] as String? ?? '',
      countedById: map['countedById'] as String? ?? '',
      countedByName: map['countedByName'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
    );
  }
}
