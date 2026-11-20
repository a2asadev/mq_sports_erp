import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/data/outbox_entry.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/providers/core_providers.dart';
import 'package:a2_stocks/providers/local_data_providers.dart';
import 'package:a2_stocks/providers/sync_controller.dart';

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

  String _stateText(BuildContext context, OutboxEntry entry) {
    switch (entry.state) {
      case OutboxState.pending:
        return context.l10n.syncWaitingToUpload(_formatTime(entry.createdAt));
      case OutboxState.sent:
        return context.l10n.syncUploadedWaitingForThe;
      case OutboxState.failed:
        return context.l10n.syncRefused(entry.error);
    }
  }

  Future<void> _confirmDownloadAgain(BuildContext context, WidgetRef ref) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(context.l10n.syncDownloadEverythingAgain2),
        content: Text(
          context.l10n.syncThisReplacesThisDevice,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.categoriesCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.syncDownloadAgain),
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
        statusTitle = context.l10n.syncSyncing;
        statusDetail = context.l10n.syncPleaseKeepTheApp;
        statusIcon = Icons.sync;
      case SyncStatus.needsAttention:
        statusTitle = context.l10n.syncChangeSNeedAttention(summary.failed);
        statusDetail = context.l10n.syncTheServerRefusedThem;
        statusIcon = Icons.error_outline;
      case SyncStatus.offline:
        statusTitle = isOnline ? context.l10n.syncTheServerCannotBe : context.l10n.syncYouAreOffline;
        statusDetail = summary.waiting > 0
            ? context.l10n.syncChangeSAreSaved(summary.waiting)
            : context.l10n.syncEverythingYouDoIs;
        statusIcon = Icons.cloud_off_outlined;
      case SyncStatus.pending:
        statusTitle = context.l10n.syncChangeSToUpload(summary.waiting);
        statusDetail = context.l10n.syncTheyAreUploadedAutomatically;
        statusIcon = Icons.cloud_upload_outlined;
      case SyncStatus.upToDate:
        statusTitle = context.l10n.syncInStepWithThe;
        statusDetail = sync.lastSyncedAt == null
            ? context.l10n.syncNothingIsWaiting
            : context.l10n.syncLastChecked(_formatTime(sync.lastSyncedAt!));
        statusIcon = Icons.cloud_done_outlined;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.syncSync),
        actions: <Widget>[
          PopupMenuButton<String>(
            tooltip: context.l10n.syncMore,
            onSelected: (String value) {
              if (value == 'again') {
                _confirmDownloadAgain(context, ref);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'again',
                child: Text(context.l10n.syncDownloadEverythingAgain),
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
            label: Text(sync.isSyncing ? context.l10n.syncSyncing : context.l10n.syncSyncNow),
          ),
          const SizedBox(height: 20),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(context.l10n.syncNothingIsWaitingTo, style: theme.textTheme.bodyMedium),
              ),
            )
          else ...<Widget>[
            Text(context.l10n.syncWaitingForTheServer(entries.length), style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            for (final OutboxEntry entry in entries)
              Card(
                child: ListTile(
                  leading: Icon(
                    _iconFor(entry),
                    color: entry.state == OutboxState.failed ? theme.colorScheme.error : null,
                  ),
                  title: Text(entry.label),
                  subtitle: Text(_stateText(context, entry)),
                  isThreeLine: entry.state == OutboxState.failed,
                  trailing: entry.state == OutboxState.failed
                      ? Wrap(
                          spacing: 4,
                          children: <Widget>[
                            TextButton(
                              onPressed: () => ref.read(syncControllerProvider.notifier).retry(entry.opId),
                              child: Text(context.l10n.syncRetry),
                            ),
                            TextButton(
                              onPressed: () => ref.read(syncControllerProvider.notifier).discard(entry.opId),
                              child: Text(context.l10n.syncDiscard),
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
