import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/activity_log_model.dart';

/// Local, append-only storage of activity logs. It deliberately has no pending
/// change records: logging must never create more things to log. Entries not
/// uploaded yet are tracked by id in a second box.
class ActivityLogStore {
  static const String _pendingBoxName = 'activity_log_pending';

  Box<String>? _box;
  Box<String>? _pendingBox;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Fires after a log was added or the list was cleaned up.
  Stream<void> get changes => _changes.stream;

  Future<Box<String>> _open() async {
    final Box<String>? existing = _box;
    if (existing != null && existing.isOpen) {
      return existing;
    }
    final Box<String> opened = await Hive.openBox<String>(StorageKeys.activityLogs);
    _box = opened;
    return opened;
  }

  Future<Box<String>> _openPending() async {
    final Box<String>? existing = _pendingBox;
    if (existing != null && existing.isOpen) {
      return existing;
    }
    final Box<String> opened = await Hive.openBox<String>(_pendingBoxName);
    _pendingBox = opened;
    return opened;
  }

  ActivityLogModel? _decode(String raw) {
    try {
      final Object? decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic>
          ? ActivityLogModel.fromMap(decoded)
          : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> add(ActivityLogModel log) async {
    try {
      final Box<String> box = await _open();
      final Box<String> pending = await _openPending();
      await box.put(log.id, jsonEncode(log.toMap()));
      await pending.put(log.id, '');
      _changes.add(null);
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to save a log: ${e.message}');
    }
  }

  /// Every log on this device, newest first. Unreadable entries are skipped.
  Future<List<ActivityLogModel>> getAll() async {
    try {
      final Box<String> box = await _open();
      final List<ActivityLogModel> logs = <ActivityLogModel>[
        for (final String raw in box.values)
          if (_decode(raw) case final ActivityLogModel log) log,
      ]..sort((ActivityLogModel a, ActivityLogModel b) =>
          b.createdAt.compareTo(a.createdAt));
      return logs;
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to read logs: ${e.message}');
    }
  }

  /// Logs that still have to be uploaded, oldest first.
  Future<List<ActivityLogModel>> getPending() async {
    try {
      final Box<String> box = await _open();
      final Box<String> pending = await _openPending();
      final List<ActivityLogModel> logs = <ActivityLogModel>[];
      final List<String> stale = <String>[];
      for (final dynamic key in pending.keys) {
        final String id = key as String;
        final String? raw = box.get(id);
        final ActivityLogModel? log = raw == null ? null : _decode(raw);
        if (log == null) {
          stale.add(id);
        } else {
          logs.add(log);
        }
      }
      if (stale.isNotEmpty) {
        await pending.deleteAll(stale);
      }
      logs.sort((ActivityLogModel a, ActivityLogModel b) =>
          a.createdAt.compareTo(b.createdAt));
      return logs;
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to read logs: ${e.message}');
    }
  }

  Future<int> pendingCount() async {
    try {
      return (await _openPending()).length;
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to read logs: ${e.message}');
    }
  }

  Future<void> markUploaded(Iterable<String> ids) async {
    try {
      final Box<String> pending = await _openPending();
      await pending.deleteAll(ids.toList());
      _changes.add(null);
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to update logs: ${e.message}');
    }
  }

  /// Removes logs older than [maxAge] that are already uploaded. Logs that
  /// are not uploaded yet are always kept.
  Future<int> purgeUploadedOlderThan(Duration maxAge) async {
    try {
      final Box<String> box = await _open();
      final Box<String> pending = await _openPending();
      final DateTime cutoff = DateTime.now().subtract(maxAge);
      final List<String> remove = <String>[];
      for (final MapEntry<dynamic, String> entry in box.toMap().entries) {
        final String id = entry.key as String;
        if (pending.containsKey(id)) {
          continue;
        }
        final ActivityLogModel? log = _decode(entry.value);
        if (log == null || log.createdAt.isBefore(cutoff)) {
          remove.add(id);
        }
      }
      if (remove.isNotEmpty) {
        await box.deleteAll(remove);
        _changes.add(null);
      }
      return remove.length;
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to clean up logs: ${e.message}');
    }
  }

  Future<void> dispose() async {
    await _changes.close();
  }
}
