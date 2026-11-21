import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/core/erp_module.dart';
import 'package:a2_stocks/core/permissions.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/online/permissions_service.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';
import 'package:a2_stocks/providers/dashboard_providers.dart';
import 'package:a2_stocks/providers/module_registry_provider.dart';
import 'package:a2_stocks/providers/parties_providers.dart';
import 'package:a2_stocks/providers/permission_providers.dart';
import 'package:a2_stocks/providers/purchasing_providers.dart';
import 'package:a2_stocks/providers/sales_providers.dart';
import 'package:a2_stocks/providers/users_providers.dart';
import 'package:a2_stocks/screens/permissions/permissions_screen.dart';

class _Me extends CurrentUserNotifier {
  _Me(this.user);
  final UserModel user;
  @override
  Future<UserModel?> build() async => user;
}

UserModel user(UserRole role, {List<String>? permissions}) => UserModel(id: 'u', email: 'a@b.pk', role: role, permissions: permissions);

Future<ProviderContainer> signedIn(UserModel me) async {
  final ProviderContainer container = ProviderContainer(overrides: <Override>[currentUserProvider.overrideWith(() => _Me(me))]);
  addTearDown(container.dispose);
  await container.read(currentUserProvider.future);
  return container;
}

bool hasAny(Set<String> ids, List<String> wanted) => wanted.any(ids.contains);

Set<String> visibleIds(ProviderContainer c) => c.read(visibleModulesProvider).map((ErpModule m) => m.id).toSet();

void main() {
  group('what a person may do', () {
    test('an admin may do everything, always', () {
      for (final String key in Permissions.all) {
        expect(user(UserRole.admin).can(key), isTrue);
        expect(user(UserRole.admin, permissions: <String>[]).can(key), isTrue);
      }
    });

    test('until the server says, managers have everything and staff nothing (how the roles always behaved)', () {
      for (final String key in Permissions.all) {
        expect(user(UserRole.manager).can(key), isTrue, reason: key);
        expect(user(UserRole.staff).can(key), isFalse, reason: key);
      }
    });

    test('once the server has said, only that list counts', () {
      final UserModel manager = user(UserRole.manager, permissions: <String>[Permissions.expensesManage]);
      expect(manager.can(Permissions.expensesManage), isTrue);
      expect(manager.can(Permissions.reportsView), isFalse);
      final UserModel staff = user(UserRole.staff, permissions: <String>[Permissions.reportsView]);
      expect(staff.can(Permissions.reportsView), isTrue);
      expect(staff.can(Permissions.expensesManage), isFalse);
    });

    test('is kept with the saved user, so it is known offline, and left out when unknown', () {
      final UserModel saved = UserModel.fromMap(user(UserRole.staff, permissions: <String>['reports.view']).toMap());
      expect(saved.permissions, <String>['reports.view']);
      expect(saved.can('reports.view'), isTrue);
      expect(user(UserRole.staff).toMap().containsKey('permissions'), isFalse);
      expect(UserModel.fromMap(<String, dynamic>{'id': 'x', 'email': 'e', 'role': 'manager'}).permissions, isNull);
      expect(user(UserRole.staff).copyWith(permissions: <String>['x']).permissions, <String>['x']);
      expect(user(UserRole.staff, permissions: <String>['x']).copyWith(displayName: 'N').permissions, <String>['x']);
    });
  });

  group('the modules a person sees follow what they may do', () {
    test('a manager sees the gated modules by default, staff do not', () async {
      final Set<String> manager = visibleIds(await signedIn(user(UserRole.manager)));
      expect(manager, containsAll(<String>['reports', 'expenses', 'vendors', 'purchases', 'promotions', 'customer_insights', 'reorder', 'purchase_orders']));
      expect(manager, isNot(contains('permissions'))); // admins only
      final Set<String> staff = visibleIds(await signedIn(user(UserRole.staff)));
      expect(hasAny(staff, <String>['reports', 'expenses', 'vendors', 'purchases', 'promotions', 'customer_insights', 'reorder', 'purchase_orders']), isFalse);
      expect(staff, containsAll(<String>['pos', 'sales', 'products', 'customers']));
    });

    test('switching a permission off hides its modules from a manager; on shows them to staff', () async {
      final Set<String> manager = visibleIds(await signedIn(user(UserRole.manager, permissions: <String>[Permissions.reportsView])));
      expect(manager, containsAll(<String>['reports', 'customer_insights']));
      expect(hasAny(manager, <String>['expenses', 'vendors', 'purchases', 'promotions']), isFalse);
      final Set<String> staff = visibleIds(await signedIn(user(UserRole.staff, permissions: <String>[Permissions.expensesManage, Permissions.purchasingManage])));
      expect(staff, containsAll(<String>['expenses', 'vendors', 'purchases', 'reorder', 'purchase_orders']));
      expect(staff, isNot(contains('reports')));
    });

    test('only an admin sees the Permissions page, and an admin sees every gated module', () async {
      final Set<String> admin = visibleIds(await signedIn(user(UserRole.admin)));
      expect(admin, containsAll(<String>['permissions', 'reports', 'expenses', 'vendors', 'promotions']));
    });
  });

  group('the actions follow the permissions', () {
    test('cancel, return, catalog, customers, vendors, purchasing and the dashboard', () async {
      final ProviderContainer staffWith = await signedIn(user(UserRole.staff, permissions: <String>[Permissions.returnsManage, Permissions.customersManage, Permissions.dashboardView]));
      expect(staffWith.read(canReturnOrdersProvider), isTrue);
      expect(staffWith.read(canManagePartiesProvider), isTrue);
      expect(staffWith.read(canViewDashboardProvider), isTrue);
      expect(staffWith.read(canCancelOrdersProvider), isFalse);
      expect(staffWith.read(canManageCatalogProvider), isFalse);
      expect(staffWith.read(canManageVendorsProvider), isFalse);
      expect(staffWith.read(canManagePurchasesProvider), isFalse);
      expect(staffWith.read(canRecordLedgerProvider), isFalse); // manual ledger entries stay with admins and managers

      final ProviderContainer managerWithout = await signedIn(user(UserRole.manager, permissions: <String>[Permissions.catalogManage]));
      expect(managerWithout.read(canManageCatalogProvider), isTrue);
      expect(managerWithout.read(canCancelOrdersProvider), isFalse);
      expect(managerWithout.read(canReturnOrdersProvider), isFalse);
      expect(managerWithout.read(canManageVendorsProvider), isFalse);
      expect(managerWithout.read(canRecordLedgerProvider), isTrue);
    });
  });

  group('the Permissions page', () {
    PermissionMatrix matrix({bool staffReports = false}) => PermissionMatrix.fromMap(<String, dynamic>{
          'permissions': <Object?>[
            <String, dynamic>{'key': 'reports.view', 'group': 'sales', 'defaults': <String, dynamic>{'manager': true, 'staff': false}},
            <String, dynamic>{'key': 'expenses.manage', 'group': 'purchasing', 'defaults': <String, dynamic>{'manager': true, 'staff': false}},
          ],
          'roles': <String, dynamic>{
            'manager': <String, dynamic>{'reports.view': true, 'expenses.manage': true},
            'staff': <String, dynamic>{'reports.view': staffReports, 'expenses.manage': false},
          },
        });

    testWidgets('shows a switch per role and capability, marks what was changed, and sends a change', (WidgetTester tester) async {
      final List<String> calls = <String>[];
      final _FakeService fake = _FakeService(matrix(staffReports: true), calls);
      tester.view.physicalSize = const Size(900, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: <Override>[
          permissionsServiceProvider.overrideWithValue(fake),
          currentUserProvider.overrideWith(() => _Me(user(UserRole.admin))),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PermissionsScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('See reports'), findsOneWidget);
      expect(find.text('Record expenses'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(4));
      expect(find.text('changed'), findsOneWidget); // staff may see reports, which is not the default
      await tester.tap(find.byKey(const ValueKey<String>('staff:expenses.manage')));
      await tester.pumpAndSettle();
      expect(calls, <String>['staff:expenses.manage:true']);
      expect(tester.takeException(), isNull);
    });
  });
}

class _FakeService implements PermissionsService {
  _FakeService(this.current, this.calls);
  PermissionMatrix current;
  final List<String> calls;

  @override
  Future<PermissionMatrix> get() async => current;

  @override
  Future<PermissionMatrix> set(String role, String permission, bool allowed) async {
    calls.add('$role:$permission:$allowed');
    return current;
  }
}
