import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/core/theme/app_theme.dart';
import 'package:mq_sports_erp/core/utils/currency.dart';
import 'package:mq_sports_erp/models/business_info.dart';
import 'package:mq_sports_erp/models/store_settings_model.dart';
import 'package:mq_sports_erp/online/business_service.dart';
import 'package:mq_sports_erp/providers/business_provider.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/user_role.dart';
import 'package:mq_sports_erp/online/online_providers.dart';
import 'package:mq_sports_erp/online/photo_service.dart';
import 'package:mq_sports_erp/online/store_settings_service.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';
import 'package:mq_sports_erp/screens/onboarding/onboarding_screen.dart';
import 'package:mq_sports_erp/widgets/photo_widgets.dart';

final Provider<BusinessService> businessServiceProvider =
    Provider<BusinessService>((Ref ref) => BusinessService(ref.watch(apiClientProvider)));

final Provider<StoreSettingsService> storeSettingsServiceProvider =
    Provider<StoreSettingsService>((Ref ref) => StoreSettingsService(ref.watch(apiClientProvider)));

/// The store settings from the server. Reload by invalidating the provider.
final AutoDisposeFutureProvider<StoreSettingsModel> storeSettingsProvider =
    FutureProvider.autoDispose<StoreSettingsModel>((Ref ref) {
  return ref.watch(storeSettingsServiceProvider).load();
});

String _problemText(Object error) =>
    error is AppException ? error.message : 'Something went wrong. Please try again.';

enum _SettingsSection {
  profile('Profile', Icons.person_outline, 'Your name, e-mail and photo'),
  store('Online store', Icons.storefront_outlined, 'Opening, delivery and alerts'),
  shop('Shop details', Icons.store_mall_directory_outlined, 'Currency and receipt details'),
  help('Help & guide', Icons.help_outline, 'The welcome tour');

  const _SettingsSection(this.title, this.icon, this.subtitle);

  final String title;
  final IconData icon;
  final String subtitle;
}

/// Settings, grouped into sections: Profile and Help for everyone. Admins and
/// managers also see the Online store section if their business runs the online
/// store (only admins can change it). They also see Shop details: the currency
/// and, for a business without the online store, the name and phone printed on
/// its receipts.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  _SettingsSection _section = _SettingsSection.profile;

  Widget _content(UserModel user, _SettingsSection section) {
    switch (section) {
      case _SettingsSection.profile:
        return _ProfileCard(user: user);
      case _SettingsSection.store:
        return _StoreSettingsCard(canEdit: user.role == UserRole.admin, myEmail: user.email);
      case _SettingsSection.shop:
        return _ShopDetailsCard(canEdit: user.role == UserRole.admin);
      case _SettingsSection.help:
        return Card(
          child: ListTile(
            leading: const Icon(Icons.tour_outlined),
            title: const Text('Welcome guide'),
            subtitle: Text('A short tour of what you can do as ${user.role.label}.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push<bool>(
              MaterialPageRoute<bool>(builder: (BuildContext c) => OnboardingScreen(role: user.role)),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final bool seesBusinessSettings = user.role == UserRole.admin || user.role == UserRole.manager;
    final bool hasStore = ref.watch(businessProvider).hasOnlineStore;
    final List<_SettingsSection> sections = <_SettingsSection>[
      for (final _SettingsSection s in _SettingsSection.values)
        if ((s != _SettingsSection.store || (seesBusinessSettings && hasStore)) &&
            (s != _SettingsSection.shop || seesBusinessSettings))
          s,
    ];
    final _SettingsSection current = sections.contains(_section) ? _section : sections.first;
    final Widget content = ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: _content(user, current),
          ),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) {
            if (box.maxWidth >= 800) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 250,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                      children: <Widget>[
                        for (final _SettingsSection s in sections)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: ListTile(
                              selected: s == current,
                              selectedTileColor: AppColors.primarySoft,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              leading: Icon(s.icon),
                              title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(s.subtitle, style: const TextStyle(fontSize: 12)),
                              onTap: () => setState(() => _section = s),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(child: content),
                ],
              );
            }
            return Column(
              children: <Widget>[
                SizedBox(
                  height: 56,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    children: <Widget>[
                      for (final _SettingsSection s in sections)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            avatar: Icon(s.icon, size: 18),
                            label: Text(s.title),
                            selected: s == current,
                            onSelected: (bool _) => setState(() => _section = s),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(child: content),
              ],
            );
          },
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

/// Shop details: the currency, and (when the business does not run the online
/// store, whose settings hold them) the shop's name and phone for receipts.
class _ShopDetailsCard extends ConsumerWidget {
  const _ShopDetailsCard({required this.canEdit});

  final bool canEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool hasStore = ref.watch(businessProvider).hasOnlineStore;
    if (hasStore) {
      // The name and phone are edited under Online store; only the currency lives here.
      return Card(
        child: Padding(padding: const EdgeInsets.all(16), child: ShopDetailsForm(initial: null, canEdit: canEdit)),
      );
    }
    final AsyncValue<StoreSettingsModel> settings = ref.watch(storeSettingsProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: settings.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
          error: (Object error, StackTrace stack) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Shop details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                '${_problemText(error)}\nThe shop details need a connection to the server.',
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
          data: (StoreSettingsModel value) => ShopDetailsForm(initial: value, canEdit: canEdit),
        ),
      ),
    );
  }
}

/// The shop details as a form. Public so it can be tested alone.
///
/// With [initial] it edits the shop's name and phone too, through the same
/// server record as the online store's settings (every other value in it is left
/// as it was). Without it, only the currency.
class ShopDetailsForm extends ConsumerStatefulWidget {
  const ShopDetailsForm({super.key, required this.initial, required this.canEdit});

  final StoreSettingsModel? initial;
  final bool canEdit;

  @override
  ConsumerState<ShopDetailsForm> createState() => _ShopDetailsFormState();
}

class _ShopDetailsFormState extends ConsumerState<ShopDetailsForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(text: widget.initial?.storeName ?? '');
  late final TextEditingController _phone = TextEditingController(text: widget.initial?.contactPhone ?? '');
  late String _currency = ref.read(businessProvider).currency;
  bool _busy = false;
  String _message = '';
  bool _failed = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
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
      BusinessInfo business = ref.read(businessProvider);
      final StoreSettingsModel? settings = widget.initial;
      if (settings != null) {
        final String name = _name.text.trim();
        final String phone = _phone.text.trim();
        await ref.read(storeSettingsServiceProvider).save(settings.copyWith(storeName: name, contactPhone: phone));
        business = business.copyWith(name: name, phone: phone);
      }
      if (_currency != business.currency) {
        // The server's answer decides, then everything is written in the new currency.
        final BusinessInfo? saved = await ref.read(businessServiceProvider).saveCurrency(_currency);
        business = business.copyWith(currency: saved?.currency ?? _currency);
      }
      await ref.read(businessUpdaterProvider)(business);
      if (!mounted) {
        return;
      }
      setState(() {
        _failed = false;
        _message = 'Saved.';
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
    final List<CurrencyInfo> choices = <CurrencyInfo>[
      ...CurrencyInfo.supported,
      // A currency the app does not list (set elsewhere) stays selectable, as itself.
      if (!CurrencyInfo.supported.any((CurrencyInfo c) => c.code == _currency)) CurrencyInfo.byCode(_currency),
    ];
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Shop details', style: Theme.of(context).textTheme.titleLarge),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Text(
              widget.canEdit
                  ? (widget.initial == null
                      ? 'The currency every amount in the app is written in.'
                      : 'Printed at the top of your receipts and in messages to customers.')
                  : 'Only an admin can change these.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (widget.initial != null) ...<Widget>[
            TextFormField(
              controller: _name,
              enabled: !locked,
              decoration: const InputDecoration(labelText: 'Shop name', border: OutlineInputBorder()),
              validator: (String? v) => (v == null || v.trim().isEmpty) ? 'Enter the shop name.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              enabled: !locked,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
          ],
          DropdownButtonFormField<String>(
            initialValue: _currency,
            decoration: const InputDecoration(
              labelText: 'Currency',
              border: OutlineInputBorder(),
              helperText: 'Amounts already recorded are not converted: they keep their numbers.',
              helperMaxLines: 2,
            ),
            items: <DropdownMenuItem<String>>[
              for (final CurrencyInfo c in choices)
                DropdownMenuItem<String>(value: c.code, child: Text('${c.code} · ${c.name} (${c.symbol})')),
            ],
            onChanged: locked ? null : (String? code) => setState(() => _currency = code ?? _currency),
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
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: _busy ? null : _save,
                icon: _busy
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save_outlined),
                label: const Text('Save'),
              ),
            ),
          ],
        ],
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
      // Receipts print the shop's name and phone: keep them in step with the settings.
      await ref.read(businessUpdaterProvider)(
        ref.read(businessProvider).copyWith(name: saved.storeName.trim(), phone: saved.contactPhone.trim()),
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

  /// A small titled divider that groups the fields under it.
  static Widget _heading(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Divider(height: 1)),
        ],
      ),
    );
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
          _heading(context, 'Status', Icons.power_settings_new),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Store is open'),
            subtitle: const Text('When off, the website shows a closed notice and takes no orders.'),
            value: _enabled,
            onChanged: locked ? null : (bool v) => setState(() => _enabled = v),
          ),
          _heading(context, 'Contact & alerts', Icons.contact_phone_outlined),
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
          _heading(context, 'Checkout & delivery', Icons.local_shipping_outlined),
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
          _heading(context, 'Stock display', Icons.inventory_2_outlined),
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
