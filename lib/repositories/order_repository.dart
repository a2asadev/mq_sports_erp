import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/ledger_model.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/pending_change.dart';
import 'package:mq_sports_erp/models/stock_ledger_model.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';
import 'package:mq_sports_erp/repositories/repository.dart';
import 'package:mq_sports_erp/services/activity_logger.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';
import 'package:mq_sports_erp/services/pending_change_store.dart';
import 'package:uuid/uuid.dart';

/// Saves an order together with everything it causes:
/// - one negative stock ledger entry per item (stock leaves),
/// - a customer ledger charge for the total, and
/// - a customer ledger payment for whatever is paid now.
///
/// Locally all records are written in Hive or none are (a failure undoes the
/// ones already written). They all carry the same pending-change group id,
/// so the sync uploads them in ONE atomic Firestore transaction. Cancelling
/// an order does the reverse in the same way.
class OrderRepository extends BaseRepository<OrderModel>
    implements OrderOperations {
  OrderRepository({
    required HiveLocalRepository<OrderModel> local,
    required PendingChangeStore pendingStore,
    ActivityLogger? logger,
    required BaseRepository<StockLedgerModel> stockRepository,
    required BaseRepository<LedgerModel> ledgerRepository,
  })  : _pendingStore = pendingStore,
        _stock = stockRepository,
        _ledger = ledgerRepository,
        super(
          collectionName: StorageKeys.orders,
          entityLabel: 'Order',
          local: local,
          pendingStore: pendingStore,
          fromMap: OrderModel.fromMap,
          labelOf: (OrderModel order) => order.orderNo,
          logger: logger,
        );

  final PendingChangeStore _pendingStore;
  final BaseRepository<StockLedgerModel> _stock;
  final BaseRepository<LedgerModel> _ledger;

  Future<void> _undoAll(List<Future<void> Function()> undo) async {
    for (final Future<void> Function() undoStep in undo.reversed) {
      try {
        await undoStep();
      } on AppException {
        continue;
      }
    }
  }

  @override
  Future<void> confirm(OrderModel order, {required double paidNow}) async {
    final String groupId = const Uuid().v4();
    final List<Future<void> Function()> undo = <Future<void> Function()>[];
    try {
      await save(order, groupId: groupId);
      undo.add(() => discardNewLocally(order.id));

      for (final OrderItem item in order.items) {
        final StockLedgerModel stockEntry = StockLedgerModel(
          productId: item.productId,
          variantId: item.variantId,
          sku: item.sku,
          quantity: -item.quantity,
          movementType: StockMovementType.sale,
          sourceId: order.id,
          unitCost: item.unitPrice,
          movementDate: order.orderDate,
          note: order.orderNo,
        );
        await _stock.save(stockEntry, groupId: groupId);
        undo.add(() => _stock.discardNewLocally(stockEntry.id));
      }

      final double total = order.totalAmount;
      if (total > 0) {
        final LedgerModel charge = LedgerModel(
          partyType: PartyType.customer,
          partyId: order.customerId,
          entryType: LedgerEntryType.charge,
          amount: total,
          entryDate: order.orderDate,
          description: 'Order ${order.orderNo}',
          reference: order.orderNo,
          orderId: order.id,
        );
        await _ledger.save(charge, groupId: groupId);
        undo.add(() => _ledger.discardNewLocally(charge.id));
      }
      if (paidNow > 0) {
        final LedgerModel payment = LedgerModel(
          partyType: PartyType.customer,
          partyId: order.customerId,
          entryType: LedgerEntryType.payment,
          amount: paidNow,
          entryDate: order.orderDate,
          description: 'Payment for ${order.orderNo}',
          reference: order.orderNo,
          orderId: order.id,
        );
        await _ledger.save(payment, groupId: groupId);
        undo.add(() => _ledger.discardNewLocally(payment.id));
      }
    } on AppException {
      await _undoAll(undo);
      rethrow;
    }
  }

  /// Group id of the order's not yet uploaded change, if it has one. A change
  /// to an order that is still waiting to be uploaded must stay in the same
  /// group as its stock and ledger entries.
  Future<String> _groupIdFor(String orderId) async {
    final List<PendingChange> pending =
        await _pendingStore.getForCollection(collectionName);
    for (final PendingChange change in pending) {
      if (change.entityId == orderId && change.groupId.isNotEmpty) {
        return change.groupId;
      }
    }
    return const Uuid().v4();
  }

  /// Saves [cancelled] (the order with status Cancelled) and returns the
  /// stock and reverses the ledger charge, all as one group. The reversal is
  /// a customer ledger payment, the same way payments are recorded for
  /// vendors. Money already paid stays on the ledger as customer credit.
  @override
  Future<void> cancel(OrderModel cancelled, {required DateTime when}) async {
    final String groupId = await _groupIdFor(cancelled.id);
    final List<Future<void> Function()> undo = <Future<void> Function()>[];
    try {
      for (final OrderItem item in cancelled.items) {
        final StockLedgerModel stockEntry = StockLedgerModel(
          productId: item.productId,
          variantId: item.variantId,
          sku: item.sku,
          quantity: item.quantity,
          movementType: StockMovementType.sale,
          sourceId: cancelled.id,
          unitCost: item.unitPrice,
          movementDate: when,
          note: 'Cancelled ${cancelled.orderNo}',
        );
        await _stock.save(stockEntry, groupId: groupId);
        undo.add(() => _stock.discardNewLocally(stockEntry.id));
      }
      final double total = cancelled.totalAmount;
      if (total > 0) {
        final LedgerModel reversal = LedgerModel(
          partyType: PartyType.customer,
          partyId: cancelled.customerId,
          entryType: LedgerEntryType.payment,
          amount: total,
          entryDate: when,
          description: 'Cancelled order ${cancelled.orderNo}',
          reference: cancelled.orderNo,
          orderId: cancelled.id,
        );
        await _ledger.save(reversal, groupId: groupId);
        undo.add(() => _ledger.discardNewLocally(reversal.id));
      }
      // Last, so that if it fails its own rollback restores the order and
      // only the new stock and ledger records above need to be undone.
      await save(cancelled, groupId: groupId);
    } on AppException {
      await _undoAll(undo);
      rethrow;
    }
  }
}
