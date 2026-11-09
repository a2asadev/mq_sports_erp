import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';
import 'package:mq_sports_erp/services/sync_service.dart';

/// Repositories included in the bulk background sync. Each new module adds
/// its repository here. (Users are synced by the admin screen only, because
/// non-admins may not read the whole `users` collection.)
final Provider<List<SyncableRepository>> syncRepositoriesProvider =
    Provider<List<SyncableRepository>>((Ref ref) {
  return <SyncableRepository>[
    ref.watch(categoryRepositoryProvider),
    ref.watch(productRepositoryProvider),
  ];
});

final Provider<SyncService> syncServiceProvider =
    Provider<SyncService>((Ref ref) {
  final SyncService service = SyncService(
    connectivity: Connectivity(),
    repositories: ref.watch(syncRepositoriesProvider),
    onStatusChanged: (SyncStatus status) =>
        ref.read(syncStatusProvider.notifier).setStatus(status),
    onSyncCompleted: () => ref.read(syncTickProvider.notifier).increment(),
  );
  service.start();
  ref.onDispose(service.dispose);
  return service;
});
