/// Shows a notification of the operating system (or the browser) while the app's
/// window is in the background.
abstract class SystemNotifier {
  /// Whether this kind of device can show them at all (desktop and the browser; phones later).
  bool get isSupported;

  /// Whether one may be shown now, without asking.
  Future<bool> isAllowed();

  /// Asks the person for permission when the platform needs it (the browser does;
  /// the desktop does not). Must be called from something the person did, such as a tap.
  /// Returns whether notifications are allowed afterwards.
  Future<bool> requestPermission();

  /// Shows a notification. The app plays its own sound, so this one is silent.
  Future<void> show({required String title, required String body});
}

/// For a device that cannot show them: everything is a quiet "no".
class NoSystemNotifier implements SystemNotifier {
  @override
  bool get isSupported => false;

  @override
  Future<bool> isAllowed() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> show({required String title, required String body}) async {}
}
