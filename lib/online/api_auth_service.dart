import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/online/api_client.dart';
import 'package:mq_sports_erp/online/remote_store.dart';
import 'package:mq_sports_erp/services/auth_admin_service.dart';
import 'package:mq_sports_erp/services/auth_service.dart';

/// Sign-in through the API (the web admin). The login is the same
/// email-and-password one the server checks; there is no Firebase on the web.
class ApiAuthService implements AuthService {
  ApiAuthService(this._api);

  final ApiClient _api;

  @override
  String? get currentUid => _api.currentUser?.id;

  @override
  AuthUserData? get currentUser {
    final UserModel? user = _api.currentUser;
    if (user == null) {
      return null;
    }
    return AuthUserData(
      uid: user.id,
      email: user.email,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      photoUrl: '',
    );
  }

  /// First the session saved by a previous visit (if any), then every sign-in
  /// and sign-out.
  @override
  Stream<String?> uidChanges() async* {
    final UserModel? restored = await _api.restoreSession();
    yield restored?.id;
    yield* _api.sessionChanges.map((UserModel? user) => user?.id);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _api.login(email, password);
  }

  @override
  Future<void> signOut() => _api.logout();

  /// The signed-in user's own record (role and active flag), from the server.
  Future<UserModel?> fetchCurrentUser() async {
    if (!_api.isSignedIn) {
      return null;
    }
    try {
      final ApiResponse response = await _api.get('/v1/auth/me');
      return UserModel.fromMap(normalizeDates(response.asMap));
    } on AuthFailureException {
      return null;
    }
  }
}

/// Creates logins through the API. The server makes the account with the
/// default role (staff); the caller's `onCreated` then saves the chosen role
/// and phone number, so a failure in between leaves the safest account, not an
/// over-privileged one.
class ApiAuthAdminService implements AuthAdminService {
  ApiAuthAdminService(this._api, this._store);

  final ApiClient _api;
  final RemoteStore _store;

  @override
  Future<void> createAccount({
    required String email,
    required String password,
    required String displayName,
    required Future<void> Function(String uid) onCreated,
  }) async {
    final ApiResponse response = await _api.post(
      '/v1/users',
      body: <String, dynamic>{
        'email': email.trim(),
        'password': password,
        if (displayName.trim().isNotEmpty) 'displayName': displayName.trim(),
      },
    );
    final Object? id = response.asMap['id'];
    if (id is! String) {
      throw const AuthFailureException('The server did not return the new user.');
    }
    // The new user must be in the local copy so the next save updates it
    // instead of trying to create it again.
    try {
      await _store.refresh();
    } on AppException {
      // The periodic refresh will catch up.
    }
    await onCreated(id);
  }
}
