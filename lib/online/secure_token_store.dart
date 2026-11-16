import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:a2_stocks/online/token_store.dart';

/// A place for one small secret that the operating system protects
/// (Keychain on iOS/macOS, Keystore on Android, Credential Manager on Windows,
/// libsecret on Linux).
abstract class SecretVault {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

class PlatformSecretVault implements SecretVault {
  PlatformSecretVault([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Mobile and desktop: the refresh token lives in the system's protected
/// storage instead of plain preferences. The user record (name, role) is not a
/// secret and stays in preferences.
///
/// - An older token left in preferences by a previous version is moved into the
///   protected storage the first time it is read.
/// - If the protected storage is not available on this computer (for example a
///   Linux desktop without a keyring), the token falls back to preferences so
///   the app still works.
class SecureTokenStore implements TokenStore {
  SecureTokenStore({SecretVault? vault, SharedPrefsTokenStore? prefs})
      : _vault = vault ?? PlatformSecretVault(),
        _prefs = prefs ?? SharedPrefsTokenStore();

  static const String _key = 'mq_refresh_token';

  final SecretVault _vault;
  final SharedPrefsTokenStore _prefs;

  @override
  Future<String?> readRefreshToken() async {
    try {
      final String? secret = await _vault.read(_key);
      if (secret != null && secret.isNotEmpty) {
        return secret;
      }
      final String? old = await _prefs.readRefreshToken();
      if (old != null && old.isNotEmpty) {
        await _vault.write(_key, old);
        await _prefs.clearRefreshToken();
        return old;
      }
      return null;
    } catch (_) {
      return _prefs.readRefreshToken();
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      await _vault.write(_key, token);
      await _prefs.clearRefreshToken();
    } catch (_) {
      await _prefs.saveRefreshToken(token);
    }
  }

  @override
  Future<String?> readUserJson() => _prefs.readUserJson();

  @override
  Future<void> saveUserJson(String json) => _prefs.saveUserJson(json);

  @override
  Future<void> clear() async {
    try {
      await _vault.delete(_key);
    } catch (_) {
      // Fall through: the preferences copy is removed below either way.
    }
    await _prefs.clear();
  }
}
