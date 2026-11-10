import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/models/pending_change.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/providers/sync_coordinator.dart';

/// Shows what is not synced yet and lets the user sync manually.
class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  String _formatTime(DateTime time) {
    final DateTime local = time.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)} ${two(local.hour)}:${two(local.minute)}';
  }

  IconData _iconFor(PendingChangeType type) {
    switch (type) {
      case PendingChangeType.create:
        return Icons.add_circle_outline;
      case PendingChangeType.update:
        return Icons.edit_outlined;
      case PendingChangeType.delete:
        return Icons.delete_outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SyncState sync = ref.watch(syncCoordinatorProvider);
    final bool isOnline = ref.watch(isOnlineProvider).valueOrNull ?? true;
    final ThemeData theme = Theme.of(context);
    final List<String> stale = sync.staleCollections;
    final bool hasPending = sync.pending.isNotEmpty;
    final bool hasStale = stale.isNotEmpty;
    final bool hasPendingDeletes = sync.pending
        .any((PendingChange c) => c.type == PendingChangeType.delete);

    final String statusTitle;
    final String statusDetail;
    final IconData statusIcon;
    switch (sync.status) {
      case SyncStatus.syncing:
        statusTitle = 'Syncing…';
        statusDetail = 'Please keep the app open.';
        statusIcon = Icons.sync;
      case SyncStatus.pending:
        statusTitle = '${sync.pending.length} change(s) not uploaded';
        statusDetail = 'These exist only on this device until you sync.';
        statusIcon = Icons.cloud_upload_outlined;
      case SyncStatus.outOfDate:
        statusTitle = 'Out of sync';
        statusDetail = 'The cloud has newer data than this device.';
        statusIcon = Icons.cloud_download_outlined;
      case SyncStatus.connecting:
        statusTitle = isOnline ? 'Checking the cloud…' : 'You are offline';
        statusDetail = isOnline
            ? 'Waiting for the cloud version information.'
            : 'Everything you do is saved on this device.';
        statusIcon = isOnline ? Icons.cloud_queue : Icons.cloud_off_outlined;
      case SyncStatus.upToDate:
        statusTitle = 'Synced';
        statusDetail = 'This device matches the cloud.';
        statusIcon = Icons.cloud_done_outlined;
    }

    final String buttonLabel = hasPendingDeletes && hasStale
        ? 'Download updates first'
        : hasPending && hasStale
        ? 'Sync now'
        : hasPending
            ? 'Upload ${sync.pending.length} change(s)'
            : hasStale
                ? 'Download updates'
                : 'Up to date';
    final bool canSync = isOnline &&
        sync.metadataLoaded &&
        !sync.isWorking &&
        (hasPending || hasStale);

    return Scaffold(
      appBar: AppBar(title: const Text('Sync')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Card(
                  child: ListTile(
                    leading: Icon(statusIcon, size: 32),
                    title: Text(statusTitle),
                    subtitle: Text(statusDetail),
                  ),
                ),
                if (sync.message != null)
                  Card(
                    color: sync.messageIsError
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.secondaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(sync.message!),
                    ),
                  ),
                if (hasPendingDeletes && hasStale)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'You have deletions waiting, and the cloud has newer '
                        'data. Deletions are only uploaded after you download '
                        'the updates, so the app can check they are still safe.',
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text('Waiting to upload (${sync.pending.length})',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                if (!hasPending)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Nothing is waiting to be uploaded.'),
                  )
                else
                  for (final PendingChange change in sync.pending)
                    Card(
                      child: ListTile(
                        leading: Icon(_iconFor(change.type)),
                        title: Text('${change.entityLabel}: ${change.itemLabel}'),
                        subtitle: Text(
                            '${change.type.label} · ${_formatTime(change.changedAt)}'),
                      ),
                    ),
                const SizedBox(height: 16),
                Text('Cloud collections', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final String collection in sync.collections)
                  Card(
                    child: ListTile(
                      title: Text(collection),
                      subtitle: Text(
                        'This device: ${sync.localVersionOf(collection) < 0 ? 'not downloaded' : 'v${sync.localVersionOf(collection)}'}'
                        ' · Cloud: ${sync.metadataLoaded ? 'v${sync.remoteVersionOf(collection)}' : '…'}'
                        '${sync.remote[collection]?.updatedAt == null ? '' : '\nCloud updated ${_formatTime(sync.remote[collection]!.updatedAt!)}'}',
                      ),
                      trailing: Icon(
                        !sync.metadataLoaded
                            ? Icons.hourglass_empty
                            : stale.contains(collection)
                                ? Icons.cloud_download_outlined
                                : Icons.check_circle_outline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (!isOnline)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Connect to the internet to sync.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: canSync
                        ? () => ref.read(syncCoordinatorProvider.notifier).syncNow()
                        : null,
                    icon: sync.isWorking
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: Text(buttonLabel),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
