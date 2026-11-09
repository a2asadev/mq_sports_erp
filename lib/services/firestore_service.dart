import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';

/// Thin Cloud Firestore gateway. It only exchanges plain maps, so Firebase
/// types never leak into models, repositories or providers.
class FirestoreService {
  FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  static const Duration _timeout = Duration(seconds: 10);

  /// Converts Firestore-specific values to plain Dart values: a `Timestamp`
  /// (for example from a field typed by hand in the console) becomes an
  /// ISO 8601 string, as the models expect.
  Map<String, dynamic> _normalize(Map<String, dynamic> data) {
    return data.map(
      (String key, dynamic value) =>
          MapEntry<String, dynamic>(key, _normalizeValue(value)),
    );
  }

  Object? _normalizeValue(Object? value) {
    if (value is Timestamp) {
      return value.toDate().toUtc().toIso8601String();
    }
    if (value is Map<String, dynamic>) {
      return _normalize(value);
    }
    if (value is List<Object?>) {
      return value.map(_normalizeValue).toList();
    }
    return value;
  }

  Future<List<Map<String, dynamic>>> fetchAll(String collection) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(collection).get().timeout(_timeout);
      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => _normalize(doc.data()))
          .toList();
    } on Exception catch (e) {
      throw RemoteSyncException('Failed to fetch $collection: $e');
    }
  }

  Future<void> upsert(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(id).set(data).timeout(_timeout);
    } on Exception catch (e) {
      throw RemoteSyncException('Failed to save $collection/$id: $e');
    }
  }

  Future<void> delete(String collection, String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete().timeout(_timeout);
    } on Exception catch (e) {
      throw RemoteSyncException('Failed to delete $collection/$id: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchWhereEquals(
    String collection,
    String field,
    String value,
  ) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(collection)
          .where(field, isEqualTo: value)
          .get()
          .timeout(_timeout);
      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => _normalize(doc.data()))
          .toList();
    } on Exception catch (e) {
      throw RemoteSyncException('Failed to query $collection: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchById(String collection, String id) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(collection).doc(id).get().timeout(_timeout);
      final Map<String, dynamic>? data = snapshot.data();
      return data == null ? null : _normalize(data);
    } on Exception catch (e) {
      throw RemoteSyncException('Failed to load $collection/$id: $e');
    }
  }
}
