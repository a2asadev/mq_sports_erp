import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/services/auth_admin_service.dart';
import 'package:mq_sports_erp/services/auth_service.dart';
import 'package:mq_sports_erp/services/firestore_service.dart';
import 'package:mq_sports_erp/services/sync_service.dart';

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

class SyncStatusNotifier extends Notifier<SyncStatus> {
  @override
  SyncStatus build() => SyncStatus.idle;

  void setStatus(SyncStatus status) {
    state = status;
  }
}

final NotifierProvider<SyncStatusNotifier, SyncStatus> syncStatusProvider =
    NotifierProvider<SyncStatusNotifier, SyncStatus>(SyncStatusNotifier.new);

/// Increments after every completed bulk sync so list notifiers can reload
/// from Hive.
class SyncTickNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() {
    state = state + 1;
  }
}

final NotifierProvider<SyncTickNotifier, int> syncTickProvider =
    NotifierProvider<SyncTickNotifier, int>(SyncTickNotifier.new);
