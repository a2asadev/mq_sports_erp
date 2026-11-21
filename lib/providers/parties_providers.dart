import 'package:a2_stocks/core/permissions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/data/local_repositories.dart';
import 'package:a2_stocks/data/outbox_entry.dart';
import 'package:a2_stocks/data/pending_effects.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/providers/local_data_providers.dart';
import 'package:a2_stocks/repositories/repository.dart';
import 'package:a2_stocks/providers/data_mode.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/online_repositories.dart';
import 'package:a2_stocks/core/constants/storage_keys.dart';
import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/models/customer_model.dart';
import 'package:a2_stocks/models/ledger_model.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/party_enums.dart';
import 'package:a2_stocks/models/party_list_item.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/models/vendor_model.dart';
import 'package:a2_stocks/providers/base_list_notifier.dart';
import 'package:a2_stocks/providers/users_providers.dart';

/// Whoever the admin allows may change vendors (managers by default).
final Provider<bool> canManageVendorsProvider = Provider<bool>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  return user != null && user.isActive && user.can(Permissions.purchasingManage);
});

/// Manual ledger entries (cash received, adjustments) stay with admins and managers.
final Provider<bool> canRecordLedgerProvider = Provider<bool>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  return user != null && user.isActive && (user.role == UserRole.admin || user.role == UserRole.manager);
});

/// Whoever the admin allows may change customers (managers by default).
final Provider<bool> canManagePartiesProvider = Provider<bool>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  return user != null &&
      user.isActive &&
      user.can(Permissions.customersManage);
});

String get _noPermissionMessage => L10n.current.partiesOnlyAdminsAndManagers;

final Provider<Repository<LedgerModel>> ledgerRepositoryProvider =
    Provider<Repository<LedgerModel>>((Ref ref) {
  if (ref.watch(dataModeProvider).isOnline) {
    return OnlineLedgerRepository(
      ref.watch(apiClientProvider),
      ref.watch(remoteStoreProvider),
    );
  }
  return LocalLedgerRepository(
    collection: ref.watch(localCollectionsProvider).ledgers,
    outbox: ref.watch(outboxStoreProvider),
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
    return L10n.current.partiesItHasLedgerEntries;
  }
  if (openingBalance != null && openingBalance.abs() >= 0.005) {
    return L10n.current.partiesItHasAnOpening;
  }
  return null;
}

final Provider<Repository<VendorModel>> vendorRepositoryProvider =
    Provider<Repository<VendorModel>>((Ref ref) {
  if (ref.watch(dataModeProvider).isOnline) {
    return OnlineVendorRepository(
      ref.watch(apiClientProvider),
      ref.watch(remoteStoreProvider),
    );
  }
  return LocalRepository<VendorModel>(
    collection: ref.watch(localCollectionsProvider).vendors,
    outbox: ref.watch(outboxStoreProvider),
    entityLabel: L10n.current.partyTypeVendor,
    labelOf: (VendorModel vendor) => vendor.name,
    overlay: (List<VendorModel> base, List<OutboxEntry> entries) =>
        overlayRecords<VendorModel>(
      collection: StorageKeys.vendors,
      base: base,
      entries: entries,
      fromMap: VendorModel.fromMap,
    ),
    deleteGuard: (String id) async {
      final VendorModel? vendor =
          await ref.read(vendorRepositoryProvider).getLocalById(id);
      return _partyDeleteReason(ref, id, vendor?.openingBalance);
    },
  );
});

final Provider<Repository<CustomerModel>> customerRepositoryProvider =
    Provider<Repository<CustomerModel>>((Ref ref) {
  if (ref.watch(dataModeProvider).isOnline) {
    return OnlineCustomerRepository(
      ref.watch(apiClientProvider),
      ref.watch(remoteStoreProvider),
    );
  }
  return LocalRepository<CustomerModel>(
    collection: ref.watch(localCollectionsProvider).customers,
    outbox: ref.watch(outboxStoreProvider),
    entityLabel: L10n.current.partyTypeCustomer,
    labelOf: (CustomerModel customer) => customer.name,
    overlay: (List<CustomerModel> base, List<OutboxEntry> entries) =>
        overlayRecords<CustomerModel>(
      collection: StorageKeys.customers,
      base: base,
      entries: entries,
      fromMap: CustomerModel.fromMap,
    ),
    deleteGuard: (String id) async {
      final CustomerModel? customer =
          await ref.read(customerRepositoryProvider).getLocalById(id);
      final String? reason =
          await _partyDeleteReason(ref, id, customer?.openingBalance);
      if (reason != null) {
        return reason;
      }
      // An order with a zero total has no ledger entry, so orders are checked
      // too. They are read here, not through the order providers, which depend
      // on this file.
      final List<OrderModel> orders = overlayOrders(
        await ref.read(localCollectionsProvider).orders.all(),
        await ref.read(outboxStoreProvider).all(),
      );
      return orders.any((OrderModel o) => o.customerId == id)
          ? L10n.current.partiesItHasOrders
          : null;
    },
  );
});

class VendorsNotifier extends BaseListNotifier<VendorModel> {
  @override
  Repository<VendorModel> get repository =>
      ref.read(vendorRepositoryProvider);

  List<VendorModel> get _items => state.valueOrNull ?? <VendorModel>[];

  String? _validate(VendorModel vendor) {
    if (vendor.name.trim().isEmpty) {
      return L10n.current.partiesVendorNameIsRequired;
    }
    final List<VendorModel> others =
        _items.where((VendorModel v) => v.id != vendor.id).toList();
    final String name = vendor.name.trim().toLowerCase();
    if (others.any((VendorModel v) => v.name.trim().toLowerCase() == name)) {
      return L10n.current.partiesAVendorNamedAlready(vendor.name.trim());
    }
    final String phone = vendor.phone.trim();
    if (phone.isNotEmpty &&
        others.any((VendorModel v) => v.phone.trim() == phone)) {
      return L10n.current.partiesAVendorWithThis;
    }
    return null;
  }

  Future<bool> createVendor(VendorModel vendor) async {
    if (!ref.read(canManageVendorsProvider)) {
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    final String? problem = _validate(vendor);
    if (problem != null) {
      return reportFailure(ValidationException(problem));
    }
    await add(vendor);
    return !state.hasError;
  }

  Future<bool> updateVendor(VendorModel vendor) async {
    if (!ref.read(canManageVendorsProvider)) {
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    final String? problem = _validate(vendor);
    if (problem != null) {
      return reportFailure(ValidationException(problem));
    }
    await updateItem(vendor);
    return !state.hasError;
  }

  Future<bool> deleteVendor(String id) async {
    if (!ref.read(canManageVendorsProvider)) {
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    try {
      final String? reason = await repository.deleteBlockReason(id);
      if (reason != null) {
        return reportFailure(ValidationException(
            L10n.current.partiesThisVendorCannotBe(reason)));
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
  Repository<CustomerModel> get repository =>
      ref.read(customerRepositoryProvider);

  List<CustomerModel> get _items => state.valueOrNull ?? <CustomerModel>[];

  String? _validate(CustomerModel customer) {
    if (customer.name.trim().isEmpty) {
      return L10n.current.partiesCustomerNameIsRequired;
    }
    final String phone = customer.phone.trim();
    if (phone.isNotEmpty &&
        _items.any((CustomerModel c) =>
            c.id != customer.id && c.phone.trim() == phone)) {
      return L10n.current.partiesACustomerWithThis;
    }
    if (customer.creditLimit < 0) {
      return L10n.current.partiesTheCreditLimitCannot;
    }
    return null;
  }

  Future<bool> createCustomer(CustomerModel customer) async {
    if (!ref.read(canManagePartiesProvider)) {
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
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
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
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
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    try {
      final String? reason = await repository.deleteBlockReason(id);
      if (reason != null) {
        return reportFailure(ValidationException(
            L10n.current.partiesThisCustomerCannotBe(reason)));
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
  Repository<LedgerModel> get repository =>
      ref.read(ledgerRepositoryProvider);

  Future<bool> addEntry(LedgerModel entry) async {
    if (!ref.read(canRecordLedgerProvider)) {
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    if (entry.amount <= 0) {
      return reportFailure(
          ValidationException(L10n.current.partiesTheAmountMustBe));
    }
    try {
      final bool partyExists = entry.partyType == PartyType.vendor
          ? await ref.read(vendorRepositoryProvider).getLocalById(entry.partyId) != null
          : await ref.read(customerRepositoryProvider).getLocalById(entry.partyId) != null;
      if (!partyExists) {
        return reportFailure(
            ValidationException(L10n.current.partiesThisPartyNoLonger));
      }
    } on AppException catch (e) {
      return reportFailure(e);
    }
    await add(entry);
    return !state.hasError;
  }

  Future<bool> deleteEntry(String id) async {
    if (!ref.read(canRecordLedgerProvider)) {
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    final LedgerModel? entry = (state.valueOrNull ?? <LedgerModel>[])
        .where((LedgerModel e) => e.id == id)
        .firstOrNull;
    if (entry != null && entry.purchaseId.isNotEmpty) {
      return reportFailure(ValidationException(
          L10n.current.partiesThisEntryBelongsTo));
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
        photoUrl: v.photoUrl,
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
        photoUrl: c.photoUrl,
        searchText: _joinNonEmpty(
          <String>[c.name, c.contactPerson, c.phone, c.email, c.city, c.address],
          ' ',
        ).toLowerCase(),
      ),
  ];
});
