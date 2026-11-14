import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/category_model.dart';
import 'package:mq_sports_erp/models/customer_model.dart';
import 'package:mq_sports_erp/models/ledger_model.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/payment_method.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/purchase_model.dart';
import 'package:mq_sports_erp/models/stock_audit_model.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/models/vendor_model.dart';
import 'package:mq_sports_erp/online/api_client.dart';

/// Times go to the server in UTC (the server's own clock is not the user's).
String _utc(DateTime time) => time.toUtc().toIso8601String();

/// Amounts have two decimals on the server; a Dart double such as
/// 0.1 + 0.2 must not be sent as 0.30000000000000004.
double _money(double amount) => (amount * 100).round() / 100;

/// Every write the app can ask of the server, as one call each.
///
/// The web app calls these straight from its repositories; the mobile and
/// desktop app calls them from the sync engine when it uploads queued actions.
/// Both therefore speak to the server in exactly the same way.
///
/// A call that carries a [key] is safe to repeat: the server answers a repeat
/// with its first answer instead of doing the action twice.
class ApiCommands {
  ApiCommands(this.api);

  final ApiClient api;

  // ---- records ------------------------------------------------------------

  /// Creates or changes a record of one of the editable collections.
  Future<void> upsert(
    String collection,
    Map<String, dynamic> map, {
    required bool isNew,
    String? key,
  }) async {
    switch (collection) {
      case StorageKeys.categories:
        return upsertCategory(CategoryModel.fromMap(map), isNew: isNew, key: key);
      case StorageKeys.products:
        return upsertProduct(ProductModel.fromMap(map), isNew: isNew, key: key);
      case StorageKeys.vendors:
        return upsertVendor(VendorModel.fromMap(map), isNew: isNew, key: key);
      case StorageKeys.customers:
        return upsertCustomer(CustomerModel.fromMap(map), isNew: isNew, key: key);
      case StorageKeys.users:
        return updateUser(UserModel.fromMap(map), key: key);
    }
    throw ValidationException('Records of "$collection" cannot be saved directly.');
  }

  Future<void> deleteRecord(String collection, String id, {String? key}) async {
    final String path = switch (collection) {
      StorageKeys.categories => '/v1/categories/$id',
      StorageKeys.products => '/v1/products/$id',
      StorageKeys.vendors => '/v1/vendors/$id',
      StorageKeys.customers => '/v1/customers/$id',
      StorageKeys.ledgers => '/v1/ledger/$id',
      StorageKeys.users => '/v1/users/$id',
      _ => throw ValidationException('Records of "$collection" cannot be deleted.'),
    };
    if (collection == StorageKeys.users) {
      // Users are never deleted (their history refers to them): turn the login off.
      await api.patch(path, body: <String, dynamic>{'isActive': false}, idempotencyKey: key);
      return;
    }
    await api.delete(path, idempotencyKey: key);
  }

  Future<void> upsertCategory(CategoryModel item, {required bool isNew, String? key}) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'name': item.name,
      'parentId': item.parentId,
      'description': item.description,
      'isActive': item.isActive,
    };
    if (isNew) {
      await api.post('/v1/categories', body: <String, dynamic>{'id': item.id, ...body}, idempotencyKey: key);
    } else {
      await api.patch('/v1/categories/${item.id}', body: body, idempotencyKey: key);
    }
  }

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

  Future<void> upsertProduct(ProductModel item, {required bool isNew, String? key}) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'id': item.id,
      'name': item.name,
      'categoryId': item.categoryId,
      'brand': item.brand,
      'description': item.description,
      'isActive': item.isActive,
      'variants': item.variants.map(variantBody).toList(),
    };
    if (isNew) {
      await api.post('/v1/products', body: body, idempotencyKey: key);
    } else {
      // The server replaces the product with its variants in one transaction.
      await api.put('/v1/products/${item.id}', body: body, idempotencyKey: key);
    }
  }

  Future<void> upsertVendor(VendorModel item, {required bool isNew, String? key}) async {
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
    if (isNew) {
      await api.post('/v1/vendors', body: <String, dynamic>{'id': item.id, ...body}, idempotencyKey: key);
    } else {
      await api.patch('/v1/vendors/${item.id}', body: body, idempotencyKey: key);
    }
  }

  Future<void> upsertCustomer(CustomerModel item, {required bool isNew, String? key}) async {
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
    if (isNew) {
      await api.post('/v1/customers', body: <String, dynamic>{'id': item.id, ...body}, idempotencyKey: key);
    } else {
      await api.patch('/v1/customers/${item.id}', body: body, idempotencyKey: key);
    }
  }

  /// A login is created through the users API (with its password); afterwards
  /// only the details change.
  Future<void> updateUser(UserModel item, {String? key}) async {
    await api.patch('/v1/users/${item.id}',
        body: <String, dynamic>{
          'displayName': item.displayName,
          'phoneNumber': item.phoneNumber,
          'role': item.role.name,
          'isActive': item.isActive,
        },
        idempotencyKey: key);
  }

  // ---- ledger -------------------------------------------------------------

  Map<String, dynamic> _payment(LedgerModel item) {
    final String defaultNote = 'Payment for ${item.reference}';
    final bool customNote = item.description.trim().isNotEmpty && item.description != defaultNote;
    return <String, dynamic>{
      'id': item.id,
      'amount': _money(item.amount),
      'date': _utc(item.entryDate),
      if (customNote) 'note': item.description,
    };
  }

  /// A manual vendor or customer ledger entry (cash received, an adjustment).
  Future<void> ledgerEntry(LedgerModel item, {String? key}) async {
    await api.post(
      '/v1/ledger',
      idempotencyKey: key,
      body: <String, dynamic>{
        'id': item.id,
        'partyType': item.partyType.name,
        'partyId': item.partyId,
        'entryType': item.entryType.name,
        'amount': _money(item.amount),
        'entryDate': _utc(item.entryDate),
        'description': item.description,
        'reference': item.reference,
        if (item.partyType == PartyType.customer && PaymentMethod.fromName(item.paymentMethod) != null)
          'paymentMethod': item.paymentMethod,
        if (item.partyType == PartyType.customer && item.paymentRef.trim().isNotEmpty)
          'paymentRef': item.paymentRef.trim(),
      },
    );
  }

  Future<void> purchasePayment(LedgerModel item, {String? key}) async {
    await api.post('/v1/purchases/${item.purchaseId}/payments', body: _payment(item), idempotencyKey: key);
  }

  Future<void> orderPayment(LedgerModel item, {String? key}) async {
    await api.post(
      '/v1/orders/${item.orderId}/payments',
      body: <String, dynamic>{
        ..._payment(item),
        if (PaymentMethod.fromName(item.paymentMethod) != null) 'paymentMethod': item.paymentMethod,
        if (item.paymentRef.trim().isNotEmpty) 'paymentRef': item.paymentRef.trim(),
      },
      idempotencyKey: key,
    );
  }

  // ---- purchases ----------------------------------------------------------

  Future<void> confirmPurchase(PurchaseModel purchase, double paidNow, {String? key}) async {
    await api.post(
      '/v1/purchases/confirm',
      idempotencyKey: key,
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
  }

  // ---- orders -------------------------------------------------------------

  /// [recordedOffline]: the sale already happened on a device without a
  /// connection, so the server records it even if the stock has run out since.
  Future<void> confirmOrder(
    OrderModel order,
    double paidNow, {
    List<PaymentLine> payments = const <PaymentLine>[],
    bool recordedOffline = false,
    String? key,
  }) async {
    await api.post(
      '/v1/orders/confirm',
      idempotencyKey: key,
      body: <String, dynamic>{
        'id': order.id,
        'orderNo': order.orderNo,
        'customerId': order.customerId,
        'saleType': order.saleType.name,
        'orderDate': _utc(order.orderDate),
        'channel': order.channel,
        'notes': order.notes,
        'discount': _money(order.discount),
        if (payments.isEmpty)
          'paidNow': _money(paidNow)
        else
          'payments': payments
              .map((PaymentLine p) => <String, dynamic>{
                    'method': p.method.name,
                    'amount': _money(p.amount),
                    if (p.reference.trim().isNotEmpty) 'reference': p.reference.trim(),
                  })
              .toList(),
        if (recordedOffline) 'recordedOffline': true,
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
  }

  /// Moves the order forward to [status] (the server steps through the pipeline).
  Future<void> setOrderStatus(String orderId, OrderStatus status, {String? key}) async {
    await api.post('/v1/orders/$orderId/status',
        body: <String, dynamic>{'status': status.name}, idempotencyKey: key);
  }

  Future<void> cancelOrder(String orderId, {String? key}) async {
    await api.post('/v1/orders/$orderId/cancel', idempotencyKey: key);
  }

  // ---- stock counts -------------------------------------------------------

  /// The server measures each count against the stock at that moment, so only
  /// what was counted is sent.
  Future<void> confirmAudit(StockAuditModel audit, {String? key}) async {
    await api.post(
      '/v1/stock-audits/confirm',
      idempotencyKey: key,
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
  }
}
