import 'package:a2_stocks/core/constants/server_text.dart';
import 'package:a2_stocks/core/constants/storage_keys.dart';
import 'package:a2_stocks/data/outbox_entry.dart';
import 'package:a2_stocks/models/ledger_model.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/payment_method.dart';
import 'package:a2_stocks/models/party_enums.dart';
import 'package:a2_stocks/models/purchase_model.dart';
import 'package:a2_stocks/models/stock_audit_model.dart';
import 'package:a2_stocks/models/stock_ledger_model.dart';
import 'package:a2_stocks/models/syncable_model.dart';
import 'package:uuid/uuid.dart';

// What the device shows = what the server has confirmed + what the user did and
// has not uploaded yet.
//
// An action such as "confirm this order" will cause an order, stock leaving, and
// a charge on the customer's ledger on the server. Until it is uploaded, those
// are worked out here, from the action alone, so the user sees them straight
// away. They are never written to the database: once the action is uploaded the
// server's own records arrive with the next download and replace them. Every
// function below also skips an action whose records have already arrived, so a
// record is never shown twice.

const Uuid _uuid = Uuid();

/// A stable id for something an action causes, so it is the same on every read.
String _derived(String opId, String part) =>
    _uuid.v5(Namespace.url.value, 'mq-erp/$opId/$part');

/// Only entries the user should still see the effect of.
Iterable<OutboxEntry> _shown(List<OutboxEntry> entries) =>
    entries.where((OutboxEntry e) => e.isShown);

OrderModel _order(Map<String, dynamic> payload) =>
    OrderModel.fromMap(payload['order'] as Map<String, dynamic>);

PurchaseModel _purchase(Map<String, dynamic> payload) =>
    PurchaseModel.fromMap(payload['purchase'] as Map<String, dynamic>);

StockAuditModel _audit(Map<String, dynamic> payload) =>
    StockAuditModel.fromMap(payload['audit'] as Map<String, dynamic>);

LedgerModel _entry(Map<String, dynamic> payload) =>
    LedgerModel.fromMap(payload['entry'] as Map<String, dynamic>);

double _paidNow(Map<String, dynamic> payload) =>
    (payload['paidNow'] as num?)?.toDouble() ?? 0;

// ---- plain records: create, change, delete ---------------------------------

/// Applies the queued creates, edits and deletes of one collection.
List<T> overlayRecords<T extends SyncableModel>({
  required String collection,
  required List<T> base,
  required List<OutboxEntry> entries,
  required T Function(Map<String, dynamic> map) fromMap,
}) {
  final Map<String, T> byId = <String, T>{for (final T item in base) item.id: item};
  for (final OutboxEntry entry in _shown(entries)) {
    if (entry.collection != collection) {
      continue;
    }
    if (entry.kind == OutboxKind.upsert) {
      final T item = fromMap(entry.payload);
      byId[item.id] = item;
    } else if (entry.kind == OutboxKind.delete) {
      byId.remove(entry.entityId);
    }
  }
  return byId.values.toList();
}

// ---- orders ----------------------------------------------------------------

List<OrderModel> overlayOrders(List<OrderModel> base, List<OutboxEntry> entries) {
  final Map<String, OrderModel> byId = <String, OrderModel>{
    for (final OrderModel o in base) o.id: o,
  };
  for (final OutboxEntry entry in _shown(entries)) {
    switch (entry.kind) {
      case OutboxKind.orderConfirm:
        final OrderModel order = _order(entry.payload);
        byId.putIfAbsent(order.id, () => order);
      case OutboxKind.orderStatus:
        final OrderModel? current = byId[entry.entityId];
        final OrderStatus target = OrderStatus.fromName(entry.payload['status'] as String?);
        if (current != null && current.status != target) {
          final OrderStatusEntry step =
              OrderStatusEntry.fromMap(entry.payload['entry'] as Map<String, dynamic>);
          byId[current.id] = current.copyWith(
            status: target,
            statusHistory: <OrderStatusEntry>[...current.statusHistory, step],
            updatedAt: entry.createdAt,
          );
        }
      case OutboxKind.orderCancel:
        final OrderModel? current = byId[entry.entityId];
        if (current != null && current.status != OrderStatus.cancelled) {
          final OrderModel cancelled = _order(entry.payload);
          byId[current.id] = current.copyWith(
            status: OrderStatus.cancelled,
            statusHistory: cancelled.statusHistory,
            updatedAt: entry.createdAt,
          );
        }
      default:
        break;
    }
  }
  return byId.values.toList();
}

// ---- purchases and stock counts --------------------------------------------

List<PurchaseModel> overlayPurchases(List<PurchaseModel> base, List<OutboxEntry> entries) {
  final Map<String, PurchaseModel> byId = <String, PurchaseModel>{
    for (final PurchaseModel p in base) p.id: p,
  };
  for (final OutboxEntry entry in _shown(entries)) {
    if (entry.kind == OutboxKind.purchaseConfirm) {
      final PurchaseModel purchase = _purchase(entry.payload);
      byId.putIfAbsent(purchase.id, () => purchase);
    }
  }
  return byId.values.toList();
}

List<StockAuditModel> overlayAudits(List<StockAuditModel> base, List<OutboxEntry> entries) {
  final Map<String, StockAuditModel> byId = <String, StockAuditModel>{
    for (final StockAuditModel a in base) a.id: a,
  };
  for (final OutboxEntry entry in _shown(entries)) {
    if (entry.kind == OutboxKind.auditConfirm) {
      final StockAuditModel audit = _audit(entry.payload);
      byId.putIfAbsent(audit.id, () => audit);
    }
  }
  return byId.values.toList();
}

// ---- stock movements -------------------------------------------------------

List<StockLedgerModel> overlayStock(List<StockLedgerModel> base, List<OutboxEntry> entries) {
  final List<StockLedgerModel> result = List<StockLedgerModel>.of(base);
  bool serverHas(String sourceId, {bool? leaving}) => base.any((StockLedgerModel m) =>
      m.sourceId == sourceId && (leaving == null || (m.quantity < 0) == leaving));

  for (final OutboxEntry entry in _shown(entries)) {
    switch (entry.kind) {
      case OutboxKind.orderConfirm:
        final OrderModel order = _order(entry.payload);
        if (serverHas(order.id, leaving: true)) {
          continue;
        }
        for (int i = 0; i < order.items.length; i++) {
          final OrderItem item = order.items[i];
          result.add(StockLedgerModel(
            id: _derived(entry.opId, 'stock/$i'),
            productId: item.productId,
            variantId: item.variantId,
            sku: item.sku,
            quantity: -item.quantity,
            movementType: StockMovementType.sale,
            sourceId: order.id,
            unitCost: item.unitPrice,
            movementDate: order.orderDate,
            note: order.orderNo,
            createdAt: entry.createdAt,
            updatedAt: entry.createdAt,
          ));
        }
      case OutboxKind.orderCancel:
        final OrderModel order = _order(entry.payload);
        if (serverHas(order.id, leaving: false)) {
          continue;
        }
        for (int i = 0; i < order.items.length; i++) {
          final OrderItem item = order.items[i];
          result.add(StockLedgerModel(
            id: _derived(entry.opId, 'stock/$i'),
            productId: item.productId,
            variantId: item.variantId,
            sku: item.sku,
            quantity: item.quantity,
            movementType: StockMovementType.sale,
            sourceId: order.id,
            unitCost: item.unitPrice,
            movementDate: entry.createdAt,
            note: 'Cancelled ${order.orderNo}',
            createdAt: entry.createdAt,
            updatedAt: entry.createdAt,
          ));
        }
      case OutboxKind.purchaseConfirm:
        final PurchaseModel purchase = _purchase(entry.payload);
        if (serverHas(purchase.id)) {
          continue;
        }
        for (int i = 0; i < purchase.items.length; i++) {
          final PurchaseItem item = purchase.items[i];
          result.add(StockLedgerModel(
            id: _derived(entry.opId, 'stock/$i'),
            productId: item.productId,
            variantId: item.variantId,
            sku: item.sku,
            quantity: item.quantity,
            movementType: StockMovementType.purchase,
            sourceId: purchase.id,
            unitCost: item.unitCost,
            movementDate: purchase.purchaseDate,
            note: purchase.purchaseNo,
            createdAt: entry.createdAt,
            updatedAt: entry.createdAt,
          ));
        }
      case OutboxKind.auditConfirm:
        final StockAuditModel audit = _audit(entry.payload);
        if (serverHas(audit.id)) {
          continue;
        }
        for (int i = 0; i < audit.items.length; i++) {
          final StockAuditItem item = audit.items[i];
          if (item.variance == 0) {
            continue;
          }
          result.add(StockLedgerModel(
            id: _derived(entry.opId, 'stock/$i'),
            productId: item.productId,
            variantId: item.variantId,
            sku: item.sku,
            quantity: item.variance,
            movementType: StockMovementType.adjustment,
            sourceId: audit.id,
            movementDate: audit.auditDate,
            note: audit.note.isEmpty ? audit.auditNo : '${audit.auditNo}: ${audit.note}',
            createdAt: entry.createdAt,
            updatedAt: entry.createdAt,
          ));
        }
      default:
        break;
    }
  }
  return result;
}

// ---- ledger entries --------------------------------------------------------

List<LedgerModel> overlayLedgers(List<LedgerModel> base, List<OutboxEntry> entries) {
  final Map<String, LedgerModel> byId = <String, LedgerModel>{
    for (final LedgerModel e in base) e.id: e,
  };
  bool serverHasOrder(String orderId, {String? descriptionStart}) => base.any(
      (LedgerModel e) =>
          e.orderId == orderId &&
          (descriptionStart == null
              ? e.description.startsWith(ServerText.cancelledOrderLedgerPrefix) == false
              : e.description.startsWith(descriptionStart)));
  bool serverHasPurchase(String purchaseId) =>
      base.any((LedgerModel e) => e.purchaseId == purchaseId);

  for (final OutboxEntry entry in _shown(entries)) {
    switch (entry.kind) {
      case OutboxKind.orderConfirm:
        final OrderModel order = _order(entry.payload);
        // The server records the charge and the payment together with the order.
        if (serverHasOrder(order.id)) {
          continue;
        }
        final List<PaymentLine> lines = PaymentLine.listFrom(entry.payload['payments']);
        final double paid = lines.isEmpty ? _paidNow(entry.payload) : PaymentLine.total(lines);
        if (order.totalAmount > 0) {
          final String id = _derived(entry.opId, 'charge');
          byId[id] = LedgerModel(
            id: id,
            partyType: PartyType.customer,
            partyId: order.customerId,
            entryType: LedgerEntryType.charge,
            amount: order.totalAmount,
            entryDate: order.orderDate,
            description: 'Order ${order.orderNo}',
            reference: order.orderNo,
            orderId: order.id,
            createdAt: entry.createdAt,
            updatedAt: entry.createdAt,
          );
        }
        if (paid > 0) {
          // One payment per method; a plain amount is one payment of no recorded method.
          final List<PaymentLine?> parts = lines.isEmpty ? <PaymentLine?>[null] : lines;
          for (int i = 0; i < parts.length; i++) {
            final PaymentLine? line = parts[i];
            final String id = _derived(entry.opId, lines.isEmpty ? 'payment' : 'payment$i');
            byId[id] = LedgerModel(
              id: id,
              partyType: PartyType.customer,
              partyId: order.customerId,
              entryType: LedgerEntryType.payment,
              amount: line?.amount ?? paid,
              entryDate: order.orderDate,
              description: 'Payment for ${order.orderNo}',
              reference: order.orderNo,
              paymentMethod: line?.method.name ?? '',
              paymentRef: line?.reference ?? '',
              orderId: order.id,
              createdAt: entry.createdAt,
              updatedAt: entry.createdAt,
            );
          }
        }
      case OutboxKind.orderCancel:
        final OrderModel order = _order(entry.payload);
        if (serverHasOrder(order.id, descriptionStart: ServerText.cancelledOrderLedgerPrefix) ||
            order.totalAmount <= 0) {
          continue;
        }
        final String id = _derived(entry.opId, 'reversal');
        byId[id] = LedgerModel(
          id: id,
          partyType: PartyType.customer,
          partyId: order.customerId,
          entryType: LedgerEntryType.payment,
          amount: order.totalAmount,
          entryDate: entry.createdAt,
          description: 'Cancelled order ${order.orderNo}',
          reference: order.orderNo,
          orderId: order.id,
          createdAt: entry.createdAt,
          updatedAt: entry.createdAt,
        );
      case OutboxKind.purchaseConfirm:
        final PurchaseModel purchase = _purchase(entry.payload);
        if (serverHasPurchase(purchase.id)) {
          continue;
        }
        final double paid = _paidNow(entry.payload);
        if (purchase.totalAmount > 0) {
          final String id = _derived(entry.opId, 'charge');
          byId[id] = LedgerModel(
            id: id,
            partyType: PartyType.vendor,
            partyId: purchase.vendorId,
            entryType: LedgerEntryType.charge,
            amount: purchase.totalAmount,
            entryDate: purchase.purchaseDate,
            description: 'Purchase ${purchase.purchaseNo}',
            reference: purchase.invoiceNo,
            purchaseId: purchase.id,
            createdAt: entry.createdAt,
            updatedAt: entry.createdAt,
          );
        }
        if (paid > 0) {
          final String id = _derived(entry.opId, 'payment');
          byId[id] = LedgerModel(
            id: id,
            partyType: PartyType.vendor,
            partyId: purchase.vendorId,
            entryType: LedgerEntryType.payment,
            amount: paid,
            entryDate: purchase.purchaseDate,
            description: 'Payment for ${purchase.purchaseNo}',
            reference: purchase.invoiceNo,
            purchaseId: purchase.id,
            createdAt: entry.createdAt,
            updatedAt: entry.createdAt,
          );
        }
      case OutboxKind.orderPayment:
      case OutboxKind.purchasePayment:
      case OutboxKind.ledgerEntry:
        // These carry the id the server will keep, so the same record is never twice.
        final LedgerModel ledger = _entry(entry.payload);
        byId.putIfAbsent(ledger.id, () => ledger);
      case OutboxKind.delete:
        if (entry.collection == StorageKeys.ledgers) {
          byId.remove(entry.entityId);
        }
      default:
        break;
    }
  }
  return byId.values.toList();
}
