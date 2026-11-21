import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/online/api_client.dart';
import 'package:a2_stocks/online/remote_store.dart';
import 'package:a2_stocks/services/auth_admin_service.dart';
import 'package:a2_stocks/services/auth_service.dart';

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

  /// The signed-in user's own record (role and active flag): the server's
  /// answer when it can be reached, otherwise the one saved at the last sign-in.
  Future<UserModel?> fetchCurrentUser() async {
    if (!_api.isSignedIn) {
      return null;
    }
    try {
      final ApiResponse response = await _api.get('/v1/auth/me');
      // The business may have been renamed (or its phone changed) since sign-in.
      final BusinessInfo? business = BusinessInfo.tryFromMap(response.asMap['tenant']);
      if (business != null) {
        await _api.rememberBusiness(business);
      }
      final UserModel me = UserModel.fromMap(normalizeDates(response.asMap));
      final List<String>? permissions = me.permissions;
      if (permissions != null) {
        await _api.rememberPermissions(permissions);
      }
      return me;
    } on AuthFailureException {
      return null;
    } on RemoteSyncException {
      return _api.currentUser;
    }
  }
}

/// Creates logins through the API. The server makes the account with the
/// default role (staff); the caller's `onCreated` then saves the chosen role
/// and phone number, so a failure in between leaves the safest account, not an
/// over-privileged one.
class ApiAuthAdminService implements AuthAdminService {
  ApiAuthAdminService(this._api, this._bringUsersUpToDate);

  final ApiClient _api;

  /// Fetches the server's users onto this device (web: refresh the in-memory
  /// copy; mobile and desktop: download), so the new user is known before it is saved.
  final Future<void> Function() _bringUsersUpToDate;

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
      throw AuthFailureException(L10n.current.apiAuthServiceTheServerDidNot);
    }
    // The new user must be in the local copy so the next save updates it
    // instead of trying to create it again.
    try {
      await _bringUsersUpToDate();
    } on AppException {
      // The periodic refresh will catch up.
    }
    await onCreated(id);
  }
}
