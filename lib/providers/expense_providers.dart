import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/models/expense.dart';
import 'package:a2_stocks/online/expenses_service.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/providers/core_providers.dart';

final Provider<ExpensesService> expensesServiceProvider =
    Provider<ExpensesService>((Ref ref) => ExpensesService(ref.watch(apiClientProvider)));

/// The categories of the business, switched-off ones included.
final AutoDisposeFutureProvider<List<ExpenseCategory>> expenseCategoriesProvider =
    FutureProvider.autoDispose<List<ExpenseCategory>>((Ref ref) => ref.watch(expensesServiceProvider).categories());

/// What the Expenses page is looking at: one month, optionally one category.
class ExpensesFilter {
  const ExpensesFilter({required this.month, this.categoryId});

  /// Any day of the month shown.
  final DateTime month;
  final String? categoryId;

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _key(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

  String get from => _key(DateTime(month.year, month.month));
  String get to => _key(DateTime(month.year, month.month + 1, 0));

  ExpensesFilter copyWith({DateTime? month, String? categoryId, bool clearCategory = false}) =>
      ExpensesFilter(month: month ?? this.month, categoryId: clearCategory ? null : (categoryId ?? this.categoryId));

  @override
  bool operator ==(Object other) =>
      other is ExpensesFilter && other.from == from && other.categoryId == categoryId;

  @override
  int get hashCode => Object.hash(from, categoryId);
}

final StateProvider<ExpensesFilter> expensesFilterProvider =
    StateProvider<ExpensesFilter>((Ref ref) => ExpensesFilter(month: DateTime.now()));

/// The expenses of the chosen month (voided ones are listed, and do not count in the total).
final AutoDisposeFutureProvider<ExpensePage> expensesProvider = FutureProvider.autoDispose<ExpensePage>((Ref ref) {
  final ExpensesFilter filter = ref.watch(expensesFilterProvider);
  ref.watch(syncTickProvider);
  return ref.watch(expensesServiceProvider).list(from: filter.from, to: filter.to, categoryId: filter.categoryId);
});

/// Today's and this month's expenses, for the dashboard and the Expenses page.
final AutoDisposeFutureProvider<ExpenseSummary> expenseSummaryProvider =
    FutureProvider.autoDispose<ExpenseSummary>((Ref ref) {
  ref.watch(syncTickProvider);
  return ref.watch(expensesServiceProvider).summary();
});
