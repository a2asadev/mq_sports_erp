import 'package:a2_stocks/models/syncable_model.dart';

/// A shop or warehouse of the business. Every business has one default branch; an admin adds more and switches
/// branches on. Stock, sales, purchases and stock counts belong to a branch; the catalog, customers and vendors are shared.
class BranchModel implements SyncableModel {
  BranchModel({
    required this.id,
    required this.name,
    this.code = '',
    this.address = '',
    this.phone = '',
    this.isDefault = false,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  final String id;
  final String name;
  final String code;
  final String address;
  final String phone;

  /// The business's main branch: what everything without a branch belongs to. It cannot be switched off.
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'name': name,
        'code': code,
        'address': address,
        'phone': phone,
        'isDefault': isDefault,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory BranchModel.fromMap(Map<String, dynamic> map) => BranchModel(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        code: map['code'] as String? ?? '',
        address: map['address'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        isDefault: map['isDefault'] as bool? ?? false,
        isActive: map['isActive'] as bool? ?? true,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
        updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
      );
}
