import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/online/api_client.dart';
import 'package:mq_sports_erp/online/token_store.dart';

const String _userJson =
    '{"id":"u1","email":"a@b.c","displayName":"Ann","phoneNumber":"","role":"manager","isActive":true,'
    '"createdAt":"2026-11-01T00:00:00.000Z","updatedAt":"2026-11-01T00:00:00.000Z"}';

http.Response _json(int status, String body) =>
    http.Response(body, status, headers: <String, String>{'content-type': 'application/json'});

String _tokens(String access, String refresh) =>
    '{"accessToken":"$access","refreshToken":"$refresh","user":$_userJson}';

ApiClient _client(MockClient mock, [TokenStore? store]) => ApiClient(
      httpClient: mock,
      baseUrl: 'http://api.test/',
      tokens: store ?? MemoryTokenStore(),
    );

void main() {
  group('sign in and out', () {
    test('login keeps the refresh token, sends the access token afterwards and announces the user', () async {
      final List<http.Request> seen = <http.Request>[];
      final MemoryTokenStore store = MemoryTokenStore();
      final ApiClient api = _client(MockClient((http.Request request) async {
        seen.add(request);
        if (request.url.path == '/v1/auth/login') {
          return _json(200, _tokens('access-1', 'refresh-1'));
        }
        return _json(200, '{"ok":true}');
      }), store);
      final List<UserModel?> announced = <UserModel?>[];
      api.sessionChanges.listen(announced.add);

      final UserModel user = await api.login('  a@b.c ', 'secret');
      await api.get('/v1/things');
      await Future<void>.delayed(Duration.zero);

      expect(user.role.name, 'manager');
      expect(await store.readRefreshToken(), 'refresh-1');
      expect(jsonDecode(seen[0].body), <String, dynamic>{'email': 'a@b.c', 'password': 'secret'});
      expect(seen[0].headers.containsKey('Authorization'), isFalse);
      expect(seen[1].headers['Authorization'], 'Bearer access-1');
      expect(seen[1].url.toString(), 'http://api.test/v1/things');
      expect(announced.single?.id, 'u1');
      expect(api.isSignedIn, isTrue);
    });

    test('a wrong password is an authentication failure with the server message', () async {
      final ApiClient api = _client(MockClient((http.Request _) async =>
          _json(401, '{"statusCode":401,"message":"Invalid email or password"}')));
      await expectLater(
        api.login('a@b.c', 'bad'),
        throwsA(isA<AuthFailureException>()
            .having((AuthFailureException e) => e.message, 'message', 'Invalid email or password')),
      );
      expect(api.isSignedIn, isFalse);
    });

    test('logout tells the server, clears everything, and still works when the server is down', () async {
      final MemoryTokenStore store = MemoryTokenStore();
      bool serverUp = true;
      final List<String> paths = <String>[];
      final ApiClient api = _client(MockClient((http.Request request) async {
        paths.add(request.url.path);
        if (!serverUp) {
          throw http.ClientException('down');
        }
        return request.url.path == '/v1/auth/login'
            ? _json(200, _tokens('a', 'r'))
            : http.Response('', 204);
      }), store);
      await api.login('a@b.c', 'x');
      final List<UserModel?> announced = <UserModel?>[];
      api.sessionChanges.listen(announced.add);

      serverUp = false;
      await api.logout();
      await Future<void>.delayed(Duration.zero);

      expect(paths.last, '/v1/auth/logout');
      expect(await store.readRefreshToken(), isNull);
      expect(api.isSignedIn, isFalse);
      expect(announced, <UserModel?>[null]);
    });

    test('restoreSession signs in again from a stored token, and forgets one that no longer works', () async {
      final MemoryTokenStore store = MemoryTokenStore();
      expect(await _client(MockClient((http.Request _) async => _json(500, '{}')), store).restoreSession(), isNull);

      await store.saveRefreshToken('old');
      final ApiClient good = _client(MockClient((http.Request request) async {
        expect(jsonDecode(request.body), <String, dynamic>{'refreshToken': 'old'});
        return _json(200, _tokens('new-access', 'new-refresh'));
      }), store);
      expect((await good.restoreSession())?.email, 'a@b.c');
      expect(await store.readRefreshToken(), 'new-refresh');

      final ApiClient revoked = _client(MockClient((http.Request _) async =>
          _json(401, '{"message":"Refresh token was already used"}')), store);
      expect(await revoked.restoreSession(), isNull);
      expect(await store.readRefreshToken(), isNull);
    });
  });

  group('expired access tokens', () {
    test('are refreshed once and the request is repeated', () async {
      int refreshes = 0;
      final List<String> thingAuth = <String>[];
      final MemoryTokenStore store = MemoryTokenStore();
      final ApiClient api = _client(MockClient((http.Request request) async {
        switch (request.url.path) {
          case '/v1/auth/login':
            return _json(200, _tokens('expired', 'r1'));
          case '/v1/auth/refresh':
            refreshes++;
            return _json(200, _tokens('fresh', 'r2'));
          default:
            thingAuth.add(request.headers['Authorization'] ?? '');
            return request.headers['Authorization'] == 'Bearer fresh'
                ? _json(200, '{"ok":true}')
                : _json(401, '{"message":"expired"}');
        }
      }), store);
      await api.login('a@b.c', 'x');

      final ApiResponse response = await api.get('/v1/things');

      expect(response.asMap['ok'], true);
      expect(refreshes, 1);
      expect(thingAuth, <String>['Bearer expired', 'Bearer fresh']);
      expect(await store.readRefreshToken(), 'r2');
    });

    test('several requests that fail together share ONE refresh', () async {
      int refreshes = 0;
      final ApiClient api = _client(MockClient((http.Request request) async {
        switch (request.url.path) {
          case '/v1/auth/login':
            return _json(200, _tokens('expired', 'r1'));
          case '/v1/auth/refresh':
            refreshes++;
            await Future<void>.delayed(const Duration(milliseconds: 20));
            return _json(200, _tokens('fresh', 'r2'));
          default:
            return request.headers['Authorization'] == 'Bearer fresh'
                ? _json(200, '{"ok":true}')
                : _json(401, '{}');
        }
      }));
      await api.login('a@b.c', 'x');

      final List<ApiResponse> results = await Future.wait(<Future<ApiResponse>>[
        api.get('/v1/a'), api.get('/v1/b'), api.get('/v1/c'), api.get('/v1/d'),
      ]);

      expect(results.every((ApiResponse r) => r.status == 200), isTrue);
      // A refresh token works once; a second refresh would sign the user out.
      expect(refreshes, 1);
    });

    test('a refresh that fails ends the session', () async {
      final MemoryTokenStore store = MemoryTokenStore();
      final ApiClient api = _client(MockClient((http.Request request) async {
        if (request.url.path == '/v1/auth/login') {
          return _json(200, _tokens('expired', 'r1'));
        }
        return _json(401, '{"message":"nope"}');
      }), store);
      await api.login('a@b.c', 'x');
      final List<UserModel?> announced = <UserModel?>[];
      api.sessionChanges.listen(announced.add);

      await expectLater(api.get('/v1/things'), throwsA(isA<AuthFailureException>()));
      await Future<void>.delayed(Duration.zero);

      expect(await store.readRefreshToken(), isNull);
      expect(api.isSignedIn, isFalse);
      expect(announced, <UserModel?>[null]);
    });
  });

  group('errors', () {
    Future<Object> failWith(int status, String body) async {
      final ApiClient api = _client(MockClient((http.Request _) async => _json(status, body)));
      try {
        await api.get('/v1/x');
      } on Object catch (e) {
        return e;
      }
      return 'no error';
    }

    test('map to the exceptions the screens already show', () async {
      expect(await failWith(400, '{"message":"Name is required."}'),
          isA<ValidationException>().having((ValidationException e) => e.message, 'message', 'Name is required.'));
      expect((await failWith(400, '{"message":["a is wrong","b is wrong"]}') as ValidationException).message,
          'a is wrong\nb is wrong');
      expect(await failWith(409, '{"message":"Not enough stock for BAT-S"}'), isA<ValidationException>());
      expect(await failWith(404, '{"message":"Order not found"}'), isA<ValidationException>());
      expect(await failWith(403, '{"message":"no"}'), isA<PermissionDeniedException>());
      expect(await failWith(429, '{}'), isA<RemoteSyncException>());
      expect(await failWith(500, 'oops'), isA<RemoteSyncException>());
      expect(await failWith(502, ''), isA<RemoteSyncException>());
    });

    test('a connection problem says the server cannot be reached', () async {
      final ApiClient api = _client(MockClient((http.Request _) async => throw http.ClientException('x')));
      await expectLater(
        api.get('/v1/x'),
        throwsA(isA<RemoteSyncException>().having((RemoteSyncException e) => e.message, 'message', contains('Cannot reach'))),
      );
    });

    test('a slow server times out', () async {
      final ApiClient api = ApiClient(
        httpClient: MockClient((http.Request _) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return _json(200, '{}');
        }),
        baseUrl: 'http://api.test',
        tokens: MemoryTokenStore(),
        timeout: const Duration(milliseconds: 20),
      );
      await expectLater(api.get('/v1/x'), throwsA(isA<RemoteSyncException>()));
    });
  });

  group('requests', () {
    test('send JSON, query values and the idempotency key', () async {
      late http.Request seen;
      final ApiClient api = _client(MockClient((http.Request request) async {
        seen = request;
        return _json(201, '{"id":"o1"}');
      }));
      final ApiResponse response = await api.post(
        '/v1/orders/confirm',
        body: <String, dynamic>{'customerId': 'c1'},
        idempotencyKey: 'order-o1',
      );
      expect(response.status, 201);
      expect(seen.method, 'POST');
      expect(seen.headers['Content-Type'], contains('application/json'));
      expect(seen.headers['Idempotency-Key'], 'order-o1');
      expect(jsonDecode(seen.body), <String, dynamic>{'customerId': 'c1'});

      await api.get('/v1/sync/changes', query: <String, String>{'since': '0', 'limit': '5'});
      expect(seen.url.queryParameters, <String, String>{'since': '0', 'limit': '5'});
    });

    test('an empty answer (delete) is fine', () async {
      final ApiClient api = _client(MockClient((http.Request _) async => http.Response('', 204)));
      final ApiResponse response = await api.delete('/v1/categories/x');
      expect(response.status, 204);
      expect(response.body, isNull);
    });
  });
}
