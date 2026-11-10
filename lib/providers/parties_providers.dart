import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/customer_model.dart';
import 'package:mq_sports_erp/models/ledger_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/party_list_item.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/user_role.dart';
import 'package:mq_sports_erp/models/vendor_model.dart';
import 'package:mq_sports_erp/providers/base_list_notifier.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';

/// Admins and managers may change vendors, customers and ledgers.
final Provider<bool> canManagePartiesProvider = Provider<bool>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  return user != null &&
      user.isActive &&
      (user.role == UserRole.admin || user.role == UserRole.manager);
});

const String _noPermissionMessage =
    'Only admins and managers can change vendors, customers and ledgers.';

final Provider<BaseRepository<LedgerModel>> ledgerRepositoryProvider =
    Provider<BaseRepository<LedgerModel>>((Ref ref) {
  return BaseRepository<LedgerModel>(
    collectionName: StorageKeys.ledgers,
    entityLabel: 'Ledger entry',
    local: HiveLocalRepository<LedgerModel>(
      boxName: StorageKeys.ledgers,
      fromMap: LedgerModel.fromMap,
    ),
    pendingStore: ref.watch(pendingChangeStoreProvider),
    fromMap: LedgerModel.fromMap,
    labelOf: (LedgerModel entry) =>
        '${entry.entryType.name} ${entry.amount.toStringAsFixed(2)}',
  );
});

/// A party can only be deleted while it has no ledger entries and no opening
/// balance (deactivate it instead). Re-checked after a sync download.
Future<String?> _partyDeleteReason(
  Ref ref,
  String partyId,
  double? openingBalance,
) async {
  final List<LedgerModel> entries =
      await ref.read(ledgerRepositoryProvider).getLocal();
  if (entries.any((LedgerModel e) => e.partyId == partyId)) {
    return 'it has ledger entries';
  }
  if (openingBalance != null && openingBalance.abs() >= 0.005) {
    return 'it has an opening balance';
  }
  return null;
}

final Provider<BaseRepository<VendorModel>> vendorRepositoryProvider =
    Provider<BaseRepository<VendorModel>>((Ref ref) {
  final HiveLocalRepository<VendorModel> local =
      HiveLocalRepository<VendorModel>(
    boxName: StorageKeys.vendors,
    fromMap: VendorModel.fromMap,
  );
  return BaseRepository<VendorModel>(
    collectionName: StorageKeys.vendors,
    entityLabel: 'Vendor',
    local: local,
    pendingStore: ref.watch(pendingChangeStoreProvider),
    fromMap: VendorModel.fromMap,
    labelOf: (VendorModel vendor) => vendor.name,
    deleteGuard: (String id) async {
      final VendorModel? vendor = await local.getById(id);
      return _partyDeleteReason(ref, id, vendor?.openingBalance);
    },
  );
});

final Provider<BaseRepository<CustomerModel>> customerRepositoryProvider =
    Provider<BaseRepository<CustomerModel>>((Ref ref) {
  final HiveLocalRepository<CustomerModel> local =
      HiveLocalRepository<CustomerModel>(
    boxName: StorageKeys.customers,
    fromMap: CustomerModel.fromMap,
  );
  return BaseRepository<CustomerModel>(
    collectionName: StorageKeys.customers,
    entityLabel: 'Customer',
    local: local,
    pendingStore: ref.watch(pendingChangeStoreProvider),
    fromMap: CustomerModel.fromMap,
    labelOf: (CustomerModel customer) => customer.name,
    deleteGuard: (String id) async {
      final CustomerModel? customer = await local.getById(id);
      return _partyDeleteReason(ref, id, customer?.openingBalance);
    },
  );
});

class VendorsNotifier extends BaseListNotifier<VendorModel> {
  @override
  BaseRepository<VendorModel> get repository =>
      ref.read(vendorRepositoryProvider);

  List<VendorModel> get _items => state.valueOrNull ?? <VendorModel>[];

  String? _validate(VendorModel vendor) {
    if (vendor.name.trim().isEmpty) {
      return 'Vendor name is required.';
    }
    final List<VendorModel> others =
        _items.where((VendorModel v) => v.id != vendor.id).toList();
    final String name = vendor.name.trim().toLowerCase();
    if (others.any((VendorModel v) => v.name.trim().toLowerCase() == name)) {
      return 'A vendor named "${vendor.name.trim()}" already exists.';
    }
    final String phone = vendor.phone.trim();
    if (phone.isNotEmpty &&
        others.any((VendorModel v) => v.phone.trim() == phone)) {
      return 'A vendor with this phone number already exists.';
    }
    return null;
  }

  Future<bool> createVendor(VendorModel vendor) async {
    if (!ref.read(canManagePartiesProvider)) {
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
    }
    final String? problem = _validate(vendor);
    if (problem != null) {
      return reportFailure(ValidationException(problem));
    }
    await add(vendor);
    return !state.hasError;
  }

  Future<bool> updateVendor(VendorModel vendor) async {
    if (!ref.read(canManagePartiesProvider)) {
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
    }
    final String? problem = _validate(vendor);
    if (problem != null) {
      return reportFailure(ValidationException(problem));
    }
    await updateItem(vendor);
    return !state.hasError;
  }

  Future<bool> deleteVendor(String id) async {
    if (!ref.read(canManagePartiesProvider)) {
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
    }
    try {
      final String? reason = await repository.deleteBlockReason(id);
      if (reason != null) {
        return reportFailure(ValidationException(
            'This vendor cannot be deleted because $reason. Deactivate it instead.'));
      }
    } on AppException catch (e) {
      return reportFailure(e);
    }
    await remove(id);
    return !state.hasError;
  }
}

final AsyncNotifierProvider<VendorsNotifier, List<VendorModel>>
    vendorsProvider =
    AsyncNotifierProvider<VendorsNotifier, List<VendorModel>>(
  VendorsNotifier.new,
);

class CustomersNotifier extends BaseListNotifier<CustomerModel> {
  @override
  BaseRepository<CustomerModel> get repository =>
      ref.read(customerRepositoryProvider);

  List<CustomerModel> get _items => state.valueOrNull ?? <CustomerModel>[];

  String? _validate(CustomerModel customer) {
    if (customer.name.trim().isEmpty) {
      return 'Customer name is required.';
    }
    final String phone = customer.phone.trim();
    if (phone.isNotEmpty &&
        _items.any((CustomerModel c) =>
            c.id != customer.id && c.phone.trim() == phone)) {
      return 'A customer with this phone number already exists.';
    }
    if (customer.creditLimit < 0) {
      return 'The credit limit cannot be negative.';
    }
    return null;
  }

  Future<bool> createCustomer(CustomerModel customer) async {
    if (!ref.read(canManagePartiesProvider)) {
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
    }
    final String? problem = _validate(customer);
    if (problem != null) {
      return reportFailure(ValidationException(problem));
    }
    await add(customer);
    return !state.hasError;
  }

  Future<bool> updateCustomer(CustomerModel customer) async {
    if (!ref.read(canManagePartiesProvider)) {
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
    }
    final String? problem = _validate(customer);
    if (problem != null) {
      return reportFailure(ValidationException(problem));
    }
    await updateItem(customer);
    return !state.hasError;
  }

  Future<bool> deleteCustomer(String id) async {
    if (!ref.read(canManagePartiesProvider)) {
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
    }
    try {
      final String? reason = await repository.deleteBlockReason(id);
      if (reason != null) {
        return reportFailure(ValidationException(
            'This customer cannot be deleted because $reason. Deactivate it instead.'));
      }
    } on AppException catch (e) {
      return reportFailure(e);
    }
    await remove(id);
    return !state.hasError;
  }
}

final AsyncNotifierProvider<CustomersNotifier, List<CustomerModel>>
    customersProvider =
    AsyncNotifierProvider<CustomersNotifier, List<CustomerModel>>(
  CustomersNotifier.new,
);

class LedgerNotifier extends BaseListNotifier<LedgerModel> {
  @override
  BaseRepository<LedgerModel> get repository =>
      ref.read(ledgerRepositoryProvider);

  Future<bool> addEntry(LedgerModel entry) async {
    if (!ref.read(canManagePartiesProvider)) {
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
    }
    if (entry.amount <= 0) {
      return reportFailure(
          const ValidationException('The amount must be greater than zero.'));
    }
    try {
      final bool partyExists = entry.partyType == PartyType.vendor
          ? await ref.read(vendorRepositoryProvider).getLocalById(entry.partyId) != null
          : await ref.read(customerRepositoryProvider).getLocalById(entry.partyId) != null;
      if (!partyExists) {
        return reportFailure(
            const ValidationException('This party no longer exists.'));
      }
    } on AppException catch (e) {
      return reportFailure(e);
    }
    await add(entry);
    return !state.hasError;
  }

  Future<bool> deleteEntry(String id) async {
    if (!ref.read(canManagePartiesProvider)) {
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
    }
    await remove(id);
    return !state.hasError;
  }
}

final AsyncNotifierProvider<LedgerNotifier, List<LedgerModel>>
    ledgerEntriesProvider =
    AsyncNotifierProvider<LedgerNotifier, List<LedgerModel>>(
  LedgerNotifier.new,
);

/// Sum of ledger entries per party id (charges minus payments). A party's
/// balance is its opening balance plus this value.
final Provider<Map<String, double>> ledgerTotalsProvider =
    Provider<Map<String, double>>((Ref ref) {
  final List<LedgerModel> entries =
      ref.watch(ledgerEntriesProvider).valueOrNull ?? <LedgerModel>[];
  final Map<String, double> totals = <String, double>{};
  for (final LedgerModel entry in entries) {
    totals[entry.partyId] = (totals[entry.partyId] ?? 0) + entry.signedAmount;
  }
  return totals;
});

String _joinNonEmpty(List<String> parts, String separator) {
  return parts
      .where((String p) => p.trim().isNotEmpty)
      .map((String p) => p.trim())
      .join(separator);
}

final Provider<List<PartyListItem>> vendorItemsProvider =
    Provider<List<PartyListItem>>((Ref ref) {
  final List<VendorModel> vendors =
      ref.watch(vendorsProvider).valueOrNull ?? <VendorModel>[];
  final Map<String, double> totals = ref.watch(ledgerTotalsProvider);
  return <PartyListItem>[
    for (final VendorModel v in vendors)
      PartyListItem(
        id: v.id,
        title: v.name,
        subtitle: _joinNonEmpty(<String>[v.contactPerson, v.city], ' · '),
        phone: v.phone,
        typeKey: v.type.name,
        typeLabel: v.type.label,
        balance: v.openingBalance + (totals[v.id] ?? 0),
        creditLimit: 0,
        isActive: v.isActive,
        searchText: _joinNonEmpty(
          <String>[v.name, v.contactPerson, v.phone, v.email, v.city, v.address],
          ' ',
        ).toLowerCase(),
      ),
  ];
});

final Provider<List<PartyListItem>> customerItemsProvider =
    Provider<List<PartyListItem>>((Ref ref) {
  final List<CustomerModel> customers =
      ref.watch(customersProvider).valueOrNull ?? <CustomerModel>[];
  final Map<String, double> totals = ref.watch(ledgerTotalsProvider);
  return <PartyListItem>[
    for (final CustomerModel c in customers)
      PartyListItem(
        id: c.id,
        title: c.name,
        subtitle: _joinNonEmpty(<String>[c.contactPerson, c.city], ' · '),
        phone: c.phone,
        typeKey: c.type.name,
        typeLabel: c.type.label,
        balance: c.openingBalance + (totals[c.id] ?? 0),
        creditLimit: c.creditLimit,
        isActive: c.isActive,
        searchText: _joinNonEmpty(
          <String>[c.name, c.contactPerson, c.phone, c.email, c.city, c.address],
          ' ',
        ).toLowerCase(),
      ),
  ];
});
