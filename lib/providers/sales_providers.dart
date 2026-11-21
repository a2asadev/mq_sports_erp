import 'package:a2_stocks/core/permissions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/models/payment_method.dart';
import 'package:a2_stocks/data/local_repositories.dart';
import 'package:a2_stocks/providers/local_data_providers.dart';
import 'package:a2_stocks/repositories/repository.dart';
import 'package:a2_stocks/providers/data_mode.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/online_repositories.dart';
import 'package:a2_stocks/core/constants/storage_keys.dart';
import 'package:a2_stocks/core/utils/tax.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/models/activity_log_model.dart';
import 'package:a2_stocks/models/customer_model.dart';
import 'package:a2_stocks/models/ledger_model.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/order_return.dart';
import 'package:a2_stocks/online/returns_service.dart';
import 'package:a2_stocks/models/party_enums.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/stock_ledger_model.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/providers/base_list_notifier.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';
import 'package:a2_stocks/providers/activity_log_providers.dart';
import 'package:a2_stocks/providers/core_providers.dart';
import 'package:a2_stocks/providers/parties_providers.dart';
import 'package:a2_stocks/providers/stock_providers.dart';
import 'package:a2_stocks/providers/users_providers.dart';
import 'package:uuid/uuid.dart';

/// Every active user (admin, manager and staff) may create orders, move them
/// along the pipeline and record payments.
final Provider<bool> canCreateOrdersProvider = Provider<bool>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  return user != null && user.isActive;
});

/// Taking goods back and refunding is for those the admin allows (managers by default).
final Provider<bool> canReturnOrdersProvider = Provider<bool>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  return user != null && user.isActive && user.can(Permissions.returnsManage);
});

/// Cancelling reverses stock and money, so only admins and managers may do it.
final Provider<bool> canCancelOrdersProvider = Provider<bool>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  return user != null &&
      user.isActive &&
      user.can(Permissions.ordersCancel);
});

String get _noPermissionMessage => L10n.current.salesYouAreNotAllowed;
String get _noCancelPermissionMessage => L10n.current.salesOnlyAdminsAndManagers;

final Provider<OrderOperations> orderRepositoryProvider =
    Provider<OrderOperations>((Ref ref) {
  if (ref.watch(dataModeProvider).isOnline) {
    return OnlineOrderRepository(
      ref.watch(apiClientProvider),
      ref.watch(remoteStoreProvider),
    );
  }
  return LocalOrderRepository(
    collection: ref.watch(localCollectionsProvider).orders,
    outbox: ref.watch(outboxStoreProvider),
  );
});

class OrdersNotifier extends BaseListNotifier<OrderModel> {
  @override
  OrderOperations get repository => ref.read(orderRepositoryProvider);

  /// The order confirmed last (the POS prints its receipt from it).
  OrderModel? lastConfirmed;

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
    String channel = 'admin',
    List<PaymentLine> payments = const <PaymentLine>[],
  }) async {
    if (!ref.read(canCreateOrdersProvider)) {
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    if (!customer.isActive) {
      return reportFailure(ValidationException(L10n.current.salesThisCustomerIsInactive));
    }
    if (items.isEmpty) {
      return reportFailure(ValidationException(L10n.current.purchaseFormAddAtLeastOne));
    }
    for (final OrderItem item in items) {
      if (item.quantity <= 0) {
        return reportFailure(ValidationException(
            L10n.current.purchasingEveryItemNeedsA));
      }
      if (item.unitPrice < 0) {
        return reportFailure(
            ValidationException(L10n.current.salesASellingPriceCannot));
      }
      if (item.discount < 0 || item.discount > item.grossAmount + 0.005) {
        return reportFailure(ValidationException(
            L10n.current.salesTheDiscountOnMust(item.productName)));
      }
    }

    // Paid by method (the POS) or as one amount (the order form).
    final double paid = payments.isEmpty ? paidNow : PaymentLine.total(payments);
    for (final PaymentLine line in payments) {
      if (line.amount <= 0) {
        return reportFailure(ValidationException(L10n.current.salesEveryPaymentMustBe));
      }
    }

    final OrderModel untaxed = OrderModel(
      orderNo: _newOrderNo(orderDate),
      customerId: customer.id,
      customerName: customer.name,
      orderDate: orderDate,
      saleType: saleType,
      channel: channel,
      items: items,
      discount: orderDiscount,
      notes: notes,
      statusHistory: <OrderStatusEntry>[_entry(OrderStatus.pending)],
    );
    // The tax of this business at this moment, kept on the order (the server works it out again and has
    // the final say, by the same rule).
    final OrderModel order = untaxed.withTax(
      computeTax(untaxed.subtotal - orderDiscount, TaxSettings.of(ref.read(businessProvider))),
    );
    if (orderDiscount < 0 || orderDiscount > order.subtotal + 0.005) {
      return reportFailure(ValidationException(
          L10n.current.salesTheOrderDiscountMust));
    }
    if (paid < 0 || paid > order.totalAmount + 0.005) {
      return reportFailure(ValidationException(
          L10n.current.salesTheAmountPaidMust));
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
              L10n.current.purchasingNoLongerExistsIn(item.productName)));
        }
        if (!product.isActive || !variant.isActive) {
          return reportFailure(ValidationException(
              L10n.current.salesIsInactive(item.productName, item.variantLabel)));
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
              L10n.current.salesNotEnoughStockFor(item.productName, item.variantLabel, available, wanted)));
        }
      }

      if (customer.creditLimit > 0) {
        final List<LedgerModel> entries =
            await ref.read(ledgerRepositoryProvider).getLocal();
        final double ledgerSum = entries
            .where((LedgerModel e) => e.partyId == customer.id)
            .fold<double>(0, (double s, LedgerModel e) => s + e.signedAmount);
        final double balanceAfter =
            customer.openingBalance + ledgerSum + order.totalAmount - paid;
        if (balanceAfter > customer.creditLimit + 0.005) {
          return reportFailure(ValidationException(
              L10n.current.salesThisOrderWouldTake(customer.name, customer.creditLimit.toStringAsFixed(2), balanceAfter.toStringAsFixed(2))));
        }
      }
    } on AppException catch (e) {
      return reportFailure(e);
    }

    final List<OrderModel> previous = state.valueOrNull ?? <OrderModel>[];
    state = AsyncData<List<OrderModel>>(<OrderModel>[...previous, order]);
    try {
      await repository.confirm(order, paidNow: paid, payments: payments);
      lastConfirmed = order;
      await _logAction(
        action: 'order_confirmed',
        order: order,
        summary: L10n.current.salesOrderConfirmedForItem(order.orderNo, order.customerName, order.items.length, order.totalUnits, order.saleType.label.toLowerCase(), order.totalAmount.toStringAsFixed(2), paid.toStringAsFixed(2)),
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
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    final OrderModel? current = await _latest(order.id);
    if (current == null) {
      return reportFailure(ValidationException(L10n.current.orderDetailThisOrderNoLonger));
    }
    final OrderStatus? next = current.status.next;
    if (next == null) {
      return reportFailure(ValidationException(
          L10n.current.salesAOrderCannotChange(current.status.label.toLowerCase())));
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
      summary: L10n.current.salesOrderMovedFromTo(updated.orderNo, current.status.label, next.label),
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
          PermissionDeniedException(_noCancelPermissionMessage));
    }
    final OrderModel? current = await _latest(order.id);
    if (current == null) {
      return reportFailure(ValidationException(L10n.current.orderDetailThisOrderNoLonger));
    }
    if (current.status.isFinal) {
      return reportFailure(ValidationException(
          L10n.current.salesAOrderCannotBe(current.status.label.toLowerCase())));
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
        summary: L10n.current.salesOrderCancelledWasUnit(cancelled.orderNo, current.status.label, cancelled.totalUnits, cancelled.totalAmount.toStringAsFixed(2), cancelled.customerName),
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
    PaymentMethod? method,
    String paymentRef = '',
  }) async {
    if (!ref.read(canCreateOrdersProvider)) {
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    if (order.status == OrderStatus.cancelled) {
      return reportFailure(
          ValidationException(L10n.current.salesACancelledOrderCannot));
    }
    if (amount <= 0) {
      return reportFailure(
          ValidationException(L10n.current.partiesTheAmountMustBe));
    }
    final double paid = ref.read(orderPaidProvider)[order.id] ?? 0;
    final double due = order.totalAmount - paid;
    if (amount > due + 0.005) {
      return reportFailure(ValidationException(
          L10n.current.purchasingThePaymentIsMore(due.toStringAsFixed(2))));
    }
    final LedgerModel entry = LedgerModel(
      partyType: PartyType.customer,
      partyId: order.customerId,
      entryType: LedgerEntryType.payment,
      amount: amount,
      entryDate: date,
      description: note.isEmpty ? 'Payment for ${order.orderNo}' : note,
      reference: order.orderNo,
      paymentMethod: method?.name ?? '',
      paymentRef: paymentRef.trim(),
      orderId: order.id,
    );
    try {
      await ref.read(ledgerRepositoryProvider).save(entry);
      await _logAction(
        action: 'order_payment',
        order: order,
        summary: L10n.current.salesPaymentOfRecordedFor(amount.toStringAsFixed(2), order.orderNo, order.customerName),
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
    if (entry.orderId.isNotEmpty && entry.partyType == PartyType.customer && entry.orderSettlement != 0) {
      paid[entry.orderId] = (paid[entry.orderId] ?? 0) + entry.orderSettlement;
    }
  }
  return paid;
});

final Provider<ReturnsService> returnsServiceProvider =
    Provider<ReturnsService>((Ref ref) => ReturnsService(ref.watch(apiClientProvider)));

/// The returns of one order, oldest first (read from the server; needs a connection).
final AutoDisposeFutureProviderFamily<List<OrderReturn>, String> orderReturnsProvider =
    FutureProvider.autoDispose.family<List<OrderReturn>, String>((Ref ref, String orderId) {
  ref.watch(syncTickProvider);
  return ref.watch(returnsServiceProvider).forOrder(orderId);
});
