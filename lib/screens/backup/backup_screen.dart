import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/backup_health.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/web_orders.dart';
import 'package:a2_stocks/core/utils/zip_export.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/export_models.dart';
import 'package:a2_stocks/providers/data_mode.dart';
import 'package:a2_stocks/providers/export_providers.dart';
import 'package:a2_stocks/providers/sync_controller.dart';

/// Backup and export (admin): whether this device's work is safely on the server, when the server last made a
/// backup, and every data set as a CSV file (one by one, or all in one ZIP) to keep or open in a spreadsheet.
/// Needs a connection.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  /// What is being saved now: a data set id, or 'zip'; '' = nothing.
  String _busy = '';

  String _title(AppLocalizations l10n, String id) => switch (id) {
        'customers' => l10n.exportDatasetCustomers,
        'vendors' => l10n.exportDatasetVendors,
        'products' => l10n.exportDatasetProducts,
        'orders' => l10n.exportDatasetOrders,
        'order_items' => l10n.exportDatasetOrderItems,
        'ledger' => l10n.exportDatasetLedger,
        'stock_movements' => l10n.exportDatasetStock,
        'purchases' => l10n.exportDatasetPurchases,
        'expenses' => l10n.exportDatasetExpenses,
        'promotions' => l10n.exportDatasetPromotions,
        _ => id,
      };

  String _when(BuildContext context, DateTime t) => DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_jm().format(t);

  String _ago(AppLocalizations l10n, DateTime t) {
    final ({AgeUnit unit, int count}) a = ageOf(t, DateTime.now());
    return switch (a.unit) {
      AgeUnit.justNow => l10n.webOrdersJustNow,
      AgeUnit.minutes => l10n.webOrdersMinutesAgo(a.count),
      AgeUnit.hours => l10n.webOrdersHoursAgo(a.count),
      AgeUnit.days => l10n.webOrdersDaysAgo(a.count),
    };
  }

  Future<void> _save(String name, Uint8List bytes, String mime) async {
    final AppLocalizations l10n = context.l10n;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final Uri? saved = await FilePicker.saveFile(fileName: name, bytes: bytes, mimeType: mime, dialogTitle: l10n.reportSaveAs);
    if (saved != null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.reportSaved)));
    }
  }

  Future<void> _one(String dataset) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = dataset);
    try {
      final ExportFile file = await ref.read(exportServiceProvider).file(dataset);
      await _save(file.fileName, Uint8List.fromList(utf8.encode(file.csv)), 'text/csv');
      ref.invalidate(exportOverviewProvider);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
    } finally {
      if (mounted) {
        setState(() => _busy = '');
      }
    }
  }

  Future<void> _all(List<DatasetInfo> sets) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = 'zip');
    try {
      final Map<String, String> files = <String, String>{};
      String day = '';
      for (final DatasetInfo d in sets) {
        final ExportFile file = await ref.read(exportServiceProvider).file(d.id);
        files[file.fileName] = file.csv;
        day = file.fileName.replaceAll(RegExp(r'^.*?-(\d{4}-\d{2}-\d{2})\.csv$'), r'$1');
      }
      await _save('backup-$day.zip', zipTextFiles(files), 'application/zip');
      ref.invalidate(exportOverviewProvider);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
    } finally {
      if (mounted) {
        setState(() => _busy = '');
      }
    }
  }

  Widget _card({required IconData icon, required Color color, required String title, required String body, String? extra}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(body),
                  if (extra != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(extra, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Whether this device's own work is on the server.
  Widget _deviceCard(AppLocalizations l10n) {
    if (ref.watch(dataModeProvider).isOnline) {
      return _card(icon: Icons.cloud_done_outlined, color: AppColors.teal, title: l10n.backupDeviceTitle, body: l10n.backupWebSaved);
    }
    final SyncSummary sync = ref.watch(syncSummaryProvider);
    final DateTime? last = sync.lastSyncedAt;
    final bool trouble = sync.waiting > 0 || sync.failed > 0;
    return _card(
      icon: trouble ? Icons.sync_problem_outlined : Icons.cloud_done_outlined,
      color: sync.failed > 0 ? AppColors.danger : (sync.waiting > 0 ? AppColors.amber : AppColors.teal),
      title: l10n.backupDeviceTitle,
      body: sync.failed > 0 ? l10n.backupDeviceRefused(sync.failed) : (sync.waiting > 0 ? l10n.backupDeviceWaiting(sync.waiting) : l10n.backupDeviceAllSaved),
      extra: last == null ? l10n.backupNeverSynced : l10n.backupLastSynced(_when(context, last)),
    );
  }

  Widget _backupCard(AppLocalizations l10n, BackupStatus status) {
    final BackupHealth health = backupHealth(status, DateTime.now());
    final DateTime? ok = status.lastSuccessAt;
    final String size = status.lastSuccessBytes == null ? '' : ' · ${humanBytes(status.lastSuccessBytes!)}';
    switch (health) {
      case BackupHealth.notSetUp:
        return _card(icon: Icons.help_outline, color: AppColors.textMuted, title: l10n.backupServerTitle, body: l10n.backupNotSetUp);
      case BackupHealth.never:
        return _card(icon: Icons.warning_amber_outlined, color: AppColors.amber, title: l10n.backupServerTitle, body: l10n.backupNoneYet);
      case BackupHealth.ok:
        return _card(icon: Icons.verified_outlined, color: AppColors.teal, title: l10n.backupServerTitle, body: l10n.backupLastOk(_ago(l10n, ok!)), extra: '${_when(context, ok)}$size');
      case BackupHealth.old:
        return _card(icon: Icons.warning_amber_outlined, color: AppColors.amber, title: l10n.backupServerTitle, body: l10n.backupTooOld(_ago(l10n, ok!)), extra: '${_when(context, ok)}$size');
      case BackupHealth.failing:
        return _card(
          icon: Icons.error_outline,
          color: AppColors.danger,
          title: l10n.backupServerTitle,
          body: l10n.backupFailed(_when(context, status.lastFailureAt!)),
          extra: ok == null ? null : l10n.backupLastGood(_when(context, ok)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<ExportOverview> overview = ref.watch(exportOverviewProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.moduleBackup),
        actions: <Widget>[IconButton(tooltip: l10n.registerRefresh, icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(exportOverviewProvider))],
      ),
      body: overview.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(errorMessageOf(error), textAlign: TextAlign.center))),
        data: (ExportOverview o) => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            _deviceCard(l10n),
            _backupCard(l10n, o.backup),
            if (o.lastExport != null)
              _card(
                icon: Icons.download_done_outlined,
                color: AppColors.sky,
                title: l10n.backupLastExportTitle,
                body: l10n.backupLastExport(_when(context, o.lastExport!.at), o.lastExport!.by.isEmpty ? '?' : o.lastExport!.by),
              ),
            const SizedBox(height: 4),
            Text(l10n.exportTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.exportHint, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _busy.isNotEmpty ? null : () => _all(o.datasets),
              icon: _busy == 'zip' ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.folder_zip_outlined),
              label: Text(l10n.exportAllZip),
            ),
            const SizedBox(height: 8),
            for (final DatasetInfo d in o.datasets)
              Card(
                margin: const EdgeInsets.only(top: 8),
                child: ListTile(
                  title: Text(_title(l10n, d.id)),
                  subtitle: Text(l10n.exportRows(d.rows)),
                  trailing: _busy == d.id
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(tooltip: l10n.exportSaveCsv, icon: const Icon(Icons.download_outlined), onPressed: _busy.isNotEmpty ? null : () => _one(d.id)),
                ),
              ),
            const SizedBox(height: 16),
            Text(l10n.exportNote, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
