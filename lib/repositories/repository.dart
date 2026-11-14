import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/purchase_model.dart';
import 'package:mq_sports_erp/models/stock_audit_model.dart';
import 'package:mq_sports_erp/models/syncable_model.dart';

/// What the providers need from a repository, whichever way it stores data.
///
/// - Mobile and desktop: `BaseRepository`, local-first (Hive + manual sync).
/// - Web: `OnlineRepository`, every write goes to the API and the data shown is
///   the server's.
///
/// `getLocal` and `getLocalById` mean "the records this app currently shows";
/// for the online repositories that is the in-memory copy of the server's data.
abstract class Repository<T extends SyncableModel> {
  String get collectionName;

  Future<List<T>> getLocal();

  Future<T?> getLocalById(String id);

  Future<void> save(T item, {String groupId = ''});

  Future<void> delete(String id);

  /// Why deleting [id] is not allowed (for example "it has subcategories"), or
  /// null when it is fine. The online repositories return null: the server
  /// decides and refuses with the same kind of message.
  Future<String?> deleteBlockReason(String id);
}

/// A purchase is confirmed as one action: the purchase, its stock and the
/// vendor ledger entries all succeed or none does.
abstract class PurchaseOperations implements Repository<PurchaseModel> {
  Future<void> confirm(PurchaseModel purchase, {required double paidNow});
}

/// An order is confirmed, and cancelled, as one action.
abstract class OrderOperations implements Repository<OrderModel> {
  Future<void> confirm(OrderModel order, {required double paidNow});

  Future<void> cancel(OrderModel cancelled, {required DateTime when});
}

/// A stock count is confirmed as one action: the audit and its adjustments.
abstract class StockAuditOperations implements Repository<StockAuditModel> {
  Future<void> confirm(StockAuditModel audit);
}
