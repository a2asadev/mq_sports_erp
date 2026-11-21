import 'package:a2_stocks/core/utils/branch_rules.dart';
import 'package:a2_stocks/providers/branch_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/data/local_repositories.dart';
import 'package:a2_stocks/providers/local_data_providers.dart';
import 'package:a2_stocks/repositories/repository.dart';
import 'package:a2_stocks/providers/data_mode.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/online_repositories.dart';
import 'package:a2_stocks/models/stock_ledger_model.dart';
import 'package:a2_stocks/providers/base_list_notifier.dart';

final Provider<Repository<StockLedgerModel>> stockLedgerRepositoryProvider =
    Provider<Repository<StockLedgerModel>>((Ref ref) {
  if (ref.watch(dataModeProvider).isOnline) {
    return OnlineStockLedgerRepository(
      ref.watch(apiClientProvider),
      ref.watch(remoteStoreProvider),
    );
  }
  return LocalStockLedgerRepository(
    collection: ref.watch(localCollectionsProvider).stockLedgers,
    outbox: ref.watch(outboxStoreProvider),
  );
});

/// Read-only list of stock movements. Entries are created by other modules
/// (for example a confirmed purchase) together with their own records.
class StockLedgerNotifier extends BaseListNotifier<StockLedgerModel> {
  @override
  Repository<StockLedgerModel> get repository =>
      ref.read(stockLedgerRepositoryProvider);
}

final AsyncNotifierProvider<StockLedgerNotifier, List<StockLedgerModel>>
    stockLedgerProvider =
    AsyncNotifierProvider<StockLedgerNotifier, List<StockLedgerModel>>(
  StockLedgerNotifier.new,
);

/// Stock on hand per variant id: the sum of its stock movements. When the business uses branches it is the stock of
/// the branch this device works in (that is what a sale there can take); otherwise the whole business's.
final Provider<Map<String, int>> stockOnHandProvider =
    Provider<Map<String, int>>((Ref ref) {
  final List<StockLedgerModel> entries =
      ref.watch(stockLedgerProvider).valueOrNull ?? <StockLedgerModel>[];
  final String branch = ref.watch(workingBranchIdProvider);
  return stockByVariant(entries, branchId: branch.isEmpty ? null : branch, defaultBranchId: ref.watch(defaultBranchIdProvider));
});
