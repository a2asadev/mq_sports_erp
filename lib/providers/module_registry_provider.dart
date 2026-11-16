import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/erp_module.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/user_role.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';
import 'package:mq_sports_erp/screens/catalog/categories_screen.dart';
import 'package:mq_sports_erp/screens/catalog/products_screen.dart';
import 'package:mq_sports_erp/screens/logs/activity_logs_screen.dart';
import 'package:mq_sports_erp/screens/parties/customers_screen.dart';
import 'package:mq_sports_erp/screens/pos/pos_screen.dart';
import 'package:mq_sports_erp/screens/purchasing/purchases_screen.dart';
import 'package:mq_sports_erp/screens/settings/settings_screen.dart';
import 'package:mq_sports_erp/screens/sales/orders_screen.dart';
import 'package:mq_sports_erp/screens/stock/stock_screen.dart';
import 'package:mq_sports_erp/screens/parties/vendors_screen.dart';
import 'package:mq_sports_erp/screens/users/users_screen.dart';

/// Registry of every ERP module. Each new module appends one `ErpModule`.
final Provider<List<ErpModule>> erpModulesProvider =
    Provider<List<ErpModule>>((Ref ref) {
  return <ErpModule>[
    ErpModule(
      id: 'categories',
      group: 'Inventory',
      title: 'Categories',
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
      group: 'Inventory',
      title: 'Products',
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
      group: 'Sales',
      title: 'Customers',
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
      group: 'Purchasing',
      title: 'Vendors',
      icon: Icons.local_shipping_outlined,
      allowedRoles: const <UserRole>{UserRole.admin, UserRole.manager},
      builder: (BuildContext context) => const VendorsScreen(),
    ),
    ErpModule(
      id: 'purchases',
      group: 'Purchasing',
      title: 'Purchases',
      icon: Icons.shopping_cart_checkout_outlined,
      allowedRoles: const <UserRole>{UserRole.admin, UserRole.manager},
      builder: (BuildContext context) => const PurchasesScreen(),
    ),
    ErpModule(
      id: 'pos',
      group: 'Main',
      title: 'POS',
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
      group: 'Sales',
      title: 'Sales & Orders',
      icon: Icons.point_of_sale_outlined,
      allowedRoles: const <UserRole>{
        UserRole.admin,
        UserRole.manager,
        UserRole.staff,
      },
      builder: (BuildContext context) => const OrdersScreen(),
    ),
    ErpModule(
      id: 'stock',
      group: 'Inventory',
      title: 'Stock',
      icon: Icons.warehouse_outlined,
      allowedRoles: const <UserRole>{
        UserRole.admin,
        UserRole.manager,
        UserRole.staff,
      },
      builder: (BuildContext context) => const StockScreen(),
    ),
    ErpModule(
      id: 'logs',
      group: 'System',
      title: 'Activity Logs',
      icon: Icons.history_outlined,
      allowedRoles: const <UserRole>{UserRole.admin},
      builder: (BuildContext context) => const ActivityLogsScreen(),
    ),
    ErpModule(
      id: 'settings',
      group: 'System',
      title: 'Settings',
      icon: Icons.settings_outlined,
      allowedRoles: const <UserRole>{
        UserRole.admin,
        UserRole.manager,
        UserRole.staff,
      },
      builder: (BuildContext context) => const SettingsScreen(),
    ),
    ErpModule(
      id: 'users',
      group: 'System',
      title: 'Users',
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
  return ref
      .watch(erpModulesProvider)
      .where((ErpModule module) => module.allowedRoles.contains(user.role))
      .toList();
});
