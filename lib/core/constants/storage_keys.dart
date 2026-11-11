/// Names shared by Hive boxes and Cloud Firestore collections.
/// Every top-level (aggregate root) entity has exactly one entry here.
class StorageKeys {
  const StorageKeys._();

  static const String activityLogs = 'activity_logs';
  static const String categories = 'categories';
  static const String customers = 'customers';
  static const String goodsReceiptNotes = 'goods_receipt_notes';
  static const String ledgers = 'ledgers';
  static const String orders = 'orders';
  static const String products = 'products';
  static const String purchaseOrders = 'purchase_orders';
  static const String purchases = 'purchases';
  static const String stockAudits = 'stock_audits';
  static const String stockLedgers = 'stock_ledgers';
  static const String users = 'users';
  static const String userProfiles = 'user_profiles';
  static const String vendors = 'vendors';
}
