import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/activity_log_model.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/services/activity_log_store.dart';
import 'package:mq_sports_erp/services/activity_logger.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';

/// How many logs "Load from cloud" fetches.
const int cloudLogLimit = 500;

final Provider<ActivityLogStore> activityLogStoreProvider =
    Provider<ActivityLogStore>((Ref ref) {
  final ActivityLogStore store = ActivityLogStore();
  ref.onDispose(store.dispose);
  return store;
});

/// Name and role of whoever is signed in, from the signed-in login and the
/// local `users` box (so it works offline and needs no user providers).
Future<LogActor> _resolveActor() async {
  final User? login = FirebaseAuth.instance.currentUser;
  if (login == null) {
    return const LogActor();
  }
  String name = login.displayName ?? login.email ?? '';
  String role = '';
  try {
    final UserModel? record = await HiveLocalRepository<UserModel>(
      boxName: StorageKeys.users,
      fromMap: UserModel.fromMap,
    ).getById(login.uid);
    if (record != null) {
      name = record.displayName.trim().isNotEmpty ? record.displayName : record.email;
      role = record.role.name;
    }
  } on AppException {
    // Falls back to the login's own name.
  }
  return LogActor(id: login.uid, name: name, role: role);
}

final Provider<ActivityLogger> activityLoggerProvider =
    Provider<ActivityLogger>((Ref ref) {
  return ActivityLogger(
    store: ref.watch(activityLogStoreProvider),
    resolveActor: _resolveActor,
  );
});

/// What the logs screen shows: this device's logs, plus whatever was loaded
/// from the cloud (merged by id, newest first).
class ActivityLogsState {
  const ActivityLogsState({
    this.logs = const <ActivityLogModel>[],
    this.pendingCount = 0,
    this.cloudLoaded = false,
    this.isLoadingCloud = false,
    this.message,
  });

  final List<ActivityLogModel> logs;

  /// Logs on this device that are not uploaded yet.
  final int pendingCount;
  final bool cloudLoaded;
  final bool isLoadingCloud;
  final String? message;

  ActivityLogsState copyWith({
    List<ActivityLogModel>? logs,
    int? pendingCount,
    bool? cloudLoaded,
    bool? isLoadingCloud,
    String? message,
    bool clearMessage = false,
  }) {
    return ActivityLogsState(
      logs: logs ?? this.logs,
      pendingCount: pendingCount ?? this.pendingCount,
      cloudLoaded: cloudLoaded ?? this.cloudLoaded,
      isLoadingCloud: isLoadingCloud ?? this.isLoadingCloud,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

class ActivityLogsNotifier extends AutoDisposeAsyncNotifier<ActivityLogsState> {
  List<ActivityLogModel> _cloud = <ActivityLogModel>[];
  bool _cloudLoaded = false;

  @override
  Future<ActivityLogsState> build() async {
    final ActivityLogStore store = ref.watch(activityLogStoreProvider);
    final StreamSubscription<void> sub = store.changes.listen((void _) {
      unawaited(reload());
    });
    ref.onDispose(sub.cancel);
    return _load(store);
  }

  Future<ActivityLogsState> _load(ActivityLogStore store) async {
    final List<ActivityLogModel> local = await store.getAll();
    final int pending = await store.pendingCount();
    final Map<String, ActivityLogModel> byId = <String, ActivityLogModel>{
      for (final ActivityLogModel log in _cloud) log.id: log,
      for (final ActivityLogModel log in local) log.id: log,
    };
    final List<ActivityLogModel> merged = byId.values.toList()
      ..sort((ActivityLogModel a, ActivityLogModel b) =>
          b.createdAt.compareTo(a.createdAt));
    return ActivityLogsState(
      logs: merged,
      pendingCount: pending,
      cloudLoaded: _cloudLoaded,
    );
  }

  Future<void> reload() async {
    final ActivityLogsState? current = state.valueOrNull;
    try {
      final ActivityLogsState fresh = await _load(ref.read(activityLogStoreProvider));
      state = AsyncData<ActivityLogsState>(fresh.copyWith(
        isLoadingCloud: current?.isLoadingCloud ?? false,
        message: current?.message,
      ));
    } on AppException catch (e, st) {
      state = AsyncError<ActivityLogsState>(e, st);
    }
  }

  /// Fetches the latest [cloudLogLimit] logs of all devices (one read per
  /// log) and merges them into the list.
  Future<void> loadFromCloud() async {
    final ActivityLogsState? current = state.valueOrNull;
    if (current == null || current.isLoadingCloud) {
      return;
    }
    state = AsyncData<ActivityLogsState>(
        current.copyWith(isLoadingCloud: true, clearMessage: true));
    try {
      final List<Map<String, dynamic>> maps =
          await ref.read(firestoreServiceProvider).fetchRecentLogs(cloudLogLimit);
      _cloud = maps.map(ActivityLogModel.fromMap).toList();
      _cloudLoaded = true;
      final ActivityLogsState fresh = await _load(ref.read(activityLogStoreProvider));
      state = AsyncData<ActivityLogsState>(fresh.copyWith(
        message: 'Loaded ${_cloud.length} log(s) from the cloud.',
      ));
    } on AppException catch (e) {
      state = AsyncData<ActivityLogsState>(
          current.copyWith(isLoadingCloud: false, message: e.message));
    }
  }
}

final AutoDisposeAsyncNotifierProvider<ActivityLogsNotifier, ActivityLogsState>
    activityLogsProvider =
    AsyncNotifierProvider.autoDispose<ActivityLogsNotifier, ActivityLogsState>(
  ActivityLogsNotifier.new,
);
