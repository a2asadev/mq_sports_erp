import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/data/local_repositories.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/providers/local_data_providers.dart';
import 'package:a2_stocks/repositories/repository.dart';
import 'package:a2_stocks/providers/data_mode.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/online_repositories.dart';
import 'package:a2_stocks/core/constants/storage_keys.dart';
import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/models/activity_log_model.dart';
import 'package:a2_stocks/models/ledger_model.dart';
import 'package:a2_stocks/models/party_enums.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/purchase_model.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/models/vendor_model.dart';
import 'package:a2_stocks/providers/base_list_notifier.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';
import 'package:a2_stocks/providers/activity_log_providers.dart';
import 'package:a2_stocks/providers/core_providers.dart';
import 'package:a2_stocks/providers/parties_providers.dart';
import 'package:a2_stocks/providers/users_providers.dart';
import 'package:uuid/uuid.dart';

/// Admins and managers may record purchases and payments.
final Provider<bool> canManagePurchasesProvider = Provider<bool>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  return user != null &&
      user.isActive &&
      (user.role == UserRole.admin || user.role == UserRole.manager);
});

String get _noPermissionMessage => L10n.current.purchasingOnlyAdminsAndManagers;

final Provider<PurchaseOperations> purchaseRepositoryProvider =
    Provider<PurchaseOperations>((Ref ref) {
  if (ref.watch(dataModeProvider).isOnline) {
    return OnlinePurchaseRepository(
      ref.watch(apiClientProvider),
      ref.watch(remoteStoreProvider),
    );
  }
  return LocalPurchaseRepository(
    collection: ref.watch(localCollectionsProvider).purchases,
    outbox: ref.watch(outboxStoreProvider),
  );
});

class PurchasesNotifier extends BaseListNotifier<PurchaseModel> {
  @override
  PurchaseOperations get repository => ref.read(purchaseRepositoryProvider);

  Future<void> _logAction({
    required String action,
    required PurchaseModel purchase,
    required String summary,
  }) {
    return ref.read(activityLoggerProvider).record(
          kind: LogKind.action,
          action: action,
          module: StorageKeys.purchases,
          entityId: purchase.id,
          entityLabel: purchase.purchaseNo,
          summary: summary,
        );
  }

  String _newPurchaseNo(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    final String day = '${date.year}${two(date.month)}${two(date.day)}';
    final String suffix = const Uuid().v4().substring(0, 4).toUpperCase();
    return 'PUR-$day-$suffix';
  }

  /// Confirms a purchase: saves it, adds the stock, and posts the vendor
  /// ledger entries, all as one group. Returns true on success.
  Future<bool> confirmPurchase({
    required VendorModel vendor,
    required DateTime purchaseDate,
    required String invoiceNo,
    required String notes,
    required List<PurchaseItem> items,
    required double paidNow,
  }) async {
    if (!ref.read(canManagePurchasesProvider)) {
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    if (!vendor.isActive) {
      return reportFailure(ValidationException(L10n.current.purchasingThisVendorIsInactive));
    }
    if (items.isEmpty) {
      return reportFailure(ValidationException(L10n.current.purchaseFormAddAtLeastOne));
    }
    for (final PurchaseItem item in items) {
      if (item.quantity <= 0) {
        return reportFailure(ValidationException(
            L10n.current.purchasingEveryItemNeedsA));
      }
      if (item.unitCost < 0) {
        return reportFailure(
            ValidationException(L10n.current.purchasingABuyingPriceCannot));
      }
    }
    try {
      final List<ProductModel> products =
          await ref.read(productRepositoryProvider).getLocal();
      for (final PurchaseItem item in items) {
        final ProductModel? product =
            products.where((ProductModel p) => p.id == item.productId).firstOrNull;
        if (product == null ||
            !product.variants.any((v) => v.id == item.variantId)) {
          return reportFailure(ValidationException(
              L10n.current.purchasingNoLongerExistsIn(item.productName)));
        }
      }
    } on AppException catch (e) {
      return reportFailure(e);
    }

    final PurchaseModel purchase = PurchaseModel(
      purchaseNo: _newPurchaseNo(purchaseDate),
      vendorId: vendor.id,
      vendorName: vendor.name,
      invoiceNo: invoiceNo,
      purchaseDate: purchaseDate,
      items: items,
      notes: notes,
    );
    if (paidNow < 0 || paidNow > purchase.totalAmount + 0.005) {
      return reportFailure(ValidationException(
          L10n.current.purchasingTheAmountPaidMust));
    }

    final List<PurchaseModel> previous = state.valueOrNull ?? <PurchaseModel>[];
    state = AsyncData<List<PurchaseModel>>(<PurchaseModel>[...previous, purchase]);
    try {
      await repository.confirm(purchase, paidNow: paidNow);
      await _logAction(
        action: 'purchase_confirmed',
        purchase: purchase,
        summary: L10n.current.purchasingPurchaseConfirmedFromItem(purchase.purchaseNo, purchase.vendorName, purchase.items.length, purchase.totalUnits, purchase.totalAmount.toStringAsFixed(2), paidNow.toStringAsFixed(2)),
      );
      // Stock, ledger and purchase lists reload from Hive.
      ref.read(syncTickProvider.notifier).increment();
      return true;
    } on AppException catch (e, st) {
      logFailure(e);
      state = AsyncValue<List<PurchaseModel>>.error(e, st)
          .copyWithPrevious(AsyncData<List<PurchaseModel>>(previous));
      return false;
    }
  }

  /// Records a payment against a purchase as a vendor ledger entry.
  Future<bool> addPayment({
    required PurchaseModel purchase,
    required double amount,
    required DateTime date,
    required String note,
  }) async {
    if (!ref.read(canManagePurchasesProvider)) {
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    if (amount <= 0) {
      return reportFailure(
          ValidationException(L10n.current.partiesTheAmountMustBe));
    }
    final double paid = ref.read(purchasePaidProvider)[purchase.id] ?? 0;
    final double due = purchase.totalAmount - paid;
    if (amount > due + 0.005) {
      return reportFailure(ValidationException(
          L10n.current.purchasingThePaymentIsMore(due.toStringAsFixed(2))));
    }
    final LedgerModel entry = LedgerModel(
      partyType: PartyType.vendor,
      partyId: purchase.vendorId,
      entryType: LedgerEntryType.payment,
      amount: amount,
      entryDate: date,
      description: note.isEmpty ? 'Payment for ${purchase.purchaseNo}' : note,
      reference: purchase.purchaseNo,
      purchaseId: purchase.id,
    );
    try {
      await ref.read(ledgerRepositoryProvider).save(entry);
      await _logAction(
        action: 'purchase_payment',
        purchase: purchase,
        summary: L10n.current.purchasingPaymentOfRecordedFor(amount.toStringAsFixed(2), purchase.purchaseNo, purchase.vendorName),
      );
      ref.read(syncTickProvider.notifier).increment();
      return true;
    } on AppException catch (e) {
      return reportFailure(e);
    }
  }
}

final AsyncNotifierProvider<PurchasesNotifier, List<PurchaseModel>>
    purchasesProvider =
    AsyncNotifierProvider<PurchasesNotifier, List<PurchaseModel>>(
  PurchasesNotifier.new,
);

/// Amount paid per purchase id: the sum of its vendor ledger payments.
final Provider<Map<String, double>> purchasePaidProvider =
    Provider<Map<String, double>>((Ref ref) {
  final List<LedgerModel> entries =
      ref.watch(ledgerEntriesProvider).valueOrNull ?? <LedgerModel>[];
  final Map<String, double> paid = <String, double>{};
  for (final LedgerModel entry in entries) {
    if (entry.purchaseId.isNotEmpty && entry.entryType == LedgerEntryType.payment) {
      paid[entry.purchaseId] = (paid[entry.purchaseId] ?? 0) + entry.amount;
    }
  }
  return paid;
});
