import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/online/api_auth_service.dart';
import 'package:mq_sports_erp/online/api_client.dart';
import 'package:mq_sports_erp/online/api_config.dart';
import 'package:mq_sports_erp/online/remote_store.dart';
import 'package:mq_sports_erp/online/token_store.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';

final Provider<TokenStore> tokenStoreProvider =
    Provider<TokenStore>((Ref ref) => SharedPrefsTokenStore());

final Provider<http.Client> httpClientProvider = Provider<http.Client>((Ref ref) {
  final http.Client client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// The one connection to the API (web admin). It holds the sign-in session.
final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((Ref ref) {
  return ApiClient(
    httpClient: ref.watch(httpClientProvider),
    baseUrl: apiBaseUrl,
    tokens: ref.watch(tokenStoreProvider),
  );
});

/// The in-memory copy of the server's data.
///
/// - Whenever it receives changes, open lists reload (the same signal the
///   local-first app uses after a sync).
/// - It asks the server for other people's changes every [onlinePollInterval]
///   while someone is signed in.
/// - It is emptied when the person signs out, and when a different person signs
///   in, so nobody ever sees the previous user's data.
final Provider<RemoteStore> remoteStoreProvider = Provider<RemoteStore>((Ref ref) {
  final ApiClient api = ref.watch(apiClientProvider);
  final RemoteStore store = RemoteStore(api);
  store.onChanged = () => ref.read(syncTickProvider.notifier).increment();

  if (api.currentUser != null) {
    store.startPolling(onlinePollInterval);
  }
  final StreamSubscription<UserModel?> subscription =
      api.sessionChanges.listen((UserModel? user) {
    store.reset();
    if (user != null) {
      store.startPolling(onlinePollInterval);
    }
  });
  ref.onDispose(() {
    unawaited(subscription.cancel());
    store.reset();
  });
  return store;
});

final Provider<ApiAuthService> apiAuthServiceProvider =
    Provider<ApiAuthService>((Ref ref) => ApiAuthService(ref.watch(apiClientProvider)));

final Provider<ApiAuthAdminService> apiAuthAdminServiceProvider =
    Provider<ApiAuthAdminService>((Ref ref) => ApiAuthAdminService(
          ref.watch(apiClientProvider),
          ref.watch(remoteStoreProvider),
        ));
