import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mq_sports_erp/data/local/app_database.dart';
import 'package:mq_sports_erp/data/local/collections.dart';
import 'package:mq_sports_erp/data/local_repositories.dart';
import 'package:mq_sports_erp/data/outbox_entry.dart';
import 'package:mq_sports_erp/data/outbox_store.dart';
import 'package:mq_sports_erp/data/pending_effects.dart';
import 'package:mq_sports_erp/data/sync_engine.dart';
import 'package:mq_sports_erp/models/category_model.dart';
import 'package:mq_sports_erp/models/ledger_model.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/online/api_client.dart';
import 'package:mq_sports_erp/online/token_store.dart';

final DateTime _t = DateTime(2026, 11, 14, 10, 30);

http.Response _json(int status, Object body) =>
    http.Response(jsonEncode(body), status, headers: <String, String>{'content-type': 'application/json'});

/// A page of the server's change feed.
http.Response _page(
  String cursor, {
  bool more = false,
  Map<String, List<Map<String, dynamic>>> changes = const <String, List<Map<String, dynamic>>>{},
  Map<String, List<String>> deleted = const <String, List<String>>{},
}) =>
    _json(200, <String, dynamic>{'cursor': cursor, 'hasMore': more, 'changes': changes, 'deleted': deleted});

Map<String, dynamic> categoryJson(String id, String name) =>
    <String, dynamic>{
      'id': id, 'name': name, 'parentId': '', 'description': '', 'isActive': true,
      'createdAt': '2026-11-14T05:30:00.000Z', 'updatedAt': '2026-11-14T05:30:00.000Z',
    };

void main() {
  late AppDatabase db;
  late LocalCollections local;
  late OutboxStore outbox;
  late SyncEngine engine;
  late List<http.Request> requests;
  late http.Response Function(http.Request request) server;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    local = LocalCollections(db);
    outbox = OutboxStore(db);
    requests = <http.Request>[];
    server = (http.Request request) => _page('0');
    final ApiClient api = ApiClient(
      httpClient: MockClient((http.Request request) async {
        requests.add(request);
        final Object? error = _failure;
        if (error != null) {
          throw error;
        }
        return server(request);
      }),
      baseUrl: 'http://api.test',
      tokens: MemoryTokenStore(),
    );
    _failure = null;
    engine = SyncEngine(api: api, db: db, collections: local, outbox: outbox, pageSize: 2);
  });

  tearDown(() async {
    await db.close();
  });

  LocalRepository<CategoryModel> categories() => LocalRepository<CategoryModel>(
        collection: local.categories,
        outbox: outbox,
        entityLabel: 'Category',
        labelOf: (CategoryModel c) => c.name,
        overlay: (List<CategoryModel> base, List<OutboxEntry> entries) => overlayRecords<CategoryModel>(
            collection: 'categories', base: base, entries: entries, fromMap: CategoryModel.fromMap),
      );

  CategoryModel cat(String id, String name) => CategoryModel(id: id, name: name, createdAt: _t, updatedAt: _t);

  OrderModel order() => OrderModel(
        id: 'o1', orderNo: 'ORD-1', customerId: 'cust', customerName: 'Ali', orderDate: _t, createdAt: _t, updatedAt: _t,
        items: <OrderItem>[
          OrderItem(id: 'i1', productId: 'p', variantId: 'v1', productName: 'Bat', variantLabel: 'S', sku: 'B-S', quantity: 3, unitPrice: 100),
        ],
        statusHistory: <OrderStatusEntry>[OrderStatusEntry(status: OrderStatus.pending, changedAt: _t)],
      );

  group('download', () {
    test('follows the pages, stores the data and moves the cursor with it', () async {
      final List<String> asked = <String>[];
      server = (http.Request request) {
        asked.add(request.url.queryParameters['since']!);
        if (request.url.queryParameters['since'] == '0') {
          return _page('11', more: true, changes: <String, List<Map<String, dynamic>>>{
            'categories': <Map<String, dynamic>>[categoryJson('c1', 'One'), categoryJson('c2', 'Two')],
          });
        }
        return _page('22', changes: <String, List<Map<String, dynamic>>>{
          'categories': <Map<String, dynamic>>[categoryJson('c3', 'Three')],
        });
      };

      expect(await engine.pull(), isTrue);

      expect(asked, <String>['0', '11']);
      expect((await local.categories.all()).map((CategoryModel c) => c.name).toList()..sort(), <String>['One', 'Three', 'Two']);
      expect(await engine.cursor(), '22');
      // The server's UTC times became local times.
      expect((await local.categories.byId('c1'))?.createdAt, DateTime.utc(2026, 11, 14, 5, 30).toLocal());
    });

    test('a later download asks only for what is new, and applies edits and deletes', () async {
      server = (http.Request request) => _page('5', changes: <String, List<Map<String, dynamic>>>{
            'categories': <Map<String, dynamic>>[categoryJson('c1', 'Old'), categoryJson('c2', 'Doomed')],
          });
      await engine.pull();

      final List<String> asked = <String>[];
      server = (http.Request request) {
        asked.add(request.url.queryParameters['since']!);
        return _page('9',
            changes: <String, List<Map<String, dynamic>>>{'categories': <Map<String, dynamic>>[categoryJson('c1', 'New')]},
            deleted: <String, List<String>>{'categories': <String>['c2']});
      };
      expect(await engine.pull(), isTrue);

      expect(asked, <String>['5']);
      expect((await local.categories.all()).single.name, 'New');
      expect(await engine.cursor(), '9');
    });

    test('nothing new means nothing changed', () async {
      server = (http.Request request) => _page('3');
      expect(await engine.pull(), isFalse);
    });

    test('a failed download leaves the cursor where it was', () async {
      server = (http.Request request) => _page('7', changes: <String, List<Map<String, dynamic>>>{
            'categories': <Map<String, dynamic>>[categoryJson('c1', 'A')],
          });
      await engine.pull();
      _failure = http.ClientException('offline');
      await expectLater(engine.pull(), throwsA(isA<Object>()));
      expect(await engine.cursor(), '7');
    });

    test('resetting forgets the downloaded data but keeps the queue', () async {
      server = (http.Request request) => _page('7', changes: <String, List<Map<String, dynamic>>>{
            'categories': <Map<String, dynamic>>[categoryJson('c1', 'A')],
          });
      await engine.pull();
      await categories().save(cat('mine', 'Queued'));

      await engine.resetDownloadedData();

      expect(await local.categories.all(), isEmpty);
      expect(await engine.cursor(), '0');
      expect((await outbox.all()).length, 1);
    });
  });

  group('upload', () {
    test('sends queued actions oldest first, each with its own id as the idempotency key', () async {
      await categories().save(cat('c1', 'Cricket'));
      await categories().save(cat('c2', 'Bats'));
      await LocalOrderRepository(collection: local.orders, outbox: outbox).confirm(order(), paidNow: 50);
      server = (http.Request request) => request.url.path == '/v1/sync/changes' ? _page('1') : _json(201, <String, dynamic>{});

      final SyncOutcome outcome = await engine.sync();

      expect(outcome.uploaded, 3);
      expect(outcome.refused, 0);
      final List<http.Request> writes = requests.where((http.Request r) => r.url.path != '/v1/sync/changes').toList();
      expect(writes.map((http.Request r) => '${r.method} ${r.url.path}').toList(),
          <String>['POST /v1/categories', 'POST /v1/categories', 'POST /v1/orders/confirm']);
      final List<OutboxEntry> queue = await outbox.all();
      expect(writes.map((http.Request r) => r.headers['Idempotency-Key']).toList(), queue.map((OutboxEntry e) => e.opId).toList());
      expect((jsonDecode(writes[0].body) as Map<String, dynamic>)['id'], 'c1');

      final Map<String, dynamic> confirm = jsonDecode(writes[2].body) as Map<String, dynamic>;
      expect(confirm['recordedOffline'], isTrue);
      expect(confirm['paidNow'], 50);
      expect(confirm['orderDate'], _t.toUtc().toIso8601String()); // sent in UTC
      expect((confirm['items'] as List<Object?>).length, 1);
    });

    test('an edit of a confirmed record is sent as an update, not a create', () async {
      await local.categories.upsertAll(<CategoryModel>[cat('c1', 'Old')]);
      await categories().save(cat('c1', 'Renamed'));
      server = (http.Request request) => request.url.path == '/v1/sync/changes' ? _page('1') : _json(200, <String, dynamic>{});
      await engine.sync();
      final http.Request write = requests.firstWhere((http.Request r) => r.url.path != '/v1/sync/changes');
      expect('${write.method} ${write.url.path}', 'PATCH /v1/categories/c1');
    });

    test('a refused action is marked failed with the server\'s reason, and the rest carry on', () async {
      await categories().save(cat('c1', 'Cricket'));
      await categories().save(cat('c2', 'Bats'));
      server = (http.Request request) {
        if (request.url.path == '/v1/sync/changes') {
          return _page('1');
        }
        final Map<String, dynamic> body = jsonDecode(request.body) as Map<String, dynamic>;
        return body['id'] == 'c1'
            ? _json(409, <String, dynamic>{'message': 'A category named "Cricket" already exists here.'})
            : _json(201, <String, dynamic>{});
      };

      final SyncOutcome outcome = await engine.sync();

      expect(outcome.uploaded, 1);
      expect(outcome.refused, 1);
      final List<OutboxEntry> queue = await outbox.all();
      expect(queue.first.state, OutboxState.failed);
      expect(queue.first.error, contains('already exists'));
      expect(queue.last.state, OutboxState.sent);
      // The refused one no longer shows as if it had worked.
      expect((await categories().getLocal()).map((CategoryModel c) => c.id), <String>['c2']);
    });

    test('without a connection everything waits, in order, and nothing is marked failed', () async {
      await categories().save(cat('c1', 'A'));
      await categories().save(cat('c2', 'B'));
      _failure = http.ClientException('no network');

      final SyncOutcome outcome = await engine.sync();

      expect(outcome.offline, isTrue);
      expect(outcome.uploaded, 0);
      final List<OutboxEntry> queue = await outbox.all();
      expect(queue.every((OutboxEntry e) => e.state == OutboxState.pending), isTrue);
      expect(queue.first.attempts, 1); // it stopped at the first one
      expect(queue.last.attempts, 0);
      expect(requests.length, 1);
    });

    test('a server error also stops the upload without marking anything failed', () async {
      await categories().save(cat('c1', 'A'));
      server = (http.Request request) => _json(500, <String, dynamic>{'message': 'boom'});
      final SyncOutcome outcome = await engine.sync();
      expect(outcome.offline, isTrue);
      expect((await outbox.all()).single.state, OutboxState.pending);
    });

    test('a session that has ended stops the sync and says so', () async {
      await categories().save(cat('c1', 'A'));
      server = (http.Request request) => _json(401, <String, dynamic>{'message': 'expired'});
      final SyncOutcome outcome = await engine.sync();
      expect(outcome.error, isNotNull);
      expect((await outbox.all()).single.state, OutboxState.pending);
    });

    test('deleting something the server no longer has counts as done', () async {
      await local.categories.upsertAll(<CategoryModel>[cat('c1', 'Gone already')]);
      await categories().delete('c1');
      server = (http.Request request) => request.url.path == '/v1/sync/changes'
          ? _page('1', deleted: <String, List<String>>{'categories': <String>['c1']})
          : _json(404, <String, dynamic>{'message': 'Category not found'});
      final SyncOutcome outcome = await engine.sync();
      expect(outcome.uploaded, 1);
      expect(outcome.refused, 0);
      expect(await outbox.all(), isEmpty); // arrived (it is gone locally) so it was tidied away
    });

    test('a payment keeps the id it was made with, so the server\'s copy has the same id', () async {
      final LedgerModel payment = LedgerModel(
        id: 'pay1', partyType: PartyType.customer, partyId: 'cust', entryType: LedgerEntryType.payment,
        amount: 25.5, orderId: 'o1', reference: 'ORD-1', description: 'Payment for ORD-1', entryDate: _t,
        createdAt: _t, updatedAt: _t);
      await LocalLedgerRepository(collection: local.ledgers, outbox: outbox).save(payment);
      server = (http.Request request) => request.url.path == '/v1/sync/changes' ? _page('1') : _json(201, <String, dynamic>{});

      await engine.sync();

      final http.Request write = requests.firstWhere((http.Request r) => r.url.path != '/v1/sync/changes');
      expect(write.url.path, '/v1/orders/o1/payments');
      final Map<String, dynamic> body = jsonDecode(write.body) as Map<String, dynamic>;
      expect(body['id'], 'pay1');
      expect(body['amount'], 25.5);
      expect(body.containsKey('note'), isFalse); // the default wording is not sent as a custom note
    });
  });

  group('after an upload', () {
    test('an accepted action keeps showing until its records have been downloaded, then goes', () async {
      await LocalOrderRepository(collection: local.orders, outbox: outbox).confirm(order(), paidNow: 0);
      final LocalOrderRepository orders = LocalOrderRepository(collection: local.orders, outbox: outbox);

      // 1st sync: the server accepted the order but its records are not in the feed yet.
      server = (http.Request request) => request.url.path == '/v1/sync/changes' ? _page('1') : _json(201, <String, dynamic>{});
      await engine.sync();
      expect((await outbox.all()).single.state, OutboxState.sent);
      expect((await orders.getLocal()).length, 1); // still shown, from the queue

      // 2nd sync: the feed now carries the server's order.
      server = (http.Request request) => _page('2', changes: <String, List<Map<String, dynamic>>>{
            'orders': <Map<String, dynamic>>[order().toMap()],
          });
      await engine.sync();
      expect(await outbox.all(), isEmpty);
      expect((await orders.getLocal()).length, 1); // now from the server, not shown twice
      expect((await local.orders.all()).length, 1);
    });
  });
}

/// Set by a test to make the next requests fail like a dropped connection.
Object? _failure;
