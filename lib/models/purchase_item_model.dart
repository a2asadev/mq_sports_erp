/// One line of a purchase. It is stored inside its `PurchaseModel` and keeps
/// a snapshot of the product and variant names, so history stays readable
/// even if the catalog changes later.
class PurchaseItemModel {
  const PurchaseItemModel({
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.variantLabel,
    required this.sku,
    required this.quantity,
    required this.unitCost,
  });

  final String productId;
  final String variantId;
  final String productName;
  final String variantLabel;
  final String sku;
  final int quantity;

  /// Buying price per unit.
  final double unitCost;

  double get lineTotal => quantity * unitCost;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'variantId': variantId,
      'productName': productName,
      'variantLabel': variantLabel,
      'sku': sku,
      'quantity': quantity,
      'unitCost': unitCost,
    };
  }

  factory PurchaseItemModel.fromMap(Map<String, dynamic> map) {
    return PurchaseItemModel(
      productId: map['productId'] as String? ?? '',
      variantId: map['variantId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      variantLabel: map['variantLabel'] as String? ?? '',
      sku: map['sku'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      unitCost: (map['unitCost'] as num?)?.toDouble() ?? 0,
    );
  }

  PurchaseItemModel copyWith({int? quantity, double? unitCost}) {
    return PurchaseItemModel(
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
