import 'package:a2_stocks/core/constants/storage_keys.dart';
import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/data/local/collections.dart';
import 'package:a2_stocks/data/outbox_entry.dart';
import 'package:a2_stocks/data/outbox_store.dart';
import 'package:a2_stocks/data/pending_effects.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/models/ledger_model.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/payment_method.dart';
import 'package:a2_stocks/models/purchase_model.dart';
import 'package:a2_stocks/models/stock_audit_model.dart';
import 'package:a2_stocks/models/stock_ledger_model.dart';
import 'package:a2_stocks/models/syncable_model.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/repositories/repository.dart';

/// Combines what the server has confirmed with what the user has queued.
typedef Overlay<T> = List<T> Function(List<T> base, List<OutboxEntry> entries);

/// Local-first repository (mobile and desktop).
///
/// - Reads: the confirmed records in the SQLite database, with the queued
///   actions applied on top, so the user sees their own work at once.
/// - Writes: nothing is written to the records. The action is queued in the
///   outbox and the sync engine uploads it when there is a connection.
///
/// The server stays the only author of its records: whatever the user did
/// offline is replaced by the server's own copy after the upload.
class LocalRepository<T extends SyncableModel> implements Repository<T> {
  LocalRepository({
    required this.collection,
    required this.outbox,
    required this.overlay,
    required this.entityLabel,
    required this.labelOf,
    this.deleteGuard,
  });

  final LocalCollection<T> collection;
  final OutboxStore outbox;
  final Overlay<T> overlay;

  /// Singular display name, for example "Category".
  final String entityLabel;
  final String Function(T item) labelOf;
  final Future<String?> Function(String id)? deleteGuard;

  @override
  String get collectionName => collection.name;

  @override
  Future<List<T>> getLocal() async => overlay(await collection.all(), await outbox.all());

  @override
  Future<T?> getLocalById(String id) async {
    final T? base = await collection.byId(id);
    final List<T> shown = overlay(base == null ? <T>[] : <T>[base], await outbox.all());
    for (final T item in shown) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  /// True when the server already has the record: confirmed here, or accepted
  /// by the server but not downloaded back yet.
  Future<bool> existsOnServer(String id) async {
    if (await collection.byId(id) != null) {
      return true;
    }
    return (await outbox.all()).any((OutboxEntry e) =>
        e.collection == collectionName &&
        e.entityId == id &&
        e.kind == OutboxKind.upsert &&
        e.state == OutboxState.sent);
  }

  String describe(T item) => '$entityLabel "${labelOf(item)}"';

  @override
  Future<void> save(T item, {String groupId = ''}) async {
    await outbox.enqueueUpsert(
      collection: collectionName,
      entityId: item.id,
      label: describe(item),
      payload: item.toMap(),
      existsOnServer: await existsOnServer(item.id),
    );
  }

  @override
  Future<void> delete(String id) async {
    final T? current = await getLocalById(id);
    await outbox.enqueueDelete(
      collection: collectionName,
      entityId: id,
      label: current == null ? '$entityLabel $id' : describe(current),
    );
  }

  @override
  Future<String?> deleteBlockReason(String id) async {
    final Future<String?> Function(String id)? guard = deleteGuard;
    return guard == null ? null : guard(id);
  }

  ValidationException unsupported(String what) => ValidationException(what);
}

/// Users: they are listed from the server and edited by admins. A login is
/// created online (it needs the server to make the account), so a user that is
/// saved here always already exists on the server.
class LocalUserRepository extends LocalRepository<UserModel> {
  LocalUserRepository({required super.collection, required super.outbox})
      : super(
          overlay: _overlay,
          entityLabel: L10n.current.activityLogsUser,
          labelOf: (UserModel u) => u.displayName.isNotEmpty ? u.displayName : u.email,
        );

  static List<UserModel> _overlay(List<UserModel> base, List<OutboxEntry> entries) =>
      overlayRecords<UserModel>(
        collection: StorageKeys.users,
        base: base,
        entries: entries,
        fromMap: UserModel.fromMap,
      );

  @override
  Future<bool> existsOnServer(String id) async => true;
}

/// Ledger entries. Payments on a purchase or an order, and manual entries, are
/// each their own kind of action (the server checks a payment against what is
/// still due).
class LocalLedgerRepository extends LocalRepository<LedgerModel> {
  LocalLedgerRepository({required super.collection, required super.outbox})
      : super(
          overlay: overlayLedgers,
          entityLabel: L10n.current.localRepositoriesLedgerEntry,
          labelOf: (LedgerModel e) => '${e.entryType.name} ${e.amount.toStringAsFixed(2)}',
        );

  @override
  Future<void> save(LedgerModel item, {String groupId = ''}) async {
    if (await collection.byId(item.id) != null) {
      throw unsupported(L10n.current.onlineRepositoriesLedgerEntriesCannotBe);
    }
    final OutboxKind kind = item.purchaseId.isNotEmpty
        ? OutboxKind.purchasePayment
        : item.orderId.isNotEmpty
            ? OutboxKind.orderPayment
            : OutboxKind.ledgerEntry;
    await outbox.enqueue(
      kind,
      collection: collectionName,
      entityId: item.id,
      label: switch (kind) {
        OutboxKind.purchasePayment => L10n.current.localRepositoriesPaymentFor(item.amount.toStringAsFixed(2), item.reference),
        OutboxKind.orderPayment => L10n.current.localRepositoriesPaymentFor(item.amount.toStringAsFixed(2), item.reference),
        _ => describe(item),
      },
      payload: <String, dynamic>{'entry': item.toMap()},
    );
  }
}

/// Stock movements are only ever caused by purchases, sales and stock counts.
class LocalStockLedgerRepository extends LocalRepository<StockLedgerModel> {
  LocalStockLedgerRepository({required super.collection, required super.outbox})
      : super(
          overlay: overlayStock,
          entityLabel: L10n.current.localRepositoriesStockEntry,
          labelOf: (StockLedgerModel e) => '${e.sku} ${e.quantity >= 0 ? '+' : ''}${e.quantity}',
        );

  static String get _message => L10n.current.onlineRepositoriesStockChangesOnlyThrough;

  @override
  Future<void> save(StockLedgerModel item, {String groupId = ''}) =>
      Future<void>.error(unsupported(_message));

  @override
  Future<void> delete(String id) => Future<void>.error(unsupported(_message));
}

class LocalPurchaseRepository extends LocalRepository<PurchaseModel> implements PurchaseOperations {
  LocalPurchaseRepository({required super.collection, required super.outbox})
      : super(
          overlay: overlayPurchases,
          entityLabel: L10n.current.stockMovementPurchase,
          labelOf: (PurchaseModel p) => p.purchaseNo,
        );

  @override
  Future<void> confirm(PurchaseModel purchase, {required double paidNow}) async {
    await outbox.enqueue(
      OutboxKind.purchaseConfirm,
      collection: collectionName,
      entityId: purchase.id,
      label: L10n.current.localRepositoriesPurchase(purchase.purchaseNo),
      payload: <String, dynamic>{'purchase': purchase.toMap(), 'paidNow': paidNow},
    );
  }

  @override
  Future<void> save(PurchaseModel item, {String groupId = ''}) =>
      Future<void>.error(unsupported(L10n.current.onlineRepositoriesAConfirmedPurchaseCannot2));

  @override
  Future<void> delete(String id) =>
      Future<void>.error(unsupported(L10n.current.onlineRepositoriesAConfirmedPurchaseCannot));
}

class LocalOrderRepository extends LocalRepository<OrderModel> implements OrderOperations {
  LocalOrderRepository({required super.collection, required super.outbox})
      : super(
          overlay: overlayOrders,
          entityLabel: L10n.current.orderDetailOrder,
          labelOf: (OrderModel o) => o.orderNo,
        );

  @override
  Future<void> confirm(
    OrderModel order, {
    required double paidNow,
    List<PaymentLine> payments = const <PaymentLine>[],
  }) async {
    await outbox.enqueue(
      OutboxKind.orderConfirm,
      collection: collectionName,
      entityId: order.id,
      label: L10n.current.localRepositoriesOrder(order.orderNo),
      payload: <String, dynamic>{
        'order': order.toMap(),
        'paidNow': paidNow,
        if (payments.isNotEmpty) 'payments': payments.map((PaymentLine p) => p.toMap()).toList(),
      },
    );
  }

  @override
  Future<void> cancel(OrderModel cancelled, {required DateTime when}) async {
    await outbox.enqueue(
      OutboxKind.orderCancel,
      collection: collectionName,
      entityId: cancelled.id,
      label: L10n.current.localRepositoriesCancelOrder(cancelled.orderNo),
      payload: <String, dynamic>{'order': cancelled.toMap()},
    );
  }

  /// The only edit of an existing order is moving it along the pipeline.
  @override
  Future<void> save(OrderModel item, {String groupId = ''}) async {
    final OrderModel? current = await getLocalById(item.id);
    if (current == null) {
      throw unsupported(L10n.current.onlineRepositoriesAnOrderIsCreated);
    }
    if (item.status == current.status || item.statusHistory.isEmpty) {
      return;
    }
    await outbox.enqueue(
      OutboxKind.orderStatus,
      collection: collectionName,
      entityId: item.id,
      label: '${item.orderNo} → ${item.status.label}',
      payload: <String, dynamic>{
        'status': item.status.name,
        'entry': item.statusHistory.last.toMap(),
      },
    );
  }

  @override
  Future<void> delete(String id) =>
      Future<void>.error(unsupported(L10n.current.onlineRepositoriesAnOrderCannotBe));
}

class LocalStockAuditRepository extends LocalRepository<StockAuditModel> implements StockAuditOperations {
  LocalStockAuditRepository({required super.collection, required super.outbox})
      : super(
          overlay: overlayAudits,
          entityLabel: L10n.current.localRepositoriesStockCount2,
          labelOf: (StockAuditModel a) => a.auditNo,
        );

  @override
  Future<void> confirm(StockAuditModel audit) async {
    await outbox.enqueue(
      OutboxKind.auditConfirm,
      collection: collectionName,
      entityId: audit.id,
      label: L10n.current.localRepositoriesStockCount(audit.auditNo),
      payload: <String, dynamic>{'audit': audit.toMap()},
    );
  }

  @override
  Future<void> save(StockAuditModel item, {String groupId = ''}) =>
      Future<void>.error(unsupported(L10n.current.onlineRepositoriesAStockCountIs));

  @override
  Future<void> delete(String id) =>
      Future<void>.error(unsupported(L10n.current.onlineRepositoriesAStockCountCannot));
}
