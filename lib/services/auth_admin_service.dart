import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';

/// Creates logins on behalf of an admin.
abstract class AuthAdminService {
  /// Creates the login, then runs [onCreated] with its id (used to save the
  /// user record). If [onCreated] throws, the just-created login is removed
  /// again where the service can (Firebase), so no orphan login is left behind.
  Future<void> createAccount({
    required String email,
    required String password,
    required String displayName,
    required Future<void> Function(String uid) onCreated,
  });
}

/// Creates Firebase Auth accounts on behalf of an admin.
///
/// The account is created through a temporary secondary Firebase app, so the
/// admin's own session on the default app is never replaced.
class FirebaseAuthAdminService implements AuthAdminService {
  static const String _appName = 'mq_user_creation';

  Future<FirebaseApp> _secondaryApp() async {
    try {
      return Firebase.app(_appName);
    } on FirebaseException {
      return Firebase.initializeApp(
        name: _appName,
        options: Firebase.app().options,
      );
    }
  }

  /// Creates the login, then runs [onCreated] with its uid (used to write the
  /// Firestore user record). If [onCreated] throws, the just-created login is
  /// deleted again so no orphan account is left behind.
  @override
  Future<void> createAccount({
    required String email,
    required String password,
    required String displayName,
    required Future<void> Function(String uid) onCreated,
  }) async {
    FirebaseApp? app;
    FirebaseAuth? auth;
    try {
      app = await _secondaryApp();
      auth = FirebaseAuth.instanceFor(app: app);
      final UserCredential credential = await auth
          .createUserWithEmailAndPassword(email: email, password: password);
      final User? created = credential.user;
      if (created == null) {
        throw const AuthFailureException('The login could not be created.');
      }
      if (displayName.isNotEmpty) {
        try {
          await created.updateDisplayName(displayName);
        } on FirebaseException {
          // Non-critical: the display name is also stored in Firestore.
        }
      }
      try {
        await onCreated(created.uid);
      } on Object {
        await _discard(created);
        rethrow;
      }
    } on FirebaseException catch (e) {
      throw AuthFailureException(_message(e));
    } finally {
      await _cleanUp(auth, app);
    }
  }

  Future<void> _discard(User user) async {
    try {
      await user.delete();
    } on FirebaseException {
      return;
    }
  }

  Future<void> _cleanUp(FirebaseAuth? auth, FirebaseApp? app) async {
    try {
      await auth?.signOut();
      await app?.delete();
    } on FirebaseException {
      return;
    }
  }

  String _message(FirebaseException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'A login with this email already exists. If that user was '
            'deleted earlier, remove the login in Firebase Authentication first.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'The password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Connect to the internet to add users.';
      default:
        return e.message ?? 'The user could not be created.';
    }
  }
}
