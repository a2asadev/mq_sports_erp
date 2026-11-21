import 'package:a2_stocks/core/permissions.dart';
import 'package:a2_stocks/models/syncable_model.dart';
import 'package:a2_stocks/models/user_role.dart';

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
    this.photoUrl = '',
    this.permissions,
    this.branchId = '',
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

  /// Address of the photo ('' = none). Changed with the photo upload, never by saving the form.
  final String photoUrl;

  /// What this person may do now, as the server last said (null until it has: then the role's defaults apply).
  /// Only the signed-in user's own record carries it.
  final List<String>? permissions;
  /// The person's home branch ('' = any).
  final String branchId;
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  /// Whether this person may do this (see [Permissions]). An admin always may.
  bool can(String permission) {
    if (role == UserRole.admin) {
      return true;
    }
    final List<String>? known = permissions;
    return known == null ? Permissions.defaultAllows(role, permission) : known.contains(permission);
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'isActive': isActive,
      'photoUrl': photoUrl,
      if (permissions != null) 'permissions': permissions,
      'branchId': branchId,
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
      photoUrl: map['photoUrl'] as String? ?? '',
      permissions: map['permissions'] is List<Object?> ? <String>[for (final Object? p in map['permissions'] as List<Object?>) '$p'] : null,
      branchId: map['branchId'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
    );
  }

  /// Returns a modified copy. `updatedAt` is bumped to now unless given.
  UserModel copyWith({
    String? branchId,
    String? displayName,
    String? phoneNumber,
    UserRole? role,
    bool? isActive,
    String? photoUrl,
    List<String>? permissions,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      photoUrl: photoUrl ?? this.photoUrl,
      permissions: permissions ?? this.permissions,
      branchId: branchId ?? this.branchId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
