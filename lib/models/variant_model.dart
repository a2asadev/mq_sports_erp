import 'package:uuid/uuid.dart';

/// A sellable variant of a product (for example size M / red). It has no
/// repository of its own: it is stored inside its parent `ProductModel`.
///
/// Pricing: every variant has a [costPrice] and a [salePrice]. A wholesale
/// variant ([isWholesale]) additionally has a [wholesalePrice]; its
/// [salePrice] is then the retail price.
class VariantModel {
  VariantModel({
    String? id,
    required this.sku,
    this.name = '',
    this.barcode = '',
    Map<String, String>? attributes,
    this.costPrice = 0,
    this.salePrice = 0,
    this.isWholesale = false,
    this.wholesalePrice = 0,
    this.alertThreshold = 0,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        attributes = Map<String, String>.unmodifiable(
          attributes ?? const <String, String>{},
        );

  final String id;
  final String sku;
  final String name;
  final String barcode;

  /// Option values such as `{'Size': 'M', 'Color': 'Red'}`.
  final Map<String, String> attributes;
  final double costPrice;

  /// Sale price, or the retail price when [isWholesale] is true.
  final double salePrice;
  final bool isWholesale;

  /// Only meaningful when [isWholesale] is true; otherwise 0.
  final double wholesalePrice;

  /// Low-stock alert level: the variant is flagged when its stock on hand is
  /// at or below this number. 0 means no alert is set.
  final int alertThreshold;
  final bool isActive;

  /// Human-readable label: the name, else the attribute values, else the SKU.
  String get label {
    if (name.isNotEmpty) {
      return name;
    }
    if (attributes.isNotEmpty) {
      return attributes.values.join(' / ');
    }
    return sku;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sku': sku,
      'name': name,
      'barcode': barcode,
      'attributes': attributes,
      'costPrice': costPrice,
      'salePrice': salePrice,
      'isWholesale': isWholesale,
      'wholesalePrice': wholesalePrice,
      'alertThreshold': alertThreshold,
      'isActive': isActive,
    };
  }

  factory VariantModel.fromMap(Map<String, dynamic> map) {
    final Map<String, dynamic> rawAttributes =
        map['attributes'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return VariantModel(
      id: map['id'] as String? ?? '',
      sku: map['sku'] as String? ?? '',
      name: map['name'] as String? ?? '',
      barcode: map['barcode'] as String? ?? '',
      attributes: rawAttributes.map(
        (String key, Object? value) =>
            MapEntry<String, String>(key, '${value ?? ''}'),
      ),
      costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0,
      salePrice: (map['salePrice'] as num?)?.toDouble() ?? 0,
      isWholesale: map['isWholesale'] as bool? ?? false,
      wholesalePrice: (map['wholesalePrice'] as num?)?.toDouble() ?? 0,
      alertThreshold: (map['alertThreshold'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  VariantModel copyWith({
    String? sku,
    String? name,
    String? barcode,
    Map<String, String>? attributes,
    double? costPrice,
    double? salePrice,
    bool? isWholesale,
    double? wholesalePrice,
    int? alertThreshold,
    bool? isActive,
  }) {
    return VariantModel(
      id: id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      attributes: attributes ?? this.attributes,
      costPrice: costPrice ?? this.costPrice,
      salePrice: salePrice ?? this.salePrice,
      isWholesale: isWholesale ?? this.isWholesale,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      isActive: isActive ?? this.isActive,
    );
  }
}
