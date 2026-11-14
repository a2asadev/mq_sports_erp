import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/providers/auth_controller.dart';
import 'package:mq_sports_erp/providers/data_mode.dart';
import 'package:mq_sports_erp/providers/sync_coordinator.dart';

/// App bar action that signs the user out after a confirmation dialog.
class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  Future<void> _onPressed(BuildContext context, WidgetRef ref) async {
    final int pendingCount = ref.read(dataModeProvider).isOnline
        ? 0
        : ref.read(syncCoordinatorProvider).pending.length;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: Text(pendingCount > 0
              ? 'You have $pendingCount change(s) that were not uploaded. '
                  'They stay on this device until you sync. Sign out anyway?'
              : 'Do you want to sign out of MQ Sports ERP?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sign out'),
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
          error is AppException ? error.message : 'Sign out failed.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoading = ref.watch(authControllerProvider).isLoading;
    return IconButton(
      tooltip: 'Sign out',
      icon: const Icon(Icons.logout),
      onPressed: isLoading ? null : () => _onPressed(context, ref),
    );
  }
}
