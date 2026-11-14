import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/stock_audit_model.dart';
import 'package:mq_sports_erp/models/stock_ledger_model.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';
import 'package:mq_sports_erp/repositories/repository.dart';
import 'package:mq_sports_erp/services/activity_logger.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';
import 'package:mq_sports_erp/services/pending_change_store.dart';
import 'package:uuid/uuid.dart';

/// Saves a stock audit together with the adjustment it causes: one stock
/// ledger entry (type adjustment) per item whose count differs from the
/// system, for the difference.
///
/// Locally all records are written in Hive or none are (a failure undoes the
/// ones already written). They all carry the same pending-change group id,
/// so the sync uploads them in ONE atomic Firestore transaction.
class StockAuditRepository extends BaseRepository<StockAuditModel>
    implements StockAuditOperations {
  StockAuditRepository({
    required HiveLocalRepository<StockAuditModel> local,
    required PendingChangeStore pendingStore,
    ActivityLogger? logger,
    required BaseRepository<StockLedgerModel> stockRepository,
  })  : _stock = stockRepository,
        super(
          collectionName: StorageKeys.stockAudits,
          entityLabel: 'Stock audit',
          local: local,
          pendingStore: pendingStore,
          fromMap: StockAuditModel.fromMap,
          labelOf: (StockAuditModel audit) => audit.auditNo,
          logger: logger,
        );

  final BaseRepository<StockLedgerModel> _stock;

  @override
  Future<void> confirm(StockAuditModel audit) async {
    final String groupId = const Uuid().v4();
    final List<Future<void> Function()> undo = <Future<void> Function()>[];
    try {
      await save(audit, groupId: groupId);
      undo.add(() => discardNewLocally(audit.id));

      for (final StockAuditItem item in audit.items) {
        if (item.variance == 0) {
          continue;
        }
        final StockLedgerModel adjustment = StockLedgerModel(
          productId: item.productId,
          variantId: item.variantId,
          sku: item.sku,
          quantity: item.variance,
          movementType: StockMovementType.adjustment,
          sourceId: audit.id,
          movementDate: audit.auditDate,
          note: audit.note.isEmpty
              ? audit.auditNo
              : '${audit.auditNo}: ${audit.note}',
        );
        await _stock.save(adjustment, groupId: groupId);
        undo.add(() => _stock.discardNewLocally(adjustment.id));
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
