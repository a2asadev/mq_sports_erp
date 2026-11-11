import 'package:mq_sports_erp/models/activity_log_model.dart';
import 'package:mq_sports_erp/services/activity_log_store.dart';

/// Who is doing something, for the log.
class LogActor {
  const LogActor({this.id = '', this.name = '', this.role = ''});

  final String id;
  final String name;
  final String role;
}

/// Writes activity logs to the local store.
///
/// Logging must never break the action being logged, so [record] swallows
/// every error. A log that could not be written is simply lost.
class ActivityLogger {
  ActivityLogger({
    required ActivityLogStore store,
    required Future<LogActor> Function() resolveActor,
  })  : _store = store,
        _resolveActor = resolveActor;

  final ActivityLogStore _store;
  final Future<LogActor> Function() _resolveActor;

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
    LogActor? actor,
  }) async {
    try {
      final LogActor who = actor ?? await _resolveActor();
      await _store.add(ActivityLogModel(
        level: level,
        kind: kind,
        action: action,
        module: module,
        entityId: entityId,
        entityLabel: entityLabel,
        summary: summary,
        changes: changes,
        groupId: groupId,
        userId: who.id,
        userName: who.name,
        userRole: who.role,
      ));
    } on Object {
      // Deliberately ignored, see the class comment.
      return;
    }
  }
}
