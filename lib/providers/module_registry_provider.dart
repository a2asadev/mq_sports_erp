import 'package:a2_stocks/core/permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/erp_module.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/providers/users_providers.dart';
import 'package:a2_stocks/screens/catalog/categories_screen.dart';
import 'package:a2_stocks/screens/catalog/products_screen.dart';
import 'package:a2_stocks/screens/expenses/expenses_screen.dart';
import 'package:a2_stocks/screens/labels/labels_screen.dart';
import 'package:a2_stocks/screens/logs/activity_logs_screen.dart';
import 'package:a2_stocks/screens/parties/customers_screen.dart';
import 'package:a2_stocks/screens/pos/pos_screen.dart';
import 'package:a2_stocks/screens/banners/banners_screen.dart';
import 'package:a2_stocks/screens/customers/customer_insights_screen.dart';
import 'package:a2_stocks/screens/permissions/permissions_screen.dart';
import 'package:a2_stocks/screens/sales/web_orders_screen.dart';
import 'package:a2_stocks/screens/promotions/promotions_screen.dart';
import 'package:a2_stocks/screens/purchasing/purchase_orders_screen.dart';
import 'package:a2_stocks/screens/purchasing/reorder_screen.dart';
import 'package:a2_stocks/screens/purchasing/purchases_screen.dart';
import 'package:a2_stocks/screens/register/register_screen.dart';
import 'package:a2_stocks/screens/reports/reports_screen.dart';
import 'package:a2_stocks/screens/settings/settings_screen.dart';
import 'package:a2_stocks/screens/sales/orders_screen.dart';
import 'package:a2_stocks/screens/stock/stock_screen.dart';
import 'package:a2_stocks/screens/parties/vendors_screen.dart';
import 'package:a2_stocks/screens/users/users_screen.dart';

/// Registry of every ERP module. Each new module appends one `ErpModule`.
final Provider<List<ErpModule>> erpModulesProvider =
    Provider<List<ErpModule>>((Ref ref) {
  return <ErpModule>[
    ErpModule(
      id: 'categories',
      group: ModuleGroup.inventory,
      title: (AppLocalizations l10n) => l10n.moduleCategories,
      icon: Icons.category_outlined,
      allowedRoles: const <UserRole>{
        UserRole.admin,
        UserRole.manager,
        UserRole.staff,
      },
      builder: (BuildContext context) => const CategoriesScreen(),
    ),
    ErpModule(
      id: 'products',
      group: ModuleGroup.inventory,
      title: (AppLocalizations l10n) => l10n.moduleProducts,
      icon: Icons.inventory_2_outlined,
      allowedRoles: const <UserRole>{
        UserRole.admin,
        UserRole.manager,
        UserRole.staff,
      },
      builder: (BuildContext context) => const ProductsScreen(),
    ),
    ErpModule(
      id: 'customers',
      group: ModuleGroup.sales,
      title: (AppLocalizations l10n) => l10n.moduleCustomers,
      icon: Icons.groups_outlined,
      allowedRoles: const <UserRole>{
        UserRole.admin,
        UserRole.manager,
        UserRole.staff,
      },
      builder: (BuildContext context) => const CustomersScreen(),
    ),
    ErpModule(
      id: 'vendors',
      group: ModuleGroup.purchasing,
      title: (AppLocalizations l10n) => l10n.moduleVendors,
      icon: Icons.local_shipping_outlined,
      allowedRoles: const <UserRole>{UserRole.admin, UserRole.manager},
      permission: Permissions.purchasingManage,
      builder: (BuildContext context) => const VendorsScreen(),
    ),
    ErpModule(
      id: 'reorder',
      group: ModuleGroup.purchasing,
      title: (AppLocalizations l10n) => l10n.moduleReorder,
      icon: Icons.playlist_add_check_outlined,
      allowedRoles: const <UserRole>{UserRole.admin, UserRole.manager},
      permission: Permissions.purchasingManage,
      builder: (BuildContext context) => const ReorderScreen(),
    ),
    ErpModule(
      id: 'purchase_orders',
      group: ModuleGroup.purchasing,
      title: (AppLocalizations l10n) => l10n.modulePurchaseOrders,
      icon: Icons.assignment_outlined,
      allowedRoles: const <UserRole>{UserRole.admin, UserRole.manager},
      permission: Permissions.purchasingManage,
      builder: (BuildContext context) => const PurchaseOrdersScreen(),
    ),
    ErpModule(
      id: 'purchases',
      group: ModuleGroup.purchasing,
      title: (AppLocalizations l10n) => l10n.modulePurchases,
      icon: Icons.shopping_cart_checkout_outlined,
      allowedRoles: const <UserRole>{UserRole.admin, UserRole.manager},
      permission: Permissions.purchasingManage,
      builder: (BuildContext context) => const PurchasesScreen(),
    ),
    ErpModule(
      id: 'banners',
      group: ModuleGroup.sales,
      title: (AppLocalizations l10n) => l10n.moduleBanners,
      icon: Icons.view_carousel_outlined,
      allowedRoles: const <UserRole>{UserRole.admin, UserRole.manager},
      needsOnlineStore: true,
      builder: (BuildContext context) => const BannersScreen(),
    ),
    ErpModule(
      id: 'web_orders',
      group: ModuleGroup.sales,
      title: (AppLocalizations l10n) => l10n.moduleWebOrders,
      icon: Icons.storefront_outlined,
      allowedRoles: const <UserRole>{UserRole.admin, UserRole.manager, UserRole.staff},
      builder: (BuildContext context) => const WebOrdersScreen(),
    ),
    ErpModule(
      id: 'customer_insights',
      group: ModuleGroup.sales,
      title: (AppLocalizations l10n) => l10n.moduleCustomerInsights,
      icon: Icons.insights_outlined,
      allowedRoles: const <UserRole>{UserRole.admin, UserRole.manager},
      permission: Permissions.reportsView,
      builder: (BuildContext context) => const CustomerInsightsScreen(),
    ),
    ErpModule(
      id: 'promotions',
      group: ModuleGroup.sales,
      title: (AppLocalizations l10n) => l10n.modulePromotions,
      icon: Icons.local_offer_outlined,
      allowedRoles: const <UserRole>{UserRole.admin, UserRole.manager},
      permission: Permissions.promotionsManage,
      builder: (BuildContext context) => const PromotionsScreen(),
    ),
    ErpModule(
      id: 'reports',
      group: ModuleGroup.sales,
      title: (AppLocalizations l10n) => l10n.moduleReports,
      icon: Icons.bar_chart_outlined,
      allowedRoles: const <UserRole>{UserRole.admin, UserRole.manager},
      permission: Permissions.reportsView,
      builder: (BuildContext context) => const ReportsScreen(),
    ),
    ErpModule(
      id: 'expenses',
      group: ModuleGroup.purchasing,
      title: (AppLocalizations l10n) => l10n.moduleExpenses,
      icon: Icons.request_quote_outlined,
      allowedRoles: const <UserRole>{UserRole.admin, UserRole.manager},
      permission: Permissions.expensesManage,
      builder: (BuildContext context) => const ExpensesScreen(),
    ),
    ErpModule(
      id: 'pos',
      group: ModuleGroup.main,
      title: (AppLocalizations l10n) => l10n.modulePos,
      icon: Icons.point_of_sale,
      allowedRoles: const <UserRole>{
        UserRole.admin,
        UserRole.manager,
        UserRole.staff,
      },
      builder: (BuildContext context) => const PosScreen(),
    ),
    ErpModule(
      id: 'sales',
      group: ModuleGroup.sales,
      title: (AppLocalizations l10n) => l10n.moduleSalesOrders,
      icon: Icons.point_of_sale_outlined,
      allowedRoles: const <UserRole>{
        UserRole.admin,
        UserRole.manager,
        UserRole.staff,
      },
      builder: (BuildContext context) => const OrdersScreen(),
    ),
    ErpModule(
      id: 'labels',
      group: ModuleGroup.inventory,
      title: (AppLocalizations l10n) => l10n.moduleLabels,
      icon: Icons.label_outline,
      allowedRoles: const <UserRole>{UserRole.admin, UserRole.manager, UserRole.staff},
      builder: (BuildContext context) => const LabelsScreen(),
    ),
    ErpModule(
      id: 'stock',
      group: ModuleGroup.inventory,
      title: (AppLocalizations l10n) => l10n.moduleStock,
      icon: Icons.warehouse_outlined,
      allowedRoles: const <UserRole>{
        UserRole.admin,
        UserRole.manager,
        UserRole.staff,
      },
      builder: (BuildContext context) => const StockScreen(),
    ),
    ErpModule(
      id: 'register',
      group: ModuleGroup.sales,
      title: (AppLocalizations l10n) => l10n.moduleCashRegister,
      icon: Icons.account_balance_wallet_outlined,
      allowedRoles: const <UserRole>{
        UserRole.admin,
        UserRole.manager,
        UserRole.staff,
      },
      needsRegister: true,
      builder: (BuildContext context) => const RegisterScreen(),
    ),
    ErpModule(
      id: 'logs',
      group: ModuleGroup.system,
      title: (AppLocalizations l10n) => l10n.moduleActivityLogs,
      icon: Icons.history_outlined,
      allowedRoles: const <UserRole>{UserRole.admin},
      builder: (BuildContext context) => const ActivityLogsScreen(),
    ),
    ErpModule(
      id: 'settings',
      group: ModuleGroup.system,
      title: (AppLocalizations l10n) => l10n.moduleSettings,
      icon: Icons.settings_outlined,
      allowedRoles: const <UserRole>{
        UserRole.admin,
        UserRole.manager,
        UserRole.staff,
      },
      builder: (BuildContext context) => const SettingsScreen(),
    ),
    ErpModule(
      id: 'permissions',
      group: ModuleGroup.system,
      title: (AppLocalizations l10n) => l10n.modulePermissions,
      icon: Icons.admin_panel_settings_outlined,
      allowedRoles: const <UserRole>{UserRole.admin},
      builder: (BuildContext context) => const PermissionsScreen(),
    ),
    ErpModule(
      id: 'users',
      group: ModuleGroup.system,
      title: (AppLocalizations l10n) => l10n.moduleUsers,
      icon: Icons.people_outline,
      allowedRoles: const <UserRole>{UserRole.admin},
      builder: (BuildContext context) => const UsersScreen(),
    ),
  ];
});

/// Modules the signed-in user may open, based on their role.
final Provider<List<ErpModule>> visibleModulesProvider =
    Provider<List<ErpModule>>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null || !user.isActive) {
    return const <ErpModule>[];
  }
  final bool usesRegister = ref.watch(businessProvider.select((BusinessInfo b) => b.usesRegister));
  final bool hasOnlineStore = ref.watch(businessProvider.select((BusinessInfo b) => b.hasOnlineStore));
  return ref
      .watch(erpModulesProvider)
      .where((ErpModule module) => (module.permission != null ? user.can(module.permission!) : module.allowedRoles.contains(user.role)) && (!module.needsRegister || usesRegister) && (!module.needsOnlineStore || hasOnlineStore))
      .toList();
});
