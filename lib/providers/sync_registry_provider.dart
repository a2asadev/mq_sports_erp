import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
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
  ];
});
