import 'package:flutter_test/flutter_test.dart';
import 'package:mq_sports_erp/core/utils/map_diff.dart';
import 'package:mq_sports_erp/models/activity_log_model.dart';

LogFieldChange _find(List<LogFieldChange> changes, String field) =>
    changes.firstWhere((LogFieldChange c) => c.field == field);

void main() {
  group('diffMaps', () {
    test('reports changed top-level fields with old and new value', () {
      final List<LogFieldChange> changes = diffMaps(
        <String, dynamic>{'name': 'Bat', 'price': 10, 'brand': 'MQ'},
        <String, dynamic>{'name': 'Bat', 'price': 12, 'brand': 'MQ'},
      );
      expect(changes, hasLength(1));
      expect(changes.single.field, 'price');
      expect(changes.single.from, '10');
      expect(changes.single.to, '12');
    });

    test('ignores updatedAt and createdAt and returns nothing when equal', () {
      final List<LogFieldChange> changes = diffMaps(
        <String, dynamic>{'name': 'Bat', 'updatedAt': '1', 'createdAt': '1'},
        <String, dynamic>{'name': 'Bat', 'updatedAt': '2', 'createdAt': '2'},
      );
      expect(changes, isEmpty);
    });

    test('compares lists of records element by element, named by sku', () {
      final List<LogFieldChange> changes = diffMaps(
        <String, dynamic>{
          'variants': <Map<String, dynamic>>[
            <String, dynamic>{'id': 'a', 'sku': 'BAT-1', 'costPrice': 100.0},
            <String, dynamic>{'id': 'b', 'sku': 'BAT-2', 'costPrice': 50.0},
          ],
        },
        <String, dynamic>{
          'variants': <Map<String, dynamic>>[
            <String, dynamic>{'id': 'a', 'sku': 'BAT-1', 'costPrice': 90.0},
            <String, dynamic>{'id': 'b', 'sku': 'BAT-2', 'costPrice': 50.0},
          ],
        },
      );
      expect(changes, hasLength(1));
      final LogFieldChange change = _find(changes, 'variants[BAT-1].costPrice');
      expect(change.from, '100.0');
      expect(change.to, '90.0');
    });

    test('shows an added and a removed list element', () {
      final List<LogFieldChange> changes = diffMaps(
        <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{'id': '1', 'name': 'Old', 'qty': 1},
          ],
        },
        <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{'id': '2', 'name': 'New', 'qty': 2},
          ],
        },
      );
      expect(_find(changes, 'items[Old].qty').to, isNull);
      expect(_find(changes, 'items[New].qty').from, isNull);
    });

    test('a field that appears or disappears has a null side', () {
      final List<LogFieldChange> changes = diffMaps(
        <String, dynamic>{'a': 1},
        <String, dynamic>{'b': 2},
      );
      expect(_find(changes, 'a').to, isNull);
      expect(_find(changes, 'b').from, isNull);
    });

    test('long values are shortened and the number of changes is capped', () {
      final List<LogFieldChange> longValue = diffMaps(
        <String, dynamic>{'note': ''},
        <String, dynamic>{'note': 'x' * 500},
      );
      expect(longValue.single.to!.length, lessThan(200));

      final List<LogFieldChange> many = diffMaps(
        <String, dynamic>{for (int i = 0; i < 100; i++) 'f$i': 0},
        <String, dynamic>{for (int i = 0; i < 100; i++) 'f$i': 1},
        maxChanges: 10,
      );
      expect(many, hasLength(10));
    });
  });

  group('ActivityLogModel', () {
    test('round-trips through toMap and fromMap', () {
      final ActivityLogModel log = ActivityLogModel(
        level: LogLevel.warning,
        kind: LogKind.record,
        action: 'update',
        module: 'products',
        entityId: 'p1',
        entityLabel: 'Bat',
        summary: 'Edited Product "Bat"',
        changes: const <LogFieldChange>[
          LogFieldChange(field: 'price', from: '1', to: '2'),
        ],
        groupId: 'g',
        userId: 'u',
        userName: 'Sara',
        userRole: 'manager',
      );
      final ActivityLogModel copy = ActivityLogModel.fromMap(log.toMap());
      expect(copy.id, log.id);
      expect(copy.level, LogLevel.warning);
      expect(copy.kind, LogKind.record);
      expect(copy.changes.single.to, '2');
      expect(copy.userName, 'Sara');
      expect(copy.createdAt.difference(log.createdAt).inMilliseconds.abs(), lessThan(2));
    });

    test('unknown level and kind fall back safely', () {
      expect(LogLevel.fromName('bogus'), LogLevel.info);
      expect(LogKind.fromName('bogus'), LogKind.action);
    });
  });
}
