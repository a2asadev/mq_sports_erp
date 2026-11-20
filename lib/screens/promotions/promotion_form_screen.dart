import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/category_model.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/promotion.dart';
import 'package:a2_stocks/online/promotions_service.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';
import 'package:a2_stocks/providers/promotion_providers.dart';

/// A new promotion, or changes to one. Pops `true` once the server has it.
class PromotionFormScreen extends ConsumerStatefulWidget {
  const PromotionFormScreen({super.key, this.promotion});

  final Promotion? promotion;

  @override
  ConsumerState<PromotionFormScreen> createState() => _PromotionFormScreenState();
}

class _PromotionFormScreenState extends ConsumerState<PromotionFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _value;
  late final TextEditingController _minQuantity;
  late final TextEditingController _minAmount;
  late final TextEditingController _code;
  late PromotionKind _kind;
  late PromotionScope _scope;
  late String? _targetId;
  late bool _pos;
  late bool _web;
  late bool _active;
  String? _startsOn;
  String? _endsOn;
  bool _busy = false;

  static String _num(double v) => v == 0 ? '' : (v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString());
  static String _key(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    final Promotion? p = widget.promotion;
    _name = TextEditingController(text: p?.name ?? '');
    _value = TextEditingController(text: p == null ? '' : _num(p.value));
    _minQuantity = TextEditingController(text: p != null && p.minQuantity > 1 ? '${p.minQuantity}' : '');
    _minAmount = TextEditingController(text: p == null ? '' : _num(p.minAmount));
    _code = TextEditingController(text: p?.code ?? '');
    _kind = p?.kind ?? PromotionKind.percent;
    _scope = p?.scope ?? PromotionScope.order;
    _targetId = p?.targetId;
    _pos = p?.channels.contains('pos') ?? true;
    _web = p?.channels.contains('web') ?? true;
    _active = p?.isActive ?? true;
    _startsOn = p?.startsOn;
    _endsOn = p?.endsOn;
  }

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    _minQuantity.dispose();
    _minAmount.dispose();
    _code.dispose();
    super.dispose();
  }

  double? get _valueNumber => double.tryParse(_value.text.trim());
  bool get _needsTarget => _scope != PromotionScope.order;

  /// What is wrong with the form, or null when it can be saved.
  String? _problem(AppLocalizations l10n) {
    if (_name.text.trim().isEmpty) {
      return l10n.promoNeedName;
    }
    final double? v = _valueNumber;
    if (v == null || v <= 0) {
      return l10n.promoNeedValue;
    }
    if (_kind == PromotionKind.percent && v > 100) {
      return l10n.promoPercentMax;
    }
    if (_needsTarget && _targetId == null) {
      return l10n.promoNeedTarget;
    }
    if (!_pos && !_web) {
      return l10n.promoNeedChannel;
    }
    if (_startsOn != null && _endsOn != null && _endsOn!.compareTo(_startsOn!) < 0) {
      return l10n.promoEndBeforeStart;
    }
    return null;
  }

  Future<void> _pickDate({required bool start}) async {
    final DateTime now = DateTime.now();
    final String? current = start ? _startsOn : _endsOn;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(current ?? '') ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null && mounted) {
      setState(() => start ? _startsOn = _key(picked) : _endsOn = _key(picked));
    }
  }

  Future<void> _save() async {
    final String? problem = _problem(context.l10n);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (problem != null) {
      messenger.showSnackBar(SnackBar(content: Text(problem)));
      return;
    }
    final NavigatorState navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      final PromotionDraft draft = PromotionDraft(
        name: _name.text,
        kind: _kind,
        value: _valueNumber!,
        scope: _scope,
        targetId: _needsTarget ? _targetId : null,
        minQuantity: int.tryParse(_minQuantity.text.trim()) ?? 1,
        minAmount: double.tryParse(_minAmount.text.trim()) ?? 0,
        code: _code.text,
        channels: <String>[if (_pos) 'pos', if (_web) 'web'],
        startsOn: _startsOn,
        endsOn: _endsOn,
        isActive: _active,
      );
      final PromotionsService service = ref.read(promotionsServiceProvider);
      if (widget.promotion == null) {
        await service.create(draft);
      } else {
        await service.update(widget.promotion!.id, draft);
      }
      navigator.pop(true);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final List<CategoryModel> categories = ref.watch(categoriesProvider).valueOrNull ?? <CategoryModel>[];
    final List<ProductModel> products = (ref.watch(productsProvider).valueOrNull ?? <ProductModel>[]).where((ProductModel p) => p.isActive).toList();
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.promotion == null ? l10n.promoNew : l10n.promoEdit)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: _name,
            enabled: !_busy,
            maxLength: 80,
            decoration: InputDecoration(labelText: l10n.promoName, border: const OutlineInputBorder()),
          ),
          Text(l10n.promoAppliesTo, style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          SegmentedButton<PromotionScope>(
            showSelectedIcon: false,
            segments: <ButtonSegment<PromotionScope>>[
              ButtonSegment<PromotionScope>(value: PromotionScope.order, label: Text(l10n.promoScopeOrder)),
              ButtonSegment<PromotionScope>(value: PromotionScope.category, label: Text(l10n.promoScopeCategory)),
              ButtonSegment<PromotionScope>(value: PromotionScope.product, label: Text(l10n.promoScopeProduct)),
            ],
            selected: <PromotionScope>{_scope},
            onSelectionChanged: _busy ? null : (Set<PromotionScope> v) => setState(() {
                  _scope = v.first;
                  _targetId = null;
                }),
          ),
          if (_scope == PromotionScope.category) ...<Widget>[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: categories.any((CategoryModel c) => c.id == _targetId) ? _targetId : null,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.promoPickCategory, border: const OutlineInputBorder()),
              items: <DropdownMenuItem<String>>[for (final CategoryModel c in categories) DropdownMenuItem<String>(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))],
              onChanged: _busy ? null : (String? id) => setState(() => _targetId = id),
            ),
            Padding(padding: const EdgeInsets.only(top: 4), child: Text(l10n.promoCategoryHint, style: theme.textTheme.bodySmall)),
          ],
          if (_scope == PromotionScope.product) ...<Widget>[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: products.any((ProductModel p) => p.id == _targetId) ? _targetId : null,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.promoPickProduct, border: const OutlineInputBorder()),
              items: <DropdownMenuItem<String>>[for (final ProductModel p in products) DropdownMenuItem<String>(value: p.id, child: Text(p.name, overflow: TextOverflow.ellipsis))],
              onChanged: _busy ? null : (String? id) => setState(() => _targetId = id),
            ),
          ],
          const SizedBox(height: 16),
          Text(l10n.promoDiscount, style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              SegmentedButton<PromotionKind>(
                showSelectedIcon: false,
                segments: <ButtonSegment<PromotionKind>>[
                  ButtonSegment<PromotionKind>(value: PromotionKind.percent, label: Text(l10n.promoKindPercent)),
                  ButtonSegment<PromotionKind>(value: PromotionKind.amount, label: Text(l10n.promoKindAmount)),
                ],
                selected: <PromotionKind>{_kind},
                onSelectionChanged: _busy ? null : (Set<PromotionKind> v) => setState(() => _kind = v.first),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _value,
                  enabled: !_busy,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  decoration: InputDecoration(labelText: _kind == PromotionKind.percent ? l10n.promoValuePercent : (_needsTarget ? l10n.promoValueAmountEach : l10n.promoValueAmountOrder), border: const OutlineInputBorder(), isDense: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_needsTarget)
            TextField(
              controller: _minQuantity,
              enabled: !_busy,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: l10n.promoMinQuantity, helperText: l10n.promoMinQuantityHint, border: const OutlineInputBorder()),
            )
          else
            TextField(
              controller: _minAmount,
              enabled: !_busy,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              decoration: InputDecoration(labelText: l10n.promoMinAmount, helperText: l10n.promoMinAmountHint, border: const OutlineInputBorder()),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _code,
            enabled: !_busy,
            maxLength: 40,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_-]'))],
            decoration: InputDecoration(labelText: l10n.promoCode, helperText: l10n.promoCodeHint, border: const OutlineInputBorder()),
          ),
          Text(l10n.promoWhere, style: theme.textTheme.titleSmall),
          CheckboxListTile(contentPadding: EdgeInsets.zero, value: _pos, onChanged: _busy ? null : (bool? v) => setState(() => _pos = v ?? false), title: Text(l10n.promoChannelPos)),
          CheckboxListTile(contentPadding: EdgeInsets.zero, value: _web, onChanged: _busy ? null : (bool? v) => setState(() => _web = v ?? false), title: Text(l10n.promoChannelWebFuture)),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _pickDate(start: true),
                  icon: const Icon(Icons.event_outlined, size: 18),
                  label: Text(_startsOn == null ? l10n.promoStarts : l10n.promoStartsOn(_startsOn!)),
                ),
              ),
              if (_startsOn != null) IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _startsOn = null)),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _pickDate(start: false),
                  icon: const Icon(Icons.event_busy_outlined, size: 18),
                  label: Text(_endsOn == null ? l10n.promoEnds : l10n.promoEndsOn(_endsOn!)),
                ),
              ),
              if (_endsOn != null) IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _endsOn = null)),
            ],
          ),
          SwitchListTile(contentPadding: EdgeInsets.zero, value: _active, onChanged: _busy ? null : (bool v) => setState(() => _active = v), title: Text(l10n.promoSwitchedOn)),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _busy ? null : _save,
            icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
            label: Text(l10n.promoSave),
          ),
        ],
      ),
    );
  }
}
