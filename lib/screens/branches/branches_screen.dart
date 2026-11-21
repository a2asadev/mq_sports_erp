import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/branch_model.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/providers/branch_providers.dart';
import 'package:a2_stocks/providers/business_provider.dart';

/// Branches (admin): the switch that makes the business work with several branches, and the list of them. Each branch
/// has its own stock, sales, purchases and stock counts; the catalog, customers and vendors are shared. A branch is
/// never deleted, only switched off once its stock has been moved out. Needs a connection.
class BranchesScreen extends ConsumerStatefulWidget {
  const BranchesScreen({super.key});

  @override
  ConsumerState<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends ConsumerState<BranchesScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action();
      await ref.read(serverChangesProvider)();
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _switchUse(bool on) => _run(() async {
        await ref.read(branchesServiceProvider).setUsesBranches(on);
        await ref.read(businessUpdaterProvider)(ref.read(businessProvider).copyWith(usesBranches: on));
      });

  Future<void> _edit({BranchModel? branch}) async {
    final _BranchDraft? draft = await showDialog<_BranchDraft>(context: context, builder: (BuildContext context) => _BranchDialog(branch: branch));
    if (draft == null) {
      return;
    }
    await _run(() async {
      final service = ref.read(branchesServiceProvider);
      if (branch == null) {
        await service.create(name: draft.name, code: draft.code, address: draft.address, phone: draft.phone);
      } else {
        await service.update(branch.id, name: draft.name, code: draft.code, address: draft.address, phone: draft.phone);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool uses = ref.watch(businessProvider.select((BusinessInfo b) => b.usesBranches));
    final List<BranchModel> branches = (ref.watch(branchesProvider).valueOrNull ?? <BranchModel>[])
      ..sort((BranchModel a, BranchModel b) => a.isDefault == b.isDefault ? a.name.toLowerCase().compareTo(b.name.toLowerCase()) : (a.isDefault ? -1 : 1));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.moduleBranches)),
      floatingActionButton: FloatingActionButton.extended(onPressed: _busy ? null : () => _edit(), icon: const Icon(Icons.add), label: Text(l10n.branchesAdd)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: <Widget>[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: uses,
            onChanged: _busy ? null : _switchUse,
            title: Text(l10n.branchesUseTitle),
            subtitle: Text(l10n.branchesUseHint),
            secondary: _busy ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.store_mall_directory_outlined),
          ),
          const Divider(),
          for (final BranchModel b in branches)
            Card(
              margin: const EdgeInsets.only(top: 8),
              child: ListTile(
                onTap: _busy ? null : () => _edit(branch: b),
                title: Row(
                  children: <Widget>[
                    Flexible(child: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                    if (b.code.isNotEmpty) Padding(padding: const EdgeInsets.only(left: 8), child: Text(b.code, style: const TextStyle(color: AppColors.textMuted))),
                    if (b.isDefault) Padding(padding: const EdgeInsets.only(left: 8), child: Chip(label: Text(l10n.branchMain), visualDensity: VisualDensity.compact)),
                  ],
                ),
                subtitle: Text(<String>[if (b.address.isNotEmpty) b.address, if (b.phone.isNotEmpty) b.phone, if (!b.isActive) l10n.branchSwitchedOff].join(' · ')),
                trailing: b.isDefault ? null : Switch(value: b.isActive, onChanged: _busy ? null : (bool on) => _run(() async => ref.read(branchesServiceProvider).setActive(b.id, on))),
              ),
            ),
          const SizedBox(height: 12),
          Text(l10n.branchesNote, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _BranchDraft {
  const _BranchDraft({required this.name, required this.code, required this.address, required this.phone});

  final String name;
  final String code;
  final String address;
  final String phone;
}

/// Name, code, address and phone of a branch. The dialog owns its fields, so they are not used after it is gone.
class _BranchDialog extends StatefulWidget {
  const _BranchDialog({this.branch});

  final BranchModel? branch;

  @override
  State<_BranchDialog> createState() => _BranchDialogState();
}

class _BranchDialogState extends State<_BranchDialog> {
  late final TextEditingController _name = TextEditingController(text: widget.branch?.name ?? '');
  late final TextEditingController _code = TextEditingController(text: widget.branch?.code ?? '');
  late final TextEditingController _address = TextEditingController(text: widget.branch?.address ?? '');
  late final TextEditingController _phone = TextEditingController(text: widget.branch?.phone ?? '');
  bool _missingName = false;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.branch == null ? l10n.branchesAdd : l10n.branchEdit),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(controller: _name, autofocus: true, maxLength: 80, decoration: InputDecoration(labelText: l10n.branchName, errorText: _missingName ? l10n.branchNeedName : null)),
            TextField(controller: _code, maxLength: 20, decoration: InputDecoration(labelText: l10n.branchCode)),
            TextField(controller: _address, maxLength: 300, decoration: InputDecoration(labelText: l10n.branchAddress)),
            TextField(controller: _phone, maxLength: 40, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: l10n.branchPhone)),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.expensesCancel)),
        FilledButton(
          onPressed: () {
            if (_name.text.trim().isEmpty) {
              setState(() => _missingName = true);
              return;
            }
            Navigator.of(context).pop(_BranchDraft(name: _name.text, code: _code.text, address: _address.text, phone: _phone.text));
          },
          child: Text(l10n.branchSave),
        ),
      ],
    );
  }
}
