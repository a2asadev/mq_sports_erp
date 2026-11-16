import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/models/customer_model.dart';
import 'package:a2_stocks/models/party_enums.dart';
import 'package:a2_stocks/models/party_list_item.dart';
import 'package:a2_stocks/providers/parties_providers.dart';
import 'package:a2_stocks/screens/parties/customer_form_screen.dart';
import 'package:a2_stocks/screens/parties/party_detail_screen.dart';
import 'package:a2_stocks/widgets/party_list_view.dart';

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CustomerModel>> async = ref.watch(customersProvider);
    final List<PartyListItem> items = ref.watch(customerItemsProvider);
    final bool canManage = ref.watch(canManagePartiesProvider);

    ref.listen<AsyncValue<List<CustomerModel>>>(customersProvider,
        (AsyncValue<List<CustomerModel>>? previous,
            AsyncValue<List<CustomerModel>> next) {
      final Object? error = next.error;
      if (error != null && !identical(error, previous?.error)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
      }
    });

    Widget body;
    if (async.valueOrNull == null) {
      final Object? error = async.error;
      body = Center(
        child: error != null
            ? Text(errorMessageOf(error))
            : const CircularProgressIndicator(),
      );
    } else {
      body = PartyListView(
        items: items,
        partyType: PartyType.customer,
        typeOptions: <MapEntry<String, String>>[
          for (final CustomerType t in CustomerType.values)
            MapEntry<String, String>(t.name, t.label),
        ],
        showCreditFilter: true,
        emptyText: 'No customers yet.',
        asCards: true,
        onSelected: (PartyListItem item) => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => PartyDetailScreen(
              partyType: PartyType.customer,
              partyId: item.id,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: body,
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const CustomerFormScreen(),
                ),
              ),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add customer'),
            )
          : null,
    );
  }
}
