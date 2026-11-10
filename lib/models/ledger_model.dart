import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/syncable_model.dart';
import 'package:uuid/uuid.dart';

/// One balance entry of a vendor or customer. A party's balance is its
/// opening balance plus every charge minus every payment.
class LedgerModel implements SyncableModel {
  LedgerModel({
    String? id,
    required this.partyType,
    required this.partyId,
    required this.entryType,
    required this.amount,
    DateTime? entryDate,
    this.description = '',
    this.reference = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        entryDate = entryDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  final String id;
  final PartyType partyType;
  final String partyId;
  final LedgerEntryType entryType;

  /// Always positive; [entryType] decides the direction.
  final double amount;
  final DateTime entryDate;
  final String description;
  final String reference;
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  /// Effect on the balance: +amount for a charge, -amount for a payment.
  double get signedAmount =>
      entryType == LedgerEntryType.charge ? amount : -amount;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'partyType': partyType.name,
      'partyId': partyId,
      'entryType': entryType.name,
      'amount': amount,
      'entryDate': entryDate.toIso8601String(),
      'description': description,
      'reference': reference,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LedgerModel.fromMap(Map<String, dynamic> map) {
    return LedgerModel(
      id: map['id'] as String? ?? '',
      partyType: PartyType.fromName(map['partyType'] as String?),
      partyId: map['partyId'] as String? ?? '',
      entryType: LedgerEntryType.fromName(map['entryType'] as String?),
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      entryDate: DateTime.tryParse(map['entryDate'] as String? ?? ''),
      description: map['description'] as String? ?? '',
      reference: map['reference'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
    );
  }

  /// Returns a modified copy. `updatedAt` is bumped to now unless given.
  LedgerModel copyWith({
    LedgerEntryType? entryType,
    double? amount,
    DateTime? entryDate,
    String? description,
    String? reference,
    DateTime? updatedAt,
  }) {
    return LedgerModel(
      id: id,
      partyType: partyType,
      partyId: partyId,
      entryType: entryType ?? this.entryType,
      amount: amount ?? this.amount,
      entryDate: entryDate ?? this.entryDate,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
