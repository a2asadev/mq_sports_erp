import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/utils/error_text.dart';
import 'package:mq_sports_erp/core/utils/formatters.dart';
import 'package:mq_sports_erp/models/customer_model.dart';
import 'package:mq_sports_erp/models/ledger_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/vendor_model.dart';
import 'package:mq_sports_erp/providers/parties_providers.dart';
import 'package:mq_sports_erp/screens/parties/customer_form_screen.dart';
import 'package:mq_sports_erp/screens/parties/ledger_entry_dialog.dart';
import 'package:mq_sports_erp/screens/parties/vendor_form_screen.dart';

class _PartyData {
  const _PartyData({
    required this.name,
    required this.typeLabel,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    required this.notes,
    required this.openingBalance,
    required this.creditLimit,
    required this.isActive,
  });

  final String name;
  final String typeLabel;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String notes;
  final double openingBalance;
  final double creditLimit;
  final bool isActive;
}

enum _DetailAction { edit, delete }

/// Details and balance ledger of one vendor or customer.
class PartyDetailScreen extends ConsumerWidget {
  const PartyDetailScreen({
    super.key,
    required this.partyType,
    required this.partyId,
  });

  final PartyType partyType;
  final String partyId;

  _PartyData? _resolve(WidgetRef ref) {
    if (partyType == PartyType.vendor) {
      final VendorModel? v = (ref.watch(vendorsProvider).valueOrNull ?? <VendorModel>[])
          .where((VendorModel x) => x.id == partyId)
          .firstOrNull;
      if (v == null) {
        return null;
      }
      return _PartyData(
        name: v.name,
        typeLabel: v.type.label,
        contactPerson: v.contactPerson,
        phone: v.phone,
        email: v.email,
        address: v.address,
        city: v.city,
        notes: v.notes,
        openingBalance: v.openingBalance,
        creditLimit: 0,
        isActive: v.isActive,
      );
    }
    final CustomerModel? c = (ref.watch(customersProvider).valueOrNull ?? <CustomerModel>[])
        .where((CustomerModel x) => x.id == partyId)
        .firstOrNull;
    if (c == null) {
      return null;
    }
    return _PartyData(
      name: c.name,
      typeLabel: c.type.label,
      contactPerson: c.contactPerson,
      phone: c.phone,
      email: c.email,
      address: c.address,
      city: c.city,
      notes: c.notes,
      openingBalance: c.openingBalance,
      creditLimit: c.creditLimit,
      isActive: c.isActive,
    );
  }

  void _edit(BuildContext context, WidgetRef ref) {
    final Widget form;
    if (partyType == PartyType.vendor) {
      final VendorModel? v = (ref.read(vendorsProvider).valueOrNull ?? <VendorModel>[])
          .where((VendorModel x) => x.id == partyId)
          .firstOrNull;
      form = VendorFormScreen(vendor: v);
    } else {
      final CustomerModel? c = (ref.read(customersProvider).valueOrNull ?? <CustomerModel>[])
          .where((CustomerModel x) => x.id == partyId)
          .firstOrNull;
      form = CustomerFormScreen(customer: c);
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (BuildContext context) => form),
    );
  }

  Future<bool> _confirm(BuildContext context, String title, String message) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _deleteParty(BuildContext context, WidgetRef ref, String name) async {
    final bool confirmed = await _confirm(
      context,
      'Delete ${partyType.label.toLowerCase()}',
      'Delete "$name"?',
    );
    if (!confirmed) {
      return;
    }
    final bool deleted = partyType == PartyType.vendor
        ? await ref.read(vendorsProvider.notifier).deleteVendor(partyId)
        : await ref.read(customersProvider.notifier).deleteCustomer(partyId);
    if (deleted && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _addEntry(BuildContext context, WidgetRef ref) async {
    final LedgerEntryDraft? draft =
        await showLedgerEntryDialog(context, partyType: partyType);
    if (draft == null) {
      return;
    }
    await ref.read(ledgerEntriesProvider.notifier).addEntry(LedgerModel(
          partyType: partyType,
          partyId: partyId,
          entryType: draft.type,
          amount: draft.amount,
          entryDate: draft.date,
          description: draft.description,
          reference: draft.reference,
        ));
  }

  Future<void> _deleteEntry(BuildContext context, WidgetRef ref, LedgerModel entry) async {
    final bool confirmed = await _confirm(
      context,
      'Delete entry',
      'Delete this ${entry.entryType.labelFor(partyType).toLowerCase()} of ${formatAmount(entry.amount)}?',
    );
    if (confirmed) {
      await ref.read(ledgerEntriesProvider.notifier).deleteEntry(entry.id);
    }
  }

  Widget _infoLine(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool canManage = ref.watch(canManagePartiesProvider);
    final _PartyData? party = _resolve(ref);
    final List<LedgerModel> allEntries =
        ref.watch(ledgerEntriesProvider).valueOrNull ?? <LedgerModel>[];

    ref.listen<AsyncValue<List<LedgerModel>>>(ledgerEntriesProvider,
        (AsyncValue<List<LedgerModel>>? previous,
            AsyncValue<List<LedgerModel>> next) {
      final Object? error = next.error;
      if (error != null && !identical(error, previous?.error)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
      }
    });

    if (party == null) {
      return Scaffold(
        appBar: AppBar(title: Text(partyType.label)),
        body: const Center(child: Text('This record no longer exists.')),
      );
    }

    // Oldest first to compute the running balance, then shown newest first.
    final List<LedgerModel> entries = allEntries
        .where((LedgerModel e) => e.partyId == partyId)
        .toList()
      ..sort((LedgerModel a, LedgerModel b) {
        final int byDate = a.entryDate.compareTo(b.entryDate);
        return byDate != 0 ? byDate : a.createdAt.compareTo(b.createdAt);
      });
    double running = party.openingBalance;
    final List<MapEntry<LedgerModel, double>> rows =
        <MapEntry<LedgerModel, double>>[];
    for (final LedgerModel entry in entries) {
      running += entry.signedAmount;
      rows.add(MapEntry<LedgerModel, double>(entry, running));
    }
    final double balance = running;
    final bool overLimit = party.creditLimit > 0 && balance > party.creditLimit;
    final List<MapEntry<LedgerModel, double>> newestFirst = rows.reversed.toList();

    final List<String> addressParts = <String>[party.address, party.city]
        .where((String p) => p.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(party.name),
        actions: <Widget>[
          if (canManage)
            PopupMenuButton<_DetailAction>(
              onSelected: (_DetailAction action) async {
                switch (action) {
                  case _DetailAction.edit:
                    _edit(context, ref);
                  case _DetailAction.delete:
                    await _deleteParty(context, ref, party.name);
                }
              },
              itemBuilder: (BuildContext context) =>
                  const <PopupMenuEntry<_DetailAction>>[
                PopupMenuItem<_DetailAction>(
                  value: _DetailAction.edit,
                  child: Text('Edit'),
                ),
                PopupMenuItem<_DetailAction>(
                  value: _DetailAction.delete,
                  child: Text('Delete'),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Chip(
                        label: Text(party.typeLabel),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (!party.isActive) ...<Widget>[
                        const SizedBox(width: 8),
                        const Chip(
                          label: Text('Inactive'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatAmount(balance.abs()),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: overLimit ? theme.colorScheme.error : null,
                    ),
                  ),
                  Text(partyType.balanceCaption(balance)),
                  if (party.creditLimit > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        overLimit
                            ? 'Over the credit limit of ${formatAmount(party.creditLimit)}'
                            : 'Credit limit ${formatAmount(party.creditLimit)}',
                        style: TextStyle(
                          color: overLimit ? theme.colorScheme.error : null,
                        ),
                      ),
                    ),
                  const Divider(height: 24),
                  if (party.contactPerson.isNotEmpty)
                    _infoLine(Icons.person_outline, party.contactPerson),
                  if (party.phone.isNotEmpty)
                    _infoLine(Icons.phone_outlined, party.phone),
                  if (party.email.isNotEmpty)
                    _infoLine(Icons.email_outlined, party.email),
                  if (addressParts.isNotEmpty)
                    _infoLine(Icons.location_on_outlined, addressParts.join(', ')),
                  if (party.notes.isNotEmpty)
                    _infoLine(Icons.notes_outlined, party.notes),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Ledger', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (party.openingBalance.abs() >= 0.005)
            Card(
              child: ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Opening balance'),
                trailing: Text(formatAmount(party.openingBalance)),
              ),
            ),
          if (newestFirst.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No ledger entries yet.'),
            )
          else
            for (final MapEntry<LedgerModel, double> row in newestFirst)
              Card(
                child: ListTile(
                  leading: Icon(
                    row.key.entryType == LedgerEntryType.charge
                        ? Icons.add_circle_outline
                        : Icons.remove_circle_outline,
                  ),
                  title: Text(row.key.description.isNotEmpty
                      ? row.key.description
                      : row.key.entryType.labelFor(partyType)),
                  subtitle: Text(
                    <String>[
                      formatDate(row.key.entryDate),
                      row.key.entryType.labelFor(partyType),
                      if (row.key.reference.isNotEmpty) 'Ref ${row.key.reference}',
                    ].join(' · '),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '${row.key.entryType == LedgerEntryType.charge ? '+' : '-'}'
                            '${formatAmount(row.key.amount)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text('Bal ${formatAmount(row.value)}',
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                      if (canManage && row.key.purchaseId.isEmpty)
                        IconButton(
                          tooltip: 'Delete entry',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteEntry(context, ref, row.key),
                        ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _addEntry(context, ref),
              icon: const Icon(Icons.post_add),
              label: const Text('Add entry'),
            )
          : null,
    );
  }
}
