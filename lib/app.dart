import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/providers/core_providers.dart';
import 'package:a2_stocks/providers/data_mode.dart';
import 'package:a2_stocks/providers/sync_controller.dart';
import 'package:a2_stocks/providers/users_providers.dart';
import 'package:a2_stocks/screens/access_denied_screen.dart';
import 'package:a2_stocks/screens/home_screen.dart';
import 'package:a2_stocks/screens/login_screen.dart';

class MqSportsApp extends ConsumerWidget {
  const MqSportsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Amounts are written with the business's currency in many places that do
    // not watch anything, so a change of currency starts the screens afresh.
    // The same goes for the accent colour. (Watching the provider also sets
    // MoneyFormat and AppColors, which the theme below reads.)
    final String currency = ref.watch(businessProvider.select((BusinessInfo b) => b.currency));
    final String brand = ref.watch(businessProvider.select((BusinessInfo b) => b.brandColor));
    return MaterialApp(
      title: 'A2 Stocks',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: KeyedSubtree(key: ValueKey<String>('$currency|$brand'), child: const _AuthGate()),
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
            message: 'Your account is not registered in A2 Stocks. '
                'Contact your administrator.',
          );
        }
        if (!user.isActive) {
          return const AccessDeniedScreen(
            message: 'Your account is inactive. Contact your administrator.',
          );
        }
        // Keeps this device in step with the server while someone is signed in
        // (mobile and desktop; the web app has nothing to sync).
        if (!ref.watch(dataModeProvider).isOnline) {
          ref.watch(syncControllerProvider);
        }
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
