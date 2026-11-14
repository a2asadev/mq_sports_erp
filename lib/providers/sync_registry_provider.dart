import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
import 'package:mq_sports_erp/providers/parties_providers.dart';
import 'package:mq_sports_erp/providers/purchasing_providers.dart';
import 'package:mq_sports_erp/providers/sales_providers.dart';
import 'package:mq_sports_erp/providers/stock_audit_providers.dart';
import 'package:mq_sports_erp/providers/stock_providers.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';

/// Sync only exists in local-first mode, where every repository is a
/// `BaseRepository`. (The online-only web app never builds this list.)
SyncableRepository _syncable(Object repository) {
  if (repository is SyncableRepository) {
    return repository;
  }
  throw StateError('Sync is only available in local-first mode.');
}

/// Every repository that takes part in sync. A new module only has to add
/// its repository here to get the full sync behaviour (pending list,
/// metadata versions, manual upload and download).
final Provider<List<SyncableRepository>> syncRepositoriesProvider =
    Provider<List<SyncableRepository>>((Ref ref) {
  return <SyncableRepository>[
    _syncable(ref.watch(nativeUserRepositoryProvider)),
    _syncable(ref.watch(categoryRepositoryProvider)),
    _syncable(ref.watch(productRepositoryProvider)),
    _syncable(ref.watch(vendorRepositoryProvider)),
    _syncable(ref.watch(customerRepositoryProvider)),
    _syncable(ref.watch(ledgerRepositoryProvider)),
    _syncable(ref.watch(purchaseRepositoryProvider)),
    _syncable(ref.watch(orderRepositoryProvider)),
    _syncable(ref.watch(stockLedgerRepositoryProvider)),
    _syncable(ref.watch(stockAuditRepositoryProvider)),
  ];
});
