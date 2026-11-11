import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/utils/error_text.dart';
import 'package:mq_sports_erp/core/utils/formatters.dart';
import 'package:mq_sports_erp/models/activity_log_model.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/user_role.dart';
import 'package:mq_sports_erp/providers/activity_log_providers.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';

String _time(ActivityLogModel log) {
  final DateTime t = log.createdAt.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${formatDate(t)} ${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
}

Color _levelColor(BuildContext context, LogLevel level) {
  switch (level) {
    case LogLevel.info:
      return Theme.of(context).colorScheme.primary;
    case LogLevel.warning:
      return Colors.orange.shade800;
    case LogLevel.error:
      return Theme.of(context).colorScheme.error;
  }
}

IconData _levelIcon(LogLevel level) {
  switch (level) {
    case LogLevel.info:
      return Icons.info_outline;
    case LogLevel.warning:
      return Icons.warning_amber_rounded;
    case LogLevel.error:
      return Icons.error_outline;
  }
}

/// Activity log viewer for admins: what every user did, what failed, and what
/// sync did. Shows this device's logs, plus the latest logs of all devices
/// after "Load from cloud".
class ActivityLogsScreen extends ConsumerStatefulWidget {
  const ActivityLogsScreen({super.key});

  @override
  ConsumerState<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends ConsumerState<ActivityLogsScreen> {
  String _query = '';
  LogLevel? _level;
  LogKind? _kind;
  String? _module;
  String? _user;
  DateTimeRange? _range;

  bool get _hasFilters =>
      _query.isNotEmpty ||
      _level != null ||
      _kind != null ||
      _module != null ||
      _user != null ||
      _range != null;

  void _clearFilters() {
    setState(() {
      _query = '';
      _level = null;
      _kind = null;
      _module = null;
      _user = null;
      _range = null;
    });
  }

  Future<void> _pickRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _range,
    );
    if (picked != null && mounted) {
      setState(() => _range = picked);
    }
  }

  bool _matches(ActivityLogModel log) {
    if (_level != null && log.level != _level) {
      return false;
    }
    if (_kind != null && log.kind != _kind) {
      return false;
    }
    if (_module != null && log.module != _module) {
      return false;
    }
    if (_user != null && log.userName != _user) {
      return false;
    }
    final DateTimeRange? range = _range;
    if (range != null) {
      final DateTime day = log.createdAt.toLocal();
      final DateTime start = DateTime(range.start.year, range.start.month, range.start.day);
      final DateTime end =
          DateTime(range.end.year, range.end.month, range.end.day).add(const Duration(days: 1));
      if (day.isBefore(start) || !day.isBefore(end)) {
        return false;
      }
    }
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return true;
    }
    return <String>[
      log.summary,
      log.entityLabel,
      log.module,
      log.action,
      log.userName,
      ...log.changes.map((LogFieldChange c) => '${c.field} ${c.from ?? ''} ${c.to ?? ''}'),
    ].join(' ').toLowerCase().contains(q);
  }

  void _showDetails(BuildContext context, ActivityLogModel log) {
    final ThemeData theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              Icon(_levelIcon(log.level), color: _levelColor(context, log.level)),
              const SizedBox(width: 8),
              Expanded(child: Text(log.action)),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(log.summary, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 12),
                  _detail('Time', _time(log)),
                  _detail('User', <String>[
                    if (log.userName.isNotEmpty) log.userName,
                    if (log.userRole.isNotEmpty) '(${log.userRole})',
                  ].join(' ')),
                  _detail('Level / type', '${log.level.label} · ${log.kind.label}'),
                  _detail('Module', log.module),
                  _detail('Record', log.entityLabel),
                  _detail('Record id', log.entityId),
                  _detail('Group', log.groupId),
                  _detail('Log id', log.id),
                  if (log.changes.isNotEmpty) ...<Widget>[
                    const Divider(height: 24),
                    Text('Changes', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    for (final LogFieldChange change in log.changes)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: SelectableText.rich(TextSpan(children: <InlineSpan>[
                          TextSpan(
                            text: '${change.field}: ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: change.from ?? '(none)'),
                          const TextSpan(text: '  →  '),
                          TextSpan(text: change.to ?? '(removed)'),
                        ])),
                      ),
                  ],
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _asText(log)));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Log copied.')),
                );
              },
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detail(String label, String value) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 96,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }

  String _asText(ActivityLogModel log) {
    final StringBuffer out = StringBuffer()
      ..writeln('${_time(log)}  [${log.level.label}] ${log.action}')
      ..writeln(log.summary)
      ..writeln('User: ${log.userName} ${log.userRole}')
      ..writeln('Module: ${log.module}  Record: ${log.entityLabel} (${log.entityId})');
    for (final LogFieldChange change in log.changes) {
      out.writeln('  ${change.field}: ${change.from ?? '(none)'} -> ${change.to ?? '(removed)'}');
    }
    return out.toString();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null || !user.isActive || user.role != UserRole.admin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Activity Logs')),
        body: const Center(child: Text('Only admins can view the activity logs.')),
      );
    }

    final AsyncValue<ActivityLogsState> async = ref.watch(activityLogsProvider);
    final ActivityLogsState? data = async.valueOrNull;

    ref.listen<AsyncValue<ActivityLogsState>>(activityLogsProvider,
        (AsyncValue<ActivityLogsState>? previous, AsyncValue<ActivityLogsState> next) {
      final String? message = next.valueOrNull?.message;
      if (message != null && message != previous?.valueOrNull?.message) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    });

    Widget body;
    if (data == null) {
      final Object? error = async.error;
      body = Center(
        child: error != null
            ? Text(errorMessageOf(error))
            : const CircularProgressIndicator(),
      );
    } else {
      final List<String> modules = (data.logs.map((ActivityLogModel l) => l.module).toSet().toList()..sort());
      final List<String> users = (data.logs
          .map((ActivityLogModel l) => l.userName)
          .where((String n) => n.isNotEmpty)
          .toSet()
          .toList()
        ..sort());
      final List<ActivityLogModel> shown = data.logs.where(_matches).toList();
      final int errors = data.logs.where((ActivityLogModel l) => l.level == LogLevel.error).length;

      body = Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search summary, record, user, field…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (String value) => setState(() => _query = value),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All levels'),
                    selected: _level == null,
                    onSelected: (bool _) => setState(() => _level = null),
                  ),
                ),
                for (final LogLevel level in LogLevel.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(level.label),
                      selected: _level == level,
                      onSelected: (bool selected) =>
                          setState(() => _level = selected ? level : null),
                    ),
                  ),
                _dropdown<LogKind>(
                  hint: 'Type',
                  value: _kind,
                  items: LogKind.values,
                  label: (LogKind k) => k.label,
                  onChanged: (LogKind? v) => setState(() => _kind = v),
                ),
                _dropdown<String>(
                  hint: 'Module',
                  value: _module,
                  items: modules,
                  label: (String m) => m,
                  onChanged: (String? v) => setState(() => _module = v),
                ),
                _dropdown<String>(
                  hint: 'User',
                  value: _user,
                  items: users,
                  label: (String u) => u,
                  onChanged: (String? v) => setState(() => _user = v),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.date_range, size: 18),
                    label: Text(_range == null
                        ? 'Date'
                        : '${formatDate(_range!.start)} – ${formatDate(_range!.end)}'),
                    onPressed: _pickRange,
                  ),
                ),
                if (_hasFilters)
                  TextButton(onPressed: _clearFilters, child: const Text('Clear')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${shown.length} of ${data.logs.length} log(s)'
                    '${errors > 0 ? ' · $errors error(s)' : ''}'
                    '${data.pendingCount > 0 ? ' · ${data.pendingCount} not uploaded yet' : ''}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: shown.isEmpty
                ? Center(
                    child: Text(data.logs.isEmpty
                        ? 'No logs on this device yet.'
                        : 'No logs match the filters.'),
                  )
                : ListView.separated(
                    itemCount: shown.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final ActivityLogModel log = shown[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(_levelIcon(log.level),
                            color: _levelColor(context, log.level)),
                        title: Text(log.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text(<String>[
                          _time(log),
                          if (log.userName.isNotEmpty) log.userName,
                          log.module,
                          if (log.changes.isNotEmpty) '${log.changes.length} change(s)',
                        ].join(' · ')),
                        onTap: () => _showDetails(context, log),
                      );
                    },
                  ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Logs'),
        actions: <Widget>[
          if (data?.isLoadingCloud ?? false)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton.icon(
              onPressed: data == null
                  ? null
                  : () => ref.read(activityLogsProvider.notifier).loadFromCloud(),
              icon: const Icon(Icons.cloud_download_outlined),
              label: Text(data?.cloudLoaded ?? false ? 'Refresh cloud' : 'Load from cloud'),
            ),
        ],
      ),
      body: body,
    );
  }

  Widget _dropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required String Function(T) label,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      // Index values: a menu item whose value is null counts as "dismissed"
      // and would never reach onSelected, so "All" is -1.
      child: PopupMenuButton<int>(
        tooltip: hint,
        onSelected: (int index) => onChanged(index < 0 ? null : items[index]),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
          PopupMenuItem<int>(value: -1, child: Text('All ${hint.toLowerCase()}s')),
          for (int i = 0; i < items.length; i++)
            PopupMenuItem<int>(value: i, child: Text(label(items[i]))),
        ],
        child: Chip(
          avatar: const Icon(Icons.arrow_drop_down, size: 18),
          label: Text(value == null ? hint : label(value)),
          backgroundColor: value == null ? null : Theme.of(context).colorScheme.secondaryContainer,
        ),
      ),
    );
  }
}
