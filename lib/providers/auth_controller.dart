import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';

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
    } on AppException catch (e, st) {
      state = AsyncError<void>(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading<void>();
    try {
      await ref.read(authServiceProvider).signOut();
      state = const AsyncData<void>(null);
    } on AppException catch (e, st) {
      state = AsyncError<void>(e, st);
    }
  }
}

final AsyncNotifierProvider<AuthController, void> authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
