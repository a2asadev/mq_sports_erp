import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/providers/business_provider.dart';

/// "Barcodes are required": off by default (a barcode is optional on every item). When an admin switches it on,
/// every new item needs one. It is asked in the welcome guide and can be changed any time in Settings > Shop
/// details. It saves at once (the server keeps it with the business), so it needs a connection; only an admin
/// can change it.
class RequireBarcodeTile extends ConsumerStatefulWidget {
  const RequireBarcodeTile({super.key, this.enabled = true});

  /// False for people who may not change it (they still see the current choice).
  final bool enabled;

  @override
  ConsumerState<RequireBarcodeTile> createState() => _RequireBarcodeTileState();
}

class _RequireBarcodeTileState extends ConsumerState<RequireBarcodeTile> {
  bool _busy = false;

  Future<void> _set(bool on) async {
    setState(() => _busy = true);
    try {
      final BusinessInfo? saved = await ref.read(businessServiceProvider).update(requireBarcode: on);
      await ref.read(businessUpdaterProvider)(ref.read(businessProvider).copyWith(requireBarcode: saved?.requireBarcode ?? on));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool on = ref.watch(businessProvider.select((BusinessInfo b) => b.requireBarcode));
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: on,
      onChanged: widget.enabled && !_busy ? _set : null,
      title: Text(context.l10n.barcodeRequiredTitle),
      subtitle: Text(context.l10n.barcodeRequiredHint),
      secondary: _busy ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.qr_code_2),
    );
  }
}
