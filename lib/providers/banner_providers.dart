import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/models/store_banner.dart';
import 'package:a2_stocks/online/banners_service.dart';
import 'package:a2_stocks/online/online_providers.dart';

final Provider<BannersService> bannersServiceProvider = Provider<BannersService>((Ref ref) => BannersService(ref.watch(apiClientProvider)));

/// The store's banners, for the page that keeps them (admin and manager; needs a connection).
final AutoDisposeFutureProvider<List<StoreBanner>> bannersProvider = FutureProvider.autoDispose<List<StoreBanner>>((Ref ref) => ref.watch(bannersServiceProvider).list());
