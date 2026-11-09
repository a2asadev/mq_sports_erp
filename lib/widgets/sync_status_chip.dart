import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/services/sync_service.dart';

class SyncStatusChip extends ConsumerWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SyncStatus status = ref.watch(syncStatusProvider);
    final (IconData icon, String label) = switch (status) {
      SyncStatus.idle => (Icons.cloud_done_outlined, 'Synced'),
      SyncStatus.syncing => (Icons.sync, 'Syncing'),
      SyncStatus.offline => (Icons.cloud_off_outlined, 'Offline'),
      SyncStatus.error => (Icons.error_outline, 'Sync issue'),
    };
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}
