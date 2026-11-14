import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/online/online_providers.dart';

/// What the shop is called in messages to customers: the store name from the
/// settings (the public store endpoint, so every role may read it). Without a
/// connection, or while the store is closed, the default name is used.
final FutureProvider<String> shopNameProvider = FutureProvider<String>((Ref ref) async {
  const String fallback = 'MQ Sports';
  try {
    final Object? name = (await ref.read(apiClientProvider).get('/v1/store/settings')).asMap['storeName'];
    return name is String && name.trim().isNotEmpty ? name.trim() : fallback;
  } catch (_) {
    return fallback;
  }
});
