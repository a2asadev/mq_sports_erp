import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/data/local/app_database.dart';
import 'package:mq_sports_erp/data/local/collections.dart';
import 'package:mq_sports_erp/data/outbox_entry.dart';
import 'package:mq_sports_erp/data/outbox_store.dart';
import 'package:mq_sports_erp/data/sync_engine.dart';
import 'package:mq_sports_erp/online/online_providers.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';

/// The database of the signed-in user (mobile and desktop).
///
/// Every user has a database file of their own on the device, so what one
/// person queued while offline is never uploaded under another person's name,
/// and nobody sees another person's data. It is opened when someone signs in
/// and closed when they sign out; their unsent work waits in their file until
/// they sign in again.
final Provider<AppDatabase> databaseProvider = Provider<AppDatabase>((Ref ref) {
  final String? userId =
      ref.watch(authUidProvider.select((AsyncValue<String?> value) => value.valueOrNull));
  if (userId == null) {
    throw StateError('No user is signed in, so there is no database to open.');
  }
  final AppDatabase db = AppDatabase.open(userId);
  ref.onDispose(db.close);
  return db;
});

final Provider<LocalCollections> localCollectionsProvider =
    Provider<LocalCollections>((Ref ref) => LocalCollections(ref.watch(databaseProvider)));

final Provider<OutboxStore> outboxStoreProvider =
    Provider<OutboxStore>((Ref ref) => OutboxStore(ref.watch(databaseProvider)));

final Provider<SyncEngine> syncEngineProvider = Provider<SyncEngine>((Ref ref) {
  return SyncEngine(
    api: ref.watch(apiClientProvider),
    db: ref.watch(databaseProvider),
    collections: ref.watch(localCollectionsProvider),
    outbox: ref.watch(outboxStoreProvider),
  );
});

/// The queue of actions waiting for the server, live.
final StreamProvider<List<OutboxEntry>> outboxEntriesProvider =
    StreamProvider<List<OutboxEntry>>((Ref ref) => ref.watch(outboxStoreProvider).watch());
