import 'package:a2_stocks/models/export_models.dart';

/// How the server's backups are doing, as one word the page can colour.
enum BackupHealth {
  /// The server does not share its backup status (a developer's machine, or not set up).
  notSetUp,

  /// Set up, but no backup has been made yet.
  never,

  /// The last backup is recent and nothing failed since.
  ok,

  /// The last good backup is older than it should be.
  old,

  /// The last attempt failed (after the last good backup).
  failing,
}

/// A daily backup that is more than a day and a half old (36 hours) has been missed.
BackupHealth backupHealth(BackupStatus status, DateTime now, {Duration maxAge = const Duration(hours: 36)}) {
  if (!status.configured) {
    return BackupHealth.notSetUp;
  }
  final DateTime? ok = status.lastSuccessAt;
  final DateTime? failed = status.lastFailureAt;
  if (ok == null && failed == null) {
    return BackupHealth.never;
  }
  if (failed != null && (ok == null || failed.isAfter(ok))) {
    return BackupHealth.failing;
  }
  return now.difference(ok!) > maxAge ? BackupHealth.old : BackupHealth.ok;
}

/// "1.5 MB": a size for people (powers of 1024).
String humanBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  const List<String> units = <String>['KB', 'MB', 'GB', 'TB'];
  double value = bytes / 1024;
  int unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  return '${value >= 100 ? value.toStringAsFixed(0) : value.toStringAsFixed(1)} ${units[unit]}';
}
