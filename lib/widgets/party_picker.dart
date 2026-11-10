import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/models/customer_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/party_list_item.dart';
import 'package:mq_sports_erp/models/vendor_model.dart';
import 'package:mq_sports_erp/providers/parties_providers.dart';
import 'package:mq_sports_erp/widgets/party_list_view.dart';

/// Result of the picker sheet. [item] is null when the user chose "no
/// party" (for example a walk-in customer).
class PartyPickResult {
  const PartyPickResult(this.item);

  final PartyListItem? item;
}

/// Typed result: [party] is null when the user cleared the selection.
class PartyPick<T> {
  const PartyPick(this.party);

  final T? party;
}

/// Bottom sheet with a searchable, filterable party list. Picking a row
/// closes the sheet (one tap). Returns null if the sheet was dismissed.
Future<PartyPickResult?> showPartyPickerSheet(
  BuildContext context, {
  required String title,
  required PartyType partyType,
  required List<PartyListItem> items,
  required List<MapEntry<String, String>> typeOptions,
  String? selectedId,
  bool showCreditFilter = false,
  String? clearLabel,
}) {
  return showModalBottomSheet<PartyPickResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext sheetContext) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (BuildContext context, ScrollController controller) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(title,
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
              ),
              if (clearLabel != null)
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_off_outlined)),
                  title: Text(clearLabel),
                  selected: selectedId == null,
                  onTap: () => Navigator.of(sheetContext)
                      .pop(const PartyPickResult(null)),
                ),
              Expanded(
                child: PartyListView(
                  items: items,
                  partyType: partyType,
                  typeOptions: typeOptions,
                  selectedId: selectedId,
                  showCreditFilter: showCreditFilter,
                  hideInactiveByDefault: true,
                  autofocusSearch: true,
                  scrollController: controller,
                  onSelected: (PartyListItem item) =>
                      Navigator.of(sheetContext).pop(PartyPickResult(item)),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Opens the vendor picker. Null = dismissed, `PartyPick(null)` = cleared.
Future<PartyPick<VendorModel>?> showVendorPicker(
  BuildContext context,
  WidgetRef ref, {
  String? selectedId,
}) async {
  final PartyPickResult? result = await showPartyPickerSheet(
    context,
    title: 'Select vendor',
    partyType: PartyType.vendor,
    items: ref.read(vendorItemsProvider),
    typeOptions: <MapEntry<String, String>>[
      for (final VendorType t in VendorType.values)
        MapEntry<String, String>(t.name, t.label),
    ],
    selectedId: selectedId,
  );
  if (result == null) {
    return null;
  }
  final String? id = result.item?.id;
  final List<VendorModel> vendors =
      ref.read(vendorsProvider).valueOrNull ?? <VendorModel>[];
  return PartyPick<VendorModel>(
    id == null ? null : vendors.where((VendorModel v) => v.id == id).firstOrNull,
  );
}

/// Opens the customer picker. With [allowWalkIn] the first row lets the user
/// choose "no customer". Null = dismissed, `PartyPick(null)` = walk-in.
Future<PartyPick<CustomerModel>?> showCustomerPicker(
  BuildContext context,
  WidgetRef ref, {
  String? selectedId,
  bool allowWalkIn = true,
}) async {
  final PartyPickResult? result = await showPartyPickerSheet(
    context,
    title: 'Select customer',
    partyType: PartyType.customer,
    items: ref.read(customerItemsProvider),
    typeOptions: <MapEntry<String, String>>[
      for (final CustomerType t in CustomerType.values)
        MapEntry<String, String>(t.name, t.label),
    ],
    selectedId: selectedId,
    showCreditFilter: true,
    clearLabel: allowWalkIn ? 'Walk-in customer (no account)' : null,
  );
  if (result == null) {
    return null;
  }
  final String? id = result.item?.id;
  final List<CustomerModel> customers =
      ref.read(customersProvider).valueOrNull ?? <CustomerModel>[];
  return PartyPick<CustomerModel>(
    id == null ? null : customers.where((CustomerModel c) => c.id == id).firstOrNull,
  );
}

class _PartyPickerField extends StatelessWidget {
  const _PartyPickerField({
    required this.label,
    required this.displayText,
    required this.hasValue,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final String displayText;
  final bool hasValue;
  final VoidCallback? onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorText: errorText,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          displayText,
          style: hasValue
              ? theme.textTheme.bodyLarge
              : theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// Form field that shows the chosen vendor and opens the picker on tap.
class VendorPickerField extends ConsumerWidget {
  const VendorPickerField({
    super.key,
    required this.vendorId,
    required this.onChanged,
    this.label = 'Vendor',
    this.errorText,
    this.enabled = true,
  });

  final String? vendorId;
  final ValueChanged<VendorModel?> onChanged;
  final String label;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<VendorModel> vendors =
        ref.watch(vendorsProvider).valueOrNull ?? <VendorModel>[];
    final VendorModel? selected =
        vendors.where((VendorModel v) => v.id == vendorId).firstOrNull;
    return _PartyPickerField(
      label: label,
      displayText: selected?.name ?? 'Select vendor',
      hasValue: selected != null,
      errorText: errorText,
      onTap: enabled
          ? () async {
              final PartyPick<VendorModel>? pick =
                  await showVendorPicker(context, ref, selectedId: vendorId);
              if (pick != null) {
                onChanged(pick.party);
              }
            }
          : null,
    );
  }
}

/// Form field that shows the chosen customer and opens the picker on tap.
/// With [allowWalkIn], an empty selection reads "Walk-in customer".
class CustomerPickerField extends ConsumerWidget {
  const CustomerPickerField({
    super.key,
    required this.customerId,
    required this.onChanged,
    this.label = 'Customer',
    this.allowWalkIn = true,
    this.errorText,
    this.enabled = true,
  });

  final String? customerId;
  final ValueChanged<CustomerModel?> onChanged;
  final String label;
  final bool allowWalkIn;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CustomerModel> customers =
        ref.watch(customersProvider).valueOrNull ?? <CustomerModel>[];
    final CustomerModel? selected =
        customers.where((CustomerModel c) => c.id == customerId).firstOrNull;
    return _PartyPickerField(
      label: label,
      displayText: selected?.name ??
          (allowWalkIn ? 'Walk-in customer' : 'Select customer'),
      hasValue: selected != null || allowWalkIn,
      errorText: errorText,
      onTap: enabled
          ? () async {
              final PartyPick<CustomerModel>? pick = await showCustomerPicker(
                context,
                ref,
                selectedId: customerId,
                allowWalkIn: allowWalkIn,
              );
              if (pick != null) {
                onChanged(pick.party);
              }
            }
          : null,
    );
  }
}
