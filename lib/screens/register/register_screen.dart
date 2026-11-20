import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/models/payment_method.dart';
import 'package:a2_stocks/models/register_day.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/providers/register_providers.dart';
import 'package:a2_stocks/providers/users_providers.dart';

/// "YYYY-MM-DD" -> a date at local midnight (only the calendar day matters).
DateTime _dayOf(String date) {
  final List<String> parts = date.split('-');
  if (parts.length != 3) {
    return DateTime.now();
  }
  return DateTime(int.tryParse(parts[0]) ?? 1970, int.tryParse(parts[1]) ?? 1, int.tryParse(parts[2]) ?? 1);
}

String _dateKey(DateTime day) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${day.year}-${two(day.month)}-${two(day.day)}';
}

/// The cash register: the cash that should be in the drawer today, counted at the
/// end of the day against what is really there. Only listed for a business that
/// keeps a register (Settings > Shop details), and it needs a connection.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  /// The day being looked at; null = today (follows the business's own clock).
  String? _date;

  Future<void> _pickDay(String current) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dayOf(current),
      firstDate: DateTime(now.year - 3),
      lastDate: now.add(const Duration(days: 1)),
    );
    if (picked != null && mounted) {
      setState(() => _date = _dateKey(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RegisterDay> day = ref.watch(registerDayProvider(_date));
    final UserRole? role = ref.watch(currentUserProvider).valueOrNull?.role;
    final bool seesHistory = role == UserRole.admin || role == UserRole.manager;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.moduleCashRegister),
        actions: <Widget>[
          if (day.valueOrNull != null)
            TextButton.icon(
              onPressed: () => _pickDay(day.requireValue.date),
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(formatShortDate(context, _dayOf(day.requireValue.date))),
            ),
          IconButton(
            tooltip: context.l10n.registerRefresh,
            onPressed: () {
              ref.invalidate(registerDayProvider(_date));
              ref.invalidate(registerClosingsProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: day.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(errorMessageOf(error), textAlign: TextAlign.center),
          ),
        ),
        data: (RegisterDay data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // A new key per day and closing, so the form starts fresh when either changes.
                  _DayCard(key: ValueKey<String>('${data.date}/${data.closing?.id}'), day: data, onClosed: () {
                    ref.invalidate(registerDayProvider(_date));
                    ref.invalidate(registerClosingsProvider);
                  }),
                  if (seesHistory) ...<Widget>[
                    const SizedBox(height: 16),
                    _History(onOpen: (String date) => setState(() => _date = date)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayCard extends ConsumerStatefulWidget {
  const _DayCard({super.key, required this.day, required this.onClosed});

  final RegisterDay day;
  final VoidCallback onClosed;

  @override
  ConsumerState<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends ConsumerState<_DayCard> {
  late final TextEditingController _counted = TextEditingController();
  late final TextEditingController _opening = TextEditingController(text: _text(widget.day.closing?.openingCash ?? widget.day.openingCash));
  late final TextEditingController _note = TextEditingController();
  bool _busy = false;
  bool _counting = false;

  static String _text(double value) => value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(2);

  @override
  void initState() {
    super.initState();
    _counted.addListener(_changed);
    _opening.addListener(_changed);
  }

  @override
  void dispose() {
    _counted.dispose();
    _opening.dispose();
    _note.dispose();
    super.dispose();
  }

  void _changed() => setState(() {});

  double? get _countedValue => double.tryParse(_counted.text.trim());
  double get _openingValue => double.tryParse(_opening.text.trim()) ?? widget.day.openingCash;

  /// What should be there with the opening cash as typed.
  double get _expected => _openingValue + widget.day.cashReceived - widget.day.cashPaid - widget.day.cashRefunded;

  Future<void> _close() async {
    final double? counted = _countedValue;
    if (counted == null || counted < 0) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(registerServiceProvider).close(
            date: widget.day.date,
            countedCash: counted,
            openingCash: (_openingValue - widget.day.openingCash).abs() > 0.004 ? _openingValue : null,
            note: _note.text,
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.registerDayClosed)));
      widget.onClosed();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final RegisterDay day = widget.day;
    final RegisterClosing? closing = day.closing;
    final ThemeData theme = Theme.of(context);
    final int unsent = ref.watch(registerUnsentProvider);
    final bool editing = closing == null || _counting;
    final double? counted = _countedValue;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    day.isToday ? context.l10n.registerToday : formatLongDate(context, _dayOf(day.date)),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                _Chip(
                  text: closing != null ? context.l10n.registerClosed : context.l10n.registerOpen,
                  color: closing != null ? AppColors.teal : AppColors.amber,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(context.l10n.registerShouldHave, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(
              formatMoney(editing ? _expected : closing.expectedCash),
              style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            _Line(label: context.l10n.registerOpening, value: formatMoney(editing ? _openingValue : closing.openingCash)),
            _Line(label: context.l10n.registerFromCustomers, value: '+ ${formatMoney(day.cashReceived)}', color: AppColors.teal),
            _Line(label: context.l10n.registerToVendors, value: '- ${formatMoney(day.cashPaid)}', color: AppColors.danger),
            if (day.cashRefunded > 0)
              _Line(label: context.l10n.registerRefunded, value: '- ${formatMoney(day.cashRefunded)}', color: AppColors.danger),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              context.l10n.registerSalesLine(day.salesCount, formatMoney(day.salesTotal)),
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
            if (day.otherReceived > 0) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                '${context.l10n.registerNotCash}: ${<String>[
                  if (day.bankReceived > 0) '${PaymentMethod.bank.label} ${formatMoney(day.bankReceived)}',
                  if (day.easypaisaReceived > 0) '${PaymentMethod.easypaisa.label} ${formatMoney(day.easypaisaReceived)}',
                  if (day.jazzcashReceived > 0) '${PaymentMethod.jazzcash.label} ${formatMoney(day.jazzcashReceived)}',
                ].join(' · ')}',
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ),
            ],
            const SizedBox(height: 16),
            if (closing != null && !_counting) ...<Widget>[
              _Outcome(difference: closing.difference, counted: closing.countedCash),
              const SizedBox(height: 8),
              Text(
                context.l10n.registerClosedBy(closing.closedByName, formatDate(closing.closedAt)),
                style: theme.textTheme.bodySmall,
              ),
              if (closing.note.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Text(closing.note, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _counting = true),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(context.l10n.registerCountAgain),
                ),
              ),
            ] else ...<Widget>[
              if (unsent > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.amberSoft, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(Icons.cloud_upload_outlined, size: 20, color: AppColors.amber),
                      const SizedBox(width: 8),
                      Expanded(child: Text(context.l10n.registerUnsent(unsent))),
                    ],
                  ),
                ),
              TextField(
                controller: _opening,
                enabled: !_busy,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                decoration: InputDecoration(
                  labelText: context.l10n.registerOpening,
                  helperText: context.l10n.registerOpeningHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _counted,
                enabled: !_busy,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                decoration: InputDecoration(
                  labelText: context.l10n.registerCounted,
                  helperText: context.l10n.registerCountedHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (counted != null) ...<Widget>[
                const SizedBox(height: 12),
                _Outcome(difference: counted - _expected, counted: counted),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _note,
                enabled: !_busy,
                maxLength: 500,
                decoration: InputDecoration(labelText: context.l10n.registerNote, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  if (closing != null)
                    TextButton(
                      onPressed: _busy ? null : () => setState(() => _counting = false),
                      child: Text(context.l10n.registerCancel),
                    ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _busy || counted == null || unsent > 0 ? null : _close,
                    icon: _busy
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.lock_outline),
                    label: Text(context.l10n.registerCloseDay),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Rs 1,000 counted: the cash matches / Rs 20 short / Rs 30 over".
class _Outcome extends StatelessWidget {
  const _Outcome({required this.difference, required this.counted});

  final double difference;
  final double counted;

  @override
  Widget build(BuildContext context) {
    final bool balanced = difference.abs() < 0.005;
    final Color color = balanced ? AppColors.teal : AppColors.danger;
    final String text = balanced
        ? context.l10n.registerBalanced
        : (difference < 0
            ? context.l10n.registerShort(formatMoney(-difference))
            : context.l10n.registerOver(formatMoney(difference)));
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: balanced ? AppColors.tealSoft : AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(balanced ? Icons.check_circle_outline : Icons.error_outline, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(context.l10n.registerCountedAmount(formatMoney(counted)), style: Theme.of(context).textTheme.bodySmall),
                Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

/// The days that were closed before, newest first; tapping one opens it.
class _History extends ConsumerWidget {
  const _History({required this.onOpen});

  final void Function(String date) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<RegisterClosing>> closings = ref.watch(registerClosingsProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(context.l10n.registerHistory, style: Theme.of(context).textTheme.titleMedium),
            ),
            ...closings.when(
              loading: () => <Widget>[const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))],
              error: (Object error, StackTrace stack) =>
                  <Widget>[Padding(padding: const EdgeInsets.all(16), child: Text(errorMessageOf(error)))],
              data: (List<RegisterClosing> items) => items.isEmpty
                  ? <Widget>[Padding(padding: const EdgeInsets.all(16), child: Text(context.l10n.registerHistoryEmpty))]
                  : <Widget>[
                      for (final RegisterClosing c in items)
                        ListTile(
                          dense: true,
                          onTap: () => onOpen(c.date),
                          title: Text(formatShortDate(context, _dayOf(c.date))),
                          subtitle: Text(c.closedByName),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(formatMoney(c.countedCash), style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(
                                c.balanced
                                    ? context.l10n.registerBalancedShort
                                    : (c.difference < 0
                                        ? context.l10n.registerShort(formatMoney(-c.difference))
                                        : context.l10n.registerOver(formatMoney(c.difference))),
                                style: TextStyle(fontSize: 12, color: c.balanced ? AppColors.teal : AppColors.danger),
                              ),
                            ],
                          ),
                        ),
                    ],
            ),
          ],
        ),
      ),
    );
  }
}
