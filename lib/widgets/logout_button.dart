import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/providers/auth_controller.dart';
import 'package:a2_stocks/providers/data_mode.dart';
import 'package:a2_stocks/providers/sync_controller.dart';

/// App bar action that signs the user out after a confirmation dialog.
class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  Future<void> _onPressed(BuildContext context, WidgetRef ref) async {
    final int pendingCount = ref.read(dataModeProvider).isOnline
        ? 0
        : ref.read(syncSummaryProvider).waiting + ref.read(syncSummaryProvider).failed;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.commonSignOut),
          content: Text(pendingCount > 0
              ? context.l10n.logoutButtonYouHaveChangeS(pendingCount)
              : context.l10n.logoutButtonDoYouWantTo),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.categoriesCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.l10n.commonSignOut),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(authControllerProvider.notifier).signOut();
    if (!context.mounted) {
      return;
    }
    final Object? error = ref.read(authControllerProvider).error;
    if (error != null) {
      final String message =
          error is AppException ? error.message : context.l10n.logoutButtonSignOutFailed;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoading = ref.watch(authControllerProvider).isLoading;
    return IconButton(
      tooltip: context.l10n.commonSignOut,
      icon: const Icon(Icons.logout),
      onPressed: isLoading ? null : () => _onPressed(context, ref),
    );
  }
}
