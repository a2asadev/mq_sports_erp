import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/syncable_model.dart';

/// Generic O(1) local storage for one entity type, keyed by UUID.
///
/// Records are stored as JSON strings, so no Hive type adapters are needed and
/// nested sub-entities (e.g. variants inside a product) are persisted together
/// with their parent aggregate root.
class HiveLocalRepository<T extends SyncableModel> {
  HiveLocalRepository({required this.boxName, required this.fromMap});

  final String boxName;
  final T Function(Map<String, dynamic> map) fromMap;

  Box<String>? _box;

  Future<Box<String>> _openBox() async {
    final Box<String>? existing = _box;
    if (existing != null && existing.isOpen) {
      return existing;
    }
    final Box<String> opened = await Hive.openBox<String>(boxName);
    _box = opened;
    return opened;
  }

  T _decode(String raw) {
    final Object? decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return fromMap(decoded);
    }
    throw const FormatException('Stored record is not a JSON object.');
  }

  Future<List<T>> getAll() async {
    try {
      final Box<String> box = await _openBox();
      return box.values.map(_decode).toList();
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to read $boxName: ${e.message}');
    } on FormatException catch (e) {
      throw LocalStorageException('Corrupted record in $boxName: ${e.message}');
    }
  }

  Future<T?> getById(String id) async {
    try {
      final Box<String> box = await _openBox();
      final String? raw = box.get(id);
      return raw == null ? null : _decode(raw);
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to read $boxName/$id: ${e.message}');
    } on FormatException catch (e) {
      throw LocalStorageException(
          'Corrupted record $boxName/$id: ${e.message}');
    }
  }

  Future<void> put(T item) async {
    try {
      final Box<String> box = await _openBox();
      await box.put(item.id, jsonEncode(item.toMap()));
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to write $boxName: ${e.message}');
    }
  }

  Future<void> putAll(List<T> items) async {
    if (items.isEmpty) {
      return;
    }
    try {
      final Box<String> box = await _openBox();
      await box.putAll(<String, String>{
        for (final T item in items) item.id: jsonEncode(item.toMap()),
      });
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to write $boxName: ${e.message}');
    }
  }

  Future<void> delete(String id) async {
    try {
      final Box<String> box = await _openBox();
      await box.delete(id);
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to delete $boxName/$id: ${e.message}');
    }
  }

  Future<void> clear() async {
    try {
      final Box<String> box = await _openBox();
      await box.clear();
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to clear $boxName: ${e.message}');
    }
  }
}
