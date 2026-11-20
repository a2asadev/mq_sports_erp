import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/expense.dart';
import 'package:a2_stocks/providers/expense_providers.dart';

/// The usual expense categories, in the language of the app. The names become the
/// business's own data: it can rename or switch off any of them.
List<String> commonExpenseCategories(AppLocalizations l10n) => <String>[
      l10n.expenseCommonRent,
      l10n.expenseCommonSalaries,
      l10n.expenseCommonElectricity,
      l10n.expenseCommonWaterGas,
      l10n.expenseCommonInternetPhone,
      l10n.expenseCommonTransport,
      l10n.expenseCommonRepairs,
      l10n.expenseCommonPackaging,
      l10n.expenseCommonMarketing,
      l10n.expenseCommonTeaFood,
      l10n.expenseCommonTaxesFees,
      l10n.expenseCommonOther,
    ];

/// Add, rename and switch off expense categories. A category with expenses is never
/// deleted, only switched off.
class ExpenseCategoriesDialog extends ConsumerStatefulWidget {
  const ExpenseCategoriesDialog({super.key});

  @override
  ConsumerState<ExpenseCategoriesDialog> createState() => _ExpenseCategoriesDialogState();
}

class _ExpenseCategoriesDialogState extends ConsumerState<ExpenseCategoriesDialog> {
  final TextEditingController _name = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(expenseCategoriesProvider);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _add() async {
    final String name = _name.text.trim();
    if (name.isEmpty) {
      return;
    }
    await _run(() async {
      await ref.read(expensesServiceProvider).createCategory(name);
      _name.clear();
    });
  }

  Future<void> _addCommon(List<ExpenseCategory> existing) async {
    final AppLocalizations l10n = context.l10n;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final Set<String> have = existing.map((ExpenseCategory c) => c.name.toLowerCase()).toSet();
    int added = 0;
    await _run(() async {
      for (final String name in commonExpenseCategories(l10n)) {
        if (!have.contains(name.toLowerCase())) {
          await ref.read(expensesServiceProvider).createCategory(name);
          added++;
        }
      }
    });
    messenger.showSnackBar(SnackBar(content: Text(l10n.expenseCatCommonAdded(added))));
  }

  Future<void> _rename(ExpenseCategory category) async {
    final String? name = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => _RenameDialog(initial: category.name),
    );
    if (name == null || name.isEmpty || name == category.name) {
      return;
    }
    await _run(() => ref.read(expensesServiceProvider).updateCategory(category.id, name: name));
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ExpenseCategory>> categories = ref.watch(expenseCategoriesProvider);
    final List<ExpenseCategory> list = categories.valueOrNull ?? <ExpenseCategory>[];
    return AlertDialog(
      title: Text(context.l10n.expenseCatTitle),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _name,
                    enabled: !_busy,
                    onSubmitted: (String _) => _add(),
                    decoration: InputDecoration(labelText: context.l10n.expenseCatNew, border: const OutlineInputBorder(), isDense: true),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _busy ? null : _add, child: Text(context.l10n.expenseCatAdd)),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _busy ? null : () => _addCommon(list),
                icon: const Icon(Icons.playlist_add),
                label: Text(context.l10n.expenseCatAddCommon),
              ),
            ),
            Flexible(
              child: categories.when(
                loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
                error: (Object error, StackTrace stack) => Text(errorMessageOf(error)),
                data: (List<ExpenseCategory> items) => ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    for (final ExpenseCategory c in items)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(c.name, style: c.isActive ? null : const TextStyle(decoration: TextDecoration.lineThrough)),
                        subtitle: Text(context.l10n.expenseCatCount(c.expenseCount)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              tooltip: context.l10n.expenseCatRename,
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: _busy ? null : () => _rename(c),
                            ),
                            Switch(
                              value: c.isActive,
                              onChanged: _busy ? null : (bool on) => _run(() => ref.read(expensesServiceProvider).updateCategory(c.id, isActive: on)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.expenseCatDone))],
    );
  }
}

/// Asks for a new name. It owns its text field, so the field is not used after the dialog is gone.
class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.expenseCatRename),
      content: TextField(controller: _name, autofocus: true, decoration: const InputDecoration(border: OutlineInputBorder())),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.expensesCancel)),
        FilledButton(onPressed: () => Navigator.pop(context, _name.text.trim()), child: Text(context.l10n.expenseCatSave)),
      ],
    );
  }
}
