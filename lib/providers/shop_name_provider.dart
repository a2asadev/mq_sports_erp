import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/providers/pos_providers.dart';

/// What the shop is called in messages to customers (see [shopInfoProvider]).
final FutureProvider<String> shopNameProvider =
    FutureProvider<String>((Ref ref) async => (await ref.watch(shopInfoProvider.future)).name);
