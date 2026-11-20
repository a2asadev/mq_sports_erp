import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/models/app_notification.dart';
import 'package:a2_stocks/online/notification_service.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/providers/core_providers.dart';

/// How often the bell checks on its own; live updates make this a safety net.
const Duration notificationsCheckEvery = Duration(minutes: 5);

final Provider<NotificationService> notificationServiceProvider =
    Provider<NotificationService>((Ref ref) => NotificationService(ref.watch(apiClientProvider)));

class NotificationsState {
  const NotificationsState({
    this.items = const <AppNotification>[],
    this.unread = 0,
    this.loaded = false,
    this.failed = false,
    this.announce = const <AppNotification>[],
  });

  /// Newest first.
  final List<AppNotification> items;

  /// How many are newer than this person's last read (the number on the bell).
  final int unread;

  /// Whether the list came from the server at least once.
  final bool loaded;

  /// The last try failed (offline, server down) and nothing has been loaded yet.
  final bool failed;

  /// The notifications that just arrived while the app was open: shown once as a pop-up.
  final List<AppNotification> announce;
}

/// The bell of the staff apps. It loads when someone signs in, again whenever the
/// server says a new notification was made (live updates), and every few minutes.
/// New ones that arrive while the app is open are also announced (a pop-up).
class NotificationsNotifier extends Notifier<NotificationsState> {
  Timer? _timer;
  bool _disposed = false;

  @override
  NotificationsState build() {
    _disposed = false;
    final String? userId =
        ref.watch(authUidProvider.select((AsyncValue<String?> value) => value.valueOrNull));
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
    });
    if (userId == null) {
      return const NotificationsState();
    }
    _timer = Timer.periodic(notificationsCheckEvery, (Timer _) => unawaited(refresh()));
    scheduleMicrotask(() => unawaited(refresh()));
    return const NotificationsState();
  }

  /// Asks the server for the latest. Safe to call at any time.
  Future<void> refresh() async {
    try {
      final NotificationList list = await ref.read(notificationServiceProvider).list();
      if (_disposed) {
        return;
      }
      final Set<String> known = <String>{for (final AppNotification n in state.items) n.id};
      // The first load is not news; after that, anything not seen before is.
      final List<AppNotification> fresh = state.loaded
          ? <AppNotification>[for (final AppNotification n in list.items) if (!known.contains(n.id)) n]
          : const <AppNotification>[];
      state = NotificationsState(items: list.items, unread: list.unread, loaded: true, announce: fresh);
    } catch (_) {
      if (!_disposed && !state.loaded) {
        state = const NotificationsState(failed: true);
      }
    }
  }

  /// Marks everything as read (the number on the bell goes to 0 at once).
  Future<void> markAllRead() async {
    if (state.unread == 0) {
      return;
    }
    state = NotificationsState(items: state.items, unread: 0, loaded: true);
    try {
      await ref.read(notificationServiceProvider).markAllRead();
    } catch (_) {
      await refresh();
    }
  }
}

final NotifierProvider<NotificationsNotifier, NotificationsState> notificationsProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(NotificationsNotifier.new);
