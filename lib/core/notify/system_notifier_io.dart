import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:a2_stocks/core/notify/system_notifier_base.dart';

/// Windows, macOS and Linux notifications. (On Windows the first use creates a
/// Start-menu shortcut for the app: the system only shows notifications for an
/// app it knows by name.)
SystemNotifier createSystemNotifier() {
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    return DesktopSystemNotifier();
  }
  return NoSystemNotifier();
}

class DesktopSystemNotifier implements SystemNotifier {
  Future<void>? _setup;

  Future<void> _ready() => _setup ??= localNotifier.setup(appName: 'A2 Stocks');

  @override
  bool get isSupported => true;

  // The desktop asks for nothing.
  @override
  Future<bool> isAllowed() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> show({required String title, required String body}) async {
    try {
      await _ready();
      await LocalNotification(title: title, body: body, silent: true).show();
    } catch (error) {
      debugPrint('Desktop notification could not be shown: $error');
    }
  }
}
