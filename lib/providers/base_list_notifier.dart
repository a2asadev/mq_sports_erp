import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/syncable_model.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';

/// Base `AsyncNotifier` for every entity list.
///
/// - Reads local Hive data first for instant state.
/// - Syncs with the cloud in the background and refreshes state silently.
/// - Mutations are optimistic and roll back to the previous snapshot on
///   failure, exposing the error through `AsyncValue.error`.
abstract class BaseListNotifier<T extends SyncableModel>
    extends AsyncNotifier<List<T>> {
  BaseRepository<T> get repository;

  bool _isDisposed = false;

  @override
  Future<List<T>> build() async {
    _isDisposed = false;
    ref.onDispose(() => _isDisposed = true);
    ref.listen<int>(syncTickProvider, (int? previous, int next) {
      unawaited(_reloadFromLocal());
    });
    final List<T> local = await repository.getLocal();
    unawaited(_backgroundSync());
    return local;
  }

  Future<void> _reloadFromLocal() async {
    try {
      final List<T> local = await repository.getLocal();
      if (!_isDisposed) {
        state = AsyncData<List<T>>(local);
      }
    } on AppException {
      return;
    }
  }

  /// Sync failures here are intentionally silent: the UI keeps showing local
  /// data and `SyncService` reports connectivity/sync status separately.
  Future<void> _backgroundSync() async {
    try {
      await repository.syncFromCloud();
      await _reloadFromLocal();
    } on AppException {
      return;
    }
  }

  Future<void> add(T item) async {
    final List<T> previous = state.valueOrNull ?? <T>[];
    state = AsyncData<List<T>>(<T>[...previous, item]);
    try {
      await repository.save(item);
    } on AppException catch (e, st) {
      _rollback(previous, e, st);
    }
  }

  Future<void> updateItem(T item) async {
    final List<T> previous = state.valueOrNull ?? <T>[];
    state = AsyncData<List<T>>(<T>[
      for (final T existing in previous) existing.id == item.id ? item : existing,
    ]);
    try {
      await repository.save(item);
    } on AppException catch (e, st) {
      _rollback(previous, e, st);
    }
  }

  Future<void> remove(String id) async {
    final List<T> previous = state.valueOrNull ?? <T>[];
    state = AsyncData<List<T>>(
      previous.where((T existing) => existing.id != id).toList(),
    );
    try {
      await repository.delete(id);
    } on AppException catch (e, st) {
      _rollback(previous, e, st);
    }
  }

  /// Exposes [error] through `AsyncValue.error` while keeping the current
  /// list available. Always returns false so callers can `return` it.
  bool reportFailure(AppException error) {
    final List<T> previous = state.valueOrNull ?? <T>[];
    state = AsyncValue<List<T>>.error(error, StackTrace.current)
        .copyWithPrevious(AsyncData<List<T>>(previous));
    return false;
  }

  void _rollback(List<T> previous, AppException error, StackTrace stackTrace) {
    if (_isDisposed) {
      return;
    }
    state = AsyncValue<List<T>>.error(error, stackTrace)
        .copyWithPrevious(AsyncData<List<T>>(previous));
  }
}
