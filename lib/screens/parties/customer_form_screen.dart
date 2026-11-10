import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/models/customer_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/providers/parties_providers.dart';
import 'package:mq_sports_erp/screens/parties/party_form_screen.dart';

class CustomerFormScreen extends ConsumerWidget {
  const CustomerFormScreen({super.key, this.customer});

  final CustomerModel? customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CustomerModel? existing = customer;
    return PartyFormScreen(
      partyType: PartyType.customer,
      typeOptions: <MapEntry<String, String>>[
        for (final CustomerType t in CustomerType.values)
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
              creditLimit: existing.creditLimit,
              openingBalance: existing.openingBalance,
              notes: existing.notes,
              isActive: existing.isActive,
            ),
      onSubmit: (PartyFormData data) {
        final CustomersNotifier notifier = ref.read(customersProvider.notifier);
        if (existing == null) {
          return notifier.createCustomer(CustomerModel(
            name: data.name,
            type: CustomerType.fromName(data.typeKey),
            contactPerson: data.contactPerson,
            phone: data.phone,
            email: data.email,
            address: data.address,
            city: data.city,
            notes: data.notes,
            creditLimit: data.creditLimit,
            openingBalance: data.openingBalance,
            isActive: data.isActive,
          ));
        }
        return notifier.updateCustomer(existing.copyWith(
          name: data.name,
          type: CustomerType.fromName(data.typeKey),
          contactPerson: data.contactPerson,
          phone: data.phone,
          email: data.email,
          address: data.address,
          city: data.city,
          notes: data.notes,
          creditLimit: data.creditLimit,
          openingBalance: data.openingBalance,
          isActive: data.isActive,
        ));
      },
    );
  }
}
