import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/pending_change.dart';

/// Persistent list of local changes that were not uploaded yet.
class PendingChangeStore {
  static const String _boxName = 'pending_changes';

  Box<String>? _box;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Fires after every change to the list.
  Stream<void> get changes => _changes.stream;

  Future<Box<String>> _open() async {
    final Box<String>? existing = _box;
    if (existing != null && existing.isOpen) {
      return existing;
    }
    final Box<String> opened = await Hive.openBox<String>(_boxName);
    _box = opened;
    return opened;
  }

  PendingChange _decode(String raw) {
    final Object? decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return PendingChange.fromMap(decoded);
    }
    throw const FormatException('Stored change is not a JSON object.');
  }

  Future<List<PendingChange>> getAll() async {
    try {
      final Box<String> box = await _open();
      final List<PendingChange> all = box.values.map(_decode).toList()
        ..sort((PendingChange a, PendingChange b) =>
            b.changedAt.compareTo(a.changedAt));
      return all;
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to read pending changes: ${e.message}');
    } on FormatException catch (e) {
      throw LocalStorageException('Corrupted pending change: ${e.message}');
    }
  }

  Future<List<PendingChange>> getForCollection(String collection) async {
    final List<PendingChange> all = await getAll();
    return all
        .where((PendingChange c) => c.collection == collection)
        .toList()
        .reversed
        .toList();
  }

  /// Records that a record was created or edited locally. A record that was
  /// created locally and not uploaded yet stays a "create".
  Future<void> recordSave({
    required String collection,
    required String entityLabel,
    required String entityId,
    required String itemLabel,
    required bool isNew,
    String groupId = '',
  }) async {
    try {
      final Box<String> box = await _open();
      final String key = '$collection:$entityId';
      final String? raw = box.get(key);
      final PendingChange? existing = raw == null ? null : _decode(raw);
      final PendingChangeType type =
          existing?.type == PendingChangeType.create || isNew
              ? PendingChangeType.create
              : PendingChangeType.update;
      final PendingChange change = PendingChange(
        collection: collection,
        entityId: entityId,
        entityLabel: entityLabel,
        itemLabel: itemLabel,
        type: type,
        changedAt: DateTime.now(),
        groupId: groupId.isNotEmpty ? groupId : (existing?.groupId ?? ''),
      );
      await box.put(key, jsonEncode(change.toMap()));
      _changes.add(null);
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to save pending change: ${e.message}');
    } on FormatException catch (e) {
      throw LocalStorageException('Corrupted pending change: ${e.message}');
    }
  }

  /// Records a local delete. Deleting a record that was never uploaded just
  /// removes its pending "create".
  Future<void> recordDelete({
    required String collection,
    required String entityLabel,
    required String entityId,
    required String itemLabel,
  }) async {
    try {
      final Box<String> box = await _open();
      final String key = '$collection:$entityId';
      final String? raw = box.get(key);
      final PendingChange? existing = raw == null ? null : _decode(raw);
      if (existing?.type == PendingChangeType.create) {
        await box.delete(key);
      } else {
        final PendingChange change = PendingChange(
          collection: collection,
          entityId: entityId,
          entityLabel: entityLabel,
          itemLabel: itemLabel,
          type: PendingChangeType.delete,
          changedAt: DateTime.now(),
        );
        await box.put(key, jsonEncode(change.toMap()));
      }
      _changes.add(null);
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to save pending change: ${e.message}');
    } on FormatException catch (e) {
      throw LocalStorageException('Corrupted pending change: ${e.message}');
    }
  }

  Future<void> removeAll(Iterable<String> keys) async {
    final List<String> list = keys.toList();
    if (list.isEmpty) {
      return;
    }
    try {
      final Box<String> box = await _open();
      await box.deleteAll(list);
      _changes.add(null);
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to clear pending changes: ${e.message}');
    }
  }

  Future<void> dispose() async {
    await _changes.close();
  }
}
