import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/activity_log_model.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/stock_audit_model.dart';
import 'package:mq_sports_erp/models/stock_ledger_model.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/user_role.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/providers/base_list_notifier.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
import 'package:mq_sports_erp/providers/activity_log_providers.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/providers/stock_providers.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';
import 'package:mq_sports_erp/repositories/stock_audit_repository.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';
import 'package:uuid/uuid.dart';

/// Adjusting stock changes what the business owns, so only admins and
/// managers may count and adjust it.
final Provider<bool> canAuditStockProvider = Provider<bool>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  return user != null &&
      user.isActive &&
      (user.role == UserRole.admin || user.role == UserRole.manager);
});

const String _noPermissionMessage =
    'Only admins and managers can count and adjust stock.';

final Provider<StockAuditRepository> stockAuditRepositoryProvider =
    Provider<StockAuditRepository>((Ref ref) {
  return StockAuditRepository(
    local: HiveLocalRepository<StockAuditModel>(
      boxName: StorageKeys.stockAudits,
      fromMap: StockAuditModel.fromMap,
    ),
    pendingStore: ref.watch(pendingChangeStoreProvider),
    logger: ref.watch(activityLoggerProvider),
    stockRepository: ref.watch(stockLedgerRepositoryProvider),
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
  StockAuditRepository get repository => ref.read(stockAuditRepositoryProvider);

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
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
    }
    if (counts.isEmpty) {
      return reportFailure(
          const ValidationException('Enter the counted quantity of at least one item.'));
    }
    for (final CountedVariant count in counts) {
      if (count.countedQuantity < 0) {
        return reportFailure(
            const ValidationException('A counted quantity cannot be negative.'));
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
          return reportFailure(const ValidationException(
              'The same item was counted twice.'));
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
          return reportFailure(const ValidationException(
              'A counted item no longer exists in the catalog.'));
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
      return reportFailure(const ValidationException(
          'Every counted quantity matches the system, so there is nothing to adjust.'));
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
            summary: 'Stock count ${audit.auditNo} applied: '
                '${audit.items.length} item(s) adjusted, net '
                '${net > 0 ? '+$net' : '$net'} unit(s).'
                '${note.isEmpty ? '' : ' Note: $note'}',
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
