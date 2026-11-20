import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/providers/business_provider.dart';

/// "I use a cash register": the switch that adds the Cash register page. It is
/// asked in the welcome guide and can be changed any time in Settings > Shop
/// details. It saves at once (the server keeps it with the business), so it needs
/// a connection; only an admin can change it.
class RegisterChoiceTile extends ConsumerStatefulWidget {
  const RegisterChoiceTile({super.key, this.enabled = true});

  /// False for people who may not change it (they still see the current choice).
  final bool enabled;

  @override
  ConsumerState<RegisterChoiceTile> createState() => _RegisterChoiceTileState();
}

class _RegisterChoiceTileState extends ConsumerState<RegisterChoiceTile> {
  bool _busy = false;

  Future<void> _set(bool on) async {
    setState(() => _busy = true);
    try {
      final BusinessInfo? saved = await ref.read(businessServiceProvider).saveUsesRegister(on);
      await ref.read(businessUpdaterProvider)(ref.read(businessProvider).copyWith(usesRegister: saved?.usesRegister ?? on));
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
    final bool on = ref.watch(businessProvider.select((BusinessInfo b) => b.usesRegister));
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: on,
      onChanged: widget.enabled && !_busy ? _set : null,
      title: Text(context.l10n.registerChoiceTitle),
      subtitle: Text(context.l10n.registerChoiceHint),
      secondary: _busy
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.account_balance_wallet_outlined),
    );
  }
}
