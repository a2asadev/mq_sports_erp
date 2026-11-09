/// Base type for every failure the app expects and handles gracefully.
abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown when a Hive read or write fails.
class LocalStorageException extends AppException {
  const LocalStorageException(super.message);
}

/// Thrown when a Cloud Firestore request fails or times out.
class RemoteSyncException extends AppException {
  const RemoteSyncException(super.message);
}

/// Thrown when authentication fails.
class AuthFailureException extends AppException {
  const AuthFailureException(super.message);
}

/// Thrown when the signed-in user is not allowed to perform an action.
class PermissionDeniedException extends AppException {
  const PermissionDeniedException(super.message);
}

/// Thrown when submitted data breaks a business rule.
class ValidationException extends AppException {
  const ValidationException(super.message);
}
