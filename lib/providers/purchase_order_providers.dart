import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/models/purchase_order.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/purchase_orders_service.dart';
import 'package:a2_stocks/providers/core_providers.dart';

final Provider<PurchaseOrdersService> purchaseOrdersServiceProvider =
    Provider<PurchaseOrdersService>((Ref ref) => PurchaseOrdersService(ref.watch(apiClientProvider)));

/// The status the list is narrowed to; null = all.
final StateProvider<PurchaseOrderStatus?> purchaseOrderFilterProvider = StateProvider<PurchaseOrderStatus?>((Ref ref) => null);

/// What the search box says.
final StateProvider<String> purchaseOrderSearchProvider = StateProvider<String>((Ref ref) => '');

/// The purchase orders, newest first (read from the server; needs a connection).
final AutoDisposeFutureProvider<List<PurchaseOrder>> purchaseOrdersProvider = FutureProvider.autoDispose<List<PurchaseOrder>>((Ref ref) {
  ref.watch(syncTickProvider);
  return ref.watch(purchaseOrdersServiceProvider).list(
        status: ref.watch(purchaseOrderFilterProvider)?.name,
        search: ref.watch(purchaseOrderSearchProvider),
      );
});

/// One order with its lines and receipts.
final AutoDisposeFutureProviderFamily<PurchaseOrder, String> purchaseOrderProvider =
    FutureProvider.autoDispose.family<PurchaseOrder, String>((Ref ref, String id) {
  ref.watch(syncTickProvider);
  return ref.watch(purchaseOrdersServiceProvider).get(id);
});
