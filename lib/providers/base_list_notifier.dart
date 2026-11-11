import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/activity_log_model.dart';
import 'package:mq_sports_erp/models/syncable_model.dart';
import 'package:mq_sports_erp/providers/activity_log_providers.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';

/// Base `AsyncNotifier` for every entity list.
///
/// - Reads only from Hive (never from Firestore).
/// - Reloads from Hive after downloaded data was merged in.
/// - Mutations are optimistic and roll back to the previous snapshot if the
///   local write fails, exposing the error through `AsyncValue.error`.
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
    return repository.getLocal();
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
    logFailure(error);
    final List<T> previous = state.valueOrNull ?? <T>[];
    state = AsyncValue<List<T>>.error(error, StackTrace.current)
        .copyWithPrevious(AsyncData<List<T>>(previous));
    return false;
  }

  /// Writes a rejected or failed action to the activity log. A refused action
  /// (validation, permission) is a warning; anything else is an error.
  void logFailure(AppException error) {
    final bool refused =
        error is ValidationException || error is PermissionDeniedException;
    unawaited(ref.read(activityLoggerProvider).record(
          kind: LogKind.failure,
          action: refused ? 'refused' : 'failed',
          level: refused ? LogLevel.warning : LogLevel.error,
          module: repository.collectionName,
          summary: error.message,
        ));
  }

  void _rollback(List<T> previous, AppException error, StackTrace stackTrace) {
    logFailure(error);
    if (_isDisposed) {
      return;
    }
    state = AsyncValue<List<T>>.error(error, stackTrace)
        .copyWithPrevious(AsyncData<List<T>>(previous));
  }
}
