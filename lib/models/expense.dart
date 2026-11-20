/// A heading expenses are recorded under (Rent, Salaries, Electricity...).
class ExpenseCategory {
  const ExpenseCategory({required this.id, required this.name, required this.isActive, this.expenseCount = 0});

  final String id;
  final String name;
  final bool isActive;

  /// Expenses recorded under it (voided ones included).
  final int expenseCount;

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) => ExpenseCategory(
        id: '${map['id'] ?? ''}',
        name: '${map['name'] ?? ''}',
        isActive: map['isActive'] != false,
        expenseCount: (map['expenseCount'] as num?)?.toInt() ?? 0,
      );
}

/// Money spent that is not stock. Never edited: a mistake is voided and entered again.
class Expense {
  const Expense({
    required this.id,
    required this.date,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.paymentMethod,
    this.paymentRef = '',
    this.payee = '',
    this.note = '',
    this.byName = '',
    this.voided = false,
    this.voidReason = '',
    this.voidedByName = '',
  });

  final String id;
  final DateTime date;
  final String categoryId;

  /// The category's name when the expense was recorded.
  final String categoryName;
  final double amount;

  /// cash, bank, easypaisa or jazzcash.
  final String paymentMethod;
  final String paymentRef;
  final String payee;
  final String note;
  final String byName;
  final bool voided;
  final String voidReason;
  final String voidedByName;

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: '${map['id'] ?? ''}',
        date: DateTime.tryParse('${map['date'] ?? ''}')?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0),
        categoryId: '${map['categoryId'] ?? ''}',
        categoryName: '${map['categoryName'] ?? ''}',
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        paymentMethod: '${map['paymentMethod'] ?? 'cash'}',
        paymentRef: '${map['paymentRef'] ?? ''}',
        payee: '${map['payee'] ?? ''}',
        note: '${map['note'] ?? ''}',
        byName: '${map['byName'] ?? ''}',
        voided: map['voided'] == true,
        voidReason: '${map['voidReason'] ?? ''}',
        voidedByName: '${map['voidedByName'] ?? ''}',
      );
}

/// One page of expenses, with what the whole period cost (voided ones left out).
class ExpensePage {
  const ExpensePage({required this.items, required this.total, required this.sum});

  final List<Expense> items;

  /// How many expenses match (not only this page).
  final int total;

  /// What they cost together.
  final double sum;

  factory ExpensePage.fromMap(Map<String, dynamic> map) {
    final Object? items = map['items'];
    return ExpensePage(
      items: <Expense>[
        if (items is List<Object?>)
          for (final Object? i in items)
            if (i is Map<String, dynamic>) Expense.fromMap(i),
      ],
      total: (map['total'] as num?)?.toInt() ?? 0,
      sum: (map['sum'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Today's and this month's expenses, and this month by category.
class ExpenseSummary {
  const ExpenseSummary({required this.today, required this.month, this.byCategory = const <ExpenseCategoryTotal>[]});

  final double today;
  final double month;
  final List<ExpenseCategoryTotal> byCategory;

  factory ExpenseSummary.fromMap(Map<String, dynamic> map) {
    final Object? rows = map['byCategory'];
    return ExpenseSummary(
      today: (map['today'] as num?)?.toDouble() ?? 0,
      month: (map['month'] as num?)?.toDouble() ?? 0,
      byCategory: <ExpenseCategoryTotal>[
        if (rows is List<Object?>)
          for (final Object? r in rows)
            if (r is Map<String, dynamic>)
              ExpenseCategoryTotal(
                categoryId: '${r['categoryId'] ?? ''}',
                name: '${r['name'] ?? ''}',
                total: (r['total'] as num?)?.toDouble() ?? 0,
                count: (r['count'] as num?)?.toInt() ?? 0,
              ),
      ],
    );
  }
}

class ExpenseCategoryTotal {
  const ExpenseCategoryTotal({required this.categoryId, required this.name, required this.total, required this.count});

  final String categoryId;
  final String name;
  final double total;
  final int count;
}
