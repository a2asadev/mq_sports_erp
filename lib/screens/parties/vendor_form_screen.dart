import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/vendor_model.dart';
import 'package:mq_sports_erp/providers/parties_providers.dart';
import 'package:mq_sports_erp/screens/parties/party_form_screen.dart';

class VendorFormScreen extends ConsumerWidget {
  const VendorFormScreen({super.key, this.vendor});

  final VendorModel? vendor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final VendorModel? existing = vendor;
    return PartyFormScreen(
      partyType: PartyType.vendor,
      typeOptions: <MapEntry<String, String>>[
        for (final VendorType t in VendorType.values)
          MapEntry<String, String>(t.name, t.label),
      ],
      initial: existing == null
          ? null
          : PartyFormData(
              name: existing.name,
              typeKey: existing.type.name,
              contactPerson: existing.contactPerson,
              phone: existing.phone,
              email: existing.email,
              address: existing.address,
              city: existing.city,
              openingBalance: existing.openingBalance,
              notes: existing.notes,
              isActive: existing.isActive,
            ),
      onSubmit: (PartyFormData data) {
        final VendorsNotifier notifier = ref.read(vendorsProvider.notifier);
        if (existing == null) {
          return notifier.createVendor(VendorModel(
            name: data.name,
            type: VendorType.fromName(data.typeKey),
            contactPerson: data.contactPerson,
            phone: data.phone,
            email: data.email,
            address: data.address,
            city: data.city,
            notes: data.notes,
            openingBalance: data.openingBalance,
            isActive: data.isActive,
          ));
        }
        return notifier.updateVendor(existing.copyWith(
          name: data.name,
          type: VendorType.fromName(data.typeKey),
          contactPerson: data.contactPerson,
          phone: data.phone,
          email: data.email,
          address: data.address,
          city: data.city,
          notes: data.notes,
          openingBalance: data.openingBalance,
          isActive: data.isActive,
        ));
      },
    );
  }
}
