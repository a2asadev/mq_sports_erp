import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/models/stock_ledger_model.dart';
import 'package:mq_sports_erp/providers/base_list_notifier.dart';
import 'package:mq_sports_erp/providers/activity_log_providers.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';

final Provider<BaseRepository<StockLedgerModel>> stockLedgerRepositoryProvider =
    Provider<BaseRepository<StockLedgerModel>>((Ref ref) {
  return BaseRepository<StockLedgerModel>(
    collectionName: StorageKeys.stockLedgers,
    entityLabel: 'Stock entry',
    local: HiveLocalRepository<StockLedgerModel>(
      boxName: StorageKeys.stockLedgers,
      fromMap: StockLedgerModel.fromMap,
    ),
    pendingStore: ref.watch(pendingChangeStoreProvider),
    logger: ref.watch(activityLoggerProvider),
    fromMap: StockLedgerModel.fromMap,
    labelOf: (StockLedgerModel entry) =>
        '${entry.sku} ${entry.quantity >= 0 ? '+' : ''}${entry.quantity}',
  );
});

/// Read-only list of stock movements. Entries are created by other modules
/// (for example a confirmed purchase) together with their own records.
class StockLedgerNotifier extends BaseListNotifier<StockLedgerModel> {
  @override
  BaseRepository<StockLedgerModel> get repository =>
      ref.read(stockLedgerRepositoryProvider);
}

final AsyncNotifierProvider<StockLedgerNotifier, List<StockLedgerModel>>
    stockLedgerProvider =
    AsyncNotifierProvider<StockLedgerNotifier, List<StockLedgerModel>>(
  StockLedgerNotifier.new,
);

/// Stock on hand per variant id: the sum of all its stock movements.
final Provider<Map<String, int>> stockOnHandProvider =
    Provider<Map<String, int>>((Ref ref) {
  final List<StockLedgerModel> entries =
      ref.watch(stockLedgerProvider).valueOrNull ?? <StockLedgerModel>[];
  final Map<String, int> totals = <String, int>{};
  for (final StockLedgerModel entry in entries) {
    totals[entry.variantId] = (totals[entry.variantId] ?? 0) + entry.quantity;
  }
  return totals;
});
