import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:mq_sports_erp/data/local/tables.dart';

part 'app_database.g.dart';

/// The local SQLite database (mobile and desktop).
@DriftDatabase(tables: <Type>[
  Users,
  Categories,
  Products,
  ProductVariants,
  Vendors,
  Customers,
  LedgerEntries,
  Purchases,
  PurchaseItems,
  StockMovements,
  StockAudits,
  StockAuditItems,
  Orders,
  OrderItems,
  OrderStatusEntries,
  Outbox,
  SyncKv,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// The database file in the app's own folder.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'mq_erp'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (OpeningDetails details) async {
          // Related rows are removed by the code that removes their parent, in
          // one transaction. Foreign keys stay off: the device may briefly hold
          // a child before its parent has arrived (the server sends them in the
          // order they changed, not parent first).
          await customStatement('PRAGMA foreign_keys = OFF');
        },
      );
}
