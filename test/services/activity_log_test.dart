import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mq_sports_erp/models/activity_log_model.dart';
import 'package:mq_sports_erp/models/syncable_model.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';
import 'package:mq_sports_erp/services/activity_log_store.dart';
import 'package:mq_sports_erp/services/activity_logger.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';
import 'package:mq_sports_erp/services/pending_change_store.dart';

class _Item implements SyncableModel {
  _Item({required this.id, required this.name, this.price = 0, DateTime? updatedAt})
      : updatedAt = updatedAt ?? DateTime.now();

  @override
  final String id;
  final String name;
  final double price;

  @override
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'name': name,
        'price': price,
        'updatedAt': updatedAt.toIso8601String(),
      };

  static _Item fromMap(Map<String, dynamic> map) => _Item(
        id: map['id'] as String,
        name: map['name'] as String,
        price: (map['price'] as num).toDouble(),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );
}

void main() {
  late Directory dir;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('mq_logs_test');
    Hive.init(dir.path);
  });

  tearDown(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  ActivityLogModel log(String summary, {DateTime? at}) => ActivityLogModel(
        kind: LogKind.action,
        action: 'test',
        module: 'm',
        summary: summary,
        createdAt: at,
      );

  group('ActivityLogStore', () {
    test('stores logs newest first and tracks what is not uploaded', () async {
      final ActivityLogStore store = ActivityLogStore();
      final DateTime now = DateTime.now();
      await store.add(log('old', at: now.subtract(const Duration(hours: 2))));
      await store.add(log('new', at: now));

      final List<ActivityLogModel> all = await store.getAll();
      expect(all.map((ActivityLogModel l) => l.summary), <String>['new', 'old']);
      expect(await store.pendingCount(), 2);

      final List<ActivityLogModel> pending = await store.getPending();
      expect(pending.first.summary, 'old'); // oldest first for upload
      await store.markUploaded(<String>[pending.first.id]);
      expect(await store.pendingCount(), 1);
      expect((await store.getAll()), hasLength(2));
    });

    test('purges only uploaded logs older than the limit', () async {
      final ActivityLogStore store = ActivityLogStore();
      final DateTime now = DateTime.now();
      final ActivityLogModel oldUploaded =
          log('old uploaded', at: now.subtract(const Duration(days: 120)));
      final ActivityLogModel oldPending =
          log('old pending', at: now.subtract(const Duration(days: 120)));
      final ActivityLogModel recentUploaded =
          log('recent uploaded', at: now.subtract(const Duration(days: 5)));
      await store.add(oldUploaded);
      await store.add(oldPending);
      await store.add(recentUploaded);
      await store.markUploaded(<String>[oldUploaded.id, recentUploaded.id]);

      final int removed = await store.purgeUploadedOlderThan(const Duration(days: 90));
      expect(removed, 1);
      final List<String> left =
          (await store.getAll()).map((ActivityLogModel l) => l.summary).toList();
      expect(left, containsAll(<String>['old pending', 'recent uploaded']));
      expect(left, isNot(contains('old uploaded')));
    });
  });

  group('ActivityLogger', () {
    test('stamps the signed-in user on every log', () async {
      final ActivityLogStore store = ActivityLogStore();
      final ActivityLogger logger = ActivityLogger(
        store: store,
        resolveActor: () async =>
            const LogActor(id: 'u1', name: 'Sara', role: 'manager'),
      );
      await logger.record(
          kind: LogKind.action, action: 'x', module: 'm', summary: 'did x');
      final ActivityLogModel saved = (await store.getAll()).single;
      expect(saved.userId, 'u1');
      expect(saved.userName, 'Sara');
      expect(saved.userRole, 'manager');
    });

    test('never throws, even when the actor cannot be resolved', () async {
      final ActivityLogger logger = ActivityLogger(
        store: ActivityLogStore(),
        resolveActor: () async => throw StateError('no user'),
      );
      await logger.record(
          kind: LogKind.action, action: 'x', module: 'm', summary: 'did x');
    });
  });

  group('BaseRepository logging', () {
    late ActivityLogStore store;
    late BaseRepository<_Item> repo;

    setUp(() {
      store = ActivityLogStore();
      repo = BaseRepository<_Item>(
        collectionName: 'items',
        entityLabel: 'Item',
        local: HiveLocalRepository<_Item>(boxName: 'items', fromMap: _Item.fromMap),
        pendingStore: PendingChangeStore(),
        fromMap: _Item.fromMap,
        labelOf: (_Item i) => i.name,
        logger: ActivityLogger(
          store: store,
          resolveActor: () async => const LogActor(id: 'u', name: 'Sara'),
        ),
      );
    });

    Future<List<ActivityLogModel>> logs() async =>
        (await store.getAll()).reversed.toList();

    test('logs a create, an edit with its field changes, and a delete', () async {
      await repo.save(_Item(id: '1', name: 'Bat', price: 10));
      await repo.save(_Item(id: '1', name: 'Bat', price: 12));
      await repo.delete('1');

      final List<ActivityLogModel> all = await logs();
      expect(all.map((ActivityLogModel l) => l.action), <String>['create', 'update', 'delete']);
      expect(all[0].summary, 'Created Item "Bat"');
      expect(all[1].changes.single.field, 'price');
      expect(all[1].changes.single.from, '10.0');
      expect(all[1].changes.single.to, '12.0');
      expect(all[2].summary, 'Deleted Item "Bat"');
      expect(all.every((ActivityLogModel l) => l.userName == 'Sara'), isTrue);
      expect(all.every((ActivityLogModel l) => l.module == 'items'), isTrue);
    });

    test('a save that changed nothing is not logged', () async {
      await repo.save(_Item(id: '1', name: 'Bat', price: 10));
      await repo.save(_Item(id: '1', name: 'Bat', price: 10));
      expect(await logs(), hasLength(1));
    });

    test('carries the group id and warns when a creation is undone', () async {
      await repo.save(_Item(id: '2', name: 'Ball'), groupId: 'grp');
      await repo.discardNewLocally('2');

      final List<ActivityLogModel> all = await logs();
      expect(all.first.groupId, 'grp');
      expect(all.last.action, 'discard');
      expect(all.last.level, LogLevel.warning);
    });
  });
}
