import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/data/local/app_database.dart';
import 'package:a2_stocks/data/local/collections.dart';
import 'package:a2_stocks/data/outbox_entry.dart';
import 'package:a2_stocks/data/outbox_store.dart';
import 'package:a2_stocks/data/sync_engine.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/providers/core_providers.dart';

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
    throw StateError(L10n.current.localDataNoUserIsSigned);
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
    StreamProvider<List<OutboxEntry>>((Ref ref) {
  final String? userId =
      ref.watch(authUidProvider.select((AsyncValue<String?> value) => value.valueOrNull));
  if (userId == null) {
    // Signing out: nobody's queue to show.
    return Stream<List<OutboxEntry>>.value(const <OutboxEntry>[]);
  }
  return ref.watch(outboxStoreProvider).watch();
});
