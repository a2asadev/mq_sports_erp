import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/providers/sync_coordinator.dart';
import 'package:mq_sports_erp/screens/sync_screen.dart';

/// App bar button showing the sync status. Tapping it opens the sync screen.
class SyncStatusChip extends ConsumerWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SyncState sync = ref.watch(syncCoordinatorProvider);
    final bool isOnline = ref.watch(isOnlineProvider).valueOrNull ?? true;
    final ColorScheme colors = Theme.of(context).colorScheme;

    final (IconData icon, String label, Color? color) = switch (sync.status) {
      SyncStatus.syncing => (Icons.sync, 'Syncing', null),
      SyncStatus.pending => (
          Icons.cloud_upload_outlined,
          '${sync.pending.length} to upload',
          colors.tertiaryContainer,
        ),
      SyncStatus.outOfDate => (
          Icons.cloud_download_outlined,
          'Out of sync',
          colors.errorContainer,
        ),
      SyncStatus.connecting => (
          isOnline ? Icons.cloud_queue : Icons.cloud_off_outlined,
          isOnline ? 'Checking' : 'Offline',
          null,
        ),
      SyncStatus.upToDate => (Icons.cloud_done_outlined, 'Synced', null),
    };

    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(!isOnline && sync.status == SyncStatus.pending
          ? '$label (offline)'
          : label),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const SyncScreen(),
        ),
      ),
    );
  }
}
