import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/online/api_auth_service.dart';
import 'package:mq_sports_erp/online/online_providers.dart';
import 'package:mq_sports_erp/online/photo_service.dart';
import 'package:mq_sports_erp/online/starter_pack_service.dart';
import 'package:mq_sports_erp/providers/data_mode.dart';
import 'package:mq_sports_erp/providers/local_data_providers.dart';
import 'package:mq_sports_erp/services/auth_admin_service.dart';
import 'package:mq_sports_erp/services/auth_service.dart';

/// Sign-in goes through the API on every platform.
final Provider<AuthService> authServiceProvider =
    Provider<AuthService>((Ref ref) => ref.watch(apiAuthServiceProvider));

/// Creating a login needs the server (it makes the account), so it works only
/// with a connection. Afterwards the new user is brought onto this device.
final Provider<AuthAdminService> authAdminServiceProvider =
    Provider<AuthAdminService>((Ref ref) {
  final bool online = ref.watch(dataModeProvider).isOnline;
  return ApiAuthAdminService(ref.watch(apiClientProvider), () async {
    if (online) {
      await ref.read(remoteStoreProvider).refresh();
    } else {
      await ref.read(syncEngineProvider).pull();
      ref.read(syncTickProvider.notifier).increment();
    }
  });
});

/// Choosing and uploading photos. After a change the new photo address is
/// brought onto this device (the web copy is refreshed; the others pull).
final Provider<PhotoService> photoServiceProvider = Provider<PhotoService>((Ref ref) {
  final bool online = ref.watch(dataModeProvider).isOnline;
  return PhotoService(
    api: ref.watch(apiClientProvider),
    httpClient: ref.watch(httpClientProvider),
    refresh: () async {
      try {
        if (online) {
          await ref.read(remoteStoreProvider).refresh();
        } else {
          await ref.read(syncEngineProvider).pull();
          ref.read(syncTickProvider.notifier).increment();
        }
      } catch (_) {
        // The photo is saved; the next sync brings it to this device.
      }
    },
  );
});

/// Starter category packs. After a pack is added the new categories are brought
/// onto this device (the web copy is refreshed; the others pull).
final Provider<StarterPackService> starterPackServiceProvider = Provider<StarterPackService>((Ref ref) {
  final bool online = ref.watch(dataModeProvider).isOnline;
  return StarterPackService(
    api: ref.watch(apiClientProvider),
    refresh: () async {
      try {
        if (online) {
          await ref.read(remoteStoreProvider).refresh();
        } else {
          await ref.read(syncEngineProvider).pull();
          ref.read(syncTickProvider.notifier).increment();
        }
      } catch (_) {
        // The categories are saved; the next sync brings them to this device.
      }
    },
  );
});

/// Current user uid, or null when signed out.
final StreamProvider<String?> authUidProvider =
    StreamProvider<String?>((Ref ref) {
  return ref.watch(authServiceProvider).uidChanges();
});

/// True while the device has a network connection.
final StreamProvider<bool> isOnlineProvider =
    StreamProvider<bool>((Ref ref) async* {
  final Connectivity connectivity = Connectivity();
  bool toOnline(List<ConnectivityResult> results) =>
      results.any((ConnectivityResult r) => r != ConnectivityResult.none);
  yield toOnline(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(toOnline);
});

/// Increments whenever data changed underneath the open lists (a sync brought
/// new data, or an action was queued), so they reload.
class SyncTickNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() {
    state = state + 1;
  }
}

final NotifierProvider<SyncTickNotifier, int> syncTickProvider =
    NotifierProvider<SyncTickNotifier, int>(SyncTickNotifier.new);
