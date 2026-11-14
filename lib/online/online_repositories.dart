import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/category_model.dart';
import 'package:mq_sports_erp/models/customer_model.dart';
import 'package:mq_sports_erp/models/ledger_model.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/purchase_model.dart';
import 'package:mq_sports_erp/models/stock_audit_model.dart';
import 'package:mq_sports_erp/models/stock_ledger_model.dart';
import 'package:mq_sports_erp/models/syncable_model.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/vendor_model.dart';
import 'package:mq_sports_erp/online/api_client.dart';
import 'package:mq_sports_erp/online/api_commands.dart';
import 'package:mq_sports_erp/online/remote_store.dart';
import 'package:mq_sports_erp/repositories/repository.dart';

/// The base of every online repository (the web app). Reads come from the
/// in-memory copy of the server's data; a write goes to the server and then the
/// copy is brought up to date, so what the screens show is what the server saved.
abstract class OnlineRepository<T extends SyncableModel> implements Repository<T> {
  OnlineRepository({
    required ApiClient api,
    required this.store,
    required this.collectionName,
    required this.fromMap,
  })  : api = api,
        commands = ApiCommands(api);

  final ApiClient api;
  final ApiCommands commands;
  final RemoteStore store;
  final T Function(JsonMap map) fromMap;

  @override
  final String collectionName;

  @override
  Future<List<T>> getLocal() async {
    await store.ensureLoaded();
    return store.list(collectionName).map(fromMap).toList();
  }

  @override
  Future<T?> getLocalById(String id) async {
    await store.ensureLoaded();
    final JsonMap? map = store.byId(collectionName, id);
    return map == null ? null : fromMap(map);
  }

  /// The server checks every delete and answers with the reason when it
  /// refuses, so there is nothing to check here first.
  @override
  Future<String?> deleteBlockReason(String id) async => null;

  @override
  Future<void> save(T item, {String groupId = ''}) async {
    await store.ensureLoaded();
    final bool exists = store.byId(collectionName, item.id) != null;
    await write(item, exists: exists);
    await refreshAfterWrite();
  }

  @override
  Future<void> delete(String id) async {
    await remove(id);
    await refreshAfterWrite();
  }

  /// Creates [item] on the server, or updates it when [exists].
  Future<void> write(T item, {required bool exists});

  Future<void> remove(String id);

  /// Brings the copy up to date. A failure here is not the write's failure
  /// (the write succeeded); the next periodic refresh catches up.
  Future<void> refreshAfterWrite() async {
    try {
      await store.refresh();
    } on AppException {
      return;
    }
  }

  /// A record that is created by an action (a confirm), never saved directly.
  ValidationException unsupported(String what) => ValidationException(what);
}

class OnlineCategoryRepository extends OnlineRepository<CategoryModel> {
  OnlineCategoryRepository(ApiClient api, RemoteStore store)
      : super(api: api, store: store, collectionName: StorageKeys.categories, fromMap: CategoryModel.fromMap);

  @override
  Future<void> write(CategoryModel item, {required bool exists}) =>
      commands.upsertCategory(item, isNew: !exists);

  @override
  Future<void> remove(String id) => commands.deleteRecord(StorageKeys.categories, id);
}

class OnlineProductRepository extends OnlineRepository<ProductModel> {
  OnlineProductRepository(ApiClient api, RemoteStore store)
      : super(api: api, store: store, collectionName: StorageKeys.products, fromMap: ProductModel.fromMap);

  @override
  Future<void> write(ProductModel item, {required bool exists}) =>
      commands.upsertProduct(item, isNew: !exists);

  @override
  Future<void> remove(String id) => commands.deleteRecord(StorageKeys.products, id);
}

class OnlineVendorRepository extends OnlineRepository<VendorModel> {
  OnlineVendorRepository(ApiClient api, RemoteStore store)
      : super(api: api, store: store, collectionName: StorageKeys.vendors, fromMap: VendorModel.fromMap);

  @override
  Future<void> write(VendorModel item, {required bool exists}) =>
      commands.upsertVendor(item, isNew: !exists);

  @override
  Future<void> remove(String id) => commands.deleteRecord(StorageKeys.vendors, id);
}

class OnlineCustomerRepository extends OnlineRepository<CustomerModel> {
  OnlineCustomerRepository(ApiClient api, RemoteStore store)
      : super(api: api, store: store, collectionName: StorageKeys.customers, fromMap: CustomerModel.fromMap);

  @override
  Future<void> write(CustomerModel item, {required bool exists}) =>
      commands.upsertCustomer(item, isNew: !exists);

  @override
  Future<void> remove(String id) => commands.deleteRecord(StorageKeys.customers, id);
}

/// Ledger entries. Entries that belong to a purchase or an order are payments
/// on it, which the server records through that purchase's or order's own
/// action (it checks the amount against what is still due).
class OnlineLedgerRepository extends OnlineRepository<LedgerModel> {
  OnlineLedgerRepository(ApiClient api, RemoteStore store)
      : super(api: api, store: store, collectionName: StorageKeys.ledgers, fromMap: LedgerModel.fromMap);

  @override
  Future<void> write(LedgerModel item, {required bool exists}) {
    if (exists) {
      throw unsupported('Ledger entries cannot be edited. Delete the entry and add it again.');
    }
    if (item.purchaseId.isNotEmpty) {
      return commands.purchasePayment(item);
    }
    if (item.orderId.isNotEmpty) {
      return commands.orderPayment(item);
    }
    return commands.ledgerEntry(item);
  }

  @override
  Future<void> remove(String id) => commands.deleteRecord(StorageKeys.ledgers, id);
}

/// Stock movements are only ever created by purchases, sales and stock counts.
class OnlineStockLedgerRepository extends OnlineRepository<StockLedgerModel> {
  OnlineStockLedgerRepository(ApiClient api, RemoteStore store)
      : super(api: api, store: store, collectionName: StorageKeys.stockLedgers, fromMap: StockLedgerModel.fromMap);

  static const String _message = 'Stock changes only through purchases, sales and stock counts.';

  @override
  Future<void> write(StockLedgerModel item, {required bool exists}) =>
      Future<void>.error(unsupported(_message));

  @override
  Future<void> remove(String id) => Future<void>.error(unsupported(_message));
}

class OnlinePurchaseRepository extends OnlineRepository<PurchaseModel> implements PurchaseOperations {
  OnlinePurchaseRepository(ApiClient api, RemoteStore store)
      : super(api: api, store: store, collectionName: StorageKeys.purchases, fromMap: PurchaseModel.fromMap);

  @override
  Future<void> confirm(PurchaseModel purchase, {required double paidNow}) async {
    await store.ensureLoaded();
    // The id as the key: a repeat after a dropped connection is not a second purchase.
    await commands.confirmPurchase(purchase, paidNow, key: 'purchase-${purchase.id}');
    await refreshAfterWrite();
  }

  @override
  Future<void> write(PurchaseModel item, {required bool exists}) =>
      Future<void>.error(unsupported('A confirmed purchase cannot be changed.'));

  @override
  Future<void> remove(String id) =>
      Future<void>.error(unsupported('A confirmed purchase cannot be deleted.'));
}

class OnlineOrderRepository extends OnlineRepository<OrderModel> implements OrderOperations {
  OnlineOrderRepository(ApiClient api, RemoteStore store)
      : super(api: api, store: store, collectionName: StorageKeys.orders, fromMap: OrderModel.fromMap);

  @override
  Future<void> confirm(OrderModel order, {required double paidNow}) async {
    await store.ensureLoaded();
    await commands.confirmOrder(order, paidNow, key: 'order-${order.id}');
    await refreshAfterWrite();
  }

  @override
  Future<void> cancel(OrderModel cancelled, {required DateTime when}) async {
    await commands.cancelOrder(cancelled.id);
    await refreshAfterWrite();
  }

  /// The only edit of an existing order is moving it along the pipeline.
  @override
  Future<void> write(OrderModel item, {required bool exists}) {
    if (!exists) {
      throw unsupported('An order is created by confirming it.');
    }
    return commands.setOrderStatus(item.id, item.status);
  }

  @override
  Future<void> remove(String id) =>
      Future<void>.error(unsupported('An order cannot be deleted. Cancel it instead.'));
}

class OnlineStockAuditRepository extends OnlineRepository<StockAuditModel>
    implements StockAuditOperations {
  OnlineStockAuditRepository(ApiClient api, RemoteStore store)
      : super(api: api, store: store, collectionName: StorageKeys.stockAudits, fromMap: StockAuditModel.fromMap);

  @override
  Future<void> confirm(StockAuditModel audit) async {
    await store.ensureLoaded();
    await commands.confirmAudit(audit, key: 'audit-${audit.id}');
    await refreshAfterWrite();
  }

  @override
  Future<void> write(StockAuditModel item, {required bool exists}) =>
      Future<void>.error(unsupported('A stock count is created by confirming it.'));

  @override
  Future<void> remove(String id) =>
      Future<void>.error(unsupported('A stock count cannot be deleted.'));
}

/// Users. A login is created through [ApiAuthAdminService]; this saves the
/// details afterwards. Users are never deleted (their history refers to them):
/// "delete" turns the login off, which has the same effect for the person.
class OnlineUserRepository extends OnlineRepository<UserModel> {
  OnlineUserRepository(ApiClient api, RemoteStore store)
      : super(api: api, store: store, collectionName: StorageKeys.users, fromMap: UserModel.fromMap);

  @override
  Future<void> write(UserModel item, {required bool exists}) {
    if (!exists) {
      throw unsupported('Users are created with a login (email and password).');
    }
    return commands.updateUser(item);
  }

  @override
  Future<void> remove(String id) => commands.deleteRecord(StorageKeys.users, id);
}
