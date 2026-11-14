import 'package:firebase_auth/firebase_auth.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';

/// Plain snapshot of the signed-in Firebase user, so Firebase types never
/// leave the services layer.
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

/// What the app needs from sign-in, whichever service does it (Firebase on
/// mobile and desktop, the API on the web).
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

/// Firebase Authentication gateway (email + password only).
/// There is intentionally no registration: accounts are created by an
/// administrator in the Firebase console.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService(this._auth);

  final FirebaseAuth _auth;

  @override
  String? get currentUid => _auth.currentUser?.uid;

  @override
  AuthUserData? get currentUser {
    final User? user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    return AuthUserData(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      phoneNumber: user.phoneNumber ?? '',
      photoUrl: user.photoURL ?? '',
    );
  }

  @override
  Stream<String?> uidChanges() {
    return _auth.authStateChanges().map((User? user) => user?.uid);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthFailureException(_signInMessage(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthFailureException(e.message ?? 'Sign out failed. Please try again.');
    }
  }

  String _signInMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact your administrator.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Connect to the internet to sign in.';
      default:
        return e.message ?? 'Sign in failed. Please try again.';
    }
  }
}
