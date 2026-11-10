import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/providers/sync_coordinator.dart';
import 'package:mq_sports_erp/providers/user_profile_providers.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';
import 'package:mq_sports_erp/screens/access_denied_screen.dart';
import 'package:mq_sports_erp/screens/home_screen.dart';
import 'package:mq_sports_erp/screens/login_screen.dart';

class MqSportsApp extends ConsumerWidget {
  const MqSportsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the sync coordinator (and its metadata listener) alive.
    ref.listen<SyncState>(syncCoordinatorProvider,
        (SyncState? previous, SyncState next) {});
    return MaterialApp(
      title: 'MQ Sports ERP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const _AuthGate(),
    );
  }
}

/// Signed out -> login. Signed in -> access check.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String?> auth = ref.watch(authUidProvider);
    return auth.when(
      data: (String? uid) =>
          uid == null ? const LoginScreen() : const _AccessGate(),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace stackTrace) => Scaffold(
        body: Center(child: Text('Authentication error: $error')),
      ),
    );
  }
}

/// A login only reaches the app when it has an active user record.
class _AccessGate extends ConsumerWidget {
  const _AccessGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserModel?> current = ref.watch(currentUserProvider);
    return current.when(
      data: (UserModel? user) {
        if (user == null) {
          return const AccessDeniedScreen(
            message: 'Your account is not registered in MQ Sports ERP. '
                'Contact your administrator.',
          );
        }
        if (!user.isActive) {
          return const AccessDeniedScreen(
            message: 'Your account is inactive. Contact your administrator.',
          );
        }
        // Keeps the personal profile (last login, account details) in sync.
        ref.watch(currentUserProfileProvider);
        return const HomeScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace stackTrace) => AccessDeniedScreen(
        message: error is AppException
            ? error.message
            : 'Your account could not be verified.',
        onRetry: () => ref.invalidate(currentUserProvider),
      ),
    );
  }
}
