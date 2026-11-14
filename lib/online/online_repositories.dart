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
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/models/vendor_model.dart';
import 'package:mq_sports_erp/online/api_client.dart';
import 'package:mq_sports_erp/online/remote_store.dart';
import 'package:mq_sports_erp/repositories/repository.dart';

/// Times go to the server in UTC (the server's own clock is not the user's).
String _utc(DateTime time) => time.toUtc().toIso8601String();

/// Amounts have two decimals on the server; a Dart double such as
/// 0.1 + 0.2 must not be sent as 0.30000000000000004.
double _money(double amount) => (amount * 100).round() / 100;

/// The base of every online repository. Reads come from the in-memory copy of
/// the server's data; a write goes to the server and then the copy is brought
/// up to date, so what the screens show is what the server saved.
abstract class OnlineRepository<T extends SyncableModel> implements Repository<T> {
  OnlineRepository({
    required this.api,
    required this.store,
    required this.collectionName,
    required this.fromMap,
  });

  final ApiClient api;
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
      : super(
          api: api,
          store: store,
          collectionName: StorageKeys.categories,
          fromMap: CategoryModel.fromMap,
        );

  @override
  Future<void> write(CategoryModel item, {required bool exists}) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'name': item.name,
      'parentId': item.parentId,
      'description': item.description,
      'isActive': item.isActive,
    };
    if (exists) {
      await api.patch('/v1/categories/${item.id}', body: body);
    } else {
      await api.post('/v1/categories', body: <String, dynamic>{'id': item.id, ...body});
    }
  }

  @override
  Future<void> remove(String id) async {
    await api.delete('/v1/categories/$id');
  }
}

class OnlineProductRepository extends OnlineRepository<ProductModel> {
  OnlineProductRepository(ApiClient api, RemoteStore store)
      : super(
          api: api,
          store: store,
          collectionName: StorageKeys.products,
          fromMap: ProductModel.fromMap,
        );

  static Map<String, dynamic> variantBody(VariantModel v) => <String, dynamic>{
        'id': v.id,
        'sku': v.sku,
        'name': v.name,
        'barcode': v.barcode,
        'attributes': v.attributes,
        'costPrice': _money(v.costPrice),
        'salePrice': _money(v.salePrice),
        'isWholesale': v.isWholesale,
        'wholesalePrice': _money(v.wholesalePrice),
        'alertThreshold': v.alertThreshold,
        'isActive': v.isActive,
      };

  @override
  Future<void> write(ProductModel item, {required bool exists}) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'id': item.id,
      'name': item.name,
      'categoryId': item.categoryId,
      'brand': item.brand,
      'description': item.description,
      'isActive': item.isActive,
      'variants': item.variants.map(variantBody).toList(),
    };
    if (exists) {
      // The server replaces the product with its variants in one transaction.
      await api.put('/v1/products/${item.id}', body: body);
    } else {
      await api.post('/v1/products', body: body);
    }
  }

  @override
  Future<void> remove(String id) async {
    await api.delete('/v1/products/$id');
  }
}

class OnlineVendorRepository extends OnlineRepository<VendorModel> {
  OnlineVendorRepository(ApiClient api, RemoteStore store)
      : super(
          api: api,
          store: store,
          collectionName: StorageKeys.vendors,
          fromMap: VendorModel.fromMap,
        );

  @override
  Future<void> write(VendorModel item, {required bool exists}) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'name': item.name,
      'type': item.type.name,
      'contactPerson': item.contactPerson,
      'phone': item.phone,
      'email': item.email,
      'address': item.address,
      'city': item.city,
      'notes': item.notes,
      'openingBalance': _money(item.openingBalance),
      'isActive': item.isActive,
    };
    if (exists) {
      await api.patch('/v1/vendors/${item.id}', body: body);
    } else {
      await api.post('/v1/vendors', body: <String, dynamic>{'id': item.id, ...body});
    }
  }

  @override
  Future<void> remove(String id) async {
    await api.delete('/v1/vendors/$id');
  }
}

class OnlineCustomerRepository extends OnlineRepository<CustomerModel> {
  OnlineCustomerRepository(ApiClient api, RemoteStore store)
      : super(
          api: api,
          store: store,
          collectionName: StorageKeys.customers,
          fromMap: CustomerModel.fromMap,
        );

  @override
  Future<void> write(CustomerModel item, {required bool exists}) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'name': item.name,
      'type': item.type.name,
      'contactPerson': item.contactPerson,
      'phone': item.phone,
      'email': item.email,
      'address': item.address,
      'city': item.city,
      'notes': item.notes,
      'creditLimit': _money(item.creditLimit),
      'openingBalance': _money(item.openingBalance),
      'isActive': item.isActive,
    };
    if (exists) {
      await api.patch('/v1/customers/${item.id}', body: body);
    } else {
      await api.post('/v1/customers', body: <String, dynamic>{'id': item.id, ...body});
    }
  }

  @override
  Future<void> remove(String id) async {
    await api.delete('/v1/customers/$id');
  }
}

/// Ledger entries. Entries that belong to a purchase or an order are payments
/// on it, which the server records through that purchase's or order's own
/// action (it checks the amount against what is still due).
class OnlineLedgerRepository extends OnlineRepository<LedgerModel> {
  OnlineLedgerRepository(ApiClient api, RemoteStore store)
      : super(
          api: api,
          store: store,
          collectionName: StorageKeys.ledgers,
          fromMap: LedgerModel.fromMap,
        );

  @override
  Future<void> write(LedgerModel item, {required bool exists}) async {
    if (exists) {
      throw unsupported('Ledger entries cannot be edited. Delete the entry and add it again.');
    }
    final String defaultNote = 'Payment for ${item.reference}';
    final bool customNote = item.description.trim().isNotEmpty && item.description != defaultNote;
    final Map<String, dynamic> payment = <String, dynamic>{
      'id': item.id,
      'amount': _money(item.amount),
      'date': _utc(item.entryDate),
      if (customNote) 'note': item.description,
    };
    if (item.purchaseId.isNotEmpty) {
      await api.post('/v1/purchases/${item.purchaseId}/payments', body: payment);
    } else if (item.orderId.isNotEmpty) {
      await api.post('/v1/orders/${item.orderId}/payments', body: payment);
    } else {
      await api.post('/v1/ledger', body: <String, dynamic>{
        'id': item.id,
        'partyType': item.partyType.name,
        'partyId': item.partyId,
        'entryType': item.entryType.name,
        'amount': _money(item.amount),
        'entryDate': _utc(item.entryDate),
        'description': item.description,
        'reference': item.reference,
      });
    }
  }

  @override
  Future<void> remove(String id) async {
    await api.delete('/v1/ledger/$id');
  }
}

/// Stock movements are only ever created by purchases, sales and stock counts.
class OnlineStockLedgerRepository extends OnlineRepository<StockLedgerModel> {
  OnlineStockLedgerRepository(ApiClient api, RemoteStore store)
      : super(
          api: api,
          store: store,
          collectionName: StorageKeys.stockLedgers,
          fromMap: StockLedgerModel.fromMap,
        );

  static const String _message =
      'Stock changes only through purchases, sales and stock counts.';

  @override
  Future<void> write(StockLedgerModel item, {required bool exists}) =>
      Future<void>.error(unsupported(_message));

  @override
  Future<void> remove(String id) => Future<void>.error(unsupported(_message));
}

class OnlinePurchaseRepository extends OnlineRepository<PurchaseModel>
    implements PurchaseOperations {
  OnlinePurchaseRepository(ApiClient api, RemoteStore store)
      : super(
          api: api,
          store: store,
          collectionName: StorageKeys.purchases,
          fromMap: PurchaseModel.fromMap,
        );

  @override
  Future<void> confirm(PurchaseModel purchase, {required double paidNow}) async {
    await store.ensureLoaded();
    await api.post(
      '/v1/purchases/confirm',
      // The id as the key: a repeat after a dropped connection is not a second purchase.
      idempotencyKey: 'purchase-${purchase.id}',
      body: <String, dynamic>{
        'id': purchase.id,
        'purchaseNo': purchase.purchaseNo,
        'vendorId': purchase.vendorId,
        'purchaseDate': _utc(purchase.purchaseDate),
        'invoiceNo': purchase.invoiceNo,
        'notes': purchase.notes,
        'paidNow': _money(paidNow),
        'items': purchase.items
            .map((PurchaseItem i) => <String, dynamic>{
                  'id': i.id,
                  'productId': i.productId,
                  'variantId': i.variantId,
                  'quantity': i.quantity,
                  'unitCost': _money(i.unitCost),
                })
            .toList(),
      },
    );
    await refreshAfterWrite();
  }

  @override
  Future<void> write(PurchaseModel item, {required bool exists}) => Future<void>.error(
      unsupported('A confirmed purchase cannot be changed.'));

  @override
  Future<void> remove(String id) =>
      Future<void>.error(unsupported('A confirmed purchase cannot be deleted.'));
}

class OnlineOrderRepository extends OnlineRepository<OrderModel>
    implements OrderOperations {
  OnlineOrderRepository(ApiClient api, RemoteStore store)
      : super(
          api: api,
          store: store,
          collectionName: StorageKeys.orders,
          fromMap: OrderModel.fromMap,
        );

  @override
  Future<void> confirm(OrderModel order, {required double paidNow}) async {
    await store.ensureLoaded();
    await api.post(
      '/v1/orders/confirm',
      idempotencyKey: 'order-${order.id}',
      body: <String, dynamic>{
        'id': order.id,
        'orderNo': order.orderNo,
        'customerId': order.customerId,
        'saleType': order.saleType.name,
        'orderDate': _utc(order.orderDate),
        'notes': order.notes,
        'discount': _money(order.discount),
        'paidNow': _money(paidNow),
        'items': order.items
            .map((OrderItem i) => <String, dynamic>{
                  'id': i.id,
                  'productId': i.productId,
                  'variantId': i.variantId,
                  'quantity': i.quantity,
                  'unitPrice': _money(i.unitPrice),
                  'discount': _money(i.discount),
                })
            .toList(),
      },
    );
    await refreshAfterWrite();
  }

  @override
  Future<void> cancel(OrderModel cancelled, {required DateTime when}) async {
    await api.post('/v1/orders/${cancelled.id}/cancel');
    await refreshAfterWrite();
  }

  /// The only edit of an existing order is moving it along the pipeline.
  @override
  Future<void> write(OrderModel item, {required bool exists}) async {
    if (!exists) {
      throw unsupported('An order is created by confirming it.');
    }
    await api.post('/v1/orders/${item.id}/status', body: <String, dynamic>{
      'status': item.status.name,
    });
  }

  @override
  Future<void> remove(String id) =>
      Future<void>.error(unsupported('An order cannot be deleted. Cancel it instead.'));
}

class OnlineStockAuditRepository extends OnlineRepository<StockAuditModel>
    implements StockAuditOperations {
  OnlineStockAuditRepository(ApiClient api, RemoteStore store)
      : super(
          api: api,
          store: store,
          collectionName: StorageKeys.stockAudits,
          fromMap: StockAuditModel.fromMap,
        );

  /// The server measures each count against the stock at that moment, so only
  /// what was counted is sent.
  @override
  Future<void> confirm(StockAuditModel audit) async {
    await store.ensureLoaded();
    await api.post(
      '/v1/stock-audits/confirm',
      idempotencyKey: 'audit-${audit.id}',
      body: <String, dynamic>{
        'id': audit.id,
        'auditNo': audit.auditNo,
        'auditDate': _utc(audit.auditDate),
        'note': audit.note,
        'counts': audit.items
            .map((StockAuditItem i) => <String, dynamic>{
                  'variantId': i.variantId,
                  'countedQuantity': i.countedQuantity,
                })
            .toList(),
      },
    );
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
      : super(
          api: api,
          store: store,
          collectionName: StorageKeys.users,
          fromMap: UserModel.fromMap,
        );

  @override
  Future<void> write(UserModel item, {required bool exists}) async {
    if (!exists) {
      throw unsupported('Users are created with a login (email and password).');
    }
    await api.patch('/v1/users/${item.id}', body: <String, dynamic>{
      'displayName': item.displayName,
      'phoneNumber': item.phoneNumber,
      'role': item.role.name,
      'isActive': item.isActive,
    });
  }

  @override
  Future<void> remove(String id) async {
    await api.patch('/v1/users/$id', body: <String, dynamic>{'isActive': false});
  }
}
