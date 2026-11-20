import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:a2_stocks/core/notify/alert_sound.dart';
import 'package:a2_stocks/core/notify/notification_alerts.dart';
import 'package:a2_stocks/core/notify/system_notifier.dart';

/// Whether the app's window is in front. When it is not (another window, minimised,
/// another browser tab) a new notification also shows as a system notification.
class AppFocusNotifier extends Notifier<bool> {
  @override
  bool build() {
    final _LifecycleWatcher watcher = _LifecycleWatcher((AppLifecycleState now) => state = now == AppLifecycleState.resumed);
    WidgetsBinding.instance.addObserver(watcher);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(watcher));
    final AppLifecycleState? now = WidgetsBinding.instance.lifecycleState;
    return now == null || now == AppLifecycleState.resumed;
  }
}

class _LifecycleWatcher with WidgetsBindingObserver {
  _LifecycleWatcher(this._onChange);

  final void Function(AppLifecycleState state) _onChange;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => _onChange(state);
}

final NotifierProvider<AppFocusNotifier, bool> appFocusedProvider =
    NotifierProvider<AppFocusNotifier, bool>(AppFocusNotifier.new);

/// The person's choices about alerts, kept on this device.
class AlertPrefsNotifier extends Notifier<AlertPrefs> {
  static const String soundKey = 'notify_sound';
  static const String systemKey = 'notify_system';

  @override
  AlertPrefs build() {
    // Sound and desktop notifications are on until the person turns them off.
    Future<void>.microtask(_load);
    return const AlertPrefs();
  }

  Future<void> _load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      state = AlertPrefs(sound: prefs.getBool(soundKey) ?? true, system: prefs.getBool(systemKey) ?? true);
    } catch (_) {
      // The defaults stay.
    }
  }

  Future<void> setSound(bool on) async {
    state = state.copyWith(sound: on);
    await _save(soundKey, on);
  }

  Future<void> setSystem(bool on) async {
    state = state.copyWith(system: on);
    await _save(systemKey, on);
  }

  Future<void> _save(String key, bool value) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {
      // Kept for this session at least.
    }
  }
}

final NotifierProvider<AlertPrefsNotifier, AlertPrefs> alertPrefsProvider =
    NotifierProvider<AlertPrefsNotifier, AlertPrefs>(AlertPrefsNotifier.new);

/// The sound and the system notification, with the person's choices and the window's focus.
final Provider<NotificationAlerts> notificationAlertsProvider = Provider<NotificationAlerts>((Ref ref) {
  return NotificationAlerts(
    sound: AssetAlertSound(),
    system: createSystemNotifier(),
    prefs: () => ref.read(alertPrefsProvider),
    isFocused: () => ref.read(appFocusedProvider),
  );
});
