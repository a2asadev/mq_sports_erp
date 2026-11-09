import 'package:mq_sports_erp/models/syncable_model.dart';
import 'package:mq_sports_erp/models/user_role.dart';

/// An application user managed by admins (`users` collection).
///
/// Deliberate exception to client-side UUID keys: [id] is the Firebase Auth
/// uid of the user's login. The Auth account is the identity, and Firestore
/// security rules can only look up a user's role by document path.
class UserModel implements SyncableModel {
  UserModel({
    required this.id,
    required this.email,
    this.displayName = '',
    this.phoneNumber = '',
    this.role = UserRole.staff,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  final String id;
  final String email;
  final String displayName;
  final String phoneNumber;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      role: UserRole.fromName(map['role'] as String?),
      isActive: map['isActive'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
    );
  }

  /// Returns a modified copy. `updatedAt` is bumped to now unless given.
  UserModel copyWith({
    String? displayName,
    String? phoneNumber,
    UserRole? role,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
