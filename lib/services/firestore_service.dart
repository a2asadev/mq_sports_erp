import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/remote_collection_meta.dart';

/// One write inside an atomic group commit. [data] null means delete.
class GroupWrite {
  const GroupWrite({required this.collection, required this.id, this.data});

  final String collection;
  final String id;
  final Map<String, dynamic>? data;
}

/// Thin Cloud Firestore gateway. It only exchanges plain maps and plain
/// values, so Firebase types never leak into models, repositories or
/// providers. Nothing here runs on its own: every call is triggered by login
/// or by the user pressing sync.
class FirestoreService {
  FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  static const String metadataCollection = 'metadata';
  static const Duration _timeout = Duration(seconds: 15);

  /// Converts Firestore-specific values to plain Dart values: a `Timestamp`
  /// becomes an ISO 8601 string, as the models expect.
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

  /// Live per-collection version info. This is the only listener in the app.
  /// Each change of a metadata document costs one read.
  Stream<Map<String, RemoteCollectionMeta>> watchMetadata() {
    return _firestore
        .collection(metadataCollection)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return <String, RemoteCollectionMeta>{
        for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
            in snapshot.docs)
          doc.id: RemoteCollectionMeta(
            version: (doc.data()['version'] as num?)?.toInt() ?? 0,
            updatedAt: (doc.data()['updated_at'] as Timestamp?)?.toDate(),
          ),
      };
    });
  }

  /// Downloads a whole collection (one read per document).
  Future<List<Map<String, dynamic>>> fetchAll(String collection) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(collection).get().timeout(_timeout);
      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              _normalize(doc.data()))
          .toList();
    } on Exception catch (e) {
      throw RemoteSyncException('Failed to download $collection: $e');
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

  static const String logsCollection = 'activity_logs';

  /// Uploads activity logs in one batch. Logs are append-only and sit outside
  /// the version system: this neither checks nor raises any metadata version,
  /// so uploading logs never makes other devices out of date. Writing a log
  /// that already exists with identical content is allowed by the rules, so a
  /// retry after an interrupted upload is safe.
  Future<void> uploadLogs(List<Map<String, dynamic>> logs) async {
    if (logs.isEmpty) {
      return;
    }
    try {
      final WriteBatch batch = _firestore.batch();
      for (final Map<String, dynamic> log in logs) {
        batch.set(_firestore.collection(logsCollection).doc(log['id'] as String), log);
      }
      await batch.commit().timeout(_timeout);
    } on Exception catch (e) {
      throw RemoteSyncException('Failed to upload logs: $e');
    }
  }

  /// The newest [limit] activity logs of all devices (one read per log).
  Future<List<Map<String, dynamic>>> fetchRecentLogs(int limit) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(logsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get()
          .timeout(_timeout);
      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              _normalize(doc.data()))
          .toList();
    } on Exception catch (e) {
      throw RemoteSyncException('Failed to load logs from the cloud: $e');
    }
  }

  /// Uploads changes to one collection in a single transaction and raises the
  /// collection's metadata version by one. Fails with
  /// [VersionConflictException] (writing nothing) if the cloud version is not
  /// [expectedVersion], meaning another device uploaded in the meantime.
  /// Returns the new version.
  Future<int> commitChanges({
    required String collection,
    required int expectedVersion,
    required List<MapEntry<String, Map<String, dynamic>>> upserts,
    required List<String> deletes,
  }) async {
    final DocumentReference<Map<String, dynamic>> metaRef =
        _firestore.collection(metadataCollection).doc(collection);
    try {
      final (bool, int) result =
          await _firestore.runTransaction<(bool, int)>((Transaction tx) async {
        final DocumentSnapshot<Map<String, dynamic>> metaSnap =
            await tx.get(metaRef);
        final int current = (metaSnap.data()?['version'] as num?)?.toInt() ?? 0;
        if (current != expectedVersion) {
          return (false, current);
        }
        for (final MapEntry<String, Map<String, dynamic>> entry in upserts) {
          tx.set(_firestore.collection(collection).doc(entry.key), entry.value);
        }
        for (final String id in deletes) {
          tx.delete(_firestore.collection(collection).doc(id));
        }
        tx.set(metaRef, <String, dynamic>{
          'version': current + 1,
          'updated_at': FieldValue.serverTimestamp(),
        });
        return (true, current + 1);
      });
      if (!result.$1) {
        throw VersionConflictException(result.$2);
      }
      return result.$2;
    } on VersionConflictException {
      rethrow;
    } on Exception catch (e) {
      throw RemoteSyncException('Failed to upload $collection: $e');
    }
  }

  /// Writes records of several collections in ONE transaction and raises each
  /// involved collection's metadata version by one. Either everything is
  /// written or nothing is. Fails with [GroupVersionConflictException]
  /// (writing nothing) if any collection's cloud version differs from
  /// [expectedVersions]. Returns the new version of each collection.
  Future<Map<String, int>> commitGroup({
    required Map<String, int> expectedVersions,
    required List<GroupWrite> writes,
  }) async {
    final Map<String, DocumentReference<Map<String, dynamic>>> metaRefs =
        <String, DocumentReference<Map<String, dynamic>>>{
      for (final String collection in expectedVersions.keys)
        collection: _firestore.collection(metadataCollection).doc(collection),
    };
    try {
      final (Map<String, int>, bool) result = await _firestore
          .runTransaction<(Map<String, int>, bool)>((Transaction tx) async {
        final Map<String, int> current = <String, int>{};
        for (final MapEntry<String, DocumentReference<Map<String, dynamic>>> entry
            in metaRefs.entries) {
          final DocumentSnapshot<Map<String, dynamic>> snap =
              await tx.get(entry.value);
          current[entry.key] = (snap.data()?['version'] as num?)?.toInt() ?? 0;
        }
        final bool matches = expectedVersions.entries.every(
            (MapEntry<String, int> e) => current[e.key] == e.value);
        if (!matches) {
          return (current, false);
        }
        for (final GroupWrite write in writes) {
          final DocumentReference<Map<String, dynamic>> ref =
              _firestore.collection(write.collection).doc(write.id);
          final Map<String, dynamic>? data = write.data;
          if (data == null) {
            tx.delete(ref);
          } else {
            tx.set(ref, data);
          }
        }
        final Map<String, int> updated = <String, int>{};
        for (final MapEntry<String, DocumentReference<Map<String, dynamic>>> entry
            in metaRefs.entries) {
          final int next = (current[entry.key] ?? 0) + 1;
          tx.set(entry.value, <String, dynamic>{
            'version': next,
            'updated_at': FieldValue.serverTimestamp(),
          });
          updated[entry.key] = next;
        }
        return (updated, true);
      });
      if (!result.$2) {
        throw GroupVersionConflictException(result.$1);
      }
      return result.$1;
    } on GroupVersionConflictException {
      rethrow;
    } on Exception catch (e) {
      throw RemoteSyncException('Failed to upload a grouped change: $e');
    }
  }
}
