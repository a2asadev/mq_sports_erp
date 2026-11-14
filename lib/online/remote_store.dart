import 'dart:async';

import 'package:mq_sports_erp/online/api_client.dart';

/// The online app's copy of the data, held in memory.
///
/// It is filled from the sync endpoint: the first call downloads everything,
/// every later call only what changed since. Nothing is written to disk, so
/// closing the page drops it and the next visit downloads again (online-only).
///
/// Writes never touch this copy directly. They go to the server, then
/// [refresh] brings the server's version back, so what the screens show is
/// always what the server saved.
class RemoteStore {
  RemoteStore(this._api, {this.pageSize = 1000});

  final ApiClient _api;
  final int pageSize;

  final Map<String, Map<String, JsonMap>> _data = <String, Map<String, JsonMap>>{};
  String _cursor = '0';
  bool _loaded = false;
  Future<void>? _loading;
  Future<void>? _refreshing;
  bool _refreshAgain = false;
  Timer? _poller;

  /// Called after records were added, changed or removed.
  void Function()? onChanged;

  bool get isLoaded => _loaded;

  /// Downloads everything the first time; later calls return at once.
  Future<void> ensureLoaded() {
    if (_loaded) {
      return Future<void>.value();
    }
    return _loading ??= refresh().whenComplete(() => _loading = null);
  }

  /// Fetches what changed on the server since the last call. A call made while
  /// one is running is not lost: another round runs right after it, so a write
  /// that finished a moment ago is always included.
  Future<void> refresh() {
    final Future<void>? running = _refreshing;
    if (running != null) {
      _refreshAgain = true;
      return running;
    }
    return _refreshing = _runRefresh().whenComplete(() => _refreshing = null);
  }

  Future<void> _runRefresh() async {
    bool changed = false;
    do {
      _refreshAgain = false;
      bool more = true;
      while (more) {
        final ApiResponse response = await _api.get(
          '/v1/sync/changes',
          query: <String, String>{'since': _cursor, 'limit': '$pageSize'},
        );
        final JsonMap page = response.asMap;
        changed = _apply(page) || changed;
        _cursor = '${page['cursor'] ?? _cursor}';
        more = page['hasMore'] == true;
      }
      _loaded = true;
    } while (_refreshAgain);
    if (changed) {
      onChanged?.call();
    }
  }

  /// Merges one page into the copy. Returns true when anything changed.
  bool _apply(JsonMap page) {
    bool changed = false;
    final Object? changes = page['changes'];
    if (changes is Map<String, dynamic>) {
      for (final MapEntry<String, dynamic> entry in changes.entries) {
        final Object? list = entry.value;
        if (list is! List<Object?>) {
          continue;
        }
        final Map<String, JsonMap> collection =
            _data.putIfAbsent(entry.key, () => <String, JsonMap>{});
        for (final Object? item in list) {
          if (item is Map<String, dynamic> && item['id'] is String) {
            collection[item['id'] as String] = normalizeDates(item);
            changed = true;
          }
        }
      }
    }
    final Object? deleted = page['deleted'];
    if (deleted is Map<String, dynamic>) {
      for (final MapEntry<String, dynamic> entry in deleted.entries) {
        final Object? ids = entry.value;
        if (ids is! List<Object?>) {
          continue;
        }
        final Map<String, JsonMap>? collection = _data[entry.key];
        for (final Object? id in ids) {
          if (id is String && collection != null && collection.remove(id) != null) {
            changed = true;
          }
        }
      }
    }
    return changed;
  }

  /// Every record of a collection, in the order the server sent them.
  List<JsonMap> list(String collection) =>
      List<JsonMap>.of(_data[collection]?.values ?? const Iterable<JsonMap>.empty());

  JsonMap? byId(String collection, String id) => _data[collection]?[id];

  /// Asks the server for other people's changes now and then.
  void startPolling(Duration every) {
    _poller?.cancel();
    _poller = Timer.periodic(every, (Timer _) {
      if (_loaded) {
        unawaited(refresh().catchError((Object _) {}));
      }
    });
  }

  /// Forgets everything (sign-out) and stops polling.
  void reset() {
    _poller?.cancel();
    _poller = null;
    _data.clear();
    _cursor = '0';
    _loaded = false;
    _loading = null;
  }
}

final RegExp _utcTimestamp =
    RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z$');

/// The server sends times in UTC ("...Z"). The screens format `DateTime`s
/// without converting them, as they were always local, so every timestamp is
/// turned into local time here.
JsonMap normalizeDates(JsonMap map) {
  return map.map((String key, dynamic value) =>
      MapEntry<String, dynamic>(key, _normalizeValue(value)));
}

Object? _normalizeValue(Object? value) {
  if (value is String && _utcTimestamp.hasMatch(value)) {
    return DateTime.parse(value).toLocal().toIso8601String();
  }
  if (value is Map<String, dynamic>) {
    return normalizeDates(value);
  }
  if (value is List<Object?>) {
    return value.map<Object?>(_normalizeValue).toList();
  }
  return value;
}
