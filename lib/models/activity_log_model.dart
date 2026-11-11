import 'package:uuid/uuid.dart';

enum LogLevel {
  info('Info'),
  warning('Warning'),
  error('Error');

  const LogLevel(this.label);

  final String label;

  static LogLevel fromName(String? name) {
    for (final LogLevel level in LogLevel.values) {
      if (level.name == name) {
        return level;
      }
    }
    return LogLevel.info;
  }
}

/// What sort of event a log entry describes.
enum LogKind {
  /// A record was created, edited or deleted.
  record('Record change'),

  /// A business action, for example "order confirmed".
  action('Action'),

  /// An action that was rejected or failed.
  failure('Failure'),

  /// A sync upload/download/conflict.
  sync('Sync'),

  /// Sign in / sign out.
  session('Session');

  const LogKind(this.label);

  final String label;

  static LogKind fromName(String? name) {
    for (final LogKind kind in LogKind.values) {
      if (kind.name == name) {
        return kind;
      }
    }
    return LogKind.action;
  }
}

/// One field of a record that changed, as text.
class LogFieldChange {
  const LogFieldChange({required this.field, this.from, this.to});

  final String field;

  /// Null when the field did not exist before.
  final String? from;

  /// Null when the field no longer exists.
  final String? to;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'field': field, 'from': from, 'to': to};
  }

  factory LogFieldChange.fromMap(Map<String, dynamic> map) {
    return LogFieldChange(
      field: map['field'] as String? ?? '',
      from: map['from'] as String?,
      to: map['to'] as String?,
    );
  }
}

/// One entry of the activity log. Logs are append-only: they are never edited
/// or deleted, and they keep names and labels as they were at the time, so
/// they stay readable whatever happens to the records they mention.
class ActivityLogModel {
  ActivityLogModel({
    String? id,
    DateTime? createdAt,
    this.level = LogLevel.info,
    required this.kind,
    required this.action,
    required this.module,
    this.entityId = '',
    this.entityLabel = '',
    required this.summary,
    List<LogFieldChange>? changes,
    this.groupId = '',
    this.userId = '',
    this.userName = '',
    this.userRole = '',
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        changes = List<LogFieldChange>.unmodifiable(
            changes ?? const <LogFieldChange>[]);

  final String id;
  final DateTime createdAt;
  final LogLevel level;
  final LogKind kind;

  /// Short machine-friendly name, for example `create`, `order_confirmed`.
  final String action;

  /// Collection name or area the event belongs to, for example `orders`.
  final String module;
  final String entityId;

  /// Name or number of the record, for example `ORD-20261112-A1B2`.
  final String entityLabel;
  final String summary;
  final List<LogFieldChange> changes;

  /// Links entries written by one action (an order and its stock and ledger
  /// entries).
  final String groupId;
  final String userId;
  final String userName;
  final String userRole;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      // UTC ISO 8601, so the text sorts in time order in Firestore.
      'createdAt': createdAt.toUtc().toIso8601String(),
      'level': level.name,
      'kind': kind.name,
      'action': action,
      'module': module,
      'entityId': entityId,
      'entityLabel': entityLabel,
      'summary': summary,
      'changes': changes.map((LogFieldChange c) => c.toMap()).toList(),
      'groupId': groupId,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
    };
  }

  factory ActivityLogModel.fromMap(Map<String, dynamic> map) {
    final List<Object?> rawChanges = map['changes'] as List<Object?>? ?? <Object?>[];
    return ActivityLogModel(
      id: map['id'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '')?.toLocal(),
      level: LogLevel.fromName(map['level'] as String?),
      kind: LogKind.fromName(map['kind'] as String?),
      action: map['action'] as String? ?? '',
      module: map['module'] as String? ?? '',
      entityId: map['entityId'] as String? ?? '',
      entityLabel: map['entityLabel'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      changes: rawChanges
          .whereType<Map<String, dynamic>>()
          .map(LogFieldChange.fromMap)
          .toList(),
      groupId: map['groupId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      userRole: map['userRole'] as String? ?? '',
    );
  }
}
