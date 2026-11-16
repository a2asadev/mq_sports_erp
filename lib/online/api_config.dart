import 'package:flutter/foundation.dart';

/// Address of the backend API chosen at build or run time:
///
///     flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3000
///     flutter build web --dart-define=API_BASE_URL=https://api.yourshop.com
///
/// Empty means "use the default for this platform" (see [apiBaseUrl]).
const String _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

/// The address the Android emulator uses for the computer it runs on.
const String _emulatorHost = '10.0.2.2';

bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Where the API is. With nothing set it is the developer's own computer:
/// `10.0.2.2` on the Android emulator (its own "localhost" is the emulator
/// itself), `localhost` everywhere else.
///
/// `10.0.2.2` only exists inside the Android emulator, so on any other
/// platform an address using it (a leftover from an emulator launch setting)
/// is replaced by `localhost` instead of timing out.
String get apiBaseUrl {
  if (_configuredBaseUrl.isEmpty) {
    return _isAndroid ? 'http://$_emulatorHost:3000' : 'http://localhost:3000';
  }
  if (!_isAndroid && _configuredBaseUrl.contains(_emulatorHost)) {
    return _configuredBaseUrl.replaceFirst(_emulatorHost, 'localhost');
  }
  return _configuredBaseUrl;
}

/// How often an open web admin asks the server for other people's changes.
const Duration onlinePollInterval = Duration(seconds: 30);
