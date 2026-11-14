/// Plain snapshot of the signed-in user.
class AuthUserData {
  const AuthUserData({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.phoneNumber,
    required this.photoUrl,
  });

  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final String photoUrl;
}

/// What the app needs from sign-in. The implementation talks to the backend API
/// (lib/online/api_auth_service.dart). There is intentionally no registration:
/// accounts are created by an administrator.
abstract class AuthService {
  /// Uid of the currently signed-in user, or null when signed out.
  String? get currentUid;

  /// Data of the signed-in user, or null when signed out.
  AuthUserData? get currentUser;

  /// Emits the signed-in user's uid, or null when signed out.
  Stream<String?> uidChanges();

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();
}
