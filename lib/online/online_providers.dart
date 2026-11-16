import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/online/api_auth_service.dart';
import 'package:a2_stocks/online/api_client.dart';
import 'package:a2_stocks/online/api_config.dart';
import 'package:a2_stocks/online/remote_store.dart';
import 'package:a2_stocks/online/secure_token_store.dart';
import 'package:a2_stocks/online/token_store.dart';
import 'package:a2_stocks/providers/core_providers.dart';

/// The refresh token: protected system storage on mobile and desktop; browser
/// storage on the web (which has no safer place).
final Provider<TokenStore> tokenStoreProvider =
    Provider<TokenStore>((Ref ref) => kIsWeb ? SharedPrefsTokenStore() : SecureTokenStore());

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

