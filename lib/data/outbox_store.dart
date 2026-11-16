import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:a2_stocks/data/local/app_database.dart';
import 'package:a2_stocks/data/local/tables.dart';
import 'package:a2_stocks/data/outbox_entry.dart';
import 'package:uuid/uuid.dart';

/// The queue of things the user did that the server has not taken over yet.
///
/// All changes happen inside a database transaction, so the queue is never half
/// written, even if the app is closed in the middle of an action.
class OutboxStore {
  OutboxStore(this._db);

  final AppDatabase _db;

  static const Uuid _uuid = Uuid();

  OutboxEntry _entry(OutboxRow r) => OutboxEntry(
        seq: r.seq,
        opId: r.opId,
        kind: OutboxKind.fromName(r.kind),
        collection: r.collection,
        entityId: r.entityId,
        label: r.label,
        payload: jsonDecode(r.payload) as Map<String, dynamic>,
        createdAt: r.createdAt,
        isNew: r.isNew,
        state: OutboxState.fromName(r.state),
        error: r.error,
        attempts: r.attempts,
      );

  /// Every entry, oldest first.
  Future<List<OutboxEntry>> all() async {
    final List<OutboxRow> rows =
        await (_db.select(_db.outbox)..orderBy(<OrderClauseGenerator<Outbox>>[(Outbox t) => OrderingTerm.asc(t.seq)])).get();
    return rows.map(_entry).toList();
  }

  /// Emits the whole queue every time it changes.
  Stream<List<OutboxEntry>> watch() {
    final SimpleSelectStatement<Outbox, OutboxRow> query = _db.select(_db.outbox)
      ..orderBy(<OrderClauseGenerator<Outbox>>[(Outbox t) => OrderingTerm.asc(t.seq)]);
    return query.watch().map((List<OutboxRow> rows) => rows.map(_entry).toList());
  }

  Future<List<OutboxEntry>> pending() async =>
      (await all()).where((OutboxEntry e) => e.state == OutboxState.pending).toList();

  Future<int> countOf(OutboxState state) async =>
      (await all()).where((OutboxEntry e) => e.state == state).length;

  OutboxCompanion _companion({
    required OutboxKind kind,
    required String collection,
    required String entityId,
    required String label,
    required Map<String, dynamic> payload,
    required bool isNew,
  }) {
    return OutboxCompanion(
      opId: Value<String>(_uuid.v4()),
      kind: Value<String>(kind.name),
      collection: Value<String>(collection),
      entityId: Value<String>(entityId),
      label: Value<String>(label),
      isNew: Value<bool>(isNew),
      payload: Value<String>(jsonEncode(payload)),
      createdAt: Value<DateTime>(DateTime.now()),
    );
  }

  /// Queues a create or an edit of a record.
  ///
  /// There is only ever one queued change per record: editing a record that is
  /// still waiting to be uploaded updates that entry (a record created offline
  /// and then edited stays ONE create, with the latest content), and it keeps
  /// its place in the queue, so things that depend on it stay after it.
  Future<void> enqueueUpsert({
    required String collection,
    required String entityId,
    required String label,
    required Map<String, dynamic> payload,
    required bool existsOnServer,
  }) {
    return _db.transaction(() async {
      final OutboxRow? waiting = await (_db.select(_db.outbox)
            ..where((Outbox t) =>
                t.collection.equals(collection) &
                t.entityId.equals(entityId) &
                t.kind.equals(OutboxKind.upsert.name) &
                t.state.isIn(<String>[OutboxState.pending.name, OutboxState.failed.name])))
          .getSingleOrNull();
      if (waiting != null) {
        await (_db.update(_db.outbox)..where((Outbox t) => t.seq.equals(waiting.seq))).write(OutboxCompanion(
          payload: Value<String>(jsonEncode(payload)),
          label: Value<String>(label),
          state: Value<String>(OutboxState.pending.name),
          error: const Value<String>(''),
        ));
        return;
      }
      await _db.into(_db.outbox).insert(_companion(
            kind: OutboxKind.upsert,
            collection: collection,
            entityId: entityId,
            label: label,
            payload: payload,
            isNew: !existsOnServer,
          ));
    });
  }

  /// Queues the removal of a record. A record that was only ever created on
  /// this device (never uploaded) is simply forgotten: nothing reaches the server.
  Future<void> enqueueDelete({
    required String collection,
    required String entityId,
    required String label,
  }) {
    return _db.transaction(() async {
      final List<OutboxRow> waiting = await (_db.select(_db.outbox)
            ..where((Outbox t) =>
                t.collection.equals(collection) &
                t.entityId.equals(entityId) &
                t.kind.isIn(<String>[OutboxKind.upsert.name, OutboxKind.ledgerEntry.name]) &
                t.state.isIn(<String>[OutboxState.pending.name, OutboxState.failed.name])))
          .get();
      final bool neverUploaded = waiting.any((OutboxRow r) => r.isNew);
      if (waiting.isNotEmpty) {
        await (_db.delete(_db.outbox)..where((Outbox t) => t.seq.isIn(waiting.map((OutboxRow r) => r.seq).toList()))).go();
      }
      if (neverUploaded) {
        return;
      }
      final OutboxRow? alreadyDeleting = await (_db.select(_db.outbox)
            ..where((Outbox t) =>
                t.collection.equals(collection) &
                t.entityId.equals(entityId) &
                t.kind.equals(OutboxKind.delete.name) &
                t.state.equals(OutboxState.pending.name)))
          .getSingleOrNull();
      if (alreadyDeleting != null) {
        return;
      }
      await _db.into(_db.outbox).insert(_companion(
            kind: OutboxKind.delete,
            collection: collection,
            entityId: entityId,
            label: label,
            payload: <String, dynamic>{},
            isNew: false,
          ));
    });
  }

  /// Queues an action (confirm an order, record a payment...).
  Future<String> enqueue(
    OutboxKind kind, {
    required String collection,
    required String entityId,
    required String label,
    required Map<String, dynamic> payload,
    bool isNew = true,
  }) async {
    final OutboxCompanion companion = _companion(
      kind: kind,
      collection: collection,
      entityId: entityId,
      label: label,
      payload: payload,
      isNew: isNew,
    );
    await _db.into(_db.outbox).insert(companion);
    return companion.opId.value;
  }

  Future<void> _set(String opId, OutboxCompanion change) =>
      (_db.update(_db.outbox)..where((Outbox t) => t.opId.equals(opId))).write(change);

  /// The server accepted it. It stays visible until its records have been downloaded.
  Future<void> markSent(String opId) =>
      _set(opId, OutboxCompanion(state: Value<String>(OutboxState.sent.name), error: const Value<String>('')));

  Future<void> markFailed(String opId, String error) =>
      _set(opId, OutboxCompanion(state: Value<String>(OutboxState.failed.name), error: Value<String>(error)));

  /// Try again (the user pressed Retry, or the server was not reachable).
  Future<void> markPending(String opId) =>
      _set(opId, OutboxCompanion(state: Value<String>(OutboxState.pending.name), error: const Value<String>('')));

  Future<void> countAttempt(String opId) async {
    await _db.customStatement('UPDATE outbox SET attempts = attempts + 1 WHERE op_id = ?', <Object>[opId]);
  }

  Future<void> remove(List<String> opIds) =>
      (_db.delete(_db.outbox)..where((Outbox t) => t.opId.isIn(opIds))).go();
}
