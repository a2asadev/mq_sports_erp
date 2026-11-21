import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/branch_rules.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/branch_model.dart';
import 'package:a2_stocks/models/stock_ledger_model.dart';
import 'package:a2_stocks/models/stock_transfer.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/transfers_service.dart';
import 'package:a2_stocks/providers/core_providers.dart';
import 'package:uuid/uuid.dart';
import 'package:a2_stocks/providers/branch_providers.dart';
import 'package:a2_stocks/providers/stock_providers.dart';
import 'package:a2_stocks/widgets/variant_picker.dart';

final Provider<TransfersService> transfersServiceProvider = Provider<TransfersService>((Ref ref) => TransfersService(ref.watch(apiClientProvider)));

/// The stock transfers made so far, newest first.
final AutoDisposeFutureProvider<List<StockTransfer>> stockTransfersProvider = FutureProvider.autoDispose<List<StockTransfer>>((Ref ref) {
  ref.watch(syncTickProvider);
  return ref.watch(transfersServiceProvider).list();
});

/// Stock moved from one branch to another: the history, and a form to move some more. Needs a connection; the stock of
/// both branches changes at once on the server and reaches every device through the sync.
class StockTransfersScreen extends ConsumerWidget {
  const StockTransfersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<List<StockTransfer>> list = ref.watch(stockTransfersProvider);
    final String locale = Localizations.localeOf(context).toString();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.moduleStockTransfers),
        actions: <Widget>[IconButton(tooltip: l10n.registerRefresh, icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(stockTransfersProvider))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l10n.transferNew),
        onPressed: () async {
          final bool? done = await Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (BuildContext context) => const TransferFormScreen()));
          if (done == true) {
            ref.invalidate(stockTransfersProvider);
          }
        },
      ),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(errorMessageOf(error), textAlign: TextAlign.center))),
        data: (List<StockTransfer> items) => items.isEmpty
            ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.transferNone, textAlign: TextAlign.center)))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: <Widget>[
                  for (final StockTransfer t in items)
                    Card(
                      margin: const EdgeInsets.only(top: 8),
                      child: ExpansionTile(
                        title: Text('${t.fromBranchName}  →  ${t.toBranchName}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${t.transferNo} · ${DateFormat.yMMMd(locale).add_jm().format(t.date)} · ${l10n.transferUnits(t.units)}'),
                        children: <Widget>[
                          for (final TransferLine line in t.items) ListTile(dense: true, title: Text('${line.productName} (${line.variantLabel})'), trailing: Text('${line.quantity}')),
                          if (t.note.isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), child: Align(alignment: Alignment.centerLeft, child: Text(t.note, style: const TextStyle(color: AppColors.textMuted)))),
                          if (t.byName.isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Align(alignment: Alignment.centerLeft, child: Text(l10n.transferBy(t.byName), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)))),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

/// A new transfer: from which branch to which, and what.
class TransferFormScreen extends ConsumerStatefulWidget {
  const TransferFormScreen({super.key});

  @override
  ConsumerState<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends ConsumerState<TransferFormScreen> {
  String _from = '';
  String _to = '';
  final Map<String, VariantPick> _picks = <String, VariantPick>{};
  final Map<String, int> _quantities = <String, int>{};
  final TextEditingController _note = TextEditingController();
  // One id per form, so pressing Save twice (or a retry after a dropped connection) moves the stock once.
  final String _id = const Uuid().v4();
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  int _available(String variantId) {
    final List<StockLedgerModel> entries = ref.read(stockLedgerProvider).valueOrNull ?? <StockLedgerModel>[];
    return stockByVariant(entries, branchId: _from, defaultBranchId: ref.read(defaultBranchIdProvider))[variantId] ?? 0;
  }

  Future<void> _add() async {
    final VariantPick? pick = await showVariantPicker(context, ref);
    if (pick == null) {
      return;
    }
    setState(() {
      _picks[pick.variant.id] = pick;
      _quantities[pick.variant.id] = (_quantities[pick.variant.id] ?? 0) + 1;
    });
  }

  String? _problem(AppLocalizations l10n) {
    if (_from.isEmpty || _to.isEmpty || _from == _to) {
      return l10n.transferChooseTwoBranches;
    }
    if (_quantities.isEmpty) {
      return l10n.transferAddItems;
    }
    for (final MapEntry<String, int> e in _quantities.entries) {
      if (e.value > _available(e.key)) {
        return l10n.transferNotEnough(_picks[e.key]?.variant.sku ?? '');
      }
    }
    return null;
  }

  Future<void> _save() async {
    final AppLocalizations l10n = context.l10n;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final String? problem = _problem(l10n);
    if (problem != null) {
      messenger.showSnackBar(SnackBar(content: Text(problem)));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(transfersServiceProvider).create(fromBranchId: _from, toBranchId: _to, quantities: _quantities, note: _note.text, id: _id);
      await ref.read(serverChangesProvider)();
      navigator.pop(true);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final List<BranchModel> branches = ref.watch(activeBranchesProvider);
    final String working = ref.watch(workingBranchIdProvider);
    if (_from.isEmpty && branches.isNotEmpty) {
      _from = branches.any((BranchModel b) => b.id == working) ? working : branches.first.id;
    }
    if ((_to.isEmpty || _to == _from) && branches.length > 1) {
      _to = branches.firstWhere((BranchModel b) => b.id != _from).id;
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.transferNew)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          DropdownButtonFormField<String>(
            value: _from,
            decoration: InputDecoration(labelText: l10n.transferFrom, border: const OutlineInputBorder()),
            items: <DropdownMenuItem<String>>[for (final BranchModel b in branches) DropdownMenuItem<String>(value: b.id, child: Text(b.name))],
            onChanged: _busy ? null : (String? v) => setState(() => _from = v ?? _from),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _to,
            decoration: InputDecoration(labelText: l10n.transferTo, border: const OutlineInputBorder()),
            items: <DropdownMenuItem<String>>[for (final BranchModel b in branches) DropdownMenuItem<String>(value: b.id, child: Text(b.name))],
            onChanged: _busy ? null : (String? v) => setState(() => _to = v ?? _to),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(child: Text(l10n.transferItems, style: Theme.of(context).textTheme.titleMedium)),
              OutlinedButton.icon(onPressed: _busy ? null : _add, icon: const Icon(Icons.add), label: Text(l10n.transferAddItem)),
            ],
          ),
          for (final MapEntry<String, int> e in _quantities.entries)
            Card(
              margin: const EdgeInsets.only(top: 8),
              child: ListTile(
                title: Text('${_picks[e.key]?.product.name ?? ''} (${_picks[e.key]?.variant.sku ?? ''})'),
                subtitle: Text(l10n.transferAvailable(_available(e.key)), style: TextStyle(color: e.value > _available(e.key) ? AppColors.danger : AppColors.textMuted)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: _busy ? null : () => setState(() => e.value <= 1 ? _quantities.remove(e.key) : _quantities[e.key] = e.value - 1)),
                    Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _busy ? null : () => setState(() => _quantities[e.key] = e.value + 1)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          TextField(controller: _note, enabled: !_busy, maxLength: 500, decoration: InputDecoration(labelText: l10n.transferNote, border: const OutlineInputBorder())),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _busy ? null : _save,
            icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
            label: Text(l10n.transferSave),
          ),
        ],
      ),
    );
  }
}
