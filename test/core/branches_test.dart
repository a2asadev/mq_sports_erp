import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/core/erp_module.dart';
import 'package:a2_stocks/core/utils/branch_rules.dart';
import 'package:a2_stocks/core/utils/tax.dart';
import 'package:a2_stocks/data/local/app_database.dart';
import 'package:a2_stocks/data/local/collections.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/branch_model.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/purchase_model.dart';
import 'package:a2_stocks/models/stock_audit_model.dart';
import 'package:a2_stocks/models/stock_ledger_model.dart';
import 'package:a2_stocks/models/stock_transfer.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/online/branches_service.dart';
import 'package:a2_stocks/providers/branch_providers.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/providers/module_registry_provider.dart';
import 'package:a2_stocks/providers/users_providers.dart';
import 'package:a2_stocks/screens/branches/branches_screen.dart';
import 'package:a2_stocks/widgets/branch_picker.dart';

BranchModel branch(String id, String name, {bool isDefault = false, bool isActive = true}) => BranchModel(id: id, name: name, isDefault: isDefault, isActive: isActive);

UserModel person(UserRole role, {String branchId = '', List<String>? permissions}) => UserModel(id: 'u', email: 'a@b.pk', role: role, branchId: branchId, permissions: permissions);

StockLedgerModel move(String variant, int quantity, {String branchId = ''}) => StockLedgerModel(productId: 'p', variantId: variant, sku: variant, quantity: quantity, movementType: StockMovementType.purchase, branchId: branchId);

class _Branches extends BranchesNotifier {
  _Branches(this.items);
  final List<BranchModel> items;
  @override
  Future<List<BranchModel>> build() async => items;
}

class _Me extends CurrentUserNotifier {
  _Me(this.user);
  final UserModel user;
  @override
  Future<UserModel?> build() async => user;
}

class _FakeBranchService implements BranchesService {
  final List<String> calls = <String>[];

  @override
  Future<BranchModel> create({required String name, String code = '', String address = '', String phone = ''}) async {
    calls.add('create:$name:$code');
    return branch('new', name);
  }

  @override
  Future<BranchModel> update(String id, {required String name, String code = '', String address = '', String phone = ''}) async {
    calls.add('update:$id:$name');
    return branch(id, name);
  }

  @override
  Future<BranchModel> setActive(String id, bool on) async {
    calls.add('active:$id:$on');
    return branch(id, 'x', isActive: on);
  }

  @override
  Future<void> setUsesBranches(bool on) async => calls.add('uses:$on');
}

void main() {
  final List<BranchModel> branches = <BranchModel>[branch('main', 'Main branch', isDefault: true), branch('lhr', 'Lahore'), branch('old', 'Closed', isActive: false)];

  group('which branch a person works in', () {
    test('is none when the business does not use branches', () {
      expect(resolveWorkingBranch(usesBranches: false, user: person(UserRole.admin), branches: branches, saved: 'lhr'), '');
    });

    test('is the one chosen last when it is still on, else the home branch, else the default', () {
      String pick(UserModel? user, String saved) => resolveWorkingBranch(usesBranches: true, user: user, branches: branches, saved: saved);
      expect(pick(person(UserRole.manager), 'lhr'), 'lhr');
      expect(pick(person(UserRole.manager), 'old'), 'main'); // switched off
      expect(pick(person(UserRole.manager), 'gone'), 'main'); // no longer there
      expect(pick(person(UserRole.manager, branchId: 'lhr'), ''), 'lhr');
      expect(pick(person(UserRole.manager, branchId: 'lhr'), 'main'), 'main'); // a manager may choose
      expect(pick(null, ''), 'main');
    });

    test('is the home branch for staff, whatever was chosen', () {
      expect(resolveWorkingBranch(usesBranches: true, user: person(UserRole.staff, branchId: 'lhr'), branches: branches, saved: 'main'), 'lhr');
      // a home branch that is switched off frees them
      expect(resolveWorkingBranch(usesBranches: true, user: person(UserRole.staff, branchId: 'old'), branches: branches, saved: 'lhr'), 'lhr');
    });

    test('may be changed by everyone except staff with a branch, and only when there is a choice', () {
      expect(mayChooseBranch(person(UserRole.admin), branches), isTrue);
      expect(mayChooseBranch(person(UserRole.manager, branchId: 'lhr'), branches), isTrue);
      expect(mayChooseBranch(person(UserRole.staff), branches), isTrue);
      expect(mayChooseBranch(person(UserRole.staff, branchId: 'lhr'), branches), isFalse);
      expect(mayChooseBranch(person(UserRole.admin), <BranchModel>[branch('main', 'Main', isDefault: true)]), isFalse);
      expect(mayChooseBranch(null, branches), isFalse);
    });
  });

  group('stock of a branch', () {
    final List<StockLedgerModel> entries = <StockLedgerModel>[move('bat', 10), move('bat', 4, branchId: 'lhr'), move('bat', -2, branchId: 'main'), move('ball', 5, branchId: 'lhr')];

    test('is the total without a branch', () {
      expect(stockByVariant(entries), <String, int>{'bat': 12, 'ball': 5});
    });

    test('counts only that branch; a movement with no branch is the default branch\'s', () {
      expect(stockByVariant(entries, branchId: 'main', defaultBranchId: 'main'), <String, int>{'bat': 8});
      expect(stockByVariant(entries, branchId: 'lhr', defaultBranchId: 'main'), <String, int>{'bat': 4, 'ball': 5});
    });

    test('names a branch, with "" meaning the default one', () {
      expect(branchName(branches, 'lhr'), 'Lahore');
      expect(branchName(branches, ''), 'Main branch');
      expect(branchName(branches, 'nope'), '');
    });
  });

  group('the branch on the records', () {
    test('travels in the map of an order, a purchase, a count, a movement and a person; none is ""', () {
      expect(OrderModel.fromMap(OrderModel(orderNo: 'O', customerId: 'c', customerName: 'x', branchId: 'lhr').toMap()).branchId, 'lhr');
      expect(OrderModel(orderNo: 'O', customerId: 'c', customerName: 'x').branchId, '');
      expect(PurchaseModel.fromMap(PurchaseModel(purchaseNo: 'P', vendorId: 'v', vendorName: 'v', branchId: 'lhr').toMap()).branchId, 'lhr');
      expect(StockAuditModel.fromMap(StockAuditModel(auditNo: 'A', branchId: 'lhr').toMap()).branchId, 'lhr');
      expect(StockLedgerModel.fromMap(move('bat', 1, branchId: 'lhr').toMap()).branchId, 'lhr');
      expect(UserModel.fromMap(person(UserRole.staff, branchId: 'lhr').toMap()).branchId, 'lhr');
      expect(OrderModel(orderNo: 'O', customerId: 'c', customerName: 'x', branchId: 'lhr').copyWith(notes: 'n').branchId, 'lhr');
      expect(OrderModel(orderNo: 'O', customerId: 'c', customerName: 'x', branchId: 'lhr').withTax(computeTax(100, TaxSettings.of(BusinessInfo.mqSports))).branchId, 'lhr');
    });

    test('the business knows whether it uses branches', () {
      expect(BusinessInfo.mqSports.usesBranches, isFalse);
      final BusinessInfo on = BusinessInfo.mqSports.copyWith(usesBranches: true);
      expect(BusinessInfo.tryFromMap(on.toMap())?.usesBranches, isTrue);
      expect(on == BusinessInfo.mqSports, isFalse);
    });

    test('a branch and a transfer are read from the server\'s answer', () {
      final BranchModel b = BranchModel.fromMap(<String, dynamic>{'id': 'x', 'name': 'Lahore', 'code': 'LHR', 'isDefault': false, 'isActive': true});
      expect((b.name, b.code, b.isDefault), ('Lahore', 'LHR', false));
      expect(BranchModel.fromMap(b.toMap()).name, 'Lahore');
      final StockTransfer t = StockTransfer.fromMap(<String, dynamic>{
        'id': 't',
        'transferNo': 'TRF-1',
        'fromBranchName': 'Main',
        'toBranchName': 'Lahore',
        'transferDate': '2026-11-21T08:00:00.000Z',
        'note': 'n',
        'byName': 'Asad',
        'items': <Object?>[<String, dynamic>{'variantId': 'v', 'productName': 'Bat', 'variantLabel': 'S', 'sku': 'B', 'quantity': 3}, <String, dynamic>{'variantId': 'w', 'productName': 'Ball', 'variantLabel': 'S', 'sku': 'L', 'quantity': 2}],
      });
      expect(t.units, 5);
      expect(t.items.first.productName, 'Bat');
    });
  });

  group('the local database', () {
    late AppDatabase db;
    late LocalCollections local;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      local = LocalCollections(db);
    });
    tearDown(() => db.close());

    test('keeps branches and the branch of every record', () async {
      await local.branches.upsertAll(<BranchModel>[branch('main', 'Main branch', isDefault: true), branch('lhr', 'Lahore')]);
      expect((await local.branches.all()).map((BranchModel b) => b.name).toSet(), <String>{'Main branch', 'Lahore'});
      expect((await local.branches.byId('main'))?.isDefault, isTrue);
      await local.orders.upsertAll(<OrderModel>[OrderModel(id: 'o', orderNo: 'O-1', customerId: 'c', customerName: 'x', branchId: 'lhr')]);
      expect((await local.orders.byId('o'))?.branchId, 'lhr');
      await local.purchases.upsertAll(<PurchaseModel>[PurchaseModel(id: 'p', purchaseNo: 'P-1', vendorId: 'v', vendorName: 'v', branchId: 'lhr')]);
      expect((await local.purchases.byId('p'))?.branchId, 'lhr');
      await local.stockAudits.upsertAll(<StockAuditModel>[StockAuditModel(id: 'a', auditNo: 'A-1', branchId: 'lhr')]);
      expect((await local.stockAudits.byId('a'))?.branchId, 'lhr');
      await local.stockLedgers.upsertAll(<StockLedgerModel>[move('bat', 3, branchId: 'lhr')]);
      expect((await local.stockLedgers.all()).single.branchId, 'lhr');
      await local.users.upsertAll(<UserModel>[person(UserRole.staff, branchId: 'lhr')]);
      expect((await local.users.byId('u'))?.branchId, 'lhr');
      expect(local.named('branches'), isNotNull);
    });
  });

  group('the screens', () {
    Future<ProviderContainer> pump(WidgetTester tester, Widget home, {required UserModel me, required List<BranchModel> list, required bool uses, _FakeBranchService? service}) async {
      tester.view.physicalSize = const Size(1000, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final ProviderContainer container = ProviderContainer(overrides: <Override>[
        currentUserProvider.overrideWith(() => _Me(me)),
        branchesProvider.overrideWith(() => _Branches(list)),
        businessProvider.overrideWithValue(BusinessInfo.mqSports.copyWith(usesBranches: uses)),
        if (service != null) branchesServiceProvider.overrideWithValue(service),
        serverChangesProvider.overrideWithValue(() async {}),
      ]);
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(appBar: AppBar(actions: <Widget>[if (home is BranchPickerChip) home], title: const Text('t')), body: home is BranchPickerChip ? const SizedBox() : home),
        ),
      ));
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('the branch picker is hidden without branches or with only one, and tied for staff with a branch', (WidgetTester tester) async {
      await pump(tester, const BranchPickerChip(), me: person(UserRole.manager), list: branches, uses: false);
      expect(find.byType(ActionChip), findsNothing);
      await pump(tester, const BranchPickerChip(), me: person(UserRole.manager), list: <BranchModel>[branch('main', 'Main branch', isDefault: true)], uses: true);
      expect(find.byType(ActionChip), findsNothing);
      await pump(tester, const BranchPickerChip(), me: person(UserRole.staff, branchId: 'lhr'), list: branches, uses: true);
      expect(find.text('Lahore'), findsOneWidget);
      expect(tester.widget<ActionChip>(find.byType(ActionChip)).onPressed, isNull);
    });

    testWidgets('a manager picks the branch to work in', (WidgetTester tester) async {
      final ProviderContainer c = await pump(tester, const BranchPickerChip(), me: person(UserRole.manager), list: branches, uses: true);
      expect(find.text('Main branch'), findsOneWidget);
      await tester.tap(find.byType(ActionChip));
      await tester.pumpAndSettle();
      expect(find.text('Closed'), findsNothing); // a branch that is off cannot be chosen
      await tester.tap(find.text('Lahore'));
      await tester.pumpAndSettle();
      expect(c.read(workingBranchIdProvider), 'lhr');
      expect(find.text('Lahore'), findsOneWidget);
    });

    testWidgets('the Branches page lists them, switches the business on and adds a branch', (WidgetTester tester) async {
      final _FakeBranchService service = _FakeBranchService();
      await pump(tester, const BranchesScreen(), me: person(UserRole.admin), list: <BranchModel>[...branches], uses: false, service: service);
      expect(find.text('Main branch'), findsOneWidget);
      expect(find.text('Main'), findsOneWidget); // the main branch is marked
      expect(find.text('Lahore'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(3)); // the business switch + Lahore + Closed (the main branch has none)
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      expect(service.calls, contains('uses:true'));
      await tester.tap(find.text('Add branch'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save')); // no name yet
      await tester.pumpAndSettle();
      expect(find.text('Give the branch a name.'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'Branch name'), 'Karachi');
      await tester.enterText(find.widgetWithText(TextField, 'Short code (optional)'), 'KHI');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(service.calls, contains('create:Karachi:KHI'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('switching a branch off asks the server', (WidgetTester tester) async {
      final _FakeBranchService service = _FakeBranchService();
      await pump(tester, const BranchesScreen(), me: person(UserRole.admin), list: <BranchModel>[...branches], uses: true, service: service);
      await tester.tap(find.byType(Switch).at(2)); // Lahore (the list is alphabetical: Main, Closed, Lahore)
      await tester.pumpAndSettle();
      expect(service.calls, contains('active:lhr:false'));
    });
  });

  group('the modules', () {
    Future<Set<String>> visible(UserModel me, {required bool uses}) async {
      final ProviderContainer c = ProviderContainer(overrides: <Override>[
        currentUserProvider.overrideWith(() => _Me(me)),
        businessProvider.overrideWithValue(BusinessInfo.mqSports.copyWith(usesBranches: uses)),
      ]);
      addTearDown(c.dispose);
      await c.read(currentUserProvider.future);
      return c.read(visibleModulesProvider).map((ErpModule m) => m.id).toSet();
    }

    test('the Branches page is the admin\'s, always; stock transfers need branches on and the stock permission', () async {
      expect(await visible(person(UserRole.admin), uses: false), contains('branches'));
      expect(await visible(person(UserRole.admin), uses: false), isNot(contains('stock_transfers')));
      expect(await visible(person(UserRole.admin), uses: true), contains('stock_transfers'));
      expect(await visible(person(UserRole.manager), uses: true), contains('stock_transfers'));
      expect(await visible(person(UserRole.manager), uses: true), isNot(contains('branches')));
      expect(await visible(person(UserRole.staff), uses: true), isNot(contains('stock_transfers')));
      expect(await visible(person(UserRole.staff, permissions: <String>['stock.audit']), uses: true), contains('stock_transfers'));
    });
  });
}

