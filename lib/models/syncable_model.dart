/// Contract every top-level (aggregate root) model fulfils so the generic
/// storage, repository and provider layers can handle it.
///
/// Implementations must stay pure Dart: no Firebase types, dates serialized
/// as ISO 8601 strings, ids generated client-side with `Uuid().v4()`.
abstract class SyncableModel {
  String get id;

  DateTime get updatedAt;

  Map<String, dynamic> toMap();
}
