/// Something the bell tells a person about: a new online order, stock running low.
///
/// The server sends a type and the values it needs, never a finished sentence;
/// the app writes the sentence in its own language (see `notificationText`).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.params,
    required this.entityType,
    required this.entityId,
    required this.createdAt,
  });

  final String id;

  /// "order.web_placed", "stock.low" or "stock.out" (a type this app does not know is shown generically).
  final String type;
  final Map<String, Object?> params;

  /// What it is about ("order", "variant") and that thing's id, so it can be opened.
  final String entityType;
  final String entityId;
  final DateTime createdAt;

  String text(String key) => '${params[key] ?? ''}';

  num number(String key) {
    final Object? value = params[key];
    if (value is num) {
      return value;
    }
    return num.tryParse('${value ?? ''}') ?? 0;
  }

  static AppNotification? tryFromMap(Object? map) {
    if (map is! Map<String, dynamic>) {
      return null;
    }
    final Object? id = map['id'];
    final Object? type = map['type'];
    final DateTime? createdAt = DateTime.tryParse('${map['createdAt'] ?? ''}')?.toLocal();
    if (id is! String || id.isEmpty || type is! String || createdAt == null) {
      return null;
    }
    final Object? params = map['params'];
    return AppNotification(
      id: id,
      type: type,
      params: params is Map<String, dynamic> ? params : const <String, Object?>{},
      entityType: map['entityType'] as String? ?? '',
      entityId: map['entityId'] as String? ?? '',
      createdAt: createdAt,
    );
  }
}

/// What `GET /v1/notifications` answers: the newest notifications for this person's
/// role, and how many of them are newer than their last read.
class NotificationList {
  const NotificationList({required this.items, required this.unread});

  final List<AppNotification> items;
  final int unread;

  static NotificationList fromMap(Map<String, dynamic> map) {
    final Object? raw = map['items'];
    return NotificationList(
      items: <AppNotification>[
        if (raw is List<Object?>)
          for (final Object? item in raw)
            if (AppNotification.tryFromMap(item) case final AppNotification n) n,
      ],
      unread: (map['unread'] as num?)?.toInt() ?? 0,
    );
  }
}
