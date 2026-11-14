import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';
import 'package:mq_sports_erp/repositories/repository.dart';
import 'package:mq_sports_erp/providers/data_mode.dart';
import 'package:mq_sports_erp/online/online_providers.dart';
import 'package:mq_sports_erp/online/online_repositories.dart';
import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/activity_log_model.dart';
import 'package:mq_sports_erp/models/customer_model.dart';
import 'package:mq_sports_erp/models/ledger_model.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/stock_ledger_model.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/user_role.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/providers/base_list_notifier.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
import 'package:mq_sports_erp/providers/activity_log_providers.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/providers/parties_providers.dart';
import 'package:mq_sports_erp/providers/stock_providers.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';
import 'package:mq_sports_erp/repositories/order_repository.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';
import 'package:uuid/uuid.dart';

/// Every active user (admin, manager and staff) may create orders, move them
/// along the pipeline and record payments.
final Provider<bool> canCreateOrdersProvider = Provider<bool>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  return user != null && user.isActive;
});

/// Cancelling reverses stock and money, so only admins and managers may do it.
final Provider<bool> canCancelOrdersProvider = Provider<bool>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  return user != null &&
      user.isActive &&
      (user.role == UserRole.admin || user.role == UserRole.manager);
});

const String _noPermissionMessage = 'You are not allowed to change orders.';
const String _noCancelPermissionMessage =
    'Only admins and managers can cancel orders.';

final Provider<OrderOperations> orderRepositoryProvider =
    Provider<OrderOperations>((Ref ref) {
  if (ref.watch(dataModeProvider).isOnline) {
    return OnlineOrderRepository(
      ref.watch(apiClientProvider),
      ref.watch(remoteStoreProvider),
    );
  }
  return OrderRepository(
    local: HiveLocalRepository<OrderModel>(
      boxName: StorageKeys.orders,
      fromMap: OrderModel.fromMap,
    ),
    pendingStore: ref.watch(pendingChangeStoreProvider),
    logger: ref.watch(activityLoggerProvider),
    stockRepository: asNative(ref.watch(stockLedgerRepositoryProvider)),
    ledgerRepository: asNative(ref.watch(ledgerRepositoryProvider)),
  );
});

class OrdersNotifier extends BaseListNotifier<OrderModel> {
  @override
  OrderOperations get repository => ref.read(orderRepositoryProvider);

  String _newOrderNo(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    final String day = '${date.year}${two(date.month)}${two(date.day)}';
    final String suffix = const Uuid().v4().substring(0, 4).toUpperCase();
    return 'ORD-$day-$suffix';
  }

  OrderStatusEntry _entry(OrderStatus status) {
    final UserModel? actor = ref.read(currentUserProvider).valueOrNull;
    final String name = actor == null
        ? ''
        : (actor.displayName.trim().isEmpty ? actor.email : actor.displayName);
    return OrderStatusEntry(
      status: status,
      byUserId: actor?.id ?? '',
      byName: name,
    );
  }

  /// Confirms an order: saves it, takes the stock out and charges the
  /// customer ledger, all as one group. Returns true on success.
  Future<bool> confirmOrder({
    required CustomerModel customer,
    required OrderSaleType saleType,
    required DateTime orderDate,
    required String notes,
    required List<OrderItem> items,
    required double orderDiscount,
    required double paidNow,
  }) async {
    if (!ref.read(canCreateOrdersProvider)) {
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
    }
    if (!customer.isActive) {
      return reportFailure(const ValidationException('This customer is inactive.'));
    }
    if (items.isEmpty) {
      return reportFailure(const ValidationException('Add at least one item.'));
    }
    for (final OrderItem item in items) {
      if (item.quantity <= 0) {
        return reportFailure(const ValidationException(
            'Every item needs a quantity of at least 1.'));
      }
      if (item.unitPrice < 0) {
        return reportFailure(
            const ValidationException('A selling price cannot be negative.'));
      }
      if (item.discount < 0 || item.discount > item.grossAmount + 0.005) {
        return reportFailure(ValidationException(
            'The discount on "${item.productName}" must be between 0 and the line amount.'));
      }
    }

    final OrderModel order = OrderModel(
      orderNo: _newOrderNo(orderDate),
      customerId: customer.id,
      customerName: customer.name,
      orderDate: orderDate,
      saleType: saleType,
      items: items,
      discount: orderDiscount,
      notes: notes,
      statusHistory: <OrderStatusEntry>[_entry(OrderStatus.pending)],
    );
    if (orderDiscount < 0 || orderDiscount > order.subtotal + 0.005) {
      return reportFailure(const ValidationException(
          'The order discount must be between 0 and the order subtotal.'));
    }
    if (paidNow < 0 || paidNow > order.totalAmount + 0.005) {
      return reportFailure(const ValidationException(
          'The amount paid must be between 0 and the order total.'));
    }

    try {
      final List<ProductModel> products =
          await ref.read(productRepositoryProvider).getLocal();
      for (final OrderItem item in items) {
        final ProductModel? product =
            products.where((ProductModel p) => p.id == item.productId).firstOrNull;
        final VariantModel? variant = product?.variants
            .where((VariantModel v) => v.id == item.variantId)
            .firstOrNull;
        if (product == null || variant == null) {
          return reportFailure(ValidationException(
              '"${item.productName}" no longer exists in the catalog.'));
        }
        if (!product.isActive || !variant.isActive) {
          return reportFailure(ValidationException(
              '"${item.productName} · ${item.variantLabel}" is inactive.'));
        }
      }

      // Stock must cover the sale. Counted from the stock ledger in Hive, and
      // per variant in case the same variant appears on several lines.
      final List<StockLedgerModel> movements =
          await ref.read(stockLedgerRepositoryProvider).getLocal();
      final Map<String, int> onHand = <String, int>{};
      for (final StockLedgerModel m in movements) {
        onHand[m.variantId] = (onHand[m.variantId] ?? 0) + m.quantity;
      }
      final Map<String, int> requested = <String, int>{};
      for (final OrderItem item in items) {
        requested[item.variantId] = (requested[item.variantId] ?? 0) + item.quantity;
      }
      for (final OrderItem item in items) {
        final int available = onHand[item.variantId] ?? 0;
        final int wanted = requested[item.variantId] ?? 0;
        if (wanted > available) {
          return reportFailure(ValidationException(
              'Not enough stock for "${item.productName} · ${item.variantLabel}": '
              '$available available, $wanted requested.'));
        }
      }

      if (customer.creditLimit > 0) {
        final List<LedgerModel> entries =
            await ref.read(ledgerRepositoryProvider).getLocal();
        final double ledgerSum = entries
            .where((LedgerModel e) => e.partyId == customer.id)
            .fold<double>(0, (double s, LedgerModel e) => s + e.signedAmount);
        final double balanceAfter =
            customer.openingBalance + ledgerSum + order.totalAmount - paidNow;
        if (balanceAfter > customer.creditLimit + 0.005) {
          return reportFailure(ValidationException(
              'This order would take ${customer.name} over the credit limit '
              '(limit ${customer.creditLimit.toStringAsFixed(2)}, balance after '
              '${balanceAfter.toStringAsFixed(2)}).'));
        }
      }
    } on AppException catch (e) {
      return reportFailure(e);
    }

    final List<OrderModel> previous = state.valueOrNull ?? <OrderModel>[];
    state = AsyncData<List<OrderModel>>(<OrderModel>[...previous, order]);
    try {
      await repository.confirm(order, paidNow: paidNow);
      await _logAction(
        action: 'order_confirmed',
        order: order,
        summary: 'Order ${order.orderNo} confirmed for ${order.customerName}: '
            '${order.items.length} item(s), ${order.totalUnits} unit(s), '
            '${order.saleType.label.toLowerCase()} sale, total '
            '${order.totalAmount.toStringAsFixed(2)}, paid now '
            '${paidNow.toStringAsFixed(2)}. Stock taken out and the customer '
            'ledger charged.',
      );
      // Stock, ledger and order lists reload from Hive.
      ref.read(syncTickProvider.notifier).increment();
      return true;
    } on AppException catch (e, st) {
      logFailure(e);
      state = AsyncValue<List<OrderModel>>.error(e, st)
          .copyWithPrevious(AsyncData<List<OrderModel>>(previous));
      return false;
    }
  }

  /// Moves an order one step along the pipeline.
  Future<bool> advanceStatus(OrderModel order) async {
    if (!ref.read(canCreateOrdersProvider)) {
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
    }
    final OrderModel? current = await _latest(order.id);
    if (current == null) {
      return reportFailure(const ValidationException('This order no longer exists.'));
    }
    final OrderStatus? next = current.status.next;
    if (next == null) {
      return reportFailure(ValidationException(
          'A ${current.status.label.toLowerCase()} order cannot change status.'));
    }
    final OrderModel updated = current.copyWith(
      status: next,
      statusHistory: <OrderStatusEntry>[...current.statusHistory, _entry(next)],
    );
    await updateItem(updated);
    if (state.hasError) {
      return false;
    }
    await _logAction(
      action: 'order_status_changed',
      order: updated,
      summary: 'Order ${updated.orderNo} moved from ${current.status.label} '
          'to ${next.label}.',
    );
    return true;
  }

  Future<void> _logAction({
    required String action,
    required OrderModel order,
    required String summary,
    LogLevel level = LogLevel.info,
  }) {
    return ref.read(activityLoggerProvider).record(
          kind: LogKind.action,
          action: action,
          level: level,
          module: StorageKeys.orders,
          entityId: order.id,
          entityLabel: order.orderNo,
          summary: summary,
        );
  }

  /// Cancels an order that was not delivered yet: the stock goes back and
  /// the customer ledger charge is reversed.
  Future<bool> cancelOrder(OrderModel order) async {
    if (!ref.read(canCancelOrdersProvider)) {
      return reportFailure(
          const PermissionDeniedException(_noCancelPermissionMessage));
    }
    final OrderModel? current = await _latest(order.id);
    if (current == null) {
      return reportFailure(const ValidationException('This order no longer exists.'));
    }
    if (current.status.isFinal) {
      return reportFailure(ValidationException(
          'A ${current.status.label.toLowerCase()} order cannot be cancelled.'));
    }
    final OrderModel cancelled = current.copyWith(
      status: OrderStatus.cancelled,
      statusHistory: <OrderStatusEntry>[
        ...current.statusHistory,
        _entry(OrderStatus.cancelled),
      ],
    );
    final List<OrderModel> previous = state.valueOrNull ?? <OrderModel>[];
    state = AsyncData<List<OrderModel>>(<OrderModel>[
      for (final OrderModel o in previous) o.id == cancelled.id ? cancelled : o,
    ]);
    try {
      await repository.cancel(cancelled, when: DateTime.now());
      await _logAction(
        action: 'order_cancelled',
        order: cancelled,
        level: LogLevel.warning,
        summary: 'Order ${cancelled.orderNo} cancelled (was '
            '${current.status.label}): ${cancelled.totalUnits} unit(s) returned '
            'to stock and the ${cancelled.totalAmount.toStringAsFixed(2)} '
            'charge on ${cancelled.customerName}\'s ledger reversed.',
      );
      ref.read(syncTickProvider.notifier).increment();
      return true;
    } on AppException catch (e, st) {
      logFailure(e);
      state = AsyncValue<List<OrderModel>>.error(e, st)
          .copyWithPrevious(AsyncData<List<OrderModel>>(previous));
      return false;
    }
  }

  /// Records a payment against an order as a customer ledger entry.
  Future<bool> addPayment({
    required OrderModel order,
    required double amount,
    required DateTime date,
    required String note,
  }) async {
    if (!ref.read(canCreateOrdersProvider)) {
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
    }
    if (order.status == OrderStatus.cancelled) {
      return reportFailure(
          const ValidationException('A cancelled order cannot take payments.'));
    }
    if (amount <= 0) {
      return reportFailure(
          const ValidationException('The amount must be greater than zero.'));
    }
    final double paid = ref.read(orderPaidProvider)[order.id] ?? 0;
    final double due = order.totalAmount - paid;
    if (amount > due + 0.005) {
      return reportFailure(ValidationException(
          'The payment is more than the amount due (${due.toStringAsFixed(2)}).'));
    }
    final LedgerModel entry = LedgerModel(
      partyType: PartyType.customer,
      partyId: order.customerId,
      entryType: LedgerEntryType.payment,
      amount: amount,
      entryDate: date,
      description: note.isEmpty ? 'Payment for ${order.orderNo}' : note,
      reference: order.orderNo,
      orderId: order.id,
    );
    try {
      await ref.read(ledgerRepositoryProvider).save(entry);
      await _logAction(
        action: 'order_payment',
        order: order,
        summary: 'Payment of ${amount.toStringAsFixed(2)} recorded for order '
            '${order.orderNo} (${order.customerName}).',
      );
      ref.read(syncTickProvider.notifier).increment();
      return true;
    } on AppException catch (e) {
      return reportFailure(e);
    }
  }

  /// The stored copy of an order, falling back to the list in memory.
  Future<OrderModel?> _latest(String id) async {
    try {
      final OrderModel? stored = await repository.getLocalById(id);
      if (stored != null) {
        return stored;
      }
    } on AppException {
      // Falls back to the in-memory list below.
    }
    return (state.valueOrNull ?? <OrderModel>[])
        .where((OrderModel o) => o.id == id)
        .firstOrNull;
  }
}

final AsyncNotifierProvider<OrdersNotifier, List<OrderModel>> ordersProvider =
    AsyncNotifierProvider<OrdersNotifier, List<OrderModel>>(OrdersNotifier.new);

/// Amount paid per order id: the sum of its customer ledger payments. For a
/// cancelled order this also contains the reversal entry, so screens do not
/// show payment progress for cancelled orders.
final Provider<Map<String, double>> orderPaidProvider =
    Provider<Map<String, double>>((Ref ref) {
  final List<LedgerModel> entries =
      ref.watch(ledgerEntriesProvider).valueOrNull ?? <LedgerModel>[];
  final Map<String, double> paid = <String, double>{};
  for (final LedgerModel entry in entries) {
    if (entry.orderId.isNotEmpty && entry.entryType == LedgerEntryType.payment) {
      paid[entry.orderId] = (paid[entry.orderId] ?? 0) + entry.amount;
    }
  }
  return paid;
});
