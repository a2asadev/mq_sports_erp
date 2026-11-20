import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/models/activity_log_model.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/providers/activity_log_providers.dart';
import 'package:a2_stocks/providers/users_providers.dart';

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

/// A short reference for a log entry (first 8 characters of its unique id),
/// easy to read out or search for; the full id is in the details.
String _shortId(ActivityLogModel log) => '#${log.id.length > 8 ? log.id.substring(0, 8) : log.id}';

Color _kindColor(LogKind kind) {
  switch (kind) {
    case LogKind.record:
      return AppColors.sky;
    case LogKind.action:
      return AppColors.teal;
    case LogKind.failure:
      return AppColors.danger;
    case LogKind.sync:
      return AppColors.violet;
    case LogKind.session:
      return AppColors.amber;
  }
}

/// A small coloured label, optionally tappable to filter by it.
class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color, this.onTap});

  final String text;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ),
    );
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

  /// Shows only the entries written by one action (an order and its stock and
  /// ledger entries), found through their shared group id.
  String? _group;

  bool get _hasFilters =>
      _group != null ||
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
      _group = null;
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
    if (_group != null && log.groupId != _group) {
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
      log.id,
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
                  _detail(context.l10n.activityLogsTime, _time(log)),
                  _detail(context.l10n.activityLogsUser, <String>[
                    if (log.userName.isNotEmpty) log.userName,
                    if (log.userRole.isNotEmpty) '(${log.userRole})',
                  ].join(' ')),
                  _detail(context.l10n.activityLogsLevelType, '${log.level.label} · ${log.kind.label}'),
                  _detail(context.l10n.activityLogsModule, log.module),
                  _detail(context.l10n.activityLogsRecord, log.entityLabel),
                  _detail(context.l10n.activityLogsRecordId, log.entityId),
                  _detail(context.l10n.activityLogsGroup, log.groupId),
                  _detail(context.l10n.activityLogsLogId, '${_shortId(log)}  ·  ${log.id}'),
                  if (log.changes.isNotEmpty) ...<Widget>[
                    const Divider(height: 24),
                    Text(context.l10n.activityLogsChanges, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    for (final LogFieldChange change in log.changes)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: SelectableText.rich(TextSpan(children: <InlineSpan>[
                          TextSpan(
                            text: '${change.field}: ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: change.from ?? context.l10n.activityLogsNone),
                          const TextSpan(text: '  →  '),
                          TextSpan(text: change.to ?? context.l10n.activityLogsRemoved),
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
                  SnackBar(content: Text(context.l10n.activityLogsLogCopied)),
                );
              },
              icon: const Icon(Icons.copy_outlined),
              label: Text(context.l10n.activityLogsCopy),
            ),
            if (log.groupId.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  setState(() => _group = log.groupId);
                },
                icon: const Icon(Icons.account_tree_outlined),
                label: Text(context.l10n.activityLogsShowLinked),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.starterPackClose),
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
      ..writeln(context.l10n.activityLogsUser2(log.userName, log.userRole))
      ..writeln(context.l10n.activityLogsModuleRecord(log.module, log.entityLabel, log.entityId));
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
        appBar: AppBar(title: Text(context.l10n.activityLogsActivityLogs)),
        body: Center(child: Text(context.l10n.activityLogsOnlyAdminsCanView)),
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
              decoration: InputDecoration(
                hintText: context.l10n.activityLogsSearchSummaryRecordUser,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
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
                    label: Text(context.l10n.activityLogsAllLevels),
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
                  hint: context.l10n.activityLogsType,
                  value: _kind,
                  items: LogKind.values,
                  label: (LogKind k) => k.label,
                  onChanged: (LogKind? v) => setState(() => _kind = v),
                ),
                _dropdown<String>(
                  hint: context.l10n.activityLogsModule,
                  value: _module,
                  items: modules,
                  label: (String m) => m,
                  onChanged: (String? v) => setState(() => _module = v),
                ),
                _dropdown<String>(
                  hint: context.l10n.activityLogsUser,
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
                        ? context.l10n.ledgerEntryDate
                        : '${formatDate(_range!.start)} – ${formatDate(_range!.end)}'),
                    onPressed: _pickRange,
                  ),
                ),
                if (_group != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InputChip(
                      avatar: const Icon(Icons.account_tree_outlined, size: 18),
                      label: Text(context.l10n.activityLogsLinkedEntries),
                      onDeleted: () => setState(() => _group = null),
                    ),
                  ),
                if (_hasFilters)
                  TextButton(onPressed: _clearFilters, child: Text(context.l10n.activityLogsClear)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${context.l10n.activityLogsCount(shown.length, data.logs.length)}'
                    '${errors > 0 ? context.l10n.activityLogsErrors(errors) : ''}'
                    '${data.pendingCount > 0 ? context.l10n.activityLogsNotUploaded(data.pendingCount) : ''}',
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
                        ? context.l10n.activityLogsNoLogsOnThis
                        : context.l10n.activityLogsNoLogsMatchThe),
                  )
                : _logList(shown, data.logs),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.activityLogsActivityLogs),
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
              label: Text(data?.cloudLoaded ?? false ? context.l10n.activityLogsRefreshCloud : context.l10n.activityLogsLoadFromCloud),
            ),
        ],
      ),
      body: body,
    );
  }

  /// The list, with a heading for each day and tags on every entry. Tapping
  /// the type or module tag filters by it.
  Widget _logList(List<ActivityLogModel> shown, List<ActivityLogModel> all) {
    final List<Object> rows = <Object>[];
    String? lastDay;
    for (final ActivityLogModel log in shown) {
      final String day = formatDate(log.createdAt);
      if (day != lastDay) {
        rows.add(day);
        lastDay = day;
      }
      rows.add(log);
    }
    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (BuildContext context, int index) {
        final Object row = rows[index];
        if (row is String) {
          return Container(
            color: AppColors.mutedFill,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(row, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          );
        }
        final ActivityLogModel log = row as ActivityLogModel;
        final int related = log.groupId.isEmpty ? 0 : all.where((ActivityLogModel l) => l.groupId == log.groupId).length;
        final Color levelColor = _levelColor(context, log.level);
        return InkWell(
          onTap: () => _showDetails(context, log),
          child: Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(_levelIcon(log.level), color: levelColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(log.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          _Tag(
                            text: log.kind.label,
                            color: _kindColor(log.kind),
                            onTap: () => setState(() => _kind = log.kind),
                          ),
                          _Tag(
                            text: log.module,
                            color: AppColors.navy,
                            onTap: () => setState(() => _module = log.module),
                          ),
                          if (log.entityLabel.isNotEmpty) _Tag(text: log.entityLabel, color: AppColors.textMuted),
                          if (related > 1)
                            _Tag(
                              text: context.l10n.activityLogsLinked(related),
                              color: AppColors.violet,
                              onTap: () => setState(() => _group = log.groupId),
                            ),
                          Text(
                            <String>[
                              _time(log),
                              if (log.userName.isNotEmpty) log.userName,
                              if (log.changes.isNotEmpty) context.l10n.activityLogsChangeS(log.changes.length),
                            ].join(' · '),
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _shortId(log),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        );
      },
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
          PopupMenuItem<int>(value: -1, child: Text(context.l10n.activityLogsAllS(hint.toLowerCase()))),
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
