import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/core/utils/backup_health.dart';
import 'package:a2_stocks/core/utils/zip_export.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/export_models.dart';
import 'package:a2_stocks/online/export_service.dart';
import 'package:a2_stocks/providers/export_providers.dart';
import 'package:a2_stocks/providers/sync_controller.dart';
import 'package:a2_stocks/screens/backup/backup_screen.dart';

BackupStatus status({bool configured = true, DateTime? ok, DateTime? failed, int? bytes}) => BackupStatus(configured: configured, lastSuccessAt: ok, lastSuccessBytes: bytes, lastFailureAt: failed);

class _FakeExport implements ExportService {
  _FakeExport(this.data);
  final ExportOverview data;
  final List<String> asked = <String>[];

  @override
  Future<ExportOverview> overview() async => data;

  @override
  Future<ExportFile> file(String dataset) async {
    asked.add(dataset);
    return ExportFile(dataset: dataset, rows: 1, fileName: '$dataset-2026-11-21.csv', csv: '﻿a,b\r\n1,2\r\n');
  }
}

void main() {
  final DateTime now = DateTime(2026, 11, 21, 12);

  group('how the backups are doing', () {
    test('is not set up when the server does not share it, and never when nothing ran', () {
      expect(backupHealth(status(configured: false), now), BackupHealth.notSetUp);
      expect(backupHealth(status(), now), BackupHealth.never);
    });

    test('is fine when the last backup is recent, old after 36 hours', () {
      expect(backupHealth(status(ok: now.subtract(const Duration(hours: 10))), now), BackupHealth.ok);
      expect(backupHealth(status(ok: now.subtract(const Duration(hours: 36))), now), BackupHealth.ok);
      expect(backupHealth(status(ok: now.subtract(const Duration(hours: 37))), now), BackupHealth.old);
    });

    test('is failing when the last attempt failed after the last good one (or there was none)', () {
      expect(backupHealth(status(ok: now.subtract(const Duration(hours: 30)), failed: now.subtract(const Duration(hours: 6))), now), BackupHealth.failing);
      expect(backupHealth(status(failed: now), now), BackupHealth.failing);
      // a failure that was followed by a good backup is over
      expect(backupHealth(status(ok: now.subtract(const Duration(hours: 2)), failed: now.subtract(const Duration(hours: 20))), now), BackupHealth.ok);
    });

    test('writes sizes for people', () {
      expect(humanBytes(512), '512 B');
      expect(humanBytes(1536), '1.5 KB');
      expect(humanBytes(1048576), '1.0 MB');
      expect(humanBytes(250 * 1024 * 1024), '250 MB');
    });
  });

  test('the server\'s answers are read, with times in local time and a missing last export as none', () {
    final ExportOverview o = ExportOverview.fromMap(<String, dynamic>{
      'datasets': <Object?>[<String, dynamic>{'id': 'customers', 'rows': 3}, <String, dynamic>{'id': 'orders', 'rows': 12}],
      'lastExport': <String, dynamic>{'at': '2026-11-20T10:00:00.000Z', 'by': 'Asad', 'dataset': 'orders'},
      'backup': <String, dynamic>{'configured': true, 'lastSuccessAt': '2026-11-21T02:00:07.000Z', 'lastSuccessBytes': 1048576, 'lastFailureAt': null},
    });
    expect(o.datasets.map((DatasetInfo d) => '${d.id}:${d.rows}').toList(), <String>['customers:3', 'orders:12']);
    expect(o.lastExport?.by, 'Asad');
    expect(o.backup.lastSuccessAt?.toUtc(), DateTime.utc(2026, 11, 21, 2, 0, 7));
    expect(o.backup.lastSuccessBytes, 1048576);
    expect(o.backup.lastFailureAt, isNull);
    expect(ExportOverview.fromMap(<String, dynamic>{}).lastExport, isNull);
    expect(ExportOverview.fromMap(<String, dynamic>{}).backup.configured, isFalse);
  });

  test('a ZIP holds every file with its text intact, also in other languages', () {
    final List<int> zip = zipTextFiles(<String, String>{'customers-2026-11-21.csv': '﻿name\r\nعلی\r\n', 'orders-2026-11-21.csv': 'a,b\r\n1,2\r\n'});
    final Archive back = ZipDecoder().decodeBytes(zip);
    expect(back.files.map((ArchiveFile f) => f.name).toList(), <String>['customers-2026-11-21.csv', 'orders-2026-11-21.csv']);
    // The byte order mark is kept (Excel needs it), so compare the bytes, not decoded text.
    expect(back.files.first.content as List<int>, utf8.encode('﻿name\r\nعلی\r\n'));
  });

  group('the Backup & export page', () {
    final ExportOverview data = ExportOverview(
      datasets: const <DatasetInfo>[DatasetInfo(id: 'customers', rows: 3), DatasetInfo(id: 'orders', rows: 1)],
      lastExport: LastExport(at: DateTime.now().subtract(const Duration(days: 2)), by: 'Asad', dataset: 'orders'),
      backup: BackupStatus(configured: true, lastSuccessAt: DateTime.now().subtract(const Duration(hours: 5)), lastSuccessBytes: 2097152),
    );

    Future<_FakeExport> pump(WidgetTester tester, {ExportOverview? overview, SyncSummary? sync, Size size = const Size(900, 1100)}) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final _FakeExport fake = _FakeExport(overview ?? data);
      await tester.pumpWidget(ProviderScope(
        overrides: <Override>[
          exportServiceProvider.overrideWithValue(fake),
          syncSummaryProvider.overrideWithValue(sync ?? SyncSummary(status: SyncStatus.upToDate, waiting: 0, failed: 0, lastSyncedAt: DateTime.now())),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BackupScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      return fake;
    }

    for (final Size size in const <Size>[Size(1200, 1100), Size(390, 900)]) {
      testWidgets('shows the device, the server backup, the last export and the data sets (${size.width.toInt()} px)', (WidgetTester tester) async {
        await pump(tester, size: size);
        expect(find.text('All your work is saved on the server.'), findsOneWidget);
        expect(find.textContaining('The last backup was 5 hours ago'), findsOneWidget);
        expect(find.textContaining('2.0 MB'), findsOneWidget);
        expect(find.textContaining('by Asad'), findsOneWidget);
        expect(find.text('Customers'), findsOneWidget);
        expect(find.text('3 rows'), findsOneWidget);
        expect(find.text('1 row'), findsOneWidget);
        expect(find.byTooltip('Save as CSV'), findsNWidgets(2));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('warns about work that is waiting or was refused, and a missed or failed backup', (WidgetTester tester) async {
      await pump(
        tester,
        sync: const SyncSummary(status: SyncStatus.needsAttention, waiting: 2, failed: 1),
        overview: ExportOverview(
          datasets: const <DatasetInfo>[],
          backup: BackupStatus(configured: true, lastSuccessAt: DateTime.now().subtract(const Duration(days: 3)), lastFailureAt: DateTime.now().subtract(const Duration(hours: 2))),
        ),
      );
      expect(find.textContaining('1 action was refused'), findsOneWidget);
      expect(find.textContaining('The last backup failed'), findsOneWidget);
      expect(find.textContaining('The last good backup was'), findsOneWidget);
    });

    testWidgets('says plainly when the server does not report backups', (WidgetTester tester) async {
      await pump(tester, overview: const ExportOverview(datasets: <DatasetInfo>[], backup: BackupStatus(configured: false)));
      expect(find.textContaining('does not report its backups'), findsOneWidget);
      expect(find.text('Last export'), findsNothing);
    });
  });
}
