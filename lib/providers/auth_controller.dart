import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/activity_log_model.dart';
import 'package:mq_sports_erp/providers/activity_log_providers.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/providers/data_mode.dart';
import 'package:mq_sports_erp/providers/sync_coordinator.dart';

/// Drives the login and logout actions. Its `AsyncValue` reflects the latest
/// action: loading while running, error with a clean message on failure.
/// The signed-in/out state itself comes from `authUidProvider`.
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading<void>();
    try {
      await ref
          .read(authServiceProvider)
          .signIn(email: email, password: password);
      state = const AsyncData<void>(null);
      await ref.read(activityLoggerProvider).record(
            kind: LogKind.session,
            action: 'login',
            module: 'session',
            summary: 'Signed in',
          );
      // Login is the one moment the whole data set is downloaded (local-first
      // mode). Online, the data loads when the first screen asks for it.
      if (!ref.read(dataModeProvider).isOnline) {
        unawaited(ref.read(syncCoordinatorProvider.notifier).syncOnLogin());
      }
    } on AppException catch (e, st) {
      state = AsyncError<void>(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading<void>();
    try {
      // Logged first: after signing out there is no user to attribute it to.
      await ref.read(activityLoggerProvider).record(
            kind: LogKind.session,
            action: 'logout',
            module: 'session',
            summary: 'Signed out',
          );
      await ref.read(authServiceProvider).signOut();
      state = const AsyncData<void>(null);
    } on AppException catch (e, st) {
      state = AsyncError<void>(e, st);
    }
  }
}

final AsyncNotifierProvider<AuthController, void> authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
