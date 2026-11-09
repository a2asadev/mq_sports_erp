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

/// Firebase Authentication gateway (email + password only).
/// There is intentionally no registration: accounts are created by an
/// administrator in the Firebase console.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  /// Uid of the currently signed-in user, or null when signed out.
  String? get currentUid => _auth.currentUser?.uid;

  /// Data of the signed-in user, or null when signed out.
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

  /// Emits the signed-in user's uid, or null when signed out.
  Stream<String?> uidChanges() {
    return _auth.authStateChanges().map((User? user) => user?.uid);
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthFailureException(_signInMessage(e));
    }
  }

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
