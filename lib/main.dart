import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mq_sports_erp/app.dart';
import 'package:mq_sports_erp/firebase_options.dart';
import 'package:mq_sports_erp/models/activity_log_model.dart';
import 'package:mq_sports_erp/providers/activity_log_providers.dart';

/// Writes an uncaught error to the activity log. The same error repeating
/// within a few seconds (for example a widget failing on every frame) is
/// logged once.
class _ErrorLogger {
  _ErrorLogger(this._container);

  final ProviderContainer _container;
  String _lastMessage = '';
  DateTime _lastAt = DateTime.fromMillisecondsSinceEpoch(0);

  void log(Object error, StackTrace? stack) {
    final String message = '$error';
    final DateTime now = DateTime.now();
    if (message == _lastMessage && now.difference(_lastAt).inSeconds < 5) {
      return;
    }
    _lastMessage = message;
    _lastAt = now;
    final List<String> frames = (stack?.toString() ?? '')
        .split('\n')
        .where((String line) => line.trim().isNotEmpty)
        .take(6)
        .toList();
    unawaited(_container.read(activityLoggerProvider).record(
          kind: LogKind.failure,
          action: 'app_error',
          level: LogLevel.error,
          module: 'app',
          summary: 'Unexpected error: ${message.length > 300 ? '${message.substring(0, 300)}…' : message}',
          changes: <LogFieldChange>[
            if (frames.isNotEmpty)
              LogFieldChange(field: 'stack trace', to: frames.join('\n')),
          ],
        ));
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    // The web build is online-only: no local database and no Firebase, it talks
    // to the API (see lib/online).
    await Hive.initFlutter();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // Hive is the single local cache, so Firestore's own cache is disabled.
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: false);
  }

  final ProviderContainer container = ProviderContainer();
  final _ErrorLogger errorLogger = _ErrorLogger(container);
  final FlutterExceptionHandler? previousFlutterHandler = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    errorLogger.log(details.exception, details.stack);
    if (previousFlutterHandler != null) {
      previousFlutterHandler(details);
    } else {
      FlutterError.presentError(details);
    }
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    errorLogger.log(error, stack);
    return false;
  };

  runApp(UncontrolledProviderScope(
    container: container,
    child: const MqSportsApp(),
  ));
}
