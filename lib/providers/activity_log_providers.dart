import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/activity_log_model.dart';
import 'package:a2_stocks/online/api_client.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/remote_store.dart';
import 'package:a2_stocks/services/activity_logger.dart';

/// How many logs "Refresh" fetches.
const int cloudLogLimit = 500;

/// The server writes the activity log (see [ActivityLogger]).
final Provider<ActivityLogger> activityLoggerProvider =
    Provider<ActivityLogger>((Ref ref) => const ActivityLogger());

/// What the logs screen shows: the latest logs of everyone, newest first.
class ActivityLogsState {
  const ActivityLogsState({
    this.logs = const <ActivityLogModel>[],
    this.pendingCount = 0,
    this.cloudLoaded = false,
    this.isLoadingCloud = false,
    this.message,
  });

  final List<ActivityLogModel> logs;

  /// Not used any more (the server keeps the logs); kept for the screen.
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

/// The logs are read from the server (admins only); they need a connection.
class ActivityLogsNotifier extends AutoDisposeAsyncNotifier<ActivityLogsState> {
  @override
  Future<ActivityLogsState> build() => _load(200);

  Future<ActivityLogsState> _load(int limit) async {
    final ApiResponse response = await ref.read(apiClientProvider).get(
      '/v1/logs',
      query: <String, String>{'limit': '$limit'},
    );
    final List<ActivityLogModel> logs = response.asList
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> map) =>
            ActivityLogModel.fromMap(normalizeDates(map)))
        .toList();
    return ActivityLogsState(logs: logs, cloudLoaded: true);
  }

  Future<void> reload() async {
    try {
      state = AsyncData<ActivityLogsState>(await _load(200));
    } on AppException catch (e, st) {
      state = AsyncError<ActivityLogsState>(e, st);
    }
  }

  /// Fetches the latest [cloudLogLimit] logs.
  Future<void> loadFromCloud() async {
    final ActivityLogsState? current = state.valueOrNull;
    if (current == null || current.isLoadingCloud) {
      return;
    }
    state = AsyncData<ActivityLogsState>(
        current.copyWith(isLoadingCloud: true, clearMessage: true));
    try {
      final ActivityLogsState fresh = await _load(cloudLogLimit);
      state = AsyncData<ActivityLogsState>(
          fresh.copyWith(message: L10n.current.activityLogLoadedLogS(fresh.logs.length)));
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
