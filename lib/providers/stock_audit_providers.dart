import 'package:a2_stocks/core/permissions.dart';
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
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/stock_audit_model.dart';
import 'package:a2_stocks/models/stock_ledger_model.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/providers/base_list_notifier.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';
import 'package:a2_stocks/providers/activity_log_providers.dart';
import 'package:a2_stocks/providers/core_providers.dart';
import 'package:a2_stocks/providers/stock_providers.dart';
import 'package:a2_stocks/providers/users_providers.dart';
import 'package:uuid/uuid.dart';

/// Adjusting stock changes what the business owns, so only admins and
/// managers may count and adjust it.
final Provider<bool> canAuditStockProvider = Provider<bool>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  return user != null &&
      user.isActive &&
      user.can(Permissions.stockAudit);
});

String get _noPermissionMessage => L10n.current.stockAuditOnlyAdminsAndManagers;

final Provider<StockAuditOperations> stockAuditRepositoryProvider =
    Provider<StockAuditOperations>((Ref ref) {
  if (ref.watch(dataModeProvider).isOnline) {
    return OnlineStockAuditRepository(
      ref.watch(apiClientProvider),
      ref.watch(remoteStoreProvider),
    );
  }
  return LocalStockAuditRepository(
    collection: ref.watch(localCollectionsProvider).stockAudits,
    outbox: ref.watch(outboxStoreProvider),
  );
});

/// One counted quantity entered on the audit screen.
class CountedVariant {
  const CountedVariant({required this.variantId, required this.countedQuantity});

  final String variantId;
  final int countedQuantity;
}

class StockAuditsNotifier extends BaseListNotifier<StockAuditModel> {
  @override
  StockAuditOperations get repository => ref.read(stockAuditRepositoryProvider);

  String _newAuditNo(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    final String day = '${date.year}${two(date.month)}${two(date.day)}';
    final String suffix = const Uuid().v4().substring(0, 4).toUpperCase();
    return 'AUD-$day-$suffix';
  }

  /// Confirms a count. The system quantity of every counted variant is read
  /// again from the stock ledger here, so the variance is always measured
  /// against what is on the device now. Variants whose count equals the system
  /// quantity are left out. Returns true on success.
  Future<bool> confirmAudit({
    required List<CountedVariant> counts,
    required String note,
    required DateTime auditDate,
  }) async {
    if (!ref.read(canAuditStockProvider)) {
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    if (counts.isEmpty) {
      return reportFailure(
          ValidationException(L10n.current.stockAuditEnterTheCountedQuantity));
    }
    for (final CountedVariant count in counts) {
      if (count.countedQuantity < 0) {
        return reportFailure(
            ValidationException(L10n.current.stockAuditACountedQuantityCannot));
      }
    }

    final List<StockAuditItem> items = <StockAuditItem>[];
    try {
      final List<ProductModel> products =
          await ref.read(productRepositoryProvider).getLocal();
      final List<StockLedgerModel> movements =
          await ref.read(stockLedgerRepositoryProvider).getLocal();
      final Map<String, int> onHand = <String, int>{};
      for (final StockLedgerModel m in movements) {
        onHand[m.variantId] = (onHand[m.variantId] ?? 0) + m.quantity;
      }
      final Set<String> seen = <String>{};
      for (final CountedVariant count in counts) {
        if (!seen.add(count.variantId)) {
          return reportFailure(ValidationException(
              L10n.current.stockAuditTheSameItemWas));
        }
        ProductModel? product;
        VariantModel? variant;
        for (final ProductModel p in products) {
          final VariantModel? found = p.variants
              .where((VariantModel v) => v.id == count.variantId)
              .firstOrNull;
          if (found != null) {
            product = p;
            variant = found;
            break;
          }
        }
        if (product == null || variant == null) {
          return reportFailure(ValidationException(
              L10n.current.stockAuditACountedItemNo));
        }
        final StockAuditItem item = StockAuditItem(
          productId: product.id,
          variantId: variant.id,
          productName: product.name,
          variantLabel: variant.label,
          sku: variant.sku,
          systemQuantity: onHand[variant.id] ?? 0,
          countedQuantity: count.countedQuantity,
        );
        if (item.variance != 0) {
          items.add(item);
        }
      }
    } on AppException catch (e) {
      return reportFailure(e);
    }

    if (items.isEmpty) {
      return reportFailure(ValidationException(
          L10n.current.stockAuditEveryCountedQuantityMatches2));
    }

    final UserModel? actor = ref.read(currentUserProvider).valueOrNull;
    final StockAuditModel audit = StockAuditModel(
      auditNo: _newAuditNo(auditDate),
      auditDate: auditDate,
      items: items,
      note: note,
      countedById: actor?.id ?? '',
      countedByName: actor == null
          ? ''
          : (actor.displayName.trim().isEmpty ? actor.email : actor.displayName),
    );

    final List<StockAuditModel> previous =
        state.valueOrNull ?? <StockAuditModel>[];
    state = AsyncData<List<StockAuditModel>>(<StockAuditModel>[...previous, audit]);
    try {
      await repository.confirm(audit);
      final int net = audit.totalVariance;
      await ref.read(activityLoggerProvider).record(
            kind: LogKind.action,
            action: 'stock_audit_applied',
            level: LogLevel.warning,
            module: StorageKeys.stockAudits,
            entityId: audit.id,
            entityLabel: audit.auditNo,
            summary: L10n.current.stockAuditLogSummary(audit.auditNo, audit.items.length, net, net > 0 ? '+$net' : '$net',
                note.isEmpty ? '' : L10n.current.stockAuditLogNote(note)),
            changes: <LogFieldChange>[
              for (final StockAuditItem item in audit.items)
                LogFieldChange(
                  field: '${item.productName} · ${item.variantLabel} (${item.sku})',
                  from: '${item.systemQuantity}',
                  to: '${item.countedQuantity}',
                ),
            ],
          );
      // Stock lists reload from Hive.
      ref.read(syncTickProvider.notifier).increment();
      return true;
    } on AppException catch (e, st) {
      logFailure(e);
      state = AsyncValue<List<StockAuditModel>>.error(e, st)
          .copyWithPrevious(AsyncData<List<StockAuditModel>>(previous));
      return false;
    }
  }
}

final AsyncNotifierProvider<StockAuditsNotifier, List<StockAuditModel>>
    stockAuditsProvider =
    AsyncNotifierProvider<StockAuditsNotifier, List<StockAuditModel>>(
  StockAuditsNotifier.new,
);
