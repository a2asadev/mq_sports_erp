import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mq_sports_erp/online/api_client.dart';
import 'package:mq_sports_erp/online/remote_store.dart';
import 'package:mq_sports_erp/online/token_store.dart';

http.Response _page(
  String cursor, {
  bool more = false,
  Map<String, List<Map<String, dynamic>>> changes = const <String, List<Map<String, dynamic>>>{},
  Map<String, List<String>> deleted = const <String, List<String>>{},
}) {
  return http.Response(
    jsonEncode(<String, dynamic>{
      'cursor': cursor,
      'hasMore': more,
      'changes': changes,
      'deleted': deleted,
    }),
    200,
    headers: <String, String>{'content-type': 'application/json'},
  );
}

RemoteStore _store(Future<http.Response> Function(http.Request) handler, {int pageSize = 1000}) {
  final ApiClient api = ApiClient(
    httpClient: MockClient(handler),
    baseUrl: 'http://api.test',
    tokens: MemoryTokenStore(),
  );
  return RemoteStore(api, pageSize: pageSize);
}

void main() {
  test('downloads everything on the first load, following the pages', () async {
    final List<Map<String, String>> queries = <Map<String, String>>[];
    final RemoteStore store = _store((http.Request request) async {
      queries.add(request.url.queryParameters);
      switch (request.url.queryParameters['since']) {
        case '0':
          return _page('10', more: true, changes: <String, List<Map<String, dynamic>>>{
            'categories': <Map<String, dynamic>>[<String, dynamic>{'id': 'c1', 'name': 'A'}],
          });
        default:
          return _page('20', changes: <String, List<Map<String, dynamic>>>{
            'categories': <Map<String, dynamic>>[<String, dynamic>{'id': 'c2', 'name': 'B'}],
            'customers': <Map<String, dynamic>>[<String, dynamic>{'id': 'u1', 'name': 'Ali'}],
          });
      }
    }, pageSize: 2);

    expect(store.isLoaded, isFalse);
    await store.ensureLoaded();

    expect(store.isLoaded, isTrue);
    expect(queries.map((Map<String, String> q) => q['since']), <String?>['0', '10']);
    expect(queries.first['limit'], '2');
    expect(store.list('categories').map((JsonMap m) => m['name']), <Object?>['A', 'B']);
    expect(store.list('customers').single['name'], 'Ali');
    expect(store.list('products'), isEmpty);
    expect(store.byId('categories', 'c2')?['name'], 'B');
    expect(store.byId('categories', 'nope'), isNull);
  });

  test('later refreshes ask only for what changed and apply edits and deletes', () async {
    final List<String> sinceValues = <String>[];
    int call = 0;
    final RemoteStore store = _store((http.Request request) async {
      sinceValues.add(request.url.queryParameters['since'] ?? '');
      call++;
      if (call == 1) {
        return _page('5', changes: <String, List<Map<String, dynamic>>>{
          'categories': <Map<String, dynamic>>[
            <String, dynamic>{'id': 'c1', 'name': 'Old'},
            <String, dynamic>{'id': 'c2', 'name': 'Gone soon'},
          ],
        });
      }
      return _page('9',
          changes: <String, List<Map<String, dynamic>>>{
            'categories': <Map<String, dynamic>>[<String, dynamic>{'id': 'c1', 'name': 'New'}],
          },
          deleted: <String, List<String>>{'categories': <String>['c2']});
    });
    await store.ensureLoaded();
    int notified = 0;
    store.onChanged = () => notified++;

    await store.refresh();

    expect(sinceValues, <String>['0', '5']);
    expect(store.list('categories').map((JsonMap m) => m['name']), <Object?>['New']);
    expect(notified, 1);
  });

  test('says nothing when nothing changed', () async {
    final RemoteStore store = _store((http.Request _) async => _page('1'));
    await store.ensureLoaded();
    int notified = 0;
    store.onChanged = () => notified++;
    await store.refresh();
    expect(notified, 0);
  });

  test('turns the server\'s UTC times into local times, everywhere inside a record', () async {
    final RemoteStore store = _store((http.Request _) async => _page('1',
        changes: <String, List<Map<String, dynamic>>>{
          'orders': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'o1',
              'orderDate': '2026-11-14T22:30:00.000Z',
              'note': 'text that is not a time',
              'statusHistory': <Map<String, dynamic>>[
                <String, dynamic>{'status': 'pending', 'changedAt': '2026-11-14T22:30:01.250Z'},
              ],
            },
          ],
        }));
    await store.ensureLoaded();

    final JsonMap order = store.byId('orders', 'o1')!;
    final DateTime parsed = DateTime.parse(order['orderDate'] as String);
    expect(parsed.isUtc, isFalse);
    expect(parsed.toUtc(), DateTime.utc(2026, 11, 14, 22, 30));
    expect(order['note'], 'text that is not a time');
    final List<Object?> history = order['statusHistory'] as List<Object?>;
    final DateTime changed = DateTime.parse((history.single as Map<String, dynamic>)['changedAt'] as String);
    expect(changed.isUtc, isFalse);
    expect(changed.toUtc(), DateTime.utc(2026, 11, 14, 22, 30, 1, 250));
  });

  test('a refresh asked for while one is running is not lost', () async {
    final List<String> sinceValues = <String>[];
    final Completer<void> release = Completer<void>();
    int call = 0;
    final RemoteStore store = _store((http.Request request) async {
      sinceValues.add(request.url.queryParameters['since'] ?? '');
      call++;
      if (call == 1) {
        await release.future; // the first round is slow
        return _page('4');
      }
      return _page('7', changes: <String, List<Map<String, dynamic>>>{
        'categories': <Map<String, dynamic>>[<String, dynamic>{'id': 'late', 'name': 'Written meanwhile'}],
      });
    });

    final Future<void> first = store.refresh();
    final Future<void> second = store.refresh(); // e.g. right after a write
    release.complete();
    await Future.wait(<Future<void>>[first, second]);

    expect(sinceValues, <String>['0', '4']);
    expect(store.byId('categories', 'late'), isNotNull);
  });

  test('an error leaves the position alone so the next refresh retries', () async {
    int call = 0;
    final RemoteStore store = _store((http.Request request) async {
      call++;
      if (call == 1) {
        throw http.ClientException('offline');
      }
      return _page('3', changes: <String, List<Map<String, dynamic>>>{
        'categories': <Map<String, dynamic>>[<String, dynamic>{'id': 'c1'}],
      });
    });
    await expectLater(store.ensureLoaded(), throwsA(isA<Object>()));
    expect(store.isLoaded, isFalse);
    await store.ensureLoaded();
    expect(store.isLoaded, isTrue);
    expect(store.list('categories'), hasLength(1));
  });

  test('reset forgets everything and starts from zero again', () async {
    final List<String> sinceValues = <String>[];
    final RemoteStore store = _store((http.Request request) async {
      sinceValues.add(request.url.queryParameters['since'] ?? '');
      return _page('8', changes: <String, List<Map<String, dynamic>>>{
        'categories': <Map<String, dynamic>>[<String, dynamic>{'id': 'c1'}],
      });
    });
    await store.ensureLoaded();
    store.reset();
    expect(store.list('categories'), isEmpty);
    expect(store.isLoaded, isFalse);
    await store.ensureLoaded();
    expect(sinceValues, <String>['0', '0']);
  });
}
