/// Kind of local change that has not been uploaded yet.
enum PendingChangeType {
  create('Created'),
  update('Edited'),
  delete('Deleted');

  const PendingChangeType(this.label);

  final String label;

  static PendingChangeType fromName(String? name) {
    for (final PendingChangeType type in PendingChangeType.values) {
      if (type.name == name) {
        return type;
      }
    }
    return PendingChangeType.update;
  }
}

/// One local change waiting to be uploaded to Firestore. At most one entry
/// exists per record; later edits update it.
class PendingChange {
  const PendingChange({
    required this.collection,
    required this.entityId,
    required this.entityLabel,
    required this.itemLabel,
    required this.type,
    required this.changedAt,
    this.groupId = '',
  });

  final String collection;
  final String entityId;

  /// Kind of record, for display (for example "Product").
  final String entityLabel;

  /// Name of the record, for display (for example "Kashmir Willow Bat").
  final String itemLabel;
  final PendingChangeType type;
  final DateTime changedAt;

  /// Changes that share a non-empty group id (for example a purchase, its
  /// stock entries and its vendor ledger entries) are uploaded together in
  /// one atomic Firestore transaction.
  final String groupId;

  String get key => '$collection:$entityId';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'collection': collection,
      'entityId': entityId,
      'entityLabel': entityLabel,
      'itemLabel': itemLabel,
      'type': type.name,
      'changedAt': changedAt.toIso8601String(),
      'groupId': groupId,
    };
  }

  factory PendingChange.fromMap(Map<String, dynamic> map) {
    return PendingChange(
      collection: map['collection'] as String? ?? '',
      entityId: map['entityId'] as String? ?? '',
      entityLabel: map['entityLabel'] as String? ?? '',
      itemLabel: map['itemLabel'] as String? ?? '',
      type: PendingChangeType.fromName(map['type'] as String?),
      changedAt: DateTime.tryParse(map['changedAt'] as String? ?? '') ??
          DateTime.now(),
      groupId: map['groupId'] as String? ?? '',
    );
  }

  PendingChange copyWith({
    String? itemLabel,
    PendingChangeType? type,
    DateTime? changedAt,
    String? groupId,
  }) {
    return PendingChange(
      collection: collection,
      entityId: entityId,
      entityLabel: entityLabel,
      itemLabel: itemLabel ?? this.itemLabel,
      type: type ?? this.type,
      changedAt: changedAt ?? this.changedAt,
      groupId: groupId ?? this.groupId,
    );
  }
}
