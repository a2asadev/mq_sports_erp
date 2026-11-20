import 'package:drift/drift.dart';

// The device's copy of the server's data, as typed relational tables.
//
// They mirror the server's PostgreSQL tables (same names and columns, camelCase
// here). Only data the SERVER has confirmed is stored here: what the user did
// while offline waits in [Outbox] until it is uploaded, and the screens show
// both together (see lib/data/pending_effects.dart).
//
// An empty string means "none" for ids that can be absent (a top-level
// category's parentId, a ledger entry that belongs to no order), exactly as in
// the app's models and the API's JSON.

@DataClassName('UserRow')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get displayName => text().withDefault(const Constant(''))();
  TextColumn get phoneNumber => text().withDefault(const Constant(''))();
  TextColumn get role => text().withDefault(const Constant('staff'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get photoUrl => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get parentId => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get photoUrl => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('ProductRow')
@TableIndex(name: 'products_category', columns: <Symbol>{#categoryId})
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get categoryId => text()();
  TextColumn get brand => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  /// The photos as a JSON list (see ProductImage).
  TextColumn get imagesJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('VariantRow')
@TableIndex(name: 'variants_product', columns: <Symbol>{#productId})
@TableIndex(name: 'variants_sku', columns: <Symbol>{#sku})
class ProductVariants extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get sku => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get barcode => text().withDefault(const Constant(''))();
  // {"Size": "L", "Grip": "Rubber"}: kept as text so the order of the keys is kept.
  TextColumn get attributesJson => text().withDefault(const Constant('{}'))();
  RealColumn get costPrice => real().withDefault(const Constant(0))();
  RealColumn get salePrice => real().withDefault(const Constant(0))();
  BoolColumn get isWholesale => boolean().withDefault(const Constant(false))();
  RealColumn get wholesalePrice => real().withDefault(const Constant(0))();
  IntColumn get alertThreshold => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('VendorRow')
class Vendors extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text().withDefault(const Constant('other'))();
  TextColumn get contactPerson => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get city => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  RealColumn get openingBalance => real().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get photoUrl => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('CustomerRow')
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text().withDefault(const Constant('retail'))();
  TextColumn get contactPerson => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get city => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  RealColumn get creditLimit => real().withDefault(const Constant(0))();
  RealColumn get openingBalance => real().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get photoUrl => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('LedgerRow')
@TableIndex(name: 'ledger_party', columns: <Symbol>{#partyId})
@TableIndex(name: 'ledger_purchase', columns: <Symbol>{#purchaseId})
@TableIndex(name: 'ledger_order', columns: <Symbol>{#orderId})
class LedgerEntries extends Table {
  TextColumn get id => text()();
  TextColumn get partyType => text()();
  TextColumn get partyId => text()();
  TextColumn get entryType => text()();
  RealColumn get amount => real()();
  DateTimeColumn get entryDate => dateTime()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get reference => text().withDefault(const Constant(''))();
  TextColumn get paymentMethod => text().withDefault(const Constant(''))();
  TextColumn get paymentRef => text().withDefault(const Constant(''))();
  TextColumn get kind => text().withDefault(const Constant(''))();
  TextColumn get purchaseId => text().withDefault(const Constant(''))();
  TextColumn get orderId => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('PurchaseRow')
@TableIndex(name: 'purchases_vendor', columns: <Symbol>{#vendorId})
class Purchases extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseNo => text()();
  TextColumn get vendorId => text()();
  TextColumn get vendorName => text()();
  TextColumn get invoiceNo => text().withDefault(const Constant(''))();
  DateTimeColumn get purchaseDate => dateTime()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  RealColumn get totalAmount => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('PurchaseItemRow')
@TableIndex(name: 'purchase_items_purchase', columns: <Symbol>{#purchaseId})
class PurchaseItems extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseId => text()();
  TextColumn get productId => text()();
  TextColumn get variantId => text()();
  TextColumn get productName => text()();
  TextColumn get variantLabel => text()();
  TextColumn get sku => text()();
  IntColumn get quantity => integer()();
  RealColumn get unitCost => real()();
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('StockMovementRow')
@TableIndex(name: 'movements_variant', columns: <Symbol>{#variantId})
@TableIndex(name: 'movements_source', columns: <Symbol>{#sourceId})
class StockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get variantId => text()();
  TextColumn get sku => text()();
  IntColumn get quantity => integer()();
  TextColumn get movementType => text()();
  TextColumn get sourceId => text().withDefault(const Constant(''))();
  RealColumn get unitCost => real().withDefault(const Constant(0))();
  DateTimeColumn get movementDate => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('StockAuditRow')
class StockAudits extends Table {
  TextColumn get id => text()();
  TextColumn get auditNo => text()();
  DateTimeColumn get auditDate => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get countedById => text().withDefault(const Constant(''))();
  TextColumn get countedByName => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('StockAuditItemRow')
class StockAuditItems extends Table {
  TextColumn get auditId => text()();
  IntColumn get position => integer()();
  TextColumn get productId => text()();
  TextColumn get variantId => text()();
  TextColumn get productName => text()();
  TextColumn get variantLabel => text()();
  TextColumn get sku => text()();
  IntColumn get systemQuantity => integer()();
  IntColumn get countedQuantity => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{auditId, position};
}

@DataClassName('OrderRow')
@TableIndex(name: 'orders_customer', columns: <Symbol>{#customerId})
@TableIndex(name: 'orders_date', columns: <Symbol>{#orderDate})
class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get orderNo => text()();
  TextColumn get customerId => text()();
  TextColumn get customerName => text()();
  DateTimeColumn get orderDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get saleType => text().withDefault(const Constant('retail'))();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get shippingFee => real().withDefault(const Constant(0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0))();
  RealColumn get gstAmount => real().withDefault(const Constant(0))();
  RealColumn get vatAmount => real().withDefault(const Constant(0))();
  RealColumn get gstRate => real().withDefault(const Constant(0))();
  RealColumn get vatRate => real().withDefault(const Constant(0))();
  BoolColumn get taxInclusive => boolean().withDefault(const Constant(false))();
  TextColumn get shippingAddress => text().withDefault(const Constant(''))();
  TextColumn get channel => text().withDefault(const Constant('admin'))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('OrderItemRow')
@TableIndex(name: 'order_items_order', columns: <Symbol>{#orderId})
class OrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text()();
  TextColumn get productId => text()();
  TextColumn get variantId => text()();
  TextColumn get productName => text()();
  TextColumn get variantLabel => text()();
  TextColumn get sku => text()();
  IntColumn get quantity => integer()();
  RealColumn get unitPrice => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('OrderStatusRow')
class OrderStatusEntries extends Table {
  TextColumn get orderId => text()();
  IntColumn get position => integer()();
  TextColumn get status => text()();
  DateTimeColumn get changedAt => dateTime()();
  TextColumn get byUserId => text().withDefault(const Constant(''))();
  TextColumn get byName => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{orderId, position};
}

/// Things the user did that the server has not accepted yet, oldest first.
///
/// An entry is a COMMAND ("confirm this order", "rename this category"), not a
/// fake record: the stock, ledger and balance changes it will cause are worked
/// out from it for display, and replaced by the server's own records after it
/// is uploaded. That way nothing is ever counted twice.
@DataClassName('OutboxRow')
class Outbox extends Table {
  /// Upload order. Entries are sent oldest first because later ones can depend
  /// on earlier ones (an order for a customer created a moment before).
  IntColumn get seq => integer().autoIncrement()();

  /// Sent as the Idempotency-Key, so a retry after a dropped connection cannot
  /// do the action twice.
  TextColumn get opId => text().unique()();

  /// upsert, delete, order_confirm, order_status, order_cancel, order_payment,
  /// purchase_confirm, purchase_payment, ledger_entry, audit_confirm.
  TextColumn get kind => text()();
  TextColumn get collection => text()();
  TextColumn get entityId => text()();

  /// Short readable text for the sync screen, such as "Order ORD-20261114-AB12".
  TextColumn get label => text()();

  /// For upserts: true when the record did not exist on the server yet.
  BoolColumn get isNew => boolean().withDefault(const Constant(false))();
  TextColumn get payload => text()();

  /// pending: waiting to be uploaded. failed: the server refused it (see [error]).
  TextColumn get state => text().withDefault(const Constant('pending'))();
  TextColumn get error => text().withDefault(const Constant(''))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

/// Small facts about the sync: the cursor, when it last worked, the device id.
@DataClassName('SyncKvRow')
class SyncKv extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}
