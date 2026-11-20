import 'package:a2_stocks/l10n/l10n.dart';
/// Base type for every failure the app expects and handles gracefully.
abstract class AppException implements Exception {
  const AppException(this.message, {this.code = ''});

  /// What to tell the person, in the language of the app.
  final String message;

  /// The API's error code ("orders.order_not_found"), or '' for an error the app raised itself.
  /// Compare with this, never with the words of [message].
  final String code;

  @override
  String toString() => message;
}

/// Thrown when a Hive read or write fails.
class LocalStorageException extends AppException {
  const LocalStorageException(super.message, {super.code});
}

/// Thrown when a Cloud Firestore request fails or times out.
class RemoteSyncException extends AppException {
  const RemoteSyncException(super.message, {super.code});
}

/// Thrown when authentication fails.
class AuthFailureException extends AppException {
  const AuthFailureException(super.message, {super.code});
}

/// Thrown when the signed-in user is not allowed to perform an action.
class PermissionDeniedException extends AppException {
  const PermissionDeniedException(super.message, {super.code});
}

/// Thrown when submitted data breaks a business rule.
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

/// Thrown when the cloud collection changed since this device last synced it.
class VersionConflictException extends AppException {
  VersionConflictException(this.currentVersion)
      : super(L10n.current.appExceptionsTheCloudDataChanged);

  final int currentVersion;
}

/// Thrown when one or more collections of a grouped upload changed in the
/// cloud since this device last synced them.
class GroupVersionConflictException extends AppException {
  GroupVersionConflictException(this.currentVersions)
      : super(L10n.current.appExceptionsTheCloudDataChanged);

  final Map<String, int> currentVersions;
}
