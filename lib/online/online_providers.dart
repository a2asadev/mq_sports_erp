import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/online/api_auth_service.dart';
import 'package:a2_stocks/online/api_client.dart';
import 'package:a2_stocks/online/api_config.dart';
import 'package:a2_stocks/online/change_feed.dart';
import 'package:a2_stocks/online/remote_store.dart';
import 'package:a2_stocks/online/secure_token_store.dart';
import 'package:a2_stocks/online/stream_client.dart';
import 'package:a2_stocks/online/token_store.dart';
import 'package:a2_stocks/providers/core_providers.dart';
import 'package:a2_stocks/providers/notification_providers.dart';

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
  // Live updates need a client that reads an answer while it arrives.
  final http.Client streamClient = createStreamClient();
  ref.onDispose(streamClient.close);
  return ApiClient(
    httpClient: ref.watch(httpClientProvider),
    baseUrl: apiBaseUrl,
    tokens: ref.watch(tokenStoreProvider),
    streamClient: streamClient,
  );
});

/// The in-memory copy of the server's data.
///
/// - Whenever it receives changes, open lists reload (the same signal the
///   local-first app uses after a sync).
/// - It asks the server for other people's changes every [onlinePollInterval]
///   while someone is signed in, and at once when the server says something
///   changed (live updates, [ChangeFeed]); the timer is the safety net.
/// - It is emptied when the person signs out, and when a different person signs
///   in, so nobody ever sees the previous user's data.
final Provider<RemoteStore> remoteStoreProvider = Provider<RemoteStore>((Ref ref) {
  final ApiClient api = ref.watch(apiClientProvider);
  final RemoteStore store = RemoteStore(api);
  store.onChanged = () => ref.read(syncTickProvider.notifier).increment();

  final ChangeFeed feed = ChangeFeed(
    open: api.openChangeStream,
    onSignal: () async {
      if (store.isLoaded) {
        await store.refresh();
      }
    },
    onNotification: () => ref.read(notificationsProvider.notifier).refresh(),
  );
  if (api.currentUser != null) {
    store.startPolling(onlinePollInterval);
    feed.start();
  }
  final StreamSubscription<UserModel?> subscription =
      api.sessionChanges.listen((UserModel? user) {
    store.reset();
    unawaited(feed.stop());
    if (user != null) {
      store.startPolling(onlinePollInterval);
      feed.start();
    }
  });
  ref.onDispose(() {
    unawaited(subscription.cancel());
    unawaited(feed.stop());
    store.reset();
  });
  return store;
});

final Provider<ApiAuthService> apiAuthServiceProvider =
    Provider<ApiAuthService>((Ref ref) => ApiAuthService(ref.watch(apiClientProvider)));

