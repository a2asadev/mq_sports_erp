import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';
import 'package:mq_sports_erp/repositories/repository.dart';
import 'package:mq_sports_erp/providers/data_mode.dart';
import 'package:mq_sports_erp/online/online_providers.dart';
import 'package:mq_sports_erp/online/online_repositories.dart';
import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/activity_log_model.dart';
import 'package:mq_sports_erp/models/ledger_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/purchase_model.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/user_role.dart';
import 'package:mq_sports_erp/models/vendor_model.dart';
import 'package:mq_sports_erp/providers/base_list_notifier.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
import 'package:mq_sports_erp/providers/activity_log_providers.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/providers/parties_providers.dart';
import 'package:mq_sports_erp/providers/stock_providers.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';
import 'package:mq_sports_erp/repositories/purchase_repository.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';
import 'package:uuid/uuid.dart';

/// Admins and managers may record purchases and payments.
final Provider<bool> canManagePurchasesProvider = Provider<bool>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  return user != null &&
      user.isActive &&
      (user.role == UserRole.admin || user.role == UserRole.manager);
});

const String _noPermissionMessage =
    'Only admins and managers can record purchases.';

final Provider<PurchaseOperations> purchaseRepositoryProvider =
    Provider<PurchaseOperations>((Ref ref) {
  if (ref.watch(dataModeProvider).isOnline) {
    return OnlinePurchaseRepository(
      ref.watch(apiClientProvider),
      ref.watch(remoteStoreProvider),
    );
  }
  return PurchaseRepository(
    local: HiveLocalRepository<PurchaseModel>(
      boxName: StorageKeys.purchases,
      fromMap: PurchaseModel.fromMap,
    ),
    pendingStore: ref.watch(pendingChangeStoreProvider),
    logger: ref.watch(activityLoggerProvider),
    stockRepository: asNative(ref.watch(stockLedgerRepositoryProvider)),
    ledgerRepository: asNative(ref.watch(ledgerRepositoryProvider)),
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
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
    }
    if (!vendor.isActive) {
      return reportFailure(const ValidationException('This vendor is inactive.'));
    }
    if (items.isEmpty) {
      return reportFailure(const ValidationException('Add at least one item.'));
    }
    for (final PurchaseItem item in items) {
      if (item.quantity <= 0) {
        return reportFailure(const ValidationException(
            'Every item needs a quantity of at least 1.'));
      }
      if (item.unitCost < 0) {
        return reportFailure(
            const ValidationException('A buying price cannot be negative.'));
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
              '"${item.productName}" no longer exists in the catalog.'));
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
      return reportFailure(const ValidationException(
          'The amount paid must be between 0 and the purchase total.'));
    }

    final List<PurchaseModel> previous = state.valueOrNull ?? <PurchaseModel>[];
    state = AsyncData<List<PurchaseModel>>(<PurchaseModel>[...previous, purchase]);
    try {
      await repository.confirm(purchase, paidNow: paidNow);
      await _logAction(
        action: 'purchase_confirmed',
        purchase: purchase,
        summary: 'Purchase ${purchase.purchaseNo} confirmed from '
            '${purchase.vendorName}: ${purchase.items.length} item(s), '
            '${purchase.totalUnits} unit(s), total '
            '${purchase.totalAmount.toStringAsFixed(2)}, paid now '
            '${paidNow.toStringAsFixed(2)}. Stock added and the vendor ledger '
            'charged.',
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
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
    }
    if (amount <= 0) {
      return reportFailure(
          const ValidationException('The amount must be greater than zero.'));
    }
    final double paid = ref.read(purchasePaidProvider)[purchase.id] ?? 0;
    final double due = purchase.totalAmount - paid;
    if (amount > due + 0.005) {
      return reportFailure(ValidationException(
          'The payment is more than the amount due (${due.toStringAsFixed(2)}).'));
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
        summary: 'Payment of ${amount.toStringAsFixed(2)} recorded for purchase '
            '${purchase.purchaseNo} (${purchase.vendorName}).',
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
