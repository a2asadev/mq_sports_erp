import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/pending_change.dart';
import 'package:mq_sports_erp/models/syncable_model.dart';
import 'package:mq_sports_erp/services/firestore_service.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';
import 'package:mq_sports_erp/services/pending_change_store.dart';

/// Result of downloading a collection. [isFullSnapshot] is false when only
/// part of the collection was downloaded (so nothing may be pruned).
class RemotePull {
  const RemotePull(this.maps, {required this.isFullSnapshot});

  final List<Map<String, dynamic>> maps;
  final bool isFullSnapshot;
}

/// What the sync coordinator needs from every repository.
abstract class SyncableRepository {
  String get collectionName;

  /// Singular display name, for example "Product".
  String get entityLabel;

  Future<RemotePull> pullFromCloud(FirestoreService remote);

  /// Merges downloaded records into Hive and returns how many local pending
  /// changes were dropped because the cloud version was newer.
  Future<int> applyRemote(RemotePull pull);

  /// Local record as a map, ready to upload; null if it no longer exists.
  Future<Map<String, dynamic>?> localMap(String id);

  /// Why deleting [id] is no longer safe given the data now on this device
  /// (for example "it has subcategories"), or null if the delete is fine.
  Future<String?> deleteBlockReason(String id);

  /// Downloads one record again and stores it locally. Used to cancel a
  /// pending delete that turned out to be unsafe.
  Future<void> restoreFromCloud(FirestoreService remote, String id);
}

/// Local-first repository. Reads and writes only touch Hive; every write is
/// also logged as a pending change. Nothing talks to Firestore here except
/// when the sync coordinator calls [pullFromCloud].
class BaseRepository<T extends SyncableModel> implements SyncableRepository {
  BaseRepository({
    required this.collectionName,
    required this.entityLabel,
    required HiveLocalRepository<T> local,
    required PendingChangeStore pendingStore,
    required T Function(Map<String, dynamic> map) fromMap,
    required String Function(T item) labelOf,
    Future<String?> Function(String id)? deleteGuard,
  })  : _local = local,
        _pending = pendingStore,
        _fromMap = fromMap,
        _labelOf = labelOf,
        _deleteGuard = deleteGuard;

  @override
  final String collectionName;

  @override
  final String entityLabel;

  final HiveLocalRepository<T> _local;
  final PendingChangeStore _pending;
  final T Function(Map<String, dynamic> map) _fromMap;
  final String Function(T item) _labelOf;
  final Future<String?> Function(String id)? _deleteGuard;

  Future<List<T>> getLocal() => _local.getAll();

  Future<T?> getLocalById(String id) => _local.getById(id);

  /// Saves to Hive and logs the pending change. If logging fails, the Hive
  /// write is undone.
  Future<void> save(T item) async {
    final T? previous = await _local.getById(item.id);
    await _local.put(item);
    try {
      await _pending.recordSave(
        collection: collectionName,
        entityLabel: entityLabel,
        entityId: item.id,
        itemLabel: _labelOf(item),
        isNew: previous == null,
      );
    } on AppException {
      if (previous == null) {
        await _local.delete(item.id);
      } else {
        await _local.put(previous);
      }
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    final T? previous = await _local.getById(id);
    await _local.delete(id);
    try {
      await _pending.recordDelete(
        collection: collectionName,
        entityLabel: entityLabel,
        entityId: id,
        itemLabel: previous == null ? id : _labelOf(previous),
      );
    } on AppException {
      if (previous != null) {
        await _local.put(previous);
      }
      rethrow;
    }
  }

  @override
  Future<RemotePull> pullFromCloud(FirestoreService remote) async {
    final List<Map<String, dynamic>> maps = await remote.fetchAll(collectionName);
    return RemotePull(maps, isFullSnapshot: true);
  }

  /// Conflict policy: the newer `updatedAt` wins. A local change that is
  /// newer than the cloud copy stays pending; a cloud copy that is newer
  /// replaces it and the pending change is dropped. A pending delete wins
  /// until it is uploaded.
  @override
  Future<int> applyRemote(RemotePull pull) async {
    final List<T> remoteItems = pull.maps.map(_fromMap).toList();
    final List<T> localItems = await _local.getAll();
    final Map<String, T> localById = <String, T>{
      for (final T item in localItems) item.id: item,
    };
    final Map<String, PendingChange> pendingById = <String, PendingChange>{
      for (final PendingChange change
          in await _pending.getForCollection(collectionName))
        change.entityId: change,
    };
    final Set<String> remoteIds = <String>{
      for (final T item in remoteItems) item.id,
    };
    final List<T> toStore = <T>[];
    final List<String> pendingToDrop = <String>[];
    int discarded = 0;

    for (final T remoteItem in remoteItems) {
      final T? localItem = localById[remoteItem.id];
      final PendingChange? change = pendingById[remoteItem.id];
      if (change != null) {
        if (change.type == PendingChangeType.delete) {
          continue;
        }
        if (localItem != null && !remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
          continue;
        }
        toStore.add(remoteItem);
        pendingToDrop.add(change.key);
        discarded++;
        continue;
      }
      if (localItem == null || remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
        toStore.add(remoteItem);
      }
    }
    await _local.putAll(toStore);

    if (pull.isFullSnapshot) {
      for (final T localItem in localItems) {
        if (remoteIds.contains(localItem.id)) {
          continue;
        }
        final PendingChange? change = pendingById[localItem.id];
        if (change != null && change.type == PendingChangeType.create) {
          continue;
        }
        await _local.delete(localItem.id);
        if (change != null) {
          pendingToDrop.add(change.key);
          discarded++;
        }
      }
    }
    await _pending.removeAll(pendingToDrop);
    return discarded;
  }

  @override
  Future<String?> deleteBlockReason(String id) async {
    final Future<String?> Function(String id)? guard = _deleteGuard;
    return guard == null ? null : guard(id);
  }

  @override
  Future<void> restoreFromCloud(FirestoreService remote, String id) async {
    final Map<String, dynamic>? map = await remote.fetchById(collectionName, id);
    if (map != null) {
      await _local.put(_fromMap(map));
    }
  }

  @override
  Future<Map<String, dynamic>?> localMap(String id) async {
    final T? item = await _local.getById(id);
    return item?.toMap();
  }
}
