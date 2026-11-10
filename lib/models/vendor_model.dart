import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/syncable_model.dart';
import 'package:uuid/uuid.dart';

/// A manufacturer or shop we purchase from. [openingBalance] is what we owed
/// the vendor before any ledger entry (positive = we owe them).
class VendorModel implements SyncableModel {
  VendorModel({
    String? id,
    required this.name,
    this.type = VendorType.manufacturer,
    this.contactPerson = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.city = '',
    this.notes = '',
    this.openingBalance = 0,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  final String id;
  final String name;
  final VendorType type;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String notes;
  final double openingBalance;
  final bool isActive;
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'type': type.name,
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'notes': notes,
      'openingBalance': openingBalance,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory VendorModel.fromMap(Map<String, dynamic> map) {
    return VendorModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      type: VendorType.fromName(map['type'] as String?),
      contactPerson: map['contactPerson'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      openingBalance: (map['openingBalance'] as num?)?.toDouble() ?? 0,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
    );
  }

  /// Returns a modified copy. `updatedAt` is bumped to now unless given.
  VendorModel copyWith({
    String? name,
    VendorType? type,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? notes,
    double? openingBalance,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return VendorModel(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      notes: notes ?? this.notes,
      openingBalance: openingBalance ?? this.openingBalance,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
