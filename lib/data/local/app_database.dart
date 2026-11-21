import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:a2_stocks/data/local/tables.dart';

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

  /// The database file of one user, in the app's own folder.
  factory AppDatabase.open(String userId) => AppDatabase(driftDatabase(name: 'mq_erp_$userId'));

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 8) {
            // Products the shop features on the online store's home page.
            await m.addColumn(products, products.isFeatured);
          }
          if (from < 7) {
            // A customer's birthday (day and month) for greetings.
            await m.addColumn(customers, customers.birthday);
          }
          if (from < 6) {
            // Tax charged on an order, and the rates it was charged at.
            await m.addColumn(orders, orders.taxAmount);
            await m.addColumn(orders, orders.gstAmount);
            await m.addColumn(orders, orders.vatAmount);
            await m.addColumn(orders, orders.gstRate);
            await m.addColumn(orders, orders.vatRate);
            await m.addColumn(orders, orders.taxInclusive);
          }
          if (from < 5) {
            // Returned goods and money handed back are ledger entries of their own kind.
            await m.addColumn(ledgerEntries, ledgerEntries.kind);
          }
          if (from < 4) {
            // How each payment was made (cash, bank, Easypaisa, JazzCash).
            await m.addColumn(ledgerEntries, ledgerEntries.paymentMethod);
            await m.addColumn(ledgerEntries, ledgerEntries.paymentRef);
          }
          if (from < 3) {
            // Photos of users, categories, customers, vendors and products.
            await m.addColumn(users, users.photoUrl);
            await m.addColumn(categories, categories.photoUrl);
            await m.addColumn(vendors, vendors.photoUrl);
            await m.addColumn(customers, customers.photoUrl);
            await m.addColumn(products, products.imagesJson);
          }
          if (from < 2) {
            // Online-store orders: delivery fee, delivery details and the channel.
            await m.addColumn(orders, orders.shippingFee);
            await m.addColumn(orders, orders.shippingAddress);
            await m.addColumn(orders, orders.channel);
          }
        },
        beforeOpen: (OpeningDetails details) async {
          // Related rows are removed by the code that removes their parent, in
          // one transaction. Foreign keys stay off: the device may briefly hold
          // a child before its parent has arrived (the server sends them in the
          // order they changed, not parent first).
          await customStatement('PRAGMA foreign_keys = OFF');
        },
      );
}
