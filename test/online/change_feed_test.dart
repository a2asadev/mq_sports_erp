import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:a2_stocks/online/api_client.dart';
import 'package:a2_stocks/online/change_feed.dart';
import 'package:a2_stocks/online/token_store.dart';

const String _userJson =
    '{"id":"u1","email":"a@b.c","displayName":"Ann","phoneNumber":"","role":"manager","isActive":true,'
    '"createdAt":"2026-11-01T00:00:00.000Z","updatedAt":"2026-11-01T00:00:00.000Z"}';

/// What the server's stream sends: events, a blank line after each.
String _events(List<String> types) => types.map((String t) => 'event: $t\ndata: {}\n\n').join();

http.StreamedResponse _stream(int status, String text) =>
    http.StreamedResponse(Stream<List<int>>.value(utf8.encode(text)), status);

Future<ApiClient> _signedIn(MockClient streaming) async {
  final MockClient plain = MockClient((http.Request request) async {
    if (request.url.path == '/v1/auth/login' || request.url.path == '/v1/auth/refresh') {
      return http.Response('{"accessToken":"access-1","refreshToken":"refresh-1","user":$_userJson}', 200,
          headers: <String, String>{'content-type': 'application/json'});
    }
    return http.Response('{}', 200);
  });
  final ApiClient api = ApiClient(
    httpClient: plain,
    streamClient: streaming,
    baseUrl: 'http://api.test',
    tokens: MemoryTokenStore(),
  );
  await api.login('a@b.c', 'secret');
  return api;
}

void main() {
  group('the update stream of the API client', () {
    test('signals when it opens and whenever something changed, never for a keep-alive', () async {
      late http.BaseRequest seen;
      final ApiClient api = await _signedIn(MockClient.streaming((http.BaseRequest request, Stream<List<int>> _) async {
        seen = request;
        return _stream(200, ': hello\n\n${_events(<String>['ready', 'ping', 'changed', 'ping', 'changed'])}');
      }));

      final List<String> signals = await api.openChangeStream().toList();

      // ready + two changes; the keep-alive pings are not signals.
      expect(signals, <String>['ready', 'changed', 'changed']);
      expect(seen.url.path, '/v1/sync/stream');
      expect(seen.headers['Authorization'], 'Bearer access-1');
      expect(seen.headers['Accept'], 'text/event-stream');
    });

    test('tells a new notification apart from an ordinary change', () async {
      final ApiClient api = await _signedIn(MockClient.streaming((http.BaseRequest request, Stream<List<int>> _) async =>
          _stream(200, _events(<String>['ready', 'notification', 'changed', 'ping']))));
      expect(await api.openChangeStream().toList(), <String>['ready', 'notification', 'changed']);
    });

    test('signs in again once when the token has expired, then reads the stream', () async {
      int calls = 0;
      final ApiClient api = await _signedIn(MockClient.streaming((http.BaseRequest request, Stream<List<int>> _) async {
        calls += 1;
        return calls == 1 ? _stream(401, '{"statusCode":401}') : _stream(200, _events(<String>['ready']));
      }));

      expect(await api.openChangeStream().toList(), <String>['ready']);
      expect(calls, 2);
    });

    test('a refusal (too many streams, a server error) is an error, so the caller backs off', () async {
      final ApiClient api = await _signedIn(MockClient.streaming(
          (http.BaseRequest request, Stream<List<int>> _) async => _stream(429, '{"code":"stream.too_many_connections"}')));
      await expectLater(api.openChangeStream().toList(), throwsA(isA<Exception>()));
    });
  });

  group('the change feed', () {
    ChangeFeed feedOf(Stream<String> Function() open, Future<void> Function() onSignal) => ChangeFeed(
          open: open,
          onSignal: onSignal,
          quiet: const Duration(milliseconds: 10),
          firstWait: const Duration(milliseconds: 10),
          longestWait: const Duration(milliseconds: 40),
        );

    test('a burst of signals is one call', () async {
      final StreamController<String> controller = StreamController<String>();
      int calls = 0;
      final ChangeFeed feed = feedOf(() => controller.stream, () async => calls++);
      feed.start();
      for (int i = 0; i < 10; i++) {
        controller.add('changed');
      }
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(calls, 1);
      controller.add('changed');
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(calls, 2);
      await feed.stop();
      await controller.close();
    });

    test('a new notification runs its own handler, and the opening ready also checks the bell', () async {
      final StreamController<String> controller = StreamController<String>();
      int syncs = 0;
      int bells = 0;
      final ChangeFeed feed = ChangeFeed(
        open: () => controller.stream,
        onSignal: () async => syncs++,
        onNotification: () async => bells++,
        quiet: const Duration(milliseconds: 10),
      );
      feed.start();
      controller.add('ready'); // connected: catch up on both
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect((syncs, bells), (1, 1));
      controller.add('notification'); // only the bell
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect((syncs, bells), (1, 2));
      controller.add('changed'); // only the data
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect((syncs, bells), (2, 2));
      await feed.stop();
      await controller.close();
    });

    test('connects again after the connection fails, and carries on signalling', () async {
      int opened = 0;
      int calls = 0;
      final ChangeFeed feed = feedOf(() {
        opened += 1;
        if (opened == 1) {
          return Stream<String>.error(Exception('connection lost'));
        }
        return Stream<String>.fromIterable(<String>['changed']);
      }, () async => calls++);
      feed.start();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await feed.stop();
      expect(opened, greaterThanOrEqualTo(2));
      expect(calls, greaterThanOrEqualTo(1));
    });

    test('a refused connection is retried with growing pauses, not in a tight loop', () async {
      int opened = 0;
      final ChangeFeed feed = ChangeFeed(
        open: () {
          opened += 1;
          return Stream<String>.error(Exception('refused'));
        },
        onSignal: () async {},
        firstWait: const Duration(milliseconds: 20),
        longestWait: const Duration(milliseconds: 80),
      );
      feed.start();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await feed.stop();
      // 20, 40, 80, 80 ms pauses: a handful of tries in 300 ms, never dozens.
      expect(opened, inInclusiveRange(2, 8));
    });

    test('stop closes the connection and nothing more happens; reconnectNow skips the pause', () async {
      final List<StreamController<String>> controllers = <StreamController<String>>[];
      int calls = 0;
      final ChangeFeed feed = ChangeFeed(
        open: () {
          final StreamController<String> controller = StreamController<String>();
          controllers.add(controller);
          // Fail at once so the feed is in its pause.
          controller.addError(Exception('down'));
          return controller.stream;
        },
        onSignal: () async => calls++,
        firstWait: const Duration(seconds: 30),
        longestWait: const Duration(seconds: 30),
      );
      feed.start();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(controllers, hasLength(1));
      feed.reconnectNow(); // the network is back: no waiting for 30 s
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(controllers.length, greaterThanOrEqualTo(2));
      await feed.stop();
      final int opened = controllers.length;
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(controllers.length, opened);
      expect(calls, 0);
      expect(feed.isRunning, isFalse);
    });
  });
}
