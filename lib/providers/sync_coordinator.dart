import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/pending_change.dart';
import 'package:mq_sports_erp/models/remote_collection_meta.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/providers/sync_registry_provider.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';
import 'package:mq_sports_erp/services/firestore_service.dart';
import 'package:mq_sports_erp/services/pending_change_store.dart';
import 'package:mq_sports_erp/services/sync_state_store.dart';

enum SyncStatus { connecting, upToDate, pending, outOfDate, syncing }

/// Everything the sync UI needs.
class SyncState {
  const SyncState({
    this.collections = const <String>[],
    this.remote = const <String, RemoteCollectionMeta>{},
    this.localVersions = const <String, int>{},
    this.pending = const <PendingChange>[],
    this.metadataLoaded = false,
    this.isWorking = false,
    this.message,
    this.messageIsError = false,
  });

  /// Names of all collections that take part in sync.
  final List<String> collections;

  /// Cloud versions, from the live metadata listener.
  final Map<String, RemoteCollectionMeta> remote;

  /// Cloud version this device last downloaded or uploaded (-1 = never).
  final Map<String, int> localVersions;

  /// Local changes not uploaded yet, newest first.
  final List<PendingChange> pending;
  final bool metadataLoaded;
  final bool isWorking;
  final String? message;
  final bool messageIsError;

  int remoteVersionOf(String collection) =>
      remote[collection]?.version ?? 0;

  int localVersionOf(String collection) => localVersions[collection] ?? -1;

  /// Collections whose cloud version differs from this device's version.
  List<String> get staleCollections {
    if (!metadataLoaded) {
      return const <String>[];
    }
    return collections
        .where((String c) => remoteVersionOf(c) != localVersionOf(c))
        .toList();
  }

  SyncStatus get status {
    if (isWorking) {
      return SyncStatus.syncing;
    }
    if (pending.isNotEmpty) {
      return SyncStatus.pending;
    }
    if (!metadataLoaded) {
      return SyncStatus.connecting;
    }
    if (staleCollections.isNotEmpty) {
      return SyncStatus.outOfDate;
    }
    return SyncStatus.upToDate;
  }

  SyncState copyWith({
    Map<String, RemoteCollectionMeta>? remote,
    Map<String, int>? localVersions,
    List<PendingChange>? pending,
    bool? metadataLoaded,
    bool? isWorking,
    String? message,
    bool? messageIsError,
    bool clearMessage = false,
  }) {
    return SyncState(
      collections: collections,
      remote: remote ?? this.remote,
      localVersions: localVersions ?? this.localVersions,
      pending: pending ?? this.pending,
      metadataLoaded: metadataLoaded ?? this.metadataLoaded,
      isWorking: isWorking ?? this.isWorking,
      message: clearMessage ? null : (message ?? this.message),
      messageIsError: clearMessage ? false : (messageIsError ?? this.messageIsError),
    );
  }
}

class _Deps {
  const _Deps({
    required this.remote,
    required this.pendingStore,
    required this.versionStore,
    required this.tick,
  });

  final FirestoreService remote;
  final PendingChangeStore pendingStore;
  final SyncStateStore versionStore;
  final SyncTickNotifier tick;
}

/// The single place where Firestore and Hive are synchronised.
///
/// - Listens to the `metadata` collection (the only live listener).
/// - Downloads collections only at login or when the user presses sync, and
///   only those whose cloud version differs from the local one.
/// - Uploads only the pending local changes, when the user presses sync.
class SyncCoordinator extends Notifier<SyncState> {
  static const int _chunkSize = 400;
  static const int _maxConflictRetries = 3;

  int _generation = 0;
  StreamSubscription<Map<String, RemoteCollectionMeta>>? _metadataSub;
  StreamSubscription<void>? _pendingSub;
  bool _loginSyncRequested = false;

  @override
  SyncState build() {
    ref.onDispose(() {
      _generation++;
      unawaited(_metadataSub?.cancel());
      unawaited(_pendingSub?.cancel());
      _metadataSub = null;
      _pendingSub = null;
    });
    final String? uid = ref.watch(authUidProvider).valueOrNull;
    final List<SyncableRepository> repos = ref.watch(syncRepositoriesProvider);
    final List<String> collections = <String>[
      for (final SyncableRepository repo in repos) repo.collectionName,
    ];
    if (uid == null) {
      return SyncState(collections: collections);
    }
    final int generation = _generation;
    unawaited(_start(generation));
    return SyncState(collections: collections);
  }

  Future<void> _start(int generation) async {
    final PendingChangeStore pendingStore = ref.read(pendingChangeStoreProvider);
    final SyncStateStore versionStore = ref.read(syncStateStoreProvider);
    final FirestoreService remote = ref.read(firestoreServiceProvider);
    try {
      final List<PendingChange> pending = await pendingStore.getAll();
      final Map<String, int> versions = await versionStore.all();
      if (generation != _generation) {
        return;
      }
      state = state.copyWith(pending: pending, localVersions: versions);
    } on AppException {
      if (generation != _generation) {
        return;
      }
    }
    _pendingSub = pendingStore.changes.listen((void _) {
      unawaited(_reloadPending(generation, pendingStore));
    });
    _metadataSub = remote.watchMetadata().listen(
      (Map<String, RemoteCollectionMeta> meta) =>
          _onMetadata(generation, meta),
      onError: (Object error) {
        if (generation == _generation && !state.metadataLoaded) {
          state = state.copyWith(
            message: 'Cannot reach the cloud right now.',
            messageIsError: true,
          );
        }
      },
    );
  }

  Future<void> _reloadPending(int generation, PendingChangeStore store) async {
    try {
      final List<PendingChange> pending = await store.getAll();
      if (generation == _generation) {
        state = state.copyWith(pending: pending);
      }
    } on AppException {
      return;
    }
  }

  void _onMetadata(int generation, Map<String, RemoteCollectionMeta> meta) {
    if (generation != _generation) {
      return;
    }
    state = state.copyWith(remote: meta, metadataLoaded: true);
    if (_loginSyncRequested) {
      _loginSyncRequested = false;
      unawaited(_runLoginSync(generation));
    }
  }

  /// Called right after a successful sign-in. Downloads every collection
  /// whose cloud version differs from this device's version.
  Future<void> syncOnLogin() async {
    if (state.metadataLoaded && !state.isWorking) {
      await _runLoginSync(_generation);
    } else {
      _loginSyncRequested = true;
    }
  }

  /// The sync button: downloads stale collections, then uploads pending
  /// changes.
  Future<void> syncNow() async {
    if (state.isWorking) {
      return;
    }
    if (!state.metadataLoaded) {
      state = state.copyWith(
        message: 'Cannot reach the cloud right now.',
        messageIsError: true,
      );
      return;
    }
    final int generation = _generation;
    final _Deps deps = _deps();
    final List<SyncableRepository> repos = ref.read(syncRepositoriesProvider);
    state = state.copyWith(isWorking: true, clearMessage: true);
    final bool hasPendingDeletes = state.pending
        .any((PendingChange c) => c.type == PendingChangeType.delete);
    if (hasPendingDeletes && state.staleCollections.isNotEmpty) {
      // Deletions are never uploaded while the cloud has newer data: download
      // first, re-check every pending deletion, then let the user sync again.
      try {
        await _downloadBeforeDeletes(generation, repos, deps);
      } on AppException catch (e) {
        _finish(generation, e.message, isError: true);
      }
      return;
    }
    int uploaded = 0;
    int downloaded = 0;
    int discarded = 0;
    try {
      for (final SyncableRepository repo in repos) {
        if (generation != _generation) {
          return;
        }
        final String name = repo.collectionName;
        if (state.staleCollections.contains(name)) {
          discarded += await _pull(generation, repo, deps, state.remoteVersionOf(name));
          downloaded++;
        }
        uploaded += await _push(generation, repo, deps);
      }
      _finish(generation, _summary(uploaded, downloaded, discarded), isError: false);
    } on AppException catch (e) {
      _finish(generation, e.message, isError: true);
    }
  }

  Future<void> _runLoginSync(int generation) async {
    if (state.isWorking) {
      return;
    }
    final _Deps deps = _deps();
    final List<SyncableRepository> repos = ref.read(syncRepositoriesProvider);
    state = state.copyWith(isWorking: true, clearMessage: true);
    int downloaded = 0;
    int discarded = 0;
    try {
      for (final SyncableRepository repo in repos) {
        if (generation != _generation) {
          return;
        }
        final String name = repo.collectionName;
        if (state.staleCollections.contains(name)) {
          discarded += await _pull(generation, repo, deps, state.remoteVersionOf(name));
          downloaded++;
        }
      }
      _finish(
        generation,
        downloaded == 0 ? null : _summary(0, downloaded, discarded),
        isError: false,
      );
    } on AppException catch (e) {
      _finish(generation, e.message, isError: true);
    }
  }

  _Deps _deps() {
    return _Deps(
      remote: ref.read(firestoreServiceProvider),
      pendingStore: ref.read(pendingChangeStoreProvider),
      versionStore: ref.read(syncStateStoreProvider),
      tick: ref.read(syncTickProvider.notifier),
    );
  }

  /// Downloads one collection, merges it into Hive and records [version] as
  /// the version this device now has. Returns the number of local changes
  /// that were replaced by newer cloud versions.
  Future<int> _pull(
    int generation,
    SyncableRepository repo,
    _Deps deps,
    int version,
  ) async {
    final RemotePull pull = await repo.pullFromCloud(deps.remote);
    final int discarded = await repo.applyRemote(pull);
    await deps.versionStore.setVersion(repo.collectionName, version);
    if (generation == _generation) {
      _setVersions(repo.collectionName, version);
      if (repo.collectionName == StorageKeys.users) {
        ref.invalidate(currentUserProvider);
      }
    }
    deps.tick.increment();
    return discarded;
  }

  /// Uploads the pending changes of one collection, in chunks, each chunk in
  /// one transaction that also raises the metadata version. If another device
  /// uploaded first, downloads its changes and tries again.
  Future<int> _push(int generation, SyncableRepository repo, _Deps deps) async {
    final String name = repo.collectionName;
    int uploaded = 0;
    int conflicts = 0;
    while (true) {
      if (generation != _generation) {
        return uploaded;
      }
      final List<PendingChange> changes =
          await deps.pendingStore.getForCollection(name);
      if (changes.isEmpty) {
        return uploaded;
      }
      final List<PendingChange> chunk = changes.take(_chunkSize).toList();
      final List<MapEntry<String, Map<String, dynamic>>> upserts =
          <MapEntry<String, Map<String, dynamic>>>[];
      final List<String> deletes = <String>[];
      for (final PendingChange change in chunk) {
        if (change.type == PendingChangeType.delete) {
          deletes.add(change.entityId);
          continue;
        }
        final Map<String, dynamic>? map = await repo.localMap(change.entityId);
        if (map != null) {
          upserts.add(MapEntry<String, Map<String, dynamic>>(change.entityId, map));
        }
      }
      if (upserts.isEmpty && deletes.isEmpty) {
        await deps.pendingStore.removeAll(chunk.map((PendingChange c) => c.key));
        continue;
      }
      try {
        final int newVersion = await deps.remote.commitChanges(
          collection: name,
          expectedVersion: state.localVersionOf(name),
          upserts: upserts,
          deletes: deletes,
        );
        await deps.versionStore.setVersion(name, newVersion);
        await deps.pendingStore.removeAll(chunk.map((PendingChange c) => c.key));
        if (generation == _generation) {
          _setVersions(name, newVersion);
        }
        uploaded += upserts.length + deletes.length;
      } on VersionConflictException catch (e) {
        conflicts++;
        if (conflicts > _maxConflictRetries) {
          throw const RemoteSyncException(
              'The cloud data keeps changing. Please try again in a moment.');
        }
        await _pull(generation, repo, deps, e.currentVersion);
        if (deletes.isNotEmpty) {
          // Someone else uploaded while we were uploading deletions: stop,
          // re-check the deletions against the downloaded data, and let the
          // user review before uploading again.
          final List<String> cancelled = await _cancelBlockedDeletes(
              generation, <SyncableRepository>[repo], deps);
          throw RemoteSyncException(
              'The cloud changed while uploading, so the updates were '
              'downloaded. ${cancelled.join(' ')} Press sync again to continue.');
        }
      }
    }
  }

  /// Download step used whenever deletions are pending and the cloud has
  /// newer data. Nothing is uploaded in this round.
  Future<void> _downloadBeforeDeletes(
    int generation,
    List<SyncableRepository> repos,
    _Deps deps,
  ) async {
    int downloaded = 0;
    int discarded = 0;
    for (final SyncableRepository repo in repos) {
      if (generation != _generation) {
        return;
      }
      final String name = repo.collectionName;
      if (state.staleCollections.contains(name)) {
        discarded += await _pull(generation, repo, deps, state.remoteVersionOf(name));
        downloaded++;
      }
    }
    final List<String> cancelled =
        await _cancelBlockedDeletes(generation, repos, deps);
    final List<String> parts = <String>[
      'The cloud had newer data, so $downloaded collection(s) were downloaded first.',
      if (discarded > 0)
        '$discarded of your change(s) were replaced by newer cloud versions.',
      ...cancelled,
      state.pending.isEmpty && cancelled.isEmpty
          ? ''
          : 'Review the list and press sync again to upload.',
    ];
    _finish(
      generation,
      parts.where((String p) => p.isNotEmpty).join(' '),
      isError: cancelled.isNotEmpty,
    );
  }

  /// Re-checks every pending deletion against the data now on the device. A
  /// deletion that is no longer safe is cancelled and the record is restored.
  /// Returns a message for each cancelled deletion.
  Future<List<String>> _cancelBlockedDeletes(
    int generation,
    List<SyncableRepository> repos,
    _Deps deps,
  ) async {
    final List<String> cancelled = <String>[];
    for (final SyncableRepository repo in repos) {
      final List<PendingChange> deletes =
          (await deps.pendingStore.getForCollection(repo.collectionName))
              .where((PendingChange c) => c.type == PendingChangeType.delete)
              .toList();
      for (final PendingChange change in deletes) {
        final String? reason = await repo.deleteBlockReason(change.entityId);
        if (reason == null) {
          continue;
        }
        await repo.restoreFromCloud(deps.remote, change.entityId);
        await deps.pendingStore.removeAll(<String>[change.key]);
        cancelled.add('"${change.itemLabel}" was not deleted because $reason.');
      }
    }
    if (cancelled.isNotEmpty) {
      deps.tick.increment();
    }
    return cancelled;
  }

  void _setVersions(String collection, int version) {
    state = state.copyWith(
      localVersions: <String, int>{...state.localVersions, collection: version},
      remote: <String, RemoteCollectionMeta>{
        ...state.remote,
        collection: RemoteCollectionMeta(
          version: version,
          updatedAt: DateTime.now(),
        ),
      },
    );
  }

  void _finish(int generation, String? message, {required bool isError}) {
    if (generation != _generation) {
      return;
    }
    state = message == null
        ? state.copyWith(isWorking: false, clearMessage: true)
        : state.copyWith(
            isWorking: false,
            message: message,
            messageIsError: isError,
          );
  }

  String _summary(int uploaded, int downloaded, int discarded) {
    final List<String> parts = <String>[];
    if (uploaded > 0) {
      parts.add('Uploaded $uploaded change(s).');
    }
    if (downloaded > 0) {
      parts.add('Downloaded $downloaded collection(s).');
    }
    if (discarded > 0) {
      parts.add('$discarded of your change(s) were replaced by newer cloud versions.');
    }
    return parts.isEmpty ? 'Everything is already up to date.' : parts.join(' ');
  }
}

final NotifierProvider<SyncCoordinator, SyncState> syncCoordinatorProvider =
    NotifierProvider<SyncCoordinator, SyncState>(SyncCoordinator.new);
