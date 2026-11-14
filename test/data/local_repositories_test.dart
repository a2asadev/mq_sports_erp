import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/data/local/app_database.dart';
import 'package:mq_sports_erp/data/local/collections.dart';
import 'package:mq_sports_erp/data/local_repositories.dart';
import 'package:mq_sports_erp/data/outbox_entry.dart';
import 'package:mq_sports_erp/data/outbox_store.dart';
import 'package:mq_sports_erp/data/pending_effects.dart';
import 'package:mq_sports_erp/models/category_model.dart';
import 'package:mq_sports_erp/models/ledger_model.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/stock_audit_model.dart';
import 'package:mq_sports_erp/models/stock_ledger_model.dart';

final DateTime _t = DateTime(2026, 11, 14, 10);

void main() {
  late AppDatabase db;
  late LocalCollections local;
  late OutboxStore outbox;
  late LocalRepository<CategoryModel> categories;
  late LocalOrderRepository orders;
  late LocalStockLedgerRepository stock;
  late LocalLedgerRepository ledger;
  late LocalStockAuditRepository audits;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    local = LocalCollections(db);
    outbox = OutboxStore(db);
    categories = LocalRepository<CategoryModel>(
      collection: local.categories,
      outbox: outbox,
      entityLabel: 'Category',
      labelOf: (CategoryModel c) => c.name,
      overlay: (List<CategoryModel> base, List<OutboxEntry> entries) => overlayRecords<CategoryModel>(
          collection: 'categories', base: base, entries: entries, fromMap: CategoryModel.fromMap),
    );
    orders = LocalOrderRepository(collection: local.orders, outbox: outbox);
    stock = LocalStockLedgerRepository(collection: local.stockLedgers, outbox: outbox);
    ledger = LocalLedgerRepository(collection: local.ledgers, outbox: outbox);
    audits = LocalStockAuditRepository(collection: local.stockAudits, outbox: outbox);
  });

  tearDown(() async {
    await db.close();
  });

  CategoryModel cat(String id, String name) => CategoryModel(id: id, name: name, createdAt: _t, updatedAt: _t);

  OrderModel order({String id = 'o1'}) => OrderModel(
        id: id, orderNo: 'ORD-1', customerId: 'cust', customerName: 'Ali', orderDate: _t, createdAt: _t, updatedAt: _t,
        items: <OrderItem>[
          OrderItem(id: 'i1', productId: 'p', variantId: 'v1', productName: 'Bat', variantLabel: 'S', sku: 'B-S', quantity: 3, unitPrice: 100),
        ],
        statusHistory: <OrderStatusEntry>[OrderStatusEntry(status: OrderStatus.pending, changedAt: _t, byName: 'Ann')],
      );

  group('plain records', () {
    test('a new record shows at once and waits in the queue as a create', () async {
      await categories.save(cat('c1', 'Cricket'));

      expect((await categories.getLocal()).single.name, 'Cricket');
      expect((await categories.getLocalById('c1'))?.name, 'Cricket');
      final List<OutboxEntry> queue = await outbox.all();
      expect(queue.single.kind, OutboxKind.upsert);
      expect(queue.single.isNew, isTrue);
      expect(queue.single.label, 'Category "Cricket"');
      // Nothing was written to the confirmed records.
      expect(await local.categories.all(), isEmpty);
    });

    test('editing an unsent record stays ONE create with the latest content, in its original place', () async {
      await categories.save(cat('c1', 'First'));
      await categories.save(cat('c2', 'Other'));
      final int firstSeq = (await outbox.all()).first.seq;

      await categories.save(cat('c1', 'Edited'));

      final List<OutboxEntry> queue = await outbox.all();
      expect(queue.length, 2);
      expect(queue.first.seq, firstSeq);
      expect(queue.first.isNew, isTrue);
      expect((await categories.getLocalById('c1'))?.name, 'Edited');
    });

    test('deleting a record that never reached the server removes it from the queue entirely', () async {
      await categories.save(cat('c1', 'Mistake'));
      await categories.delete('c1');
      expect(await outbox.all(), isEmpty);
      expect(await categories.getLocal(), isEmpty);
    });

    test('editing a confirmed record queues an update, and deleting it replaces the edit with a delete', () async {
      await local.categories.upsertAll(<CategoryModel>[cat('c1', 'Confirmed')]);

      await categories.save(cat('c1', 'Renamed'));
      List<OutboxEntry> queue = await outbox.all();
      expect(queue.single.isNew, isFalse);
      expect((await categories.getLocalById('c1'))?.name, 'Renamed');
      expect((await local.categories.byId('c1'))?.name, 'Confirmed');

      await categories.delete('c1');
      queue = await outbox.all();
      expect(queue.single.kind, OutboxKind.delete);
      expect(await categories.getLocal(), isEmpty);
      expect(await categories.getLocalById('c1'), isNull);
      // Deleting twice does not queue two deletes.
      await categories.delete('c1');
      expect((await outbox.all()).length, 1);
    });

    test('a record the server accepted but has not sent back is edited as an update, not a second create', () async {
      await categories.save(cat('c1', 'Sent'));
      await outbox.markSent((await outbox.all()).single.opId);
      await categories.save(cat('c1', 'Edited after sending'));
      final List<OutboxEntry> queue = await outbox.all();
      expect(queue.length, 2);
      expect(queue.last.isNew, isFalse);
    });

    test('a refused entry stops showing and can be retried', () async {
      await categories.save(cat('c1', 'Refused'));
      final String opId = (await outbox.all()).single.opId;
      await outbox.markFailed(opId, 'A category named "Refused" already exists here.');

      expect(await categories.getLocal(), isEmpty);
      expect((await outbox.all()).single.error, contains('already exists'));
      expect(await outbox.countOf(OutboxState.failed), 1);

      await outbox.markPending(opId);
      expect((await categories.getLocal()).single.name, 'Refused');
      expect(await outbox.countOf(OutboxState.failed), 0);
    });

    test('editing a refused entry puts it back to pending with the new content', () async {
      await categories.save(cat('c1', 'Bad'));
      await outbox.markFailed((await outbox.all()).single.opId, 'no');
      await categories.save(cat('c1', 'Fixed'));
      final OutboxEntry entry = (await outbox.all()).single;
      expect(entry.state, OutboxState.pending);
      expect(entry.error, '');
      expect(entry.payload['name'], 'Fixed');
    });

    test('the queue keeps entries in upload order and the delete guard is used', () async {
      final LocalRepository<CategoryModel> guarded = LocalRepository<CategoryModel>(
        collection: local.categories,
        outbox: outbox,
        entityLabel: 'Category',
        labelOf: (CategoryModel c) => c.name,
        overlay: (List<CategoryModel> base, List<OutboxEntry> entries) => base,
        deleteGuard: (String id) async => id == 'busy' ? 'it has subcategories' : null,
      );
      expect(await guarded.deleteBlockReason('busy'), 'it has subcategories');
      expect(await guarded.deleteBlockReason('free'), isNull);
      await categories.save(cat('a', 'A'));
      await categories.save(cat('b', 'B'));
      expect((await outbox.all()).map((OutboxEntry e) => e.entityId), <String>['a', 'b']);
    });
  });

  group('actions', () {
    test('confirming an order shows the order, the stock leaving and the debt, and queues one action', () async {
      await local.stockLedgers.upsertAll(<StockLedgerModel>[
        StockLedgerModel(id: 'm0', productId: 'p', variantId: 'v1', sku: 'B-S', quantity: 10,
            movementType: StockMovementType.purchase, createdAt: _t, updatedAt: _t),
      ]);

      await orders.confirm(order(), paidNow: 100);

      expect((await orders.getLocal()).single.orderNo, 'ORD-1');
      final List<StockLedgerModel> movements = await stock.getLocal();
      expect(movements.fold<int>(0, (int s, StockLedgerModel m) => s + m.quantity), 7);
      final List<LedgerModel> entries = await ledger.getLocal();
      expect(entries.fold<double>(0, (double s, LedgerModel e) => s + e.signedAmount), 200);
      final List<OutboxEntry> queue = await outbox.all();
      expect(queue.single.kind, OutboxKind.orderConfirm);
      expect(queue.single.label, 'Order ORD-1');
      // The confirmed tables did not change.
      expect(await local.orders.all(), isEmpty);
      expect((await local.stockLedgers.all()).length, 1);
    });

    test('moving an order on queues a status step; the same status twice queues nothing', () async {
      await local.orders.upsertAll(<OrderModel>[order()]);
      final OrderModel current = (await orders.getLocalById('o1'))!;
      final OrderModel advanced = current.copyWith(
        status: OrderStatus.processing,
        statusHistory: <OrderStatusEntry>[
          ...current.statusHistory,
          OrderStatusEntry(status: OrderStatus.processing, changedAt: _t, byName: 'Ann'),
        ],
      );

      await orders.save(advanced);
      await orders.save(advanced);
      expect((await orders.getLocalById('o1'))?.status, OrderStatus.processing);
      // The second save sees the status already applied, so it queues nothing more.
      expect((await outbox.all()).length, 1);
    });

    test('cancelling shows the order as cancelled and gives the stock back', () async {
      await local.orders.upsertAll(<OrderModel>[order()]);
      // 10 bought, 3 sold by this order: 7 on the shelf.
      await local.stockLedgers.upsertAll(<StockLedgerModel>[
        StockLedgerModel(id: 'm0', productId: 'p', variantId: 'v1', sku: 'B-S', quantity: 10,
            movementType: StockMovementType.purchase, sourceId: 'pu1', createdAt: _t, updatedAt: _t),
        StockLedgerModel(id: 'm1', productId: 'p', variantId: 'v1', sku: 'B-S', quantity: -3,
            movementType: StockMovementType.sale, sourceId: 'o1', createdAt: _t, updatedAt: _t),
      ]);
      final OrderModel base = (await orders.getLocalById('o1'))!;
      final OrderModel cancelled = base.copyWith(
        status: OrderStatus.cancelled,
        statusHistory: <OrderStatusEntry>[
          ...base.statusHistory,
          OrderStatusEntry(status: OrderStatus.cancelled, changedAt: _t, byName: 'Ann'),
        ],
      );
      await orders.cancel(cancelled, when: _t);

      expect((await orders.getLocalById('o1'))?.status, OrderStatus.cancelled);
      expect((await stock.getLocal()).fold<int>(0, (int s, StockLedgerModel m) => s + m.quantity), 10);
    });

    test('payments queue as the kind of action that matches what they belong to', () async {
      LedgerModel payment(String id, {String orderId = '', String purchaseId = ''}) => LedgerModel(
          id: id, partyType: PartyType.customer, partyId: 'cust', entryType: LedgerEntryType.payment,
          amount: 25, reference: 'REF', orderId: orderId, purchaseId: purchaseId, createdAt: _t, updatedAt: _t);

      await ledger.save(payment('a', orderId: 'o1'));
      await ledger.save(payment('b', purchaseId: 'pu1'));
      await ledger.save(payment('c'));

      expect((await outbox.all()).map((OutboxEntry e) => e.kind),
          <OutboxKind>[OutboxKind.orderPayment, OutboxKind.purchasePayment, OutboxKind.ledgerEntry]);
      expect((await ledger.getLocal()).length, 3);

      // A manual entry that was never uploaded can be taken back.
      await ledger.delete('c');
      expect((await outbox.all()).length, 2);
      expect((await ledger.getLocal()).length, 2);
    });

    test('a stock count queues one action and shows its adjustment', () async {
      final StockAuditModel audit = StockAuditModel(
        id: 'a1', auditNo: 'AUD-1', auditDate: _t, createdAt: _t, updatedAt: _t,
        items: <StockAuditItem>[
          const StockAuditItem(productId: 'p', variantId: 'v1', productName: 'Bat', variantLabel: 'S', sku: 'B-S', systemQuantity: 7, countedQuantity: 5),
        ],
      );
      await audits.confirm(audit);
      expect((await audits.getLocal()).single.auditNo, 'AUD-1');
      expect((await stock.getLocal()).single.quantity, -2);
      expect((await outbox.all()).single.kind, OutboxKind.auditConfirm);
    });

    test('things that only an action can create refuse a direct save', () async {
      await expectLater(stock.save(StockLedgerModel(productId: 'p', variantId: 'v', sku: 's', quantity: 1, movementType: StockMovementType.adjustment)),
          throwsA(isA<ValidationException>()));
      await expectLater(orders.delete('o1'), throwsA(isA<ValidationException>()));
      await expectLater(orders.save(order(id: 'ghost')), throwsA(isA<ValidationException>()));
    });
  });

  group('the queue', () {
    test('survives a restart: entries are in the database, in order', () async {
      await categories.save(cat('a', 'A'));
      await orders.confirm(order(), paidNow: 0);
      final OutboxStore again = OutboxStore(db); // as after reopening the app
      final List<OutboxEntry> queue = await again.all();
      expect(queue.map((OutboxEntry e) => e.kind), <OutboxKind>[OutboxKind.upsert, OutboxKind.orderConfirm]);
      expect(queue.first.seq < queue.last.seq, isTrue);
      expect(queue.map((OutboxEntry e) => e.opId).toSet().length, 2);
    });

    test('can be watched, counted and cleared', () async {
      final List<int> sizes = <int>[];
      final subscription = outbox.watch().listen((List<OutboxEntry> e) => sizes.add(e.length));
      await categories.save(cat('a', 'A'));
      await categories.save(cat('b', 'B'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(sizes.last, 2);
      expect((await outbox.pending()).length, 2);

      await outbox.countAttempt((await outbox.all()).first.opId);
      expect((await outbox.all()).first.attempts, 1);

      await outbox.remove((await outbox.all()).map((OutboxEntry e) => e.opId).toList());
      expect(await outbox.all(), isEmpty);
      await subscription.cancel();
    });
  });
}
