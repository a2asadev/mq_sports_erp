import 'package:hive/hive.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';

/// Remembers, per collection, which cloud version this device last
/// downloaded or uploaded. -1 means "never synced".
class SyncStateStore {
  static const String _boxName = 'sync_state';
  static const String _prefix = 'version:';

  Box<String>? _box;

  Future<Box<String>> _open() async {
    final Box<String>? existing = _box;
    if (existing != null && existing.isOpen) {
      return existing;
    }
    final Box<String> opened = await Hive.openBox<String>(_boxName);
    _box = opened;
    return opened;
  }

  Future<Map<String, int>> all() async {
    try {
      final Box<String> box = await _open();
      final Map<String, int> result = <String, int>{};
      for (final dynamic rawKey in box.keys) {
        final String key = rawKey as String;
        if (!key.startsWith(_prefix)) {
          continue;
        }
        final int? value = int.tryParse(box.get(key) ?? '');
        if (value != null) {
          result[key.substring(_prefix.length)] = value;
        }
      }
      return result;
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to read sync state: ${e.message}');
    }
  }

  Future<void> setVersion(String collection, int version) async {
    try {
      final Box<String> box = await _open();
      await box.put('$_prefix$collection', version.toString());
    } on HiveError catch (e) {
      throw LocalStorageException('Failed to save sync state: ${e.message}');
    }
  }
}
