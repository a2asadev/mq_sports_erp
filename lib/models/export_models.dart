/// One data set the admin can take out (`GET /v1/export`).
class DatasetInfo {
  const DatasetInfo({required this.id, required this.rows});

  /// customers, vendors, products, orders, order_items, ledger, stock_movements, purchases, expenses, promotions.
  final String id;
  final int rows;
}

/// What the server's backup job last did. Only known when the server shares it (`configured`).
class BackupStatus {
  const BackupStatus({required this.configured, this.lastSuccessAt, this.lastSuccessBytes, this.lastFailureAt});

  final bool configured;
  final DateTime? lastSuccessAt;
  final int? lastSuccessBytes;
  final DateTime? lastFailureAt;

  factory BackupStatus.fromMap(Object? raw) {
    final Map<String, dynamic> m = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};
    DateTime? time(Object? v) => v is String ? DateTime.tryParse(v)?.toLocal() : null;
    return BackupStatus(
      configured: m['configured'] == true,
      lastSuccessAt: time(m['lastSuccessAt']),
      lastSuccessBytes: (m['lastSuccessBytes'] as num?)?.toInt(),
      lastFailureAt: time(m['lastFailureAt']),
    );
  }
}

class LastExport {
  const LastExport({required this.at, required this.by, required this.dataset});

  final DateTime at;
  final String by;
  final String dataset;
}

class ExportOverview {
  const ExportOverview({required this.datasets, required this.backup, this.lastExport});

  final List<DatasetInfo> datasets;
  final BackupStatus backup;
  final LastExport? lastExport;

  factory ExportOverview.fromMap(Map<String, dynamic> m) {
    final Object? last = m['lastExport'];
    final DateTime? at = last is Map<String, dynamic> && last['at'] is String ? DateTime.tryParse(last['at'] as String)?.toLocal() : null;
    return ExportOverview(
      datasets: <DatasetInfo>[
        for (final Object? d in (m['datasets'] as List<Object?>? ?? <Object?>[]))
          if (d is Map<String, dynamic>) DatasetInfo(id: '${d['id']}', rows: (d['rows'] as num?)?.toInt() ?? 0),
      ],
      backup: BackupStatus.fromMap(m['backup']),
      lastExport: at == null ? null : LastExport(at: at, by: '${(last as Map<String, dynamic>)['by'] ?? ''}', dataset: '${last['dataset'] ?? ''}'),
    );
  }
}

/// One data set as a CSV file (the whole file as text, with a byte order mark so any spreadsheet reads any language).
class ExportFile {
  const ExportFile({required this.dataset, required this.rows, required this.fileName, required this.csv});

  final String dataset;
  final int rows;
  final String fileName;
  final String csv;

  factory ExportFile.fromMap(Map<String, dynamic> m) => ExportFile(
        dataset: '${m['dataset'] ?? ''}',
        rows: (m['rows'] as num?)?.toInt() ?? 0,
        fileName: '${m['fileName'] ?? 'export.csv'}',
        csv: '${m['csv'] ?? ''}',
      );
}
