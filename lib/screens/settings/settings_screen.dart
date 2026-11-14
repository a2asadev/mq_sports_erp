import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/store_settings_model.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/user_role.dart';
import 'package:mq_sports_erp/online/online_providers.dart';
import 'package:mq_sports_erp/online/photo_service.dart';
import 'package:mq_sports_erp/online/store_settings_service.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';
import 'package:mq_sports_erp/screens/onboarding/onboarding_screen.dart';
import 'package:mq_sports_erp/widgets/photo_widgets.dart';

final Provider<StoreSettingsService> storeSettingsServiceProvider =
    Provider<StoreSettingsService>((Ref ref) => StoreSettingsService(ref.watch(apiClientProvider)));

/// The store settings from the server. Reload by invalidating the provider.
final AutoDisposeFutureProvider<StoreSettingsModel> storeSettingsProvider =
    FutureProvider.autoDispose<StoreSettingsModel>((Ref ref) {
  return ref.watch(storeSettingsServiceProvider).load();
});

String _problemText(Object error) =>
    error is AppException ? error.message : 'Something went wrong. Please try again.';

/// Settings for everyone: your profile photo and the welcome guide. Admins and
/// managers also see the online store's settings (only admins can change them).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final bool seesStore = user.role == UserRole.admin || user.role == UserRole.manager;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _ProfileCard(user: user),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.tour_outlined),
                        title: const Text('Welcome guide'),
                        subtitle: Text('A short tour of what you can do as ${user.role.label}.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push<bool>(
                          MaterialPageRoute<bool>(builder: (BuildContext c) => OnboardingScreen(role: user.role)),
                        ),
                      ),
                    ),
                    if (seesStore) ...<Widget>[
                      const SizedBox(height: 16),
                      _StoreSettingsCard(canEdit: user.role == UserRole.admin, myEmail: user.email),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final String name = user.displayName.isNotEmpty ? user.displayName : user.email;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            Text('${user.email} · ${user.role.label}'),
            const SizedBox(height: 16),
            PhotoEditor(
              kind: PhotoKind.user,
              entityId: user.id,
              photoUrl: user.photoUrl,
              title: 'Your photo',
              onChanged: (String url) {},
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreSettingsCard extends ConsumerWidget {
  const _StoreSettingsCard({required this.canEdit, required this.myEmail});

  final bool canEdit;
  final String myEmail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<StoreSettingsModel> settings = ref.watch(storeSettingsProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: settings.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
          error: (Object error, StackTrace stack) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Online store', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                '${_problemText(error)}\nThe store settings need a connection to the server.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(storeSettingsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
          data: (StoreSettingsModel value) =>
              StoreSettingsForm(initial: value, canEdit: canEdit, myEmail: myEmail),
        ),
      ),
    );
  }
}

/// The online store's settings as a form. Public so it can be tested alone.
class StoreSettingsForm extends ConsumerStatefulWidget {
  const StoreSettingsForm({super.key, required this.initial, required this.canEdit, required this.myEmail});

  final StoreSettingsModel initial;
  final bool canEdit;
  final String myEmail;

  @override
  ConsumerState<StoreSettingsForm> createState() => _StoreSettingsFormState();
}

class _StoreSettingsFormState extends ConsumerState<StoreSettingsForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late bool _enabled = widget.initial.enabled;
  late final TextEditingController _name = TextEditingController(text: widget.initial.storeName);
  late final TextEditingController _phone = TextEditingController(text: widget.initial.contactPhone);
  late final TextEditingController _notify = TextEditingController(text: widget.initial.notifyEmail);
  late final TextEditingController _note = TextEditingController(text: widget.initial.checkoutNote);
  late final TextEditingController _fee = TextEditingController(text: _money(widget.initial.deliveryFee));
  late final TextEditingController _free = TextEditingController(text: _money(widget.initial.freeDeliveryAbove));
  late final TextEditingController _low = TextEditingController(text: '${widget.initial.lowStockBelow}');
  bool _busy = false;
  String _message = '';
  bool _failed = false;

  static String _money(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[_name, _phone, _notify, _note, _fee, _free, _low]) {
      c.dispose();
    }
    super.dispose();
  }

  static String? _amount(String? value) {
    final double? parsed = double.tryParse((value ?? '').trim());
    if (parsed == null || parsed < 0) {
      return 'Enter an amount of 0 or more.';
    }
    return null;
  }

  static String? _email(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return null;
    }
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text) ? null : 'Enter a valid e-mail address.';
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _busy = true;
      _message = '';
    });
    try {
      final StoreSettingsModel saved = await ref.read(storeSettingsServiceProvider).save(
            StoreSettingsModel(
              enabled: _enabled,
              storeName: _name.text.trim(),
              contactPhone: _phone.text.trim(),
              notifyEmail: _notify.text.trim(),
              checkoutNote: _note.text.trim(),
              deliveryFee: double.parse(_fee.text.trim()),
              freeDeliveryAbove: double.parse(_free.text.trim()),
              lowStockBelow: int.tryParse(_low.text.trim()) ?? 5,
            ),
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _failed = false;
        _message = saved.enabled ? 'Saved. The store is open.' : 'Saved. The store is closed: it takes no orders.';
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _failed = true;
          _message = _problemText(error);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _testEmail() async {
    final TextEditingController to = TextEditingController(text: widget.myEmail);
    final String? address = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Send test e-mail'),
        content: TextField(
          controller: to,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Send to', border: OutlineInputBorder()),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(to.text.trim()), child: const Text('Send')),
        ],
      ),
    );
    disposeControllerLater(to);
    if (address == null || address.isEmpty || !mounted) {
      return;
    }
    if (_email(address) != null) {
      setState(() {
        _failed = true;
        _message = 'Enter a valid e-mail address.';
      });
      return;
    }
    setState(() {
      _busy = true;
      _message = '';
    });
    try {
      final TestEmailResult result = await ref.read(storeSettingsServiceProvider).sendTestEmail(address);
      if (!mounted) {
        return;
      }
      setState(() {
        _failed = !result.sent;
        _message = result.sent
            ? 'Test e-mail sent to $address. Check the inbox (and the spam folder).'
            : result.configured
                ? 'The mail server refused or could not be reached. Check the SMTP settings on the server.'
                : 'E-mail is not set up on the server yet (SMTP_HOST is empty). See docs/deploy.md.';
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _failed = true;
          _message = _problemText(error);
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
    final bool locked = _busy || !widget.canEdit;
    InputDecoration deco(String label, {String? helper}) =>
        InputDecoration(labelText: label, helperText: helper, border: const OutlineInputBorder());
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Online store', style: Theme.of(context).textTheme.titleLarge),
          if (!widget.canEdit)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Only an admin can change these.', style: Theme.of(context).textTheme.bodySmall),
            ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Store is open'),
            subtitle: const Text('When off, the website shows a closed notice and takes no orders.'),
            value: _enabled,
            onChanged: locked ? null : (bool v) => setState(() => _enabled = v),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _name,
            enabled: !locked,
            decoration: deco('Store name'),
            validator: (String? v) => (v == null || v.trim().isEmpty) ? 'Enter the store name.' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phone,
            enabled: !locked,
            keyboardType: TextInputType.phone,
            decoration: deco('Contact phone', helper: 'Shown in the website footer.'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notify,
            enabled: !locked,
            keyboardType: TextInputType.emailAddress,
            decoration: deco('Send new-order alerts to (e-mail)', helper: 'Leave empty for no alerts.'),
            validator: _email,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _note,
            enabled: !locked,
            maxLines: 2,
            decoration: deco('Note at checkout', helper: 'For example delivery times.'),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _fee,
                  enabled: !locked,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: deco('Delivery fee'),
                  validator: _amount,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _free,
                  enabled: !locked,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: deco('Free delivery from', helper: '0 = never free'),
                  validator: _amount,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _low,
            enabled: !locked,
            keyboardType: TextInputType.number,
            decoration: deco('Show "Low stock" at or below', helper: 'Customers never see exact numbers.'),
            validator: (String? v) {
              final int? n = int.tryParse((v ?? '').trim());
              return (n == null || n < 0) ? 'Enter a whole number, 0 or more.' : null;
            },
          ),
          if (_message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _message,
                style: TextStyle(color: _failed ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary),
              ),
            ),
          if (widget.canEdit) ...<Widget>[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: _busy ? null : _save,
                  icon: _busy
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined),
                  label: const Text('Save settings'),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _testEmail,
                  icon: const Icon(Icons.mark_email_read_outlined),
                  label: const Text('Send test e-mail'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
