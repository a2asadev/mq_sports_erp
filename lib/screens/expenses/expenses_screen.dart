import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/models/expense.dart';
import 'package:a2_stocks/providers/expense_providers.dart';
import 'package:a2_stocks/screens/expenses/expense_categories_dialog.dart';
import 'package:a2_stocks/screens/expenses/expense_form_dialog.dart';
import 'package:a2_stocks/widgets/stat_strip.dart';

/// Expenses (rent, salaries, electricity...): one month at a time, by category. Admin
/// and manager only. It needs a connection; an expense is never edited or deleted,
/// only voided, so the books can always be traced.
class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  Future<void> _void(BuildContext context, WidgetRef ref, Expense expense) async {
    final String? text = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => _VoidDialog(expense: expense),
    );
    if (text == null || !context.mounted) {
      return;
    }
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = context.l10n;
    try {
      await ref.read(expensesServiceProvider).voidExpense(expense.id, reason: text);
      ref.invalidate(expensesProvider);
      ref.invalidate(expenseSummaryProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.expensesVoidDone)));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
    }
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final bool? saved = await showDialog<bool>(context: context, builder: (BuildContext context) => const ExpenseFormDialog());
    if (saved == true) {
      ref.invalidate(expensesProvider);
      ref.invalidate(expenseSummaryProvider);
      ref.invalidate(expenseCategoriesProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ExpensesFilter filter = ref.watch(expensesFilterProvider);
    final AsyncValue<ExpensePage> page = ref.watch(expensesProvider);
    final List<ExpenseCategory> categories = ref.watch(expenseCategoriesProvider).valueOrNull ?? <ExpenseCategory>[];
    final String locale = Localizations.localeOf(context).toString();
    final DateTime now = DateTime.now();
    final bool isThisMonth = filter.month.year == now.year && filter.month.month == now.month;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.moduleExpenses),
        actions: <Widget>[
          IconButton(
            tooltip: context.l10n.expensesCategories,
            icon: const Icon(Icons.category_outlined),
            onPressed: () async {
              await showDialog<void>(context: context, builder: (BuildContext context) => const ExpenseCategoriesDialog());
              ref.invalidate(expenseCategoriesProvider);
            },
          ),
          IconButton(
            tooltip: context.l10n.registerRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(expensesProvider);
              ref.invalidate(expenseCategoriesProvider);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.expensesAdd),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: <Widget>[
                IconButton(
                  tooltip: context.l10n.expensesPreviousMonth,
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => ref.read(expensesFilterProvider.notifier).state =
                      filter.copyWith(month: DateTime(filter.month.year, filter.month.month - 1)),
                ),
                Text(DateFormat.yMMMM(locale).format(filter.month), style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  tooltip: context.l10n.expensesNextMonth,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: isThisMonth
                      ? null
                      : () => ref.read(expensesFilterProvider.notifier).state =
                          filter.copyWith(month: DateTime(filter.month.year, filter.month.month + 1)),
                ),
                const Spacer(),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String?>(
                    key: ValueKey<String?>(filter.categoryId),
                    initialValue: filter.categoryId,
                    isExpanded: true,
                    decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                    items: <DropdownMenuItem<String?>>[
                      DropdownMenuItem<String?>(value: null, child: Text(context.l10n.expensesAllCategories)),
                      for (final ExpenseCategory c in categories)
                        DropdownMenuItem<String?>(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (String? id) => ref.read(expensesFilterProvider.notifier).state =
                        id == null ? filter.copyWith(clearCategory: true) : filter.copyWith(categoryId: id),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          Expanded(
            child: page.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stack) =>
                  Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(errorMessageOf(error), textAlign: TextAlign.center))),
              data: (ExpensePage data) => _body(context, ref, data),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, ExpensePage data) {
    final List<Expense> counted = data.items.where((Expense e) => !e.voided).toList();
    final Map<String, double> byCategory = <String, double>{};
    for (final Expense e in counted) {
      byCategory[e.categoryName] = (byCategory[e.categoryName] ?? 0) + e.amount;
    }
    final List<MapEntry<String, double>> ranked = byCategory.entries.toList()
      ..sort((MapEntry<String, double> a, MapEntry<String, double> b) => b.value.compareTo(a.value));
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: <Widget>[
        StatStrip(
          items: <StatItem>[
            StatItem(icon: Icons.payments_outlined, color: AppColors.danger, label: context.l10n.expensesSpent, value: formatMoney(data.sum)),
            StatItem(
              icon: Icons.receipt_long_outlined,
              color: AppColors.sky,
              label: context.l10n.expensesCountLabel,
              value: '${counted.length}',
            ),
          ],
        ),
        if (ranked.isNotEmpty)
          Card(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(context.l10n.expensesByCategory, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  for (final MapEntry<String, double> row in ranked.take(8))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: <Widget>[
                          Expanded(flex: 3, child: Text(row.key, overflow: TextOverflow.ellipsis)),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: LinearProgressIndicator(
                                value: data.sum <= 0 ? 0 : (row.value / data.sum).clamp(0, 1).toDouble(),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                                color: AppColors.danger,
                                backgroundColor: AppColors.dangerSoft,
                              ),
                            ),
                          ),
                          SizedBox(width: 96, child: Text(formatMoney(row.value), textAlign: TextAlign.end)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        if (data.items.isEmpty)
          Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(context.l10n.expensesNone)))
        else
          for (final Expense e in data.items) _tile(context, ref, e),
      ],
    );
  }

  Widget _tile(BuildContext context, WidgetRef ref, Expense e) {
    final TextStyle strike = e.voided
        ? const TextStyle(decoration: TextDecoration.lineThrough, color: AppColors.textMuted)
        : const TextStyle(fontWeight: FontWeight.w600);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: ListTile(
        leading: Icon(e.voided ? Icons.block : Icons.receipt_long_outlined, color: e.voided ? AppColors.textMuted : AppColors.danger),
        title: Text(e.categoryName, style: e.voided ? const TextStyle(decoration: TextDecoration.lineThrough) : null),
        subtitle: Text(<String>[
          formatDate(e.date),
          if (e.payee.isNotEmpty) e.payee,
          paymentMethodLabelOf(e.paymentMethod),
          if (e.paymentRef.isNotEmpty) e.paymentRef,
          if (e.note.isNotEmpty) e.note,
          if (e.byName.isNotEmpty) context.l10n.orderDetailBy(e.byName),
          if (e.voided) '${context.l10n.expensesVoided}${e.voidReason.isEmpty ? '' : ': ${e.voidReason}'}',
        ].join(' · ')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(formatMoney(e.amount), style: strike),
            if (!e.voided)
              PopupMenuButton<String>(
                onSelected: (String _) => _void(context, ref, e),
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<String>>[PopupMenuItem<String>(value: 'void', child: Text(context.l10n.expensesVoid))],
              ),
          ],
        ),
      ),
    );
  }
}

/// Asks why an expense is voided. It owns its text field, so the field is not used after the dialog is gone.
class _VoidDialog extends StatefulWidget {
  const _VoidDialog({required this.expense});

  final Expense expense;

  @override
  State<_VoidDialog> createState() => _VoidDialogState();
}

class _VoidDialogState extends State<_VoidDialog> {
  final TextEditingController _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.expensesVoidTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(context.l10n.expensesVoidBody(formatMoney(widget.expense.amount), widget.expense.categoryName)),
          const SizedBox(height: 12),
          TextField(
            controller: _reason,
            maxLength: 300,
            decoration: InputDecoration(labelText: context.l10n.expensesVoidReason, border: const OutlineInputBorder()),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.expensesCancel)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () => Navigator.pop(context, _reason.text),
          child: Text(context.l10n.expensesVoid),
        ),
      ],
    );
  }
}
