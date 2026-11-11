import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
import 'package:mq_sports_erp/providers/parties_providers.dart';
import 'package:mq_sports_erp/providers/purchasing_providers.dart';
import 'package:mq_sports_erp/providers/sales_providers.dart';
import 'package:mq_sports_erp/providers/stock_audit_providers.dart';
import 'package:mq_sports_erp/providers/stock_providers.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';

/// Every repository that takes part in sync. A new module only has to add
/// its repository here to get the full sync behaviour (pending list,
/// metadata versions, manual upload and download).
final Provider<List<SyncableRepository>> syncRepositoriesProvider =
    Provider<List<SyncableRepository>>((Ref ref) {
  return <SyncableRepository>[
    ref.watch(userRepositoryProvider),
    ref.watch(categoryRepositoryProvider),
    ref.watch(productRepositoryProvider),
    ref.watch(vendorRepositoryProvider),
    ref.watch(customerRepositoryProvider),
    ref.watch(ledgerRepositoryProvider),
    ref.watch(purchaseRepositoryProvider),
    ref.watch(orderRepositoryProvider),
    ref.watch(stockLedgerRepositoryProvider),
    ref.watch(stockAuditRepositoryProvider),
  ];
});
