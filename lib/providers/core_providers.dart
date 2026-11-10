import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/services/auth_admin_service.dart';
import 'package:mq_sports_erp/services/auth_service.dart';
import 'package:mq_sports_erp/services/firestore_service.dart';
import 'package:mq_sports_erp/services/pending_change_store.dart';
import 'package:mq_sports_erp/services/sync_state_store.dart';

final Provider<FirestoreService> firestoreServiceProvider =
    Provider<FirestoreService>((Ref ref) {
  return FirestoreService(FirebaseFirestore.instance);
});

final Provider<AuthService> authServiceProvider =
    Provider<AuthService>((Ref ref) {
  return AuthService(FirebaseAuth.instance);
});

final Provider<AuthAdminService> authAdminServiceProvider =
    Provider<AuthAdminService>((Ref ref) {
  return AuthAdminService();
});

/// Current user uid, or null when signed out.
final StreamProvider<String?> authUidProvider =
    StreamProvider<String?>((Ref ref) {
  return ref.watch(authServiceProvider).uidChanges();
});

final Provider<PendingChangeStore> pendingChangeStoreProvider =
    Provider<PendingChangeStore>((Ref ref) {
  final PendingChangeStore store = PendingChangeStore();
  ref.onDispose(store.dispose);
  return store;
});

final Provider<SyncStateStore> syncStateStoreProvider =
    Provider<SyncStateStore>((Ref ref) => SyncStateStore());

/// True while the device has a network connection.
final StreamProvider<bool> isOnlineProvider =
    StreamProvider<bool>((Ref ref) async* {
  final Connectivity connectivity = Connectivity();
  bool toOnline(List<ConnectivityResult> results) =>
      results.any((ConnectivityResult r) => r != ConnectivityResult.none);
  yield toOnline(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(toOnline);
});

/// Increments whenever downloaded data was merged into Hive, so open lists
/// reload from Hive.
class SyncTickNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() {
    state = state + 1;
  }
}

final NotifierProvider<SyncTickNotifier, int> syncTickProvider =
    NotifierProvider<SyncTickNotifier, int>(SyncTickNotifier.new);
