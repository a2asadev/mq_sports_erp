import 'package:mq_sports_erp/models/syncable_model.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:uuid/uuid.dart';

/// A product (aggregate root). Its variants are nested inside it and are
/// stored, synced and versioned together with the product.
class ProductModel implements SyncableModel {
  ProductModel({
    String? id,
    required this.name,
    required this.categoryId,
    this.brand = '',
    this.description = '',
    this.isActive = true,
    List<VariantModel>? variants,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        variants = List<VariantModel>.unmodifiable(
          variants ?? const <VariantModel>[],
        ),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  final String id;
  final String name;

  /// Id of the (leaf or intermediate) category this product belongs to.
  final String categoryId;
  final String brand;
  final String description;
  final bool isActive;
  final List<VariantModel> variants;
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  double get minSalePrice => variants.isEmpty
      ? 0
      : variants
          .map((VariantModel v) => v.salePrice)
          .reduce((double a, double b) => a < b ? a : b);

  double get maxSalePrice => variants.isEmpty
      ? 0
      : variants
          .map((VariantModel v) => v.salePrice)
          .reduce((double a, double b) => a > b ? a : b);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'brand': brand,
      'description': description,
      'isActive': isActive,
      'variants': variants.map((VariantModel v) => v.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    final List<Object?> rawVariants =
        map['variants'] as List<Object?>? ?? <Object?>[];
    return ProductModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      description: map['description'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      variants: rawVariants
          .whereType<Map<String, dynamic>>()
          .map(VariantModel.fromMap)
          .toList(),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
    );
  }

  /// Returns a modified copy. `updatedAt` is bumped to now unless given.
  ProductModel copyWith({
    String? name,
    String? categoryId,
    String? brand,
    String? description,
    bool? isActive,
    List<VariantModel>? variants,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      variants: variants ?? this.variants,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
