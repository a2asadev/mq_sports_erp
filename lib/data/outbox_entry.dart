/// What a queued action is.
enum OutboxKind {
  /// Create or change a record: category, product, vendor, customer, user.
  upsert,
  delete,

  /// Order actions.
  orderConfirm,
  orderStatus,
  orderCancel,
  orderPayment,

  /// Purchase actions.
  purchaseConfirm,
  purchasePayment,

  /// A manual vendor/customer ledger entry (cash received, adjustment).
  ledgerEntry,

  /// A stock count.
  auditConfirm;

  static OutboxKind fromName(String name) {
    for (final OutboxKind kind in OutboxKind.values) {
      if (kind.name == name) {
        return kind;
      }
    }
    throw ArgumentError('Unknown outbox kind: $name');
  }
}

enum OutboxState {
  /// Waiting to be uploaded.
  pending,

  /// The server accepted it. It stays (and keeps being shown) until the next
  /// download has brought the server's own records, so nothing flickers or is
  /// counted twice in between.
  sent,

  /// The server refused it (see [OutboxEntry.error]). The user can retry or discard it.
  failed;

  static OutboxState fromName(String name) {
    for (final OutboxState state in OutboxState.values) {
      if (state.name == name) {
        return state;
      }
    }
    return OutboxState.pending;
  }
}

/// One thing the user did that the server has not fully taken over yet.
class OutboxEntry {
  const OutboxEntry({
    required this.seq,
    required this.opId,
    required this.kind,
    required this.collection,
    required this.entityId,
    required this.label,
    required this.payload,
    required this.createdAt,
    this.isNew = false,
    this.state = OutboxState.pending,
    this.error = '',
    this.attempts = 0,
  });

  /// Upload order.
  final int seq;

  /// Sent to the server as the Idempotency-Key, so a retry cannot do it twice.
  final String opId;
  final OutboxKind kind;
  final String collection;
  final String entityId;
  final String label;

  /// Everything needed to do it again later, as plain JSON.
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  /// For an upsert: the record does not exist on the server yet.
  final bool isNew;
  final OutboxState state;
  final String error;
  final int attempts;

  /// True while the screens should show what this entry will cause.
  bool get isShown => state != OutboxState.failed;

  OutboxEntry copyWith({
    Map<String, dynamic>? payload,
    String? label,
    bool? isNew,
    OutboxState? state,
    String? error,
    int? attempts,
  }) {
    return OutboxEntry(
      seq: seq,
      opId: opId,
      kind: kind,
      collection: collection,
      entityId: entityId,
      label: label ?? this.label,
      payload: payload ?? this.payload,
      createdAt: createdAt,
      isNew: isNew ?? this.isNew,
      state: state ?? this.state,
      error: error ?? this.error,
      attempts: attempts ?? this.attempts,
    );
  }
}
