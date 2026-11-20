import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/expense.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/register_day.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/online/expenses_service.dart';
import 'package:a2_stocks/providers/dashboard_providers.dart';
import 'package:a2_stocks/providers/expense_providers.dart';
import 'package:a2_stocks/screens/expenses/expense_categories_dialog.dart';
import 'package:a2_stocks/screens/expenses/expense_form_dialog.dart';
import 'package:a2_stocks/screens/expenses/expenses_screen.dart';

class _FakeExpenses implements ExpensesService {
  _FakeExpenses({List<ExpenseCategory>? categories, List<Expense>? expenses})
      : cats = categories ?? <ExpenseCategory>[const ExpenseCategory(id: 'c1', name: 'Rent', isActive: true), const ExpenseCategory(id: 'c2', name: 'Tea and food', isActive: true)],
        items = expenses ?? <Expense>[];

  List<ExpenseCategory> cats;
  List<Expense> items;
  final List<Map<String, Object?>> created = <Map<String, Object?>>[];
  final List<String> voided = <String>[];
  final List<String> createdCategories = <String>[];

  @override
  Future<List<ExpenseCategory>> categories() async => cats;

  @override
  Future<ExpenseCategory> createCategory(String name) async {
    createdCategories.add(name);
    final ExpenseCategory c = ExpenseCategory(id: 'n${cats.length}', name: name, isActive: true);
    cats = <ExpenseCategory>[...cats, c];
    return c;
  }

  @override
  Future<ExpenseCategory> updateCategory(String id, {String? name, bool? isActive}) async => cats.first;

  @override
  Future<ExpensePage> list({String? from, String? to, String? categoryId, bool includeVoided = true, int limit = 200}) async =>
      ExpensePage(items: items, total: items.length, sum: items.where((Expense e) => !e.voided).fold<double>(0, (double s, Expense e) => s + e.amount));

  @override
  Future<ExpenseSummary> summary() async => const ExpenseSummary(today: 0, month: 0);

  @override
  Future<Expense> create({
    required String categoryId,
    required double amount,
    required DateTime date,
    String paymentMethod = 'cash',
    String paymentRef = '',
    String payee = '',
    String note = '',
    String? requestId,
  }) async {
    created.add(<String, Object?>{'category': categoryId, 'amount': amount, 'method': paymentMethod, 'ref': paymentRef, 'payee': payee, 'note': note});
    return Expense(id: 'e', date: date, categoryId: categoryId, categoryName: 'x', amount: amount, paymentMethod: paymentMethod);
  }

  @override
  Future<Expense> voidExpense(String id, {String reason = ''}) async {
    voided.add('$id:$reason');
    return items.first;
  }
}

Expense _expense(String id, double amount, {String category = 'Rent', bool voided = false, String payee = ''}) => Expense(
      id: id,
      date: DateTime(2026, 11, 20),
      categoryId: 'c1',
      categoryName: category,
      amount: amount,
      paymentMethod: 'cash',
      payee: payee,
      byName: 'Ali',
      voided: voided,
      voidReason: voided ? 'typo' : '',
    );

Widget _app(_FakeExpenses service, Widget home) => ProviderScope(
      overrides: <Override>[expensesServiceProvider.overrideWithValue(service)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );

void main() {
  group('the models', () {
    test('read an expense, a page and a summary', () {
      final Expense e = Expense.fromMap(<String, dynamic>{
        'id': 'e1',
        'date': '2026-11-20T10:00:00.000Z',
        'categoryId': 'c',
        'categoryName': 'Rent',
        'amount': 25000,
        'paymentMethod': 'bank',
        'voided': true,
        'voidReason': 'typo',
      });
      expect(e.amount, 25000);
      expect(e.voided, isTrue);
      expect(Expense.fromMap(<String, dynamic>{'id': 'x'}).paymentMethod, 'cash');

      final ExpensePage page = ExpensePage.fromMap(<String, dynamic>{
        'items': <Object?>[<String, dynamic>{'id': 'a', 'amount': 5}],
        'total': 9,
        'sum': 42.5,
      });
      expect(page.items, hasLength(1));
      expect(page.total, 9);
      expect(page.sum, 42.5);

      final ExpenseSummary s = ExpenseSummary.fromMap(<String, dynamic>{
        'today': 10,
        'month': 100,
        'byCategory': <Object?>[<String, dynamic>{'categoryId': 'c', 'name': 'Rent', 'total': 90, 'count': 2}],
      });
      expect(s.month, 100);
      expect(s.byCategory.single.count, 2);
    });

    test('the register counts the cash that was spent', () {
      final RegisterDay day = RegisterDay.fromMap(<String, dynamic>{'date': '2026-11-22', 'cashExpenses': 300, 'expectedCash': -300});
      expect(day.cashExpenses, 300);
      expect(RegisterDay.fromMap(<String, dynamic>{'date': 'x'}).cashExpenses, 0);
    });

    test('the filter is one month and says its first and last day', () {
      final ExpensesFilter f = ExpensesFilter(month: DateTime(2026, 2, 14));
      expect(f.from, '2026-02-01');
      expect(f.to, '2026-02-28');
      expect(ExpensesFilter(month: DateTime(2028, 2, 3)).to, '2028-02-29');
      expect(f.copyWith(categoryId: 'c').categoryId, 'c');
      expect(f.copyWith(categoryId: 'c').copyWith(clearCategory: true).categoryId, isNull);
    });
  });

  group('the estimated profit', () {
    test('is the sales of the month less what the goods cost and the expenses', () {
      final DateTime now = DateTime(2026, 11, 20, 12);
      final ProductModel product = ProductModel(
        id: 'p',
        name: 'Bat',
        categoryId: 'cat',
        variants: <VariantModel>[VariantModel(id: 'v1', sku: 'BAT', costPrice: 60, salePrice: 100)],
      );
      final OrderModel sold = OrderModel(
        orderNo: 'O1',
        customerId: 'c',
        customerName: 'Ali',
        orderDate: DateTime(2026, 11, 5),
        items: <OrderItem>[
          OrderItem(productId: 'p', variantId: 'v1', productName: 'Bat', variantLabel: '', sku: 'BAT', quantity: 3, unitPrice: 100),
        ],
      );
      final OrderModel cancelled = sold.copyWith(status: OrderStatus.cancelled);
      final OrderModel lastMonth = OrderModel(
        orderNo: 'O0',
        customerId: 'c',
        customerName: 'Ali',
        orderDate: DateTime(2026, 10, 5),
        items: <OrderItem>[
          OrderItem(productId: 'p', variantId: 'v1', productName: 'Bat', variantLabel: '', sku: 'BAT', quantity: 9, unitPrice: 100),
        ],
      );
      final DashboardStats stats = computeDashboardStats(
        orders: <OrderModel>[sold, cancelled, lastMonth],
        products: <ProductModel>[product],
        onHand: const <String, int>{},
        now: now,
      );
      expect(stats.salesMonth, 300);
      expect(stats.costOfSalesMonth, 180); // 3 x 60; the cancelled order and last month do not count
      expect(stats.grossProfitMonth, 120);
      // With 50 of expenses the month's estimate is 70.
      expect(stats.grossProfitMonth - 50, 70);
    });
  });

  group('the Expenses page', () {
    testWidgets('lists the month, counts what is not voided, and voids one with a reason', (WidgetTester tester) async {
      final _FakeExpenses service = _FakeExpenses(expenses: <Expense>[
        _expense('a', 25000, payee: 'Landlord'),
        _expense('b', 300, category: 'Tea and food'),
        _expense('c', 999, voided: true),
      ]);
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(service, const ExpensesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Rs 25,300'), findsOneWidget); // the total leaves the voided one out
      expect(find.textContaining('Landlord'), findsOneWidget);
      expect(find.textContaining('Voided: typo'), findsOneWidget);

      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Void').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Reason (optional)'), 'Entered twice');
      await tester.tap(find.widgetWithText(FilledButton, 'Void'));
      await tester.pumpAndSettle();
      expect(service.voided, <String>['a:Entered twice']);
    });

    testWidgets('says so when the month has no expenses', (WidgetTester tester) async {
      await tester.pumpWidget(_app(_FakeExpenses(), const ExpensesScreen()));
      await tester.pumpAndSettle();
      expect(find.text('No expenses recorded for this month yet.'), findsOneWidget);
    });
  });

  group('adding an expense', () {
    Future<_FakeExpenses> open(WidgetTester tester, {_FakeExpenses? service}) async {
      final _FakeExpenses fake = service ?? _FakeExpenses();
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(fake, Builder(builder: (BuildContext context) => Scaffold(body: Center(child: FilledButton(onPressed: () => showDialog<bool>(context: context, builder: (BuildContext context) => const ExpenseFormDialog()), child: const Text('open')))))));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return fake;
    }

    testWidgets('needs a category and an amount, then records it', (WidgetTester tester) async {
      final _FakeExpenses service = await open(tester);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save expense')).onPressed, isNull);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tea and food').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Amount'), '150');
      await tester.enterText(find.widgetWithText(TextField, 'Paid to (optional)'), 'Canteen');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Save expense'));
      await tester.pumpAndSettle();

      expect(service.created.single, <String, Object?>{'category': 'c2', 'amount': 150.0, 'method': 'cash', 'ref': '', 'payee': 'Canteen', 'note': ''});
    });

    testWidgets('without categories it sends the person to add some', (WidgetTester tester) async {
      await open(tester, service: _FakeExpenses(categories: <ExpenseCategory>[]));
      expect(find.textContaining('no expense categories yet'), findsOneWidget);
    });

    testWidgets('a switched-off category is not offered', (WidgetTester tester) async {
      await open(
        tester,
        service: _FakeExpenses(categories: <ExpenseCategory>[
          const ExpenseCategory(id: 'c1', name: 'Rent', isActive: false),
          const ExpenseCategory(id: 'c2', name: 'Fuel', isActive: true),
        ]),
      );
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      expect(find.text('Rent'), findsNothing);
      expect(find.text('Fuel'), findsWidgets);
    });
  });

  group('the categories', () {
    testWidgets('"add the usual ones" adds only those that are not there yet', (WidgetTester tester) async {
      final _FakeExpenses service = _FakeExpenses(categories: <ExpenseCategory>[const ExpenseCategory(id: 'c1', name: 'rent', isActive: true)]);
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(service, const Scaffold(body: ExpenseCategoriesDialog())));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add the usual ones'));
      await tester.pumpAndSettle();
      expect(service.createdCategories, hasLength(11)); // 12 usual ones, "Rent" was there in other letters
      expect(service.createdCategories, isNot(contains('Rent')));
      expect(service.createdCategories, contains('Salaries'));
    });
  });
}
