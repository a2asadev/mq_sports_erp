import 'package:mq_sports_erp/models/activity_log_model.dart';

/// The app's hook for "something worth logging happened".
///
/// The server writes the activity log itself, at the moment each action is
/// accepted and with the signed-in user taken from the login, so the app has
/// nothing to record. The hook stays so the screens' code keeps saying what
/// happened; it does nothing.
class ActivityLogger {
  const ActivityLogger();

  Future<void> record({
    required LogKind kind,
    required String action,
    required String module,
    required String summary,
    LogLevel level = LogLevel.info,
    String entityId = '',
    String entityLabel = '',
    List<LogFieldChange> changes = const <LogFieldChange>[],
    String groupId = '',
  }) async {}
}
