import 'package:a2_stocks/models/user_role.dart';

/// What a manager or a member of staff may do. The admin of a business switches these per role (Permissions page);
/// the server decides and tells the app what the signed-in person may do now, and the app shows and allows only
/// that. An admin can always do everything. The names are the server's (`src/permissions/permissions.ts`).
class Permissions {
  const Permissions._();

  static const String dashboardView = 'dashboard.view';
  static const String reportsView = 'reports.view';
  static const String ordersCancel = 'orders.cancel';
  static const String returnsManage = 'returns.manage';
  static const String promotionsManage = 'promotions.manage';
  static const String customersManage = 'customers.manage';
  static const String catalogManage = 'catalog.manage';
  static const String stockAudit = 'stock.audit';
  static const String purchasingManage = 'purchasing.manage';
  static const String expensesManage = 'expenses.manage';

  /// In the order the Permissions page lists them.
  static const List<String> all = <String>[
    dashboardView,
    reportsView,
    ordersCancel,
    returnsManage,
    promotionsManage,
    customersManage,
    catalogManage,
    stockAudit,
    purchasingManage,
    expensesManage,
  ];

  /// What the product gives a role before the admin changes anything: managers everything, staff nothing. Used until
  /// the server has said (a session saved before permissions existed) and by the tests.
  static bool defaultAllows(UserRole role, String key) => role == UserRole.admin || (role == UserRole.manager && all.contains(key));

  /// The permissions that decide which records the server sends to the device (vendors and purchases, stock audits).
  /// When one of these changes the device downloads everything again.
  static const List<String> affectSync = <String>[purchasingManage, stockAudit];
}
