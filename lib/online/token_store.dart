import 'package:shared_preferences/shared_preferences.dart';

/// Where the refresh token is kept so a page reload does not sign the user out.
/// The (short-lived) access token is never stored, only held in memory.
abstract class TokenStore {
  Future<String?> readRefreshToken();

  Future<void> saveRefreshToken(String token);

  Future<void> clear();
}

/// Browser local storage (web) or the platform's preferences (other platforms).
///
/// Local storage can be read by any script on the page, so the web admin must
/// never load third-party scripts. A later step can move the refresh token into
/// an httpOnly cookie set by the API.
class SharedPrefsTokenStore implements TokenStore {
  static const String _key = 'mq_refresh_token';

  @override
  Future<String?> readRefreshToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  @override
  Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

/// Keeps the token in memory only (tests).
class MemoryTokenStore implements TokenStore {
  String? _token;

  @override
  Future<String?> readRefreshToken() async => _token;

  @override
  Future<void> saveRefreshToken(String token) async {
    _token = token;
  }

  @override
  Future<void> clear() async {
    _token = null;
  }
}
