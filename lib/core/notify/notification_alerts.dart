import 'package:flutter/foundation.dart';
import 'package:a2_stocks/core/notify/alert_sound.dart';
import 'package:a2_stocks/core/notify/system_notifier.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/notification_text.dart';
import 'package:a2_stocks/models/app_notification.dart';

/// What a person chose: a sound for new notifications, and desktop notifications
/// while the window is in the background. (Kept on this device.)
class AlertPrefs {
  const AlertPrefs({this.sound = true, this.system = true});

  final bool sound;
  final bool system;

  AlertPrefs copyWith({bool? sound, bool? system}) => AlertPrefs(sound: sound ?? this.sound, system: system ?? this.system);
}

/// How a test of the alerts went, for the Settings screen to say.
enum AlertTestResult {
  /// The sound played (if on) and a notification was shown.
  sent,

  /// The sound played (if on), but desktop notifications are off in Settings.
  systemOff,

  /// The browser or system does not allow notifications for this app.
  notAllowed,

  /// This device cannot show system notifications at all.
  unsupported,
}

/// Tells the person about new notifications beyond the pop-up in the app: a
/// sound, and a notification of the operating system when the window is in the
/// background (so a new online order is noticed from another window too).
class NotificationAlerts {
  NotificationAlerts({
    required AlertSound sound,
    required SystemNotifier system,
    required AlertPrefs Function() prefs,
    required bool Function() isFocused,
    AppLocalizations Function()? l10n,
  })  : _sound = sound,
        _system = system,
        _prefs = prefs,
        _isFocused = isFocused,
        _l10n = l10n ?? (() => L10n.current);

  final AlertSound _sound;
  final SystemNotifier _system;
  final AlertPrefs Function() _prefs;
  final bool Function() _isFocused;
  final AppLocalizations Function() _l10n;

  /// The most notifications shown at once as system notifications (the rest are in the bell).
  static const int systemLimit = 3;

  /// Called with notifications that just arrived.
  Future<void> announce(List<AppNotification> items) async {
    if (items.isEmpty) {
      return;
    }
    final AlertPrefs prefs = _prefs();
    if (prefs.sound) {
      // One sound for the batch: the order chime wins over the stock tone.
      final bool anOrder = items.any((AppNotification n) => n.type == 'order.web_placed');
      await _sound.play(anOrder ? AlertSoundKind.newOrder : AlertSoundKind.stock);
    }
    // While the window is in front the pop-up is enough.
    if (prefs.system && !_isFocused() && _system.isSupported && await _system.isAllowed()) {
      for (final AppNotification n in items.take(systemLimit)) {
        final NotificationText text = notificationText(_l10n(), n);
        await _system.show(title: text.title, body: text.detail);
      }
    }
  }

  /// A test from Settings: plays the sound (if on) and shows a notification now,
  /// whether or not the window is in front.
  Future<AlertTestResult> sendTest() async {
    final AlertPrefs prefs = _prefs();
    if (prefs.sound) {
      await _sound.play(AlertSoundKind.newOrder);
    }
    if (!_system.isSupported) {
      return AlertTestResult.unsupported;
    }
    if (!prefs.system) {
      return AlertTestResult.systemOff;
    }
    if (!await _system.isAllowed()) {
      return AlertTestResult.notAllowed;
    }
    final AppLocalizations l10n = _l10n();
    await _system.show(title: l10n.notifSettingsTestTitle, body: l10n.notifSettingsTestBody);
    return AlertTestResult.sent;
  }

  /// For the Settings switch: asks the platform for permission (the browser asks the person).
  Future<bool> requestSystemPermission() async {
    try {
      return await _system.requestPermission();
    } catch (error) {
      debugPrint('Notification permission could not be asked: $error');
      return false;
    }
  }

  bool get systemSupported => _system.isSupported;

  Future<bool> systemAllowed() => _system.isAllowed();
}
