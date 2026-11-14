import 'package:flutter_test/flutter_test.dart';
import 'package:mq_sports_erp/online/secure_token_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeVault implements SecretVault {
  final Map<String, String> data = <String, String>{};
  bool broken = false;

  void _check() {
    if (broken) {
      throw StateError('no keyring');
    }
  }

  @override
  Future<String?> read(String key) async {
    _check();
    return data[key];
  }

  @override
  Future<void> write(String key, String value) async {
    _check();
    data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _check();
    data.remove(key);
  }
}

Future<String?> _prefsToken() async => (await SharedPreferences.getInstance()).getString('mq_refresh_token');

void main() {
  late _FakeVault vault;
  late SecureTokenStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    vault = _FakeVault();
    store = SecureTokenStore(vault: vault);
  });

  test('the refresh token goes to protected storage, never to plain preferences', () async {
    await store.saveRefreshToken('secret-1');
    expect(await store.readRefreshToken(), 'secret-1');
    expect(vault.data['mq_refresh_token'], 'secret-1');
    expect(await _prefsToken(), isNull);
  });

  test('a token from an older version is moved over and removed from preferences', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{'mq_refresh_token': 'old-token'});
    expect(await store.readRefreshToken(), 'old-token');
    expect(vault.data['mq_refresh_token'], 'old-token');
    expect(await _prefsToken(), isNull);
  });

  test('the user record stays readable and signing out clears everything', () async {
    await store.saveRefreshToken('t');
    await store.saveUserJson('{"id":"u"}');
    expect(await store.readUserJson(), '{"id":"u"}');
    await store.clear();
    expect(await store.readRefreshToken(), isNull);
    expect(await store.readUserJson(), isNull);
    expect(vault.data, isEmpty);
  });

  test('without a keyring the app still works, using preferences', () async {
    vault.broken = true;
    await store.saveRefreshToken('fallback');
    expect(await store.readRefreshToken(), 'fallback');
    expect(await _prefsToken(), 'fallback');
    await store.clear();
    expect(await store.readRefreshToken(), isNull);
  });
}
