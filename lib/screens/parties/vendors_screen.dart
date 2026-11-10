import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/utils/error_text.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/party_list_item.dart';
import 'package:mq_sports_erp/models/vendor_model.dart';
import 'package:mq_sports_erp/providers/parties_providers.dart';
import 'package:mq_sports_erp/screens/parties/party_detail_screen.dart';
import 'package:mq_sports_erp/screens/parties/vendor_form_screen.dart';
import 'package:mq_sports_erp/widgets/party_list_view.dart';

class VendorsScreen extends ConsumerWidget {
  const VendorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<VendorModel>> async = ref.watch(vendorsProvider);
    final List<PartyListItem> items = ref.watch(vendorItemsProvider);
    final bool canManage = ref.watch(canManagePartiesProvider);

    ref.listen<AsyncValue<List<VendorModel>>>(vendorsProvider,
        (AsyncValue<List<VendorModel>>? previous,
            AsyncValue<List<VendorModel>> next) {
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
        partyType: PartyType.vendor,
        typeOptions: <MapEntry<String, String>>[
          for (final VendorType t in VendorType.values)
            MapEntry<String, String>(t.name, t.label),
        ],
        emptyText: 'No vendors yet.',
        onSelected: (PartyListItem item) => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => PartyDetailScreen(
              partyType: PartyType.vendor,
              partyId: item.id,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Vendors')),
      body: body,
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const VendorFormScreen(),
                ),
              ),
              icon: const Icon(Icons.add_business_outlined),
              label: const Text('Add vendor'),
            )
          : null,
    );
  }
}
