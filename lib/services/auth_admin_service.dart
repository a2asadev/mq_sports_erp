/// Creates logins on behalf of an admin. The implementation talks to the
/// backend API (lib/online/api_auth_service.dart) and needs a connection.
abstract class AuthAdminService {
  /// Creates the login, then runs [onCreated] with its id (used to save the
  /// user's details).
  Future<void> createAccount({
    required String email,
    required String password,
    required String displayName,
    required Future<void> Function(String uid) onCreated,
  });
}
