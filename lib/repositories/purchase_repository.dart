import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/ledger_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/purchase_model.dart';
import 'package:mq_sports_erp/models/stock_ledger_model.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';
import 'package:mq_sports_erp/services/activity_logger.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';
import 'package:mq_sports_erp/services/pending_change_store.dart';
import 'package:uuid/uuid.dart';

/// Saves a purchase together with everything it causes:
/// - one stock ledger entry per item (adds stock),
/// - a vendor ledger charge for the total, and
/// - a vendor ledger payment for whatever is paid now.
///
/// Locally all records are written in Hive or none are (a failure undoes the
/// ones already written). They all carry the same pending-change group id,
/// so the sync uploads them in ONE atomic Firestore transaction.
class PurchaseRepository extends BaseRepository<PurchaseModel> {
  PurchaseRepository({
    required HiveLocalRepository<PurchaseModel> local,
    required PendingChangeStore pendingStore,
    ActivityLogger? logger,
    required BaseRepository<StockLedgerModel> stockRepository,
    required BaseRepository<LedgerModel> ledgerRepository,
  })  : _stock = stockRepository,
        _ledger = ledgerRepository,
        super(
          collectionName: StorageKeys.purchases,
          entityLabel: 'Purchase',
          local: local,
          pendingStore: pendingStore,
          fromMap: PurchaseModel.fromMap,
          labelOf: (PurchaseModel purchase) => purchase.purchaseNo,
          logger: logger,
        );

  final BaseRepository<StockLedgerModel> _stock;
  final BaseRepository<LedgerModel> _ledger;

  Future<void> confirm(PurchaseModel purchase, {required double paidNow}) async {
    final String groupId = const Uuid().v4();
    final List<Future<void> Function()> undo = <Future<void> Function()>[];
    try {
      await save(purchase, groupId: groupId);
      undo.add(() => discardNewLocally(purchase.id));

      for (final PurchaseItem item in purchase.items) {
        final StockLedgerModel stockEntry = StockLedgerModel(
          productId: item.productId,
          variantId: item.variantId,
          sku: item.sku,
          quantity: item.quantity,
          movementType: StockMovementType.purchase,
          sourceId: purchase.id,
          unitCost: item.unitCost,
          movementDate: purchase.purchaseDate,
          note: purchase.purchaseNo,
        );
        await _stock.save(stockEntry, groupId: groupId);
        undo.add(() => _stock.discardNewLocally(stockEntry.id));
      }

      final double total = purchase.totalAmount;
      if (total > 0) {
        final LedgerModel charge = LedgerModel(
          partyType: PartyType.vendor,
          partyId: purchase.vendorId,
          entryType: LedgerEntryType.charge,
          amount: total,
          entryDate: purchase.purchaseDate,
          description: 'Purchase ${purchase.purchaseNo}',
          reference: purchase.invoiceNo,
          purchaseId: purchase.id,
        );
        await _ledger.save(charge, groupId: groupId);
        undo.add(() => _ledger.discardNewLocally(charge.id));
      }
      if (paidNow > 0) {
        final LedgerModel payment = LedgerModel(
          partyType: PartyType.vendor,
          partyId: purchase.vendorId,
          entryType: LedgerEntryType.payment,
          amount: paidNow,
          entryDate: purchase.purchaseDate,
          description: 'Payment for ${purchase.purchaseNo}',
          reference: purchase.invoiceNo,
          purchaseId: purchase.id,
        );
        await _ledger.save(payment, groupId: groupId);
        undo.add(() => _ledger.discardNewLocally(payment.id));
      }
    } on AppException {
      for (final Future<void> Function() undoStep in undo.reversed) {
        try {
          await undoStep();
        } on AppException {
          continue;
        }
      }
      rethrow;
    }
  }
}
