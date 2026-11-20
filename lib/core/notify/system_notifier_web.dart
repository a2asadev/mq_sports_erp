import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'package:a2_stocks/core/notify/system_notifier_base.dart';

/// The browser's notifications (the Notification API). The browser asks the
/// person once; it only allows the request from something the person did.
SystemNotifier createSystemNotifier() => BrowserSystemNotifier();

class BrowserSystemNotifier implements SystemNotifier {
  @override
  bool get isSupported => true;

  @override
  Future<bool> isAllowed() async => web.Notification.permission == 'granted';

  @override
  Future<bool> requestPermission() async {
    if (web.Notification.permission == 'granted') {
      return true;
    }
    if (web.Notification.permission == 'denied') {
      return false;
    }
    final JSString answer = await web.Notification.requestPermission().toDart;
    return answer.toDart == 'granted';
  }

  @override
  Future<void> show({required String title, required String body}) async {
    try {
      final web.Notification notification =
          web.Notification(title, web.NotificationOptions(body: body, silent: true));
      // Clicking it brings the admin tab forward.
      notification.onclick = ((web.Event event) {
        web.window.focus();
        notification.close();
      }).toJS;
    } catch (error) {
      debugPrint('Browser notification could not be shown: $error');
    }
  }
}
