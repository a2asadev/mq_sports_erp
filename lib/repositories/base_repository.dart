import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/syncable_model.dart';
import 'package:mq_sports_erp/services/firestore_service.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';

/// Implemented by every repository so `SyncService` can sync it in bulk.
abstract class SyncableRepository {
  String get collectionName;

  Future<void> syncFromCloud();
}

/// Offline-first coordinator between Hive (instant) and Firestore (cloud).
///
/// Reads always come from Hive. Writes hit Hive first and are then pushed to
/// Firestore; if the push fails the local change is reverted and the
/// exception is rethrown so the provider can roll back its state too.
class BaseRepository<T extends SyncableModel> implements SyncableRepository {
  BaseRepository({
    required this.collectionName,
    required HiveLocalRepository<T> local,
    required FirestoreService remote,
    required T Function(Map<String, dynamic> map) fromMap,
  })  : _local = local,
        _remote = remote,
        _fromMap = fromMap;

  @override
  final String collectionName;

  final HiveLocalRepository<T> _local;
  final FirestoreService _remote;
  final T Function(Map<String, dynamic> map) _fromMap;

  Future<List<T>> getLocal() => _local.getAll();

  Future<T?> getLocalById(String id) => _local.getById(id);

  /// Pulls the collection from Firestore. A cloud record replaces the local
  /// one only when it is new to this device or has a newer `updatedAt`.
  @override
  Future<void> syncFromCloud() async {
    final List<Map<String, dynamic>> remoteMaps =
        await _remote.fetchAll(collectionName);
    final Map<String, T> localById = <String, T>{
      for (final T item in await _local.getAll()) item.id: item,
    };
    final List<T> toStore = <T>[];
    for (final Map<String, dynamic> map in remoteMaps) {
      final T remoteItem = _fromMap(map);
      final T? localItem = localById[remoteItem.id];
      if (localItem == null || remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
        toStore.add(remoteItem);
      }
    }
    await _local.putAll(toStore);
  }

  Future<void> save(T item) async {
    final T? previous = await _local.getById(item.id);
    await _local.put(item);
    try {
      await _remote.upsert(collectionName, item.id, item.toMap());
    } on RemoteSyncException {
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
      await _remote.delete(collectionName, id);
    } on RemoteSyncException {
      if (previous != null) {
        await _local.put(previous);
      }
      rethrow;
    }
  }
}
