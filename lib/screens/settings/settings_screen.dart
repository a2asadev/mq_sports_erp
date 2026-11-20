import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/currency.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/widgets/brand_logo.dart';
import 'package:a2_stocks/widgets/photo_widgets.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/models/store_settings_model.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/photo_service.dart';
import 'package:a2_stocks/online/store_settings_service.dart';
import 'package:a2_stocks/providers/users_providers.dart';
import 'package:a2_stocks/screens/onboarding/onboarding_screen.dart';
import 'package:a2_stocks/screens/catalog/barcode_choice.dart';
import 'package:a2_stocks/screens/register/register_choice.dart';
import 'package:a2_stocks/screens/settings/notification_settings_card.dart';
import 'package:a2_stocks/screens/settings/tax_settings_form.dart';

final Provider<StoreSettingsService> storeSettingsServiceProvider =
    Provider<StoreSettingsService>((Ref ref) => StoreSettingsService(ref.watch(apiClientProvider)));

/// The store settings from the server. Reload by invalidating the provider.
final AutoDisposeFutureProvider<StoreSettingsModel> storeSettingsProvider =
    FutureProvider.autoDispose<StoreSettingsModel>((Ref ref) {
  return ref.watch(storeSettingsServiceProvider).load();
});

String _problemText(Object error) =>
    error is AppException ? error.message : L10n.current.settingsSomethingWentWrongPlease;

enum _SettingsSection {
  profile(Icons.person_outline),
  notifications(Icons.notifications_none),
  store(Icons.storefront_outlined),
  shop(Icons.store_mall_directory_outlined),
  help(Icons.help_outline);

  const _SettingsSection(this.icon);

  final IconData icon;

  String title(AppLocalizations l10n) {
    switch (this) {
      case _SettingsSection.profile:
        return l10n.settingsProfile;
      case _SettingsSection.notifications:
        return l10n.settingsNotifications;
      case _SettingsSection.store:
        return l10n.settingsOnlineStore;
      case _SettingsSection.shop:
        return l10n.settingsShopDetails;
      case _SettingsSection.help:
        return l10n.settingsHelpGuide;
    }
  }

  String subtitle(AppLocalizations l10n) {
    switch (this) {
      case _SettingsSection.profile:
        return l10n.settingsYourNameEMail;
      case _SettingsSection.notifications:
        return l10n.settingsNotificationsSubtitle;
      case _SettingsSection.store:
        return l10n.settingsOpeningDeliveryAndAlerts;
      case _SettingsSection.shop:
        return l10n.settingsCurrencyAndReceiptDetails;
      case _SettingsSection.help:
        return l10n.settingsTheWelcomeTour;
    }
  }
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
      case _SettingsSection.notifications:
        return const NotificationSettingsCard();
      case _SettingsSection.store:
        return _StoreSettingsCard(canEdit: user.role == UserRole.admin, myEmail: user.email);
      case _SettingsSection.shop:
        return _ShopDetailsCard(canEdit: user.role == UserRole.admin);
      case _SettingsSection.help:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              child: ListTile(
                leading: const Icon(Icons.tour_outlined),
                title: Text(context.l10n.settingsWelcomeGuide),
                subtitle: Text(context.l10n.settingsAShortTourOf(user.role.label)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push<bool>(
                  MaterialPageRoute<bool>(builder: (BuildContext c) => OnboardingScreen(role: user.role)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const _AboutCard(),
          ],
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
      appBar: AppBar(title: Text(context.l10n.settingsSettings)),
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
                              title: Text(s.title(context.l10n), style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(s.subtitle(context.l10n), style: const TextStyle(fontSize: 12)),
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
                            label: Text(s.title(context.l10n)),
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
              title: context.l10n.settingsYourPhoto,
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
              Text(context.l10n.settingsShopDetails, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                context.l10n.settingsTheShopDetailsNeed(_problemText(error)),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(storeSettingsProvider),
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.commonTryAgain),
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
  late String _brand = ref.read(businessProvider).brandColor;
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
      final String? newCurrency = _currency != business.currency ? _currency : null;
      final String? newBrand = _brand != business.brandColor ? _brand : null;
      if (newCurrency != null || newBrand != null) {
        // The server's answer decides; then amounts, buttons and charts follow it.
        final BusinessInfo? saved =
            await ref.read(businessServiceProvider).update(currency: newCurrency, brandColor: newBrand);
        business = business.copyWith(
          currency: saved?.currency ?? newCurrency,
          brandColor: saved?.brandColor ?? newBrand,
        );
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
          Text(context.l10n.settingsShopDetails, style: Theme.of(context).textTheme.titleLarge),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Text(
              widget.canEdit
                  ? (widget.initial == null
                      ? context.l10n.settingsTheCurrencyEveryAmount
                      : context.l10n.settingsPrintedAtTheTop)
                  : context.l10n.settingsOnlyAnAdminCan,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          PhotoEditor(
            kind: PhotoKind.business,
            entityId: ref.watch(businessProvider).id,
            photoUrl: ref.watch(businessProvider).logoUrl,
            title: context.l10n.settingsLogo,
            enabled: widget.canEdit && !_busy,
            onChanged: (String url) => ref.read(businessUpdaterProvider)(
              ref.read(businessProvider).copyWith(logoUrl: url),
            ),
          ),
          const SizedBox(height: 16),
          Text(context.l10n.settingsBrandColour, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            context.l10n.settingsButtonsSelectionsAndCharts,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              for (final BrandChoice choice in brandChoices)
                BrandSwatch(
                  choice: choice,
                  selected: _brand == choice.hex,
                  onTap: locked ? null : () => setState(() => _brand = choice.hex),
                ),
            ],
          ),
          const SizedBox(height: 8),
          RegisterChoiceTile(enabled: widget.canEdit && !_busy),
          RequireBarcodeTile(enabled: widget.canEdit && !_busy),
          const Divider(height: 24),
          TaxSettingsForm(canEdit: widget.canEdit),
          const Divider(height: 24),
          if (widget.initial != null) ...<Widget>[
            TextFormField(
              controller: _name,
              enabled: !locked,
              decoration: InputDecoration(labelText: context.l10n.settingsShopName, border: const OutlineInputBorder()),
              validator: (String? v) => (v == null || v.trim().isEmpty) ? context.l10n.settingsEnterTheShopName : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              enabled: !locked,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: context.l10n.partyFormPhone, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
          ],
          DropdownButtonFormField<String>(
            initialValue: _currency,
            decoration: InputDecoration(
              labelText: context.l10n.settingsCurrency,
              border: const OutlineInputBorder(),
              helperText: context.l10n.settingsAmountsAlreadyRecordedAre,
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
                label: Text(context.l10n.settingsSave),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The colours a business can pick as its accent, besides the A2 Stocks default.
/// Each is darkened by the theme if white text would be hard to read on it.
class BrandChoice {
  const BrandChoice(this.label, this.hex);

  final String Function(AppLocalizations l10n) label;

  /// "#RRGGBB", or '' for the default A2 Stocks teal.
  final String hex;
}

final List<BrandChoice> brandChoices = <BrandChoice>[
  BrandChoice((AppLocalizations l10n) => l10n.settingsA2StocksTeal, ''),
  BrandChoice((AppLocalizations l10n) => l10n.settingsBlue, '#2563EB'),
  BrandChoice((AppLocalizations l10n) => l10n.settingsViolet, '#7C3AED'),
  BrandChoice((AppLocalizations l10n) => l10n.settingsMagenta, '#C026D3'),
  BrandChoice((AppLocalizations l10n) => l10n.settingsPink, '#DB2777'),
  BrandChoice((AppLocalizations l10n) => l10n.settingsRed, '#DC2626'),
  BrandChoice((AppLocalizations l10n) => l10n.settingsOrange, '#EA580C'),
  BrandChoice((AppLocalizations l10n) => l10n.settingsGold, '#CA8A04'),
  BrandChoice((AppLocalizations l10n) => l10n.settingsGreen, '#16A34A'),
  BrandChoice((AppLocalizations l10n) => l10n.settingsDarkTeal, '#0F766E'),
  BrandChoice((AppLocalizations l10n) => l10n.settingsSlate, '#475569'),
];

/// One round colour choice; the chosen one carries a tick.
class BrandSwatch extends StatelessWidget {
  const BrandSwatch({super.key, required this.choice, required this.selected, required this.onTap});

  final BrandChoice choice;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = AppColors.readableOnWhite(AppColors.tryParseHex(choice.hex) ?? AppColors.a2Primary);
    return Tooltip(
      message: choice.label(context.l10n),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: selected ? AppColors.text : Colors.transparent, width: 2.5),
          ),
          child: selected ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
        ),
      ),
    );
  }
}

/// What this software is and who made it.
class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const BrandLogo(height: 44, markOnly: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('A2 Stocks', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  Text(context.l10n.settingsPosInventorySoftware),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.settingsCraftedWithLoveBy,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
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
              Text(context.l10n.settingsOnlineStore, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                context.l10n.settingsTheStoreSettingsNeed(_problemText(error)),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(storeSettingsProvider),
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.commonTryAgain),
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

  String? _amount(String? value) {
    final double? parsed = double.tryParse((value ?? '').trim());
    if (parsed == null || parsed < 0) {
      return context.l10n.settingsEnterAnAmountOf;
    }
    return null;
  }

  String? _email(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return null;
    }
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text) ? null : context.l10n.settingsEnterAValidE;
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
        _message = saved.enabled ? context.l10n.settingsSavedTheStoreIs2 : context.l10n.settingsSavedTheStoreIs;
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
        title: Text(context.l10n.settingsSendTestEMail),
        content: TextField(
          controller: to,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: context.l10n.settingsSendTo, border: const OutlineInputBorder()),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.categoriesCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(to.text.trim()), child: Text(context.l10n.settingsSend)),
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
        _message = context.l10n.settingsEnterAValidE;
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
            ? context.l10n.settingsTestEMailSent(address)
            : result.configured
                ? context.l10n.settingsTheMailServerRefused
                : context.l10n.settingsEMailIsNot;
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
          Text(context.l10n.settingsOnlineStore, style: Theme.of(context).textTheme.titleLarge),
          if (!widget.canEdit)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(context.l10n.settingsOnlyAnAdminCan, style: Theme.of(context).textTheme.bodySmall),
            ),
          _heading(context, context.l10n.categoriesStatus, Icons.power_settings_new),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.settingsStoreIsOpen),
            subtitle: Text(context.l10n.settingsWhenOffTheWebsite),
            value: _enabled,
            onChanged: locked ? null : (bool v) => setState(() => _enabled = v),
          ),
          _heading(context, context.l10n.settingsContactAlerts, Icons.contact_phone_outlined),
          TextFormField(
            controller: _name,
            enabled: !locked,
            decoration: deco(context.l10n.settingsStoreName),
            validator: (String? v) => (v == null || v.trim().isEmpty) ? context.l10n.settingsEnterTheStoreName : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phone,
            enabled: !locked,
            keyboardType: TextInputType.phone,
            decoration: deco(context.l10n.settingsContactPhone, helper: context.l10n.settingsShownInTheWebsite),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notify,
            enabled: !locked,
            keyboardType: TextInputType.emailAddress,
            decoration: deco(context.l10n.settingsSendNewOrderAlerts, helper: context.l10n.settingsLeaveEmptyForNo),
            validator: _email,
          ),
          _heading(context, context.l10n.settingsCheckoutDelivery, Icons.local_shipping_outlined),
          TextFormField(
            controller: _note,
            enabled: !locked,
            maxLines: 2,
            decoration: deco(context.l10n.settingsNoteAtCheckout, helper: context.l10n.settingsForExampleDeliveryTimes),
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
                  decoration: deco(context.l10n.settingsDeliveryFee),
                  validator: _amount,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _free,
                  enabled: !locked,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: deco(context.l10n.settingsFreeDeliveryFrom, helper: context.l10n.settings0NeverFree),
                  validator: _amount,
                ),
              ),
            ],
          ),
          _heading(context, context.l10n.settingsStockDisplay, Icons.inventory_2_outlined),
          TextFormField(
            controller: _low,
            enabled: !locked,
            keyboardType: TextInputType.number,
            decoration: deco(context.l10n.settingsShowLowStockAt, helper: context.l10n.settingsCustomersNeverSeeExact),
            validator: (String? v) {
              final int? n = int.tryParse((v ?? '').trim());
              return (n == null || n < 0) ? context.l10n.settingsEnterAWholeNumber : null;
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
                  label: Text(context.l10n.settingsSaveSettings),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _testEmail,
                  icon: const Icon(Icons.mark_email_read_outlined),
                  label: Text(context.l10n.settingsSendTestEMail),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
