import 'package:flutter_test/flutter_test.dart';
import 'package:mq_sports_erp/data/outbox_entry.dart';
import 'package:mq_sports_erp/data/pending_effects.dart';
import 'package:mq_sports_erp/models/category_model.dart';
import 'package:mq_sports_erp/models/ledger_model.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/payment_method.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/purchase_model.dart';
import 'package:mq_sports_erp/models/stock_audit_model.dart';
import 'package:mq_sports_erp/models/stock_ledger_model.dart';

final DateTime _t = DateTime(2026, 11, 14, 10);
int _seq = 0;

OutboxEntry entry(
  OutboxKind kind,
  Map<String, dynamic> payload, {
  String collection = 'orders',
  String entityId = 'x',
  OutboxState state = OutboxState.pending,
  bool isNew = false,
  String? opId,
}) {
  _seq++;
  return OutboxEntry(
    seq: _seq,
    opId: opId ?? 'op-$_seq',
    kind: kind,
    collection: collection,
    entityId: entityId,
    label: 'label',
    payload: payload,
    createdAt: _t,
    isNew: isNew,
    state: state,
  );
}

OrderModel sampleOrder({String id = 'o1', int qty = 3, double price = 100, double discount = 0}) => OrderModel(
      id: id, orderNo: 'ORD-1', customerId: 'cust', customerName: 'Ali', orderDate: _t, discount: discount,
      createdAt: _t, updatedAt: _t,
      items: <OrderItem>[
        OrderItem(id: 'i1', productId: 'p', variantId: 'v1', productName: 'Bat', variantLabel: 'S', sku: 'B-S', quantity: qty, unitPrice: price),
      ],
      statusHistory: <OrderStatusEntry>[OrderStatusEntry(status: OrderStatus.pending, changedAt: _t, byName: 'Ann')],
    );

StockLedgerModel move(String id, int qty, String source, {String variant = 'v1'}) => StockLedgerModel(
    id: id, productId: 'p', variantId: variant, sku: 'B-S', quantity: qty,
    movementType: StockMovementType.sale, sourceId: source, createdAt: _t, updatedAt: _t);

int onHand(List<StockLedgerModel> list, String variant) => list
    .where((StockLedgerModel m) => m.variantId == variant)
    .fold<int>(0, (int s, StockLedgerModel m) => s + m.quantity);

double owed(List<LedgerModel> list, String party) =>
    list.where((LedgerModel e) => e.partyId == party).fold<double>(0, (double s, LedgerModel e) => s + e.signedAmount);

void main() {
  group('plain records', () {
    CategoryModel cat(String id, String name) => CategoryModel(id: id, name: name, createdAt: _t, updatedAt: _t);

    test('queued creates, edits and deletes show on top of the confirmed data', () {
      final List<CategoryModel> base = <CategoryModel>[cat('a', 'Old name'), cat('b', 'To delete')];
      final List<CategoryModel> shown = overlayRecords<CategoryModel>(
        collection: 'categories',
        base: base,
        fromMap: CategoryModel.fromMap,
        entries: <OutboxEntry>[
          entry(OutboxKind.upsert, cat('a', 'New name').toMap(), collection: 'categories', entityId: 'a'),
          entry(OutboxKind.upsert, cat('c', 'Created offline').toMap(), collection: 'categories', entityId: 'c', isNew: true),
          entry(OutboxKind.delete, <String, dynamic>{}, collection: 'categories', entityId: 'b'),
        ],
      );
      expect(shown.map((CategoryModel c) => '${c.id}:${c.name}').toList()..sort(), <String>['a:New name', 'c:Created offline']);
      // The confirmed list itself is untouched.
      expect(base.map((CategoryModel c) => c.name), <String>['Old name', 'To delete']);
    });

    test('a refused entry shows nothing, other collections are ignored', () {
      final List<CategoryModel> shown = overlayRecords<CategoryModel>(
        collection: 'categories',
        base: <CategoryModel>[cat('a', 'Same')],
        fromMap: CategoryModel.fromMap,
        entries: <OutboxEntry>[
          entry(OutboxKind.upsert, cat('a', 'Refused edit').toMap(), collection: 'categories', entityId: 'a', state: OutboxState.failed),
          entry(OutboxKind.upsert, cat('z', 'Other').toMap(), collection: 'products', entityId: 'z'),
        ],
      );
      expect(shown.single.name, 'Same');
    });

    test('a sent entry still shows until the server\'s copy arrives', () {
      final List<CategoryModel> shown = overlayRecords<CategoryModel>(
        collection: 'categories',
        base: <CategoryModel>[],
        fromMap: CategoryModel.fromMap,
        entries: <OutboxEntry>[
          entry(OutboxKind.upsert, cat('a', 'Just sent').toMap(), collection: 'categories', entityId: 'a', state: OutboxState.sent),
        ],
      );
      expect(shown.single.name, 'Just sent');
    });
  });

  group('an order confirmed offline', () {
    final OrderModel order = sampleOrder(discount: 10); // 3 x 100 - 10 = 290
    final OutboxEntry confirm = entry(OutboxKind.orderConfirm,
        <String, dynamic>{'order': order.toMap(), 'paidNow': 100}, entityId: 'o1', opId: 'op-confirm');

    test('shows the order, the stock leaving and what the customer owes', () {
      final List<OutboxEntry> entries = <OutboxEntry>[confirm];
      final List<OrderModel> orders = overlayOrders(<OrderModel>[], entries);
      final List<StockLedgerModel> stock = overlayStock(<StockLedgerModel>[move('m0', 10, 'purchase-1')], entries);
      final List<LedgerModel> ledger = overlayLedgers(<LedgerModel>[], entries);

      expect(orders.single.id, 'o1');
      expect(orders.single.totalAmount, 290);
      expect(onHand(stock, 'v1'), 10 - 3);
      expect(owed(ledger, 'cust'), 290 - 100);
      expect(ledger.where((LedgerModel e) => e.orderId == 'o1').length, 2);
    });

    test('the same ids come out every time it is read', () {
      final List<String> first = overlayLedgers(<LedgerModel>[], <OutboxEntry>[confirm]).map((LedgerModel e) => e.id).toList()..sort();
      final List<String> second = overlayLedgers(<LedgerModel>[], <OutboxEntry>[confirm]).map((LedgerModel e) => e.id).toList()..sort();
      expect(first, second);
      expect(first.toSet().length, 2);
    });

    test('once the server\'s own records have arrived, nothing is counted twice', () {
      // What the server created for the same order: its own ids.
      final List<StockLedgerModel> serverStock = <StockLedgerModel>[
        move('m0', 10, 'purchase-1'),
        move('server-m1', -3, 'o1'),
      ];
      final List<LedgerModel> serverLedger = <LedgerModel>[
        LedgerModel(id: 'server-c', partyType: PartyType.customer, partyId: 'cust', entryType: LedgerEntryType.charge, amount: 290, orderId: 'o1', description: 'Order ORD-1', createdAt: _t, updatedAt: _t),
        LedgerModel(id: 'server-p', partyType: PartyType.customer, partyId: 'cust', entryType: LedgerEntryType.payment, amount: 100, orderId: 'o1', description: 'Payment for ORD-1', createdAt: _t, updatedAt: _t),
      ];
      final List<OutboxEntry> sent = <OutboxEntry>[confirm.copyWith(state: OutboxState.sent)];

      expect(onHand(overlayStock(serverStock, sent), 'v1'), 7);
      expect(owed(overlayLedgers(serverLedger, sent), 'cust'), 190);
      expect(overlayOrders(<OrderModel>[order], sent).length, 1);
    });

    test('a refused order disappears from every list', () {
      final List<OutboxEntry> failed = <OutboxEntry>[confirm.copyWith(state: OutboxState.failed)];
      expect(overlayOrders(<OrderModel>[], failed), isEmpty);
      expect(overlayStock(<StockLedgerModel>[], failed), isEmpty);
      expect(overlayLedgers(<LedgerModel>[], failed), isEmpty);
    });

    test('a free order has no charge, and no payment when nothing was paid', () {
      final OrderModel free = sampleOrder(price: 0);
      final List<LedgerModel> ledger = overlayLedgers(<LedgerModel>[], <OutboxEntry>[
        entry(OutboxKind.orderConfirm, <String, dynamic>{'order': free.toMap(), 'paidNow': 0}, entityId: 'o1'),
      ]);
      expect(ledger, isEmpty);
    });
  });

  group('order status and cancel', () {
    final OrderModel order = sampleOrder();

    test('moving an order on adds one history step, and is not applied twice', () {
      final OutboxEntry advance = entry(OutboxKind.orderStatus, <String, dynamic>{
        'status': 'processing',
        'entry': OrderStatusEntry(status: OrderStatus.processing, changedAt: _t, byName: 'Bo').toMap(),
      }, entityId: 'o1');

      final List<OrderModel> once = overlayOrders(<OrderModel>[order], <OutboxEntry>[advance]);
      expect(once.single.status, OrderStatus.processing);
      expect(once.single.statusHistory.length, 2);

      // The server's copy already says processing: the entry changes nothing.
      final List<OrderModel> arrived = overlayOrders(once, <OutboxEntry>[advance.copyWith(state: OutboxState.sent)]);
      expect(arrived.single.statusHistory.length, 2);
    });

    test('cancelling returns the stock and reverses the charge, and shows the order as cancelled', () {
      final OrderModel cancelled = order.copyWith(
        status: OrderStatus.cancelled,
        statusHistory: <OrderStatusEntry>[...order.statusHistory, OrderStatusEntry(status: OrderStatus.cancelled, changedAt: _t)],
      );
      final OutboxEntry cancel = entry(OutboxKind.orderCancel, <String, dynamic>{'order': cancelled.toMap()}, entityId: 'o1');
      final List<OutboxEntry> entries = <OutboxEntry>[
        entry(OutboxKind.orderConfirm, <String, dynamic>{'order': order.toMap(), 'paidNow': 0}, entityId: 'o1'),
        cancel,
      ];

      final List<OrderModel> orders = overlayOrders(<OrderModel>[], entries);
      expect(orders.single.status, OrderStatus.cancelled);
      expect(onHand(overlayStock(<StockLedgerModel>[move('m0', 10, 'purchase-1')], entries), 'v1'), 10);
      expect(owed(overlayLedgers(<LedgerModel>[], entries), 'cust'), 0);
    });
  });

  group('purchases, payments and counts', () {
    final PurchaseModel purchase = PurchaseModel(
      id: 'pu1', purchaseNo: 'PUR-1', vendorId: 'vend', vendorName: 'V', purchaseDate: _t, createdAt: _t, updatedAt: _t,
      items: <PurchaseItem>[
        PurchaseItem(id: 'i1', productId: 'p', variantId: 'v1', productName: 'Bat', variantLabel: 'S', sku: 'B-S', quantity: 10, unitCost: 50),
      ],
    );

    test('a purchase adds stock and charges the vendor', () {
      final List<OutboxEntry> entries = <OutboxEntry>[
        entry(OutboxKind.purchaseConfirm, <String, dynamic>{'purchase': purchase.toMap(), 'paidNow': 200}, collection: 'purchases', entityId: 'pu1'),
      ];
      expect(overlayPurchases(<PurchaseModel>[], entries).single.totalAmount, 500);
      expect(onHand(overlayStock(<StockLedgerModel>[], entries), 'v1'), 10);
      expect(owed(overlayLedgers(<LedgerModel>[], entries), 'vend'), 300);
    });

    test('a payment is shown once, and not again when the server\'s copy (same id) has arrived', () {
      final LedgerModel payment = LedgerModel(
        id: 'pay1', partyType: PartyType.customer, partyId: 'cust', entryType: LedgerEntryType.payment,
        amount: 50, orderId: 'o1', createdAt: _t, updatedAt: _t);
      final OutboxEntry op = entry(OutboxKind.orderPayment, <String, dynamic>{'entry': payment.toMap()}, collection: 'ledgers', entityId: 'pay1');

      expect(overlayLedgers(<LedgerModel>[], <OutboxEntry>[op]).length, 1);
      expect(overlayLedgers(<LedgerModel>[payment], <OutboxEntry>[op.copyWith(state: OutboxState.sent)]).length, 1);
    });

    test('a stock count adds an adjustment only for the items that differ', () {
      final StockAuditModel audit = StockAuditModel(
        id: 'a1', auditNo: 'AUD-1', auditDate: _t, note: 'shelf', createdAt: _t, updatedAt: _t,
        items: <StockAuditItem>[
          const StockAuditItem(productId: 'p', variantId: 'v1', productName: 'Bat', variantLabel: 'S', sku: 'B-S', systemQuantity: 7, countedQuantity: 5),
          const StockAuditItem(productId: 'p', variantId: 'v2', productName: 'Bat', variantLabel: 'L', sku: 'B-L', systemQuantity: 3, countedQuantity: 3),
        ],
      );
      final List<OutboxEntry> entries = <OutboxEntry>[
        entry(OutboxKind.auditConfirm, <String, dynamic>{'audit': audit.toMap()}, collection: 'stock_audits', entityId: 'a1'),
      ];
      final List<StockLedgerModel> stock = overlayStock(<StockLedgerModel>[move('m0', 7, 'purchase-1')], entries);
      expect(onHand(stock, 'v1'), 5);
      expect(stock.where((StockLedgerModel m) => m.variantId == 'v2'), isEmpty);
      expect(stock.last.note, 'AUD-1: shelf');
      expect(overlayAudits(<StockAuditModel>[], entries).single.id, 'a1');
    });
  });
  group('a POS sale paid by several methods, offline', () {
    final OrderModel order = sampleOrder(); // 3 x 100 = 300
    final OutboxEntry confirm = entry(
      OutboxKind.orderConfirm,
      <String, dynamic>{
        'order': order.toMap(),
        'paidNow': 300,
        'payments': <Map<String, dynamic>>[
          const PaymentLine(method: PaymentMethod.cash, amount: 120).toMap(),
          const PaymentLine(method: PaymentMethod.easypaisa, amount: 180, reference: 'EP-1').toMap(),
        ],
      },
      entityId: 'o1',
      opId: 'op-pos',
    );

    test('one payment per method shows at once, with its reference', () {
      final List<LedgerModel> ledger = overlayLedgers(<LedgerModel>[], <OutboxEntry>[confirm]);
      final List<LedgerModel> payments = ledger.where((LedgerModel e) => e.entryType == LedgerEntryType.payment).toList()
        ..sort((LedgerModel a, LedgerModel b) => a.amount.compareTo(b.amount));
      expect(payments.map((LedgerModel p) => '${p.paymentMethod}:${p.amount}:${p.paymentRef}'), <String>['cash:120.0:', 'easypaisa:180.0:EP-1']);
      expect(payments.map((LedgerModel p) => p.id).toSet(), hasLength(2));
      expect(ledger.where((LedgerModel e) => e.entryType == LedgerEntryType.charge).single.amount, 300);
      // Paid in full: nothing owed.
      expect(owed(ledger, 'cust'), 0);
    });

    test('the same ids every time, and nothing twice once the server has the order', () {
      List<String> ids() => overlayLedgers(<LedgerModel>[], <OutboxEntry>[confirm]).map((LedgerModel e) => e.id).toList()..sort();
      expect(ids(), ids());
      final List<LedgerModel> serverLedger = <LedgerModel>[
        LedgerModel(id: 'server-c', partyType: PartyType.customer, partyId: 'cust', entryType: LedgerEntryType.charge, amount: 300, orderId: 'o1', description: 'Order ORD-1', createdAt: _t, updatedAt: _t),
        LedgerModel(id: 'server-p1', partyType: PartyType.customer, partyId: 'cust', entryType: LedgerEntryType.payment, amount: 120, orderId: 'o1', paymentMethod: 'cash', createdAt: _t, updatedAt: _t),
        LedgerModel(id: 'server-p2', partyType: PartyType.customer, partyId: 'cust', entryType: LedgerEntryType.payment, amount: 180, orderId: 'o1', paymentMethod: 'easypaisa', createdAt: _t, updatedAt: _t),
      ];
      final List<OutboxEntry> sent = <OutboxEntry>[confirm.copyWith(state: OutboxState.sent)];
      expect(overlayLedgers(serverLedger, sent), hasLength(3));
    });
  });
}
