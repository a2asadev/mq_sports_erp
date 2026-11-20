import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/data/outbox_entry.dart';
import 'package:a2_stocks/data/sync_engine.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/online/change_feed.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/providers/auth_controller.dart';
import 'package:a2_stocks/providers/core_providers.dart';
import 'package:a2_stocks/providers/local_data_providers.dart';
import 'package:a2_stocks/providers/notification_providers.dart';
import 'package:a2_stocks/providers/users_providers.dart';

/// How often a signed-in device checks with the server on its own.
const Duration autoSyncInterval = Duration(seconds: 60);

/// A short wait after the user queues something, so several quick actions go
/// up together.
const Duration autoSyncDelay = Duration(seconds: 3);

class SyncUiState {
  const SyncUiState({
    this.isSyncing = false,
    this.lastSyncedAt,
    this.message,
    this.messageIsError = false,
    this.offline = false,
  });

  final bool isSyncing;

  /// The last time a sync finished with the server reachable.
  final DateTime? lastSyncedAt;
  final String? message;
  final bool messageIsError;

  /// The last attempt could not reach the server.
  final bool offline;

  SyncUiState copyWith({
    bool? isSyncing,
    DateTime? lastSyncedAt,
    String? message,
    bool? messageIsError,
    bool? offline,
    bool clearMessage = false,
  }) {
    return SyncUiState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      message: clearMessage ? null : (message ?? this.message),
      messageIsError: clearMessage ? false : (messageIsError ?? this.messageIsError),
      offline: offline ?? this.offline,
    );
  }
}

/// Keeps a signed-in device in step with the server (mobile and desktop).
///
/// It syncs by itself: when someone signs in, when the connection comes back,
/// a few seconds after the user queues something, and every minute. The sync
/// screen's button does the same on demand. All of it is safe to repeat.
class SyncController extends Notifier<SyncUiState> {
  Timer? _ticker;
  Timer? _debounce;
  bool _running = false;
  bool _again = false;
  bool _disposed = false;
  int _lastPending = 0;

  @override
  SyncUiState build() {
    _disposed = false;
    // On sign-out this rebuilds before the gate leaves the screen: with nobody
    // signed in there is no database, so stay idle instead of opening one.
    final String? userId =
        ref.watch(authUidProvider.select((AsyncValue<String?> value) => value.valueOrNull));
    if (userId == null) {
      return const SyncUiState();
    }
    final SyncEngine engine = ref.watch(syncEngineProvider);
    ref.onDispose(() {
      _disposed = true;
      _ticker?.cancel();
      _debounce?.cancel();
    });

    // Live updates: when the server says something changed, sync at once instead of
    // waiting for the timer (which stays as the safety net).
    final ChangeFeed feed = ChangeFeed(
      open: ref.read(apiClientProvider).openChangeStream,
      onSignal: syncNow,
      onNotification: () => ref.read(notificationsProvider.notifier).refresh(),
    )..start();
    ref.onDispose(() => unawaited(feed.stop()));

    ref.listen<AsyncValue<bool>>(isOnlineProvider, (AsyncValue<bool>? before, AsyncValue<bool> now) {
      if ((now.valueOrNull ?? false) && !(before?.valueOrNull ?? false)) {
        feed.reconnectNow();
        unawaited(syncNow());
      }
    });
    ref.listen<AsyncValue<List<OutboxEntry>>>(outboxEntriesProvider,
        (AsyncValue<List<OutboxEntry>>? before, AsyncValue<List<OutboxEntry>> now) {
      final int pending = (now.valueOrNull ?? <OutboxEntry>[])
          .where((OutboxEntry e) => e.state == OutboxState.pending)
          .length;
      if (pending > _lastPending) {
        _debounce?.cancel();
        _debounce = Timer(autoSyncDelay, () => unawaited(syncNow()));
      }
      _lastPending = pending;
    });
    _ticker = Timer.periodic(autoSyncInterval, (Timer _) => unawaited(syncNow()));

    scheduleMicrotask(() async {
      final DateTime? last = await engine.lastSyncedAt();
      if (!_disposed && last != null) {
        state = state.copyWith(lastSyncedAt: last);
      }
      // The first sync (a full download on a new device) starts right away.
      unawaited(syncNow());
    });
    return const SyncUiState();
  }

  /// Runs a sync now. A call while one is running makes it run once more
  /// straight after, so nothing queued in the meantime waits for the timer.
  Future<void> syncNow({bool manual = false}) async {
    if (_running) {
      _again = true;
      return;
    }
    _running = true;
    if (!_disposed) {
      state = state.copyWith(isSyncing: true, clearMessage: manual);
    }
    try {
      do {
        _again = false;
        await _syncOnce(manual: manual);
      } while (_again && !_disposed);
    } finally {
      _running = false;
      if (!_disposed) {
        state = state.copyWith(isSyncing: false);
      }
    }
  }

  Future<void> _syncOnce({required bool manual}) async {
    final SyncEngine engine = ref.read(syncEngineProvider);
    final SyncOutcome outcome;
    try {
      outcome = await engine.sync();
    } on Object catch (e) {
      if (!_disposed) {
        state = state.copyWith(message: L10n.current.syncControllerSyncFailed(e), messageIsError: true);
      }
      return;
    }
    if (_disposed) {
      return;
    }
    if (outcome.uploaded > 0 || outcome.downloaded || outcome.refused > 0) {
      // Open lists reload from the database.
      ref.read(syncTickProvider.notifier).increment();
    }
    if (outcome.error != null) {
      state = state.copyWith(message: outcome.error, messageIsError: true);
      return;
    }
    if (outcome.offline) {
      state = state.copyWith(
        offline: true,
        message: manual ? L10n.current.syncControllerTheServerCannotBe : null,
        messageIsError: manual,
      );
      return;
    }
    final DateTime? last = await engine.lastSyncedAt();
    state = state.copyWith(
      offline: false,
      lastSyncedAt: last,
      message: manual
          ? outcome.refused > 0
              ? L10n.current.syncControllerChangeSWereRefused(outcome.refused)
              : L10n.current.syncControllerEverythingIsInStep
          : null,
      messageIsError: outcome.refused > 0,
    );
    await _checkOwnAccount();
  }

  /// The server may have switched this account off, or changed its role.
  Future<void> _checkOwnAccount() async {
    final String? me = ref.read(apiClientProvider).currentUser?.id;
    if (me == null) {
      return;
    }
    final UserModel? record = await ref.read(localCollectionsProvider).users.byId(me);
    if (record == null) {
      return;
    }
    if (!record.isActive) {
      await ref.read(authControllerProvider.notifier).signOut();
      return;
    }
    final UserModel? current = ref.read(currentUserProvider).valueOrNull;
    if (current != null && (current.role != record.role || current.isActive != record.isActive)) {
      ref.invalidate(currentUserProvider);
    }
  }

  /// Puts a refused action back in the queue.
  Future<void> retry(String opId) async {
    await ref.read(outboxStoreProvider).markPending(opId);
    unawaited(syncNow(manual: true));
  }

  /// Gives up on a refused action: it is forgotten and never uploaded.
  Future<void> discard(String opId) async {
    await ref.read(outboxStoreProvider).remove(<String>[opId]);
    ref.read(syncTickProvider.notifier).increment();
  }

  /// Throws away the downloaded copy and downloads everything again. Work that
  /// is still waiting to be uploaded is kept.
  Future<void> downloadEverythingAgain() async {
    await ref.read(syncEngineProvider).resetDownloadedData();
    ref.read(syncTickProvider.notifier).increment();
    await syncNow(manual: true);
  }
}

final NotifierProvider<SyncController, SyncUiState> syncControllerProvider =
    NotifierProvider<SyncController, SyncUiState>(SyncController.new);

/// The one-word state shown in the app bar.
enum SyncStatus { syncing, needsAttention, offline, pending, upToDate }

class SyncSummary {
  const SyncSummary({
    required this.status,
    required this.waiting,
    required this.failed,
    this.lastSyncedAt,
  });

  final SyncStatus status;

  /// Actions the server has not taken over yet (waiting or accepted but not downloaded).
  final int waiting;

  /// Actions the server refused.
  final int failed;
  final DateTime? lastSyncedAt;
}

final Provider<SyncSummary> syncSummaryProvider = Provider<SyncSummary>((Ref ref) {
  final List<OutboxEntry> entries = ref.watch(outboxEntriesProvider).valueOrNull ?? <OutboxEntry>[];
  final SyncUiState sync = ref.watch(syncControllerProvider);
  final bool online = ref.watch(isOnlineProvider).valueOrNull ?? true;
  final int failed = entries.where((OutboxEntry e) => e.state == OutboxState.failed).length;
  final int waiting = entries.where((OutboxEntry e) => e.state == OutboxState.pending).length;

  final SyncStatus status;
  if (sync.isSyncing) {
    status = SyncStatus.syncing;
  } else if (failed > 0) {
    status = SyncStatus.needsAttention;
  } else if (!online || sync.offline) {
    status = SyncStatus.offline;
  } else if (waiting > 0) {
    status = SyncStatus.pending;
  } else {
    status = SyncStatus.upToDate;
  }
  return SyncSummary(status: status, waiting: waiting, failed: failed, lastSyncedAt: sync.lastSyncedAt);
});
