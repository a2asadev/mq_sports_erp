import 'dart:convert';

import 'package:mq_sports_erp/models/activity_log_model.dart';

const int _maxValueLength = 120;

String _clip(String value) {
  return value.length <= _maxValueLength
      ? value
      : '${value.substring(0, _maxValueLength)}…';
}

/// Readable key for an element of a list of records, so a change inside
/// `variants` reads `variants[BAT-5].costPrice` and not `variants[2]`.
String _elementKey(Map<String, dynamic> element) {
  for (final String key in <String>['sku', 'name', 'id']) {
    final Object? value = element[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
  }
  return '?';
}

bool _isRecordList(List<Object?> list) {
  return list.isNotEmpty &&
      list.every((Object? e) => e is Map<String, dynamic> && e['id'] is String);
}

void _flatten(String path, Object? value, Map<String, String> out) {
  if (value is Map<String, dynamic>) {
    for (final MapEntry<String, dynamic> entry in value.entries) {
      _flatten(path.isEmpty ? entry.key : '$path.${entry.key}', entry.value, out);
    }
  } else if (value is List<Object?> && _isRecordList(value)) {
    for (final Object? element in value) {
      final Map<String, dynamic> map = element! as Map<String, dynamic>;
      _flatten('$path[${_elementKey(map)}]', map, out);
    }
  } else if (value is List<Object?>) {
    out[path] = jsonEncode(value);
  } else {
    out[path] = '${value ?? ''}';
  }
}

/// Field-level differences between two `toMap()` results. Lists of records
/// that have an `id` (variants, order items) are compared element by element.
/// `updatedAt` and `createdAt` are ignored. Returns at most [maxChanges]
/// entries.
List<LogFieldChange> diffMaps(
  Map<String, dynamic> before,
  Map<String, dynamic> after, {
  int maxChanges = 40,
}) {
  const Set<String> ignored = <String>{'updatedAt', 'createdAt'};
  final Map<String, String> oldFlat = <String, String>{};
  final Map<String, String> newFlat = <String, String>{};
  _flatten('', Map<String, dynamic>.of(before)..removeWhere((String k, _) => ignored.contains(k)), oldFlat);
  _flatten('', Map<String, dynamic>.of(after)..removeWhere((String k, _) => ignored.contains(k)), newFlat);

  final Set<String> keys = <String>{...oldFlat.keys, ...newFlat.keys};
  final List<LogFieldChange> changes = <LogFieldChange>[];
  for (final String key in keys) {
    final String? oldValue = oldFlat[key];
    final String? newValue = newFlat[key];
    if (oldValue == newValue) {
      continue;
    }
    changes.add(LogFieldChange(
      field: key,
      from: oldValue == null ? null : _clip(oldValue),
      to: newValue == null ? null : _clip(newValue),
    ));
    if (changes.length >= maxChanges) {
      break;
    }
  }
  return changes;
}
