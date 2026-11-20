import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/tax_text.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/providers/business_provider.dart';

/// Settings > Shop details > Tax: switched on or off, a GST rate and a VAT rate (either, or both on the
/// same price), and whether the shelf prices already include the tax. Only an admin can change it; it
/// saves with its own button and needs a connection (the server keeps it with the business).
class TaxSettingsForm extends ConsumerStatefulWidget {
  const TaxSettingsForm({super.key, required this.canEdit});

  final bool canEdit;

  @override
  ConsumerState<TaxSettingsForm> createState() => _TaxSettingsFormState();
}

class _TaxSettingsFormState extends ConsumerState<TaxSettingsForm> {
  late bool _enabled;
  late bool _includes;
  late final TextEditingController _gst;
  late final TextEditingController _vat;
  late final TextEditingController _number;
  bool _busy = false;
  String _message = '';
  bool _failed = false;

  static String _rate(double value) => value == 0 ? '' : formatRate(value);

  @override
  void initState() {
    super.initState();
    // Made now, not on first use: a field that is never drawn is still disposed with the form.
    final BusinessInfo business = ref.read(businessProvider);
    _enabled = business.taxEnabled;
    _includes = business.pricesIncludeTax;
    _gst = TextEditingController(text: _rate(business.gstRate));
    _vat = TextEditingController(text: _rate(business.vatRate));
    _number = TextEditingController(text: business.taxNumber);
  }

  @override
  void dispose() {
    _gst.dispose();
    _vat.dispose();
    _number.dispose();
    super.dispose();
  }

  /// A typed rate: empty means 0; null when it is not a number from 0 to 100.
  double? _parse(String text) {
    final String t = text.trim();
    if (t.isEmpty) {
      return 0;
    }
    final double? value = double.tryParse(t);
    if (value == null || value < 0 || value > 100) {
      return null;
    }
    return (value * 100).round() / 100;
  }

  Future<void> _save() async {
    final AppLocalizations l10n = context.l10n;
    final double? gst = _parse(_gst.text);
    final double? vat = _parse(_vat.text);
    if (gst == null || vat == null) {
      setState(() {
        _failed = true;
        _message = l10n.taxRateInvalid;
      });
      return;
    }
    if (_enabled && gst + vat <= 0) {
      setState(() {
        _failed = true;
        _message = l10n.taxNeedsRate;
      });
      return;
    }
    setState(() {
      _busy = true;
      _message = '';
    });
    try {
      final BusinessInfo? saved = await ref.read(businessServiceProvider).update(
            taxEnabled: _enabled,
            gstRate: gst,
            vatRate: vat,
            pricesIncludeTax: _includes,
            taxNumber: _number.text.trim(),
          );
      // The server's answer decides; then every sale, receipt and total follows it.
      await ref.read(businessUpdaterProvider)(ref.read(businessProvider).copyWith(
            taxEnabled: saved?.taxEnabled ?? _enabled,
            gstRate: saved?.gstRate ?? gst,
            vatRate: saved?.vatRate ?? vat,
            pricesIncludeTax: saved?.pricesIncludeTax ?? _includes,
            taxNumber: saved?.taxNumber ?? _number.text.trim(),
          ));
      if (mounted) {
        setState(() {
          _failed = false;
          _message = l10n.taxSaved;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _failed = true;
          _message = errorMessageOf(error);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool locked = _busy || !widget.canEdit;
    final ThemeData theme = Theme.of(context);
    InputDecoration field(String label) => InputDecoration(labelText: label, suffixText: '%', border: const OutlineInputBorder(), isDense: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(l10n.taxSettingsTitle, style: theme.textTheme.titleSmall),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _enabled,
          onChanged: locked ? null : (bool on) => setState(() => _enabled = on),
          title: Text(l10n.taxSettingsSwitch),
          subtitle: Text(widget.canEdit ? l10n.taxSettingsHint : l10n.taxAdminOnly),
          secondary: const Icon(Icons.receipt_long_outlined),
        ),
        if (_enabled) ...<Widget>[
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _gst,
                  enabled: !locked,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  decoration: field(l10n.taxGstRate),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _vat,
                  enabled: !locked,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  decoration: field(l10n.taxVatRate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.taxIncludesTitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 6),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: <ButtonSegment<bool>>[
              ButtonSegment<bool>(value: true, label: Text(l10n.taxIncludesYes)),
              ButtonSegment<bool>(value: false, label: Text(l10n.taxIncludesNo)),
            ],
            selected: <bool>{_includes},
            onSelectionChanged: locked ? null : (Set<bool> v) => setState(() => _includes = v.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _number,
            enabled: !locked,
            maxLength: 60,
            decoration: InputDecoration(labelText: l10n.taxNumberLabel, border: const OutlineInputBorder(), isDense: true),
          ),
        ],
        if (widget.canEdit) ...<Widget>[
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              FilledButton(
                onPressed: locked ? null : _save,
                child: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.taxSave),
              ),
              if (_message.isNotEmpty) ...<Widget>[
                const SizedBox(width: 12),
                Expanded(child: Text(_message, style: TextStyle(color: _failed ? AppColors.danger : AppColors.teal))),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
