import 'package:uuid/uuid.dart';
import 'package:a2_stocks/models/expense.dart';
import 'package:a2_stocks/online/api_client.dart';

/// Expenses and their categories (`/v1/expenses`, `/v1/expense-categories`).
/// Admin and manager only. They need a connection: the figures are the server's.
class ExpensesService {
  ExpensesService(this._api);

  final ApiClient _api;

  Future<List<ExpenseCategory>> categories() async {
    final ApiResponse response = await _api.get('/v1/expense-categories');
    return <ExpenseCategory>[
      for (final Object? item in response.asList)
        if (item is Map<String, dynamic>) ExpenseCategory.fromMap(item),
    ];
  }

  Future<ExpenseCategory> createCategory(String name) async {
    final ApiResponse response = await _api.post('/v1/expense-categories', body: <String, dynamic>{'name': name});
    return ExpenseCategory.fromMap(response.asMap);
  }

  Future<ExpenseCategory> updateCategory(String id, {String? name, bool? isActive}) async {
    final ApiResponse response = await _api.patch('/v1/expense-categories/$id', body: <String, dynamic>{
      if (name != null) 'name': name,
      if (isActive != null) 'isActive': isActive,
    });
    return ExpenseCategory.fromMap(response.asMap);
  }

  /// The expenses of the days [from] to [to] ("YYYY-MM-DD", both included), newest first.
  Future<ExpensePage> list({String? from, String? to, String? categoryId, bool includeVoided = true, int limit = 200}) async {
    final ApiResponse response = await _api.get('/v1/expenses', query: <String, String>{
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (categoryId != null) 'categoryId': categoryId,
      if (includeVoided) 'includeVoided': 'true',
      'limit': '$limit',
    });
    return ExpensePage.fromMap(response.asMap);
  }

  Future<ExpenseSummary> summary() async {
    final ApiResponse response = await _api.get('/v1/expenses/summary');
    return ExpenseSummary.fromMap(response.asMap);
  }

  /// Records an expense. The id doubles as the idempotency key, so a double tap
  /// cannot record it twice.
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
    final String id = requestId ?? const Uuid().v4();
    final ApiResponse response = await _api.post(
      '/v1/expenses',
      idempotencyKey: id,
      body: <String, dynamic>{
        'id': id,
        'categoryId': categoryId,
        'amount': (amount * 100).roundToDouble() / 100,
        'date': date.toUtc().toIso8601String(),
        'paymentMethod': paymentMethod,
        if (paymentRef.trim().isNotEmpty) 'paymentRef': paymentRef.trim(),
        if (payee.trim().isNotEmpty) 'payee': payee.trim(),
        if (note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
    return Expense.fromMap(response.asMap);
  }

  Future<Expense> voidExpense(String id, {String reason = ''}) async {
    final ApiResponse response = await _api.post(
      '/v1/expenses/$id/void',
      body: <String, dynamic>{if (reason.trim().isNotEmpty) 'reason': reason.trim()},
    );
    return Expense.fromMap(response.asMap);
  }
}
