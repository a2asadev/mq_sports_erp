import 'package:drift/drift.dart';
import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/data/local/app_database.dart';
import 'package:a2_stocks/data/local/collections.dart';
import 'package:a2_stocks/data/local/tables.dart';
import 'package:a2_stocks/data/outbox_entry.dart';
import 'package:a2_stocks/data/outbox_store.dart';
import 'package:a2_stocks/models/ledger_model.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/payment_method.dart';
import 'package:a2_stocks/models/purchase_model.dart';
import 'package:a2_stocks/models/stock_audit_model.dart';
import 'package:a2_stocks/online/api_client.dart';
import 'package:a2_stocks/online/api_commands.dart';
import 'package:a2_stocks/online/remote_store.dart';
import 'package:a2_stocks/models/syncable_model.dart';

/// What one sync did.
class SyncOutcome {
  const SyncOutcome({
    this.uploaded = 0,
    this.refused = 0,
    this.downloaded = false,
    this.offline = false,
    this.error,
  });

  /// Queued actions the server accepted.
  final int uploaded;

  /// Queued actions the server refused (they wait in the queue, marked failed).
  final int refused;

  /// New data arrived from the server.
  final bool downloaded;

  /// The server could not be reached, so the rest waits for the next try.
  final bool offline;

  /// A problem the user should see (for example "session ended").
  final String? error;
}

/// Keeps this device and the server in step.
///
/// - **Upload**: the queued actions go to the server one by one, oldest first.
///   Each carries its own id as an Idempotency-Key, so a retry after a dropped
///   connection can never do an action twice. An action the server refuses is
///   marked failed (with the server's reason) and the rest carry on; if the
///   server cannot be reached everything waits.
/// - **Download**: everything that changed since the last time, using the
///   server's cursor, written to the local database together with the new
///   cursor in ONE transaction (so a crash never loses or repeats a change).
class SyncEngine {
  SyncEngine({
    required ApiClient api,
    required AppDatabase db,
    required LocalCollections collections,
    required OutboxStore outbox,
    this.pageSize = 1000,
  })  : _api = api,
        _db = db,
        _collections = collections,
        _outbox = outbox,
        _commands = ApiCommands(api);

  final ApiClient _api;
  final AppDatabase _db;
  final LocalCollections _collections;
  final OutboxStore _outbox;
  final ApiCommands _commands;
  final int pageSize;

  static const String _cursorKey = 'cursor';
  static const String _lastSyncKey = 'lastSyncAt';

  // ---- small facts ----------------------------------------------------------

  Future<String?> _get(String key) async {
    final SyncKvRow? row = await (_db.select(_db.syncKv)..where((SyncKv t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _set(String key, String value) => _db
      .into(_db.syncKv)
      .insertOnConflictUpdate(SyncKvCompanion(key: Value<String>(key), value: Value<String>(value)));

  Future<String> cursor() async => await _get(_cursorKey) ?? '0';

  /// When a sync last finished with the server reachable (null: never).
  Future<DateTime?> lastSyncedAt() async {
    final String? value = await _get(_lastSyncKey);
    return value == null ? null : DateTime.tryParse(value);
  }

  // ---- a whole sync ---------------------------------------------------------

  /// Upload, then download, then tidy up.
  Future<SyncOutcome> sync() async {
    final _Push push = await _push();
    if (push.offline) {
      return SyncOutcome(uploaded: push.uploaded, refused: push.refused, offline: true);
    }
    if (push.authError != null) {
      return SyncOutcome(uploaded: push.uploaded, refused: push.refused, error: push.authError);
    }
    try {
      final bool downloaded = await pull();
      await _tidy();
      await _set(_lastSyncKey, DateTime.now().toIso8601String());
      return SyncOutcome(uploaded: push.uploaded, refused: push.refused, downloaded: downloaded);
    } on AuthFailureException catch (e) {
      return SyncOutcome(uploaded: push.uploaded, refused: push.refused, error: e.message);
    } on RemoteSyncException {
      return SyncOutcome(uploaded: push.uploaded, refused: push.refused, offline: true);
    }
  }

  // ---- download -------------------------------------------------------------

  /// Downloads everything new. True when anything arrived.
  Future<bool> pull() async {
    bool changed = false;
    bool more = true;
    while (more) {
      final String since = await cursor();
      final ApiResponse response = await _api.get(
        '/v1/sync/changes',
        query: <String, String>{'since': since, 'limit': '$pageSize'},
      );
      final JsonMap page = response.asMap;
      bool pageChanged = false;
      await _db.transaction(() async {
        final Object? changes = page['changes'];
        if (changes is Map<String, dynamic>) {
          for (final MapEntry<String, dynamic> entry in changes.entries) {
            final LocalCollection<SyncableModel>? collection = _collections.named(entry.key);
            final Object? list = entry.value;
            if (collection == null || list is! List<Object?> || list.isEmpty) {
              continue;
            }
            await collection.upsertMaps(<Map<String, dynamic>>[
              for (final Object? item in list)
                if (item is Map<String, dynamic>) normalizeDates(item),
            ]);
            pageChanged = true;
          }
        }
        final Object? deleted = page['deleted'];
        if (deleted is Map<String, dynamic>) {
          for (final MapEntry<String, dynamic> entry in deleted.entries) {
            final LocalCollection<SyncableModel>? collection = _collections.named(entry.key);
            final Object? ids = entry.value;
            if (collection == null || ids is! List<Object?> || ids.isEmpty) {
              continue;
            }
            await collection.deleteIds(ids.whereType<String>().toList());
            pageChanged = true;
          }
        }
        // The cursor moves in the same transaction as the data it covers.
        await _set(_cursorKey, '${page['cursor'] ?? since}');
      });
      changed = changed || pageChanged;
      more = page['hasMore'] == true;
    }
    return changed;
  }

  /// Forgets the downloaded data and the cursor, so the next sync downloads
  /// everything again. Queued actions are kept.
  Future<void> resetDownloadedData() async {
    await _db.transaction(() async {
      for (final LocalCollection<SyncableModel> collection in _collections.every) {
        await collection.clear();
      }
      await _set(_cursorKey, '0');
    });
  }

  // ---- upload ---------------------------------------------------------------

  Future<_Push> _push() async {
    int uploaded = 0;
    int refused = 0;
    for (final OutboxEntry entry in await _outbox.pending()) {
      try {
        await _send(entry);
        await _outbox.markSent(entry.opId);
        uploaded++;
      } on AuthFailureException catch (e) {
        return _Push(uploaded: uploaded, refused: refused, authError: e.message);
      } on RemoteSyncException {
        // No connection, or the server is having trouble: stop here, keep order.
        await _outbox.countAttempt(entry.opId);
        return _Push(uploaded: uploaded, refused: refused, offline: true);
      } on AppException catch (e) {
        await _outbox.markFailed(entry.opId, e.message);
        refused++;
      }
    }
    return _Push(uploaded: uploaded, refused: refused);
  }

  Future<void> _send(OutboxEntry entry) async {
    final String key = entry.opId;
    final Map<String, dynamic> p = entry.payload;
    switch (entry.kind) {
      case OutboxKind.upsert:
        await _commands.upsert(entry.collection, p, isNew: entry.isNew, key: key);
      case OutboxKind.delete:
        try {
          await _commands.deleteRecord(entry.collection, entry.entityId, key: key);
        } on ValidationException catch (e) {
          // Already gone from the server: the delete has happened.
          if (!e.message.toLowerCase().contains('not found')) {
            rethrow;
          }
        }
      case OutboxKind.orderConfirm:
        // The sale already happened at the counter, so it is recorded even when
        // the stock has since run out (the Stock screen flags negative stock).
        await _commands.confirmOrder(
          OrderModel.fromMap(p['order'] as Map<String, dynamic>),
          (p['paidNow'] as num?)?.toDouble() ?? 0,
          payments: PaymentLine.listFrom(p['payments']),
          recordedOffline: true,
          key: key,
        );
      case OutboxKind.orderStatus:
        await _commands.setOrderStatus(entry.entityId, OrderStatus.fromName(p['status'] as String?), key: key);
      case OutboxKind.orderCancel:
        await _commands.cancelOrder(entry.entityId, key: key);
      case OutboxKind.orderPayment:
        await _commands.orderPayment(LedgerModel.fromMap(p['entry'] as Map<String, dynamic>), key: key);
      case OutboxKind.purchaseConfirm:
        await _commands.confirmPurchase(
          PurchaseModel.fromMap(p['purchase'] as Map<String, dynamic>),
          (p['paidNow'] as num?)?.toDouble() ?? 0,
          key: key,
        );
      case OutboxKind.purchasePayment:
        await _commands.purchasePayment(LedgerModel.fromMap(p['entry'] as Map<String, dynamic>), key: key);
      case OutboxKind.ledgerEntry:
        await _commands.ledgerEntry(LedgerModel.fromMap(p['entry'] as Map<String, dynamic>), key: key);
      case OutboxKind.auditConfirm:
        await _commands.confirmAudit(StockAuditModel.fromMap(p['audit'] as Map<String, dynamic>), key: key);
    }
  }

  // ---- tidy up --------------------------------------------------------------

  /// An accepted action keeps showing until its records have been downloaded,
  /// then it is removed. One whose records have not arrived yet stays and is
  /// checked again at the next sync.
  Future<void> _tidy() async {
    final List<String> done = <String>[];
    for (final OutboxEntry entry in await _outbox.all()) {
      if (entry.state == OutboxState.sent && await _arrived(entry)) {
        done.add(entry.opId);
      }
    }
    if (done.isNotEmpty) {
      await _outbox.remove(done);
    }
  }

  Future<bool> _arrived(OutboxEntry entry) async {
    switch (entry.kind) {
      case OutboxKind.orderConfirm:
        return await _collections.orders.byId(entry.entityId) != null;
      case OutboxKind.purchaseConfirm:
        return await _collections.purchases.byId(entry.entityId) != null;
      case OutboxKind.auditConfirm:
        return await _collections.stockAudits.byId(entry.entityId) != null;
      case OutboxKind.orderPayment:
      case OutboxKind.purchasePayment:
      case OutboxKind.ledgerEntry:
        return await _collections.ledgers.byId(entry.entityId) != null;
      case OutboxKind.orderStatus:
        final OrderModel? order = await _collections.orders.byId(entry.entityId);
        final OrderStatus target = OrderStatus.fromName(entry.payload['status'] as String?);
        return order != null && (order.status == target || order.status.index > target.index);
      case OutboxKind.orderCancel:
        return (await _collections.orders.byId(entry.entityId))?.status == OrderStatus.cancelled;
      case OutboxKind.delete:
        return await _collections.named(entry.collection)?.byId(entry.entityId) == null;
      case OutboxKind.upsert:
        // An edit can go at once (the old copy is already on screen). A new
        // record stays until the server's copy has arrived, or it would
        // disappear from the screen for a moment.
        return !entry.isNew ||
            await _collections.named(entry.collection)?.byId(entry.entityId) != null;
    }
  }
}

class _Push {
  const _Push({this.uploaded = 0, this.refused = 0, this.offline = false, this.authError});

  final int uploaded;
  final int refused;
  final bool offline;
  final String? authError;
}
