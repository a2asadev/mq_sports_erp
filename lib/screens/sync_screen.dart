import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/data/outbox_entry.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/providers/local_data_providers.dart';
import 'package:mq_sports_erp/providers/sync_controller.dart';

/// Shows what has not reached the server yet, and lets the user sync on demand.
///
/// Syncing normally happens by itself (when there is a connection, a few
/// seconds after something is saved, and every minute); this screen is for
/// seeing what is going on and for the rare case that needs the user.
class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  String _formatTime(DateTime time) {
    final DateTime local = time.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)} ${two(local.hour)}:${two(local.minute)}';
  }

  IconData _iconFor(OutboxEntry entry) {
    if (entry.state == OutboxState.failed) {
      return Icons.error_outline;
    }
    if (entry.state == OutboxState.sent) {
      return Icons.check_circle_outline;
    }
    switch (entry.kind) {
      case OutboxKind.upsert:
        return entry.isNew ? Icons.add_circle_outline : Icons.edit_outlined;
      case OutboxKind.delete:
        return Icons.delete_outline;
      case OutboxKind.orderCancel:
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  String _stateText(OutboxEntry entry) {
    switch (entry.state) {
      case OutboxState.pending:
        return 'Waiting to upload · ${_formatTime(entry.createdAt)}';
      case OutboxState.sent:
        return 'Uploaded, waiting for the server\'s copy';
      case OutboxState.failed:
        return 'Refused: ${entry.error}';
    }
  }

  Future<void> _confirmDownloadAgain(BuildContext context, WidgetRef ref) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Download everything again?'),
        content: const Text(
          'This replaces this device\'s copy of the data with the server\'s. '
          'Changes that are waiting to be uploaded are kept.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Download again'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(syncControllerProvider.notifier).downloadEverythingAgain();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SyncSummary summary = ref.watch(syncSummaryProvider);
    final SyncUiState sync = ref.watch(syncControllerProvider);
    final List<OutboxEntry> entries =
        ref.watch(outboxEntriesProvider).valueOrNull ?? <OutboxEntry>[];
    final bool isOnline = ref.watch(isOnlineProvider).valueOrNull ?? true;
    final ThemeData theme = Theme.of(context);

    final String statusTitle;
    final String statusDetail;
    final IconData statusIcon;
    switch (summary.status) {
      case SyncStatus.syncing:
        statusTitle = 'Syncing…';
        statusDetail = 'Please keep the app open.';
        statusIcon = Icons.sync;
      case SyncStatus.needsAttention:
        statusTitle = '${summary.failed} change(s) need attention';
        statusDetail = 'The server refused them. Retry them, or discard them below.';
        statusIcon = Icons.error_outline;
      case SyncStatus.offline:
        statusTitle = isOnline ? 'The server cannot be reached' : 'You are offline';
        statusDetail = summary.waiting > 0
            ? '${summary.waiting} change(s) are saved on this device and are '
                'uploaded automatically when the connection is back.'
            : 'Everything you do is saved on this device and uploaded later.';
        statusIcon = Icons.cloud_off_outlined;
      case SyncStatus.pending:
        statusTitle = '${summary.waiting} change(s) to upload';
        statusDetail = 'They are uploaded automatically in a few seconds.';
        statusIcon = Icons.cloud_upload_outlined;
      case SyncStatus.upToDate:
        statusTitle = 'In step with the server';
        statusDetail = sync.lastSyncedAt == null
            ? 'Nothing is waiting.'
            : 'Last checked ${_formatTime(sync.lastSyncedAt!)}.';
        statusIcon = Icons.cloud_done_outlined;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync'),
        actions: <Widget>[
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (String value) {
              if (value == 'again') {
                _confirmDownloadAgain(context, ref);
              }
            },
            itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'again',
                child: Text('Download everything again'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: ListTile(
              leading: Icon(statusIcon, size: 32),
              title: Text(statusTitle),
              subtitle: Text(statusDetail),
            ),
          ),
          if (sync.message != null) ...<Widget>[
            const SizedBox(height: 8),
            Card(
              color: sync.messageIsError
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(sync.message!),
              ),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: sync.isSyncing
                ? null
                : () => ref.read(syncControllerProvider.notifier).syncNow(manual: true),
            icon: const Icon(Icons.sync),
            label: Text(sync.isSyncing ? 'Syncing…' : 'Sync now'),
          ),
          const SizedBox(height: 20),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Nothing is waiting to be uploaded.', style: theme.textTheme.bodyMedium),
              ),
            )
          else ...<Widget>[
            Text('Waiting for the server (${entries.length})', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            for (final OutboxEntry entry in entries)
              Card(
                child: ListTile(
                  leading: Icon(
                    _iconFor(entry),
                    color: entry.state == OutboxState.failed ? theme.colorScheme.error : null,
                  ),
                  title: Text(entry.label),
                  subtitle: Text(_stateText(entry)),
                  isThreeLine: entry.state == OutboxState.failed,
                  trailing: entry.state == OutboxState.failed
                      ? Wrap(
                          spacing: 4,
                          children: <Widget>[
                            TextButton(
                              onPressed: () => ref.read(syncControllerProvider.notifier).retry(entry.opId),
                              child: const Text('Retry'),
                            ),
                            TextButton(
                              onPressed: () => ref.read(syncControllerProvider.notifier).discard(entry.opId),
                              child: const Text('Discard'),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
