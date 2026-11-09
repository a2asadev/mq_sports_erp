import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/erp_module.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/user_role.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';
import 'package:mq_sports_erp/screens/catalog/categories_screen.dart';
import 'package:mq_sports_erp/screens/catalog/products_screen.dart';
import 'package:mq_sports_erp/screens/users/users_screen.dart';

/// Registry of every ERP module. Each new module appends one `ErpModule`.
final Provider<List<ErpModule>> erpModulesProvider =
    Provider<List<ErpModule>>((Ref ref) {
  return <ErpModule>[
    ErpModule(
      id: 'categories',
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
      id: 'users',
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
