import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';

enum SyncStatus { idle, syncing, offline, error }

/// Watches network connectivity and, whenever a connection is available,
/// pulls every registered collection from Cloud Firestore into Hive.
class SyncService {
  SyncService({
    required Connectivity connectivity,
    required List<SyncableRepository> repositories,
    required void Function(SyncStatus status) onStatusChanged,
    required void Function() onSyncCompleted,
  })  : _connectivity = connectivity,
        _repositories = repositories,
        _onStatusChanged = onStatusChanged,
        _onSyncCompleted = onSyncCompleted;

  final Connectivity _connectivity;
  final List<SyncableRepository> _repositories;
  final void Function(SyncStatus status) _onStatusChanged;
  final void Function() _onSyncCompleted;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isSyncing = false;
  bool _isDisposed = false;

  void start() {
    _subscription = _connectivity.onConnectivityChanged.listen(_handle);
    unawaited(_checkInitialConnectivity());
  }

  Future<void> _checkInitialConnectivity() async {
    final List<ConnectivityResult> results =
        await _connectivity.checkConnectivity();
    _handle(results);
  }

  void _handle(List<ConnectivityResult> results) {
    if (_isDisposed) {
      return;
    }
    final bool isOnline = results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.ethernet);
    if (!isOnline) {
      _onStatusChanged(SyncStatus.offline);
      return;
    }
    unawaited(syncAll());
  }

  /// Syncs every registered repository. A failure in one collection never
  /// prevents the others from syncing.
  Future<void> syncAll() async {
    if (_isSyncing || _isDisposed) {
      return;
    }
    _isSyncing = true;
    _onStatusChanged(SyncStatus.syncing);
    bool hadFailure = false;
    try {
      for (final SyncableRepository repository in _repositories) {
        try {
          await repository.syncFromCloud();
        } on AppException {
          hadFailure = true;
        }
      }
    } finally {
      _isSyncing = false;
    }
    if (_isDisposed) {
      return;
    }
    _onSyncCompleted();
    _onStatusChanged(hadFailure ? SyncStatus.error : SyncStatus.idle);
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await _subscription?.cancel();
    _subscription = null;
  }
}
