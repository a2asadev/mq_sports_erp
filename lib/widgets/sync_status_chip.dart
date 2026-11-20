import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/providers/sync_controller.dart';
import 'package:a2_stocks/screens/sync_screen.dart';

/// App bar button showing the sync status. Tapping it opens the sync screen.
class SyncStatusChip extends ConsumerWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SyncSummary summary = ref.watch(syncSummaryProvider);
    final ColorScheme colors = Theme.of(context).colorScheme;

    final (IconData icon, String label, Color? color) = switch (summary.status) {
      SyncStatus.syncing => (Icons.sync, context.l10n.syncStatusChipSyncing, null),
      SyncStatus.needsAttention => (
          Icons.error_outline,
          context.l10n.syncStatusChipNeedAttention(summary.failed),
          colors.errorContainer,
        ),
      SyncStatus.offline => (
          Icons.cloud_off_outlined,
          summary.waiting > 0 ? context.l10n.syncStatusChipWaitingOffline(summary.waiting) : context.l10n.syncStatusChipOffline,
          summary.waiting > 0 ? colors.tertiaryContainer : null,
        ),
      SyncStatus.pending => (
          Icons.cloud_upload_outlined,
          context.l10n.syncStatusChipToUpload(summary.waiting),
          colors.tertiaryContainer,
        ),
      SyncStatus.upToDate => (Icons.cloud_done_outlined, context.l10n.syncStatusChipSynced, null),
    };

    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
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
