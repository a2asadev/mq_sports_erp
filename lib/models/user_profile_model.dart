import 'package:mq_sports_erp/models/syncable_model.dart';
import 'package:uuid/uuid.dart';

/// Profile of an application user, linked to a Firebase Auth account through
/// [authUid]. Pure Dart: dates are ISO 8601 strings in `toMap()`.
class UserProfileModel implements SyncableModel {
  UserProfileModel({
    String? id,
    required this.authUid,
    required this.email,
    this.displayName = '',
    this.phoneNumber = '',
    this.photoUrl = '',
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        lastLoginAt = lastLoginAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  final String id;

  /// Firebase Auth uid of the account this profile belongs to.
  final String authUid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final String photoUrl;
  final DateTime lastLoginAt;
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'authUid': authUid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as String? ?? '',
      authUid: map['authUid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      lastLoginAt: DateTime.tryParse(map['lastLoginAt'] as String? ?? ''),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
    );
  }

  /// Returns a modified copy. `updatedAt` is bumped to now unless given, so
  /// every edit wins the newest-record-wins sync comparison.
  UserProfileModel copyWith({
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    DateTime? lastLoginAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id,
      authUid: authUid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
