import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:a2_stocks/core/utils/customer_insights.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/online/photo_service.dart';
import 'package:a2_stocks/widgets/photo_widgets.dart';
import 'package:a2_stocks/models/party_enums.dart';

/// Values entered in the vendor/customer form.
class PartyFormData {
  const PartyFormData({
    required this.name,
    required this.typeKey,
    this.contactPerson = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.city = '',
    this.creditLimit = 0,
    this.openingBalance = 0,
    this.notes = '',
    this.isActive = true,
    this.photoUrl = '',
    this.birthday = '',
  });

  final String name;
  final String typeKey;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String city;
  final double creditLimit;
  final double openingBalance;
  final String notes;
  final bool isActive;
  final String photoUrl;

  /// A customer's birthday, "MM-DD" or ''.
  final String birthday;
}

/// One form for both vendors and customers. The vendor/customer wrappers turn
/// [PartyFormData] into their models and call their notifiers.
class PartyFormScreen extends StatefulWidget {
  const PartyFormScreen({
    super.key,
    required this.partyType,
    required this.typeOptions,
    required this.onSubmit,
    this.initial,
    this.entityId,
  });

  /// The id of the saved record (null while adding), needed for its photo.
  final String? entityId;

  final PartyType partyType;
  final List<MapEntry<String, String>> typeOptions;
  final PartyFormData? initial;

  /// Returns true when saved, so the form can close.
  final Future<bool> Function(PartyFormData data) onSubmit;

  @override
  State<PartyFormScreen> createState() => _PartyFormScreenState();
}

class _PartyFormScreenState extends State<PartyFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _creditController;
  late final TextEditingController _openingController;
  late final TextEditingController _notesController;
  late String _typeKey;
  late bool _isActive;
  late String _photoUrl;
  String _birthday = '';
  bool _isSubmitting = false;

  bool get _isCustomer => widget.partyType == PartyType.customer;

  @override
  void initState() {
    super.initState();
    final PartyFormData? initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _contactController = TextEditingController(text: initial?.contactPerson ?? '');
    _phoneController = TextEditingController(text: initial?.phone ?? '');
    _emailController = TextEditingController(text: initial?.email ?? '');
    _addressController = TextEditingController(text: initial?.address ?? '');
    _cityController = TextEditingController(text: initial?.city ?? '');
    _creditController = TextEditingController(
        text: (initial?.creditLimit ?? 0).toStringAsFixed(2));
    _openingController = TextEditingController(
        text: (initial?.openingBalance ?? 0).toStringAsFixed(2));
    _notesController = TextEditingController(text: initial?.notes ?? '');
    _typeKey = initial?.typeKey ?? widget.typeOptions.first.key;
    _isActive = initial?.isActive ?? true;
    _photoUrl = initial?.photoUrl ?? '';
    _birthday = initial?.birthday ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _creditController.dispose();
    _openingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    setState(() => _isSubmitting = true);
    final bool saved = await widget.onSubmit(PartyFormData(
      name: _nameController.text.trim(),
      typeKey: _typeKey,
      contactPerson: _contactController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      creditLimit: _isCustomer ? double.parse(_creditController.text.trim()) : 0,
      openingBalance: double.parse(_openingController.text.trim()),
      notes: _notesController.text.trim(),
      isActive: _isActive,
      photoUrl: _photoUrl,
      birthday: _isCustomer ? _birthday : '',
    ));
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    if (saved) {
      Navigator.of(context).pop();
    }
  }

  Widget _gap() => const SizedBox(height: 16);

  /// The birthday is only a day and a month: the picker is held to the leap year 2000, so 29 February can be chosen
  /// and no year is ever asked for.
  Widget _birthdayField(BuildContext context, {required bool enabled}) {
    final ({int month, int day})? b = parseBirthday(_birthday);
    final String text = b == null
        ? context.l10n.partyFormBirthdayNone
        : DateFormat.MMMd(Localizations.localeOf(context).toString()).format(DateTime(2000, b.month, b.day));
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: enabled
                ? () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000, b?.month ?? 1, b?.day ?? 1),
                      firstDate: DateTime(2000, 1, 1),
                      lastDate: DateTime(2000, 12, 31),
                      helpText: context.l10n.partyFormBirthday,
                    );
                    if (picked != null) {
                      setState(() => _birthday = birthdayKey(picked.month, picked.day));
                    }
                  }
                : null,
            icon: const Icon(Icons.cake_outlined, size: 18),
            label: Align(alignment: AlignmentDirectional.centerStart, child: Text('${context.l10n.partyFormBirthday}: $text')),
          ),
        ),
        if (b != null && enabled)
          IconButton(tooltip: context.l10n.partyFormBirthdayClear, icon: const Icon(Icons.close), onPressed: () => setState(() => _birthday = '')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.initial != null;
    final String noun = widget.partyType.label.toLowerCase();
    final bool locked = _isSubmitting;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? context.l10n.partyFormEdit(noun) : context.l10n.partyFormAdd(noun))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (widget.entityId != null)
                      PhotoEditor(
                        kind: _isCustomer ? PhotoKind.customer : PhotoKind.vendor,
                        entityId: widget.entityId!,
                        photoUrl: _photoUrl,
                        title: _isCustomer ? context.l10n.partyFormCustomerPhotoShopFront : context.l10n.partyFormVendorPhotoLogo,
                        enabled: !locked,
                        onChanged: (String url) => _photoUrl = url,
                      )
                    else
                      const PhotoAfterSaveHint(),
                    _gap(),
                    TextFormField(
                      controller: _nameController,
                      enabled: !locked,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: _isCustomer ? context.l10n.partyFormNameShopName : context.l10n.partyFormNameBusinessName,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (String? value) =>
                          (value == null || value.trim().isEmpty)
                              ? context.l10n.categoryFormNameIsRequired
                              : null,
                    ),
                    _gap(),
                    DropdownButtonFormField<String>(
                      value: _typeKey,
                      decoration: InputDecoration(
                        labelText: context.l10n.activityLogsType,
                        border: const OutlineInputBorder(),
                      ),
                      items: widget.typeOptions
                          .map((MapEntry<String, String> option) =>
                              DropdownMenuItem<String>(
                                value: option.key,
                                child: Text(option.value),
                              ))
                          .toList(),
                      onChanged: locked
                          ? null
                          : (String? value) {
                              if (value != null) {
                                setState(() => _typeKey = value);
                              }
                            },
                    ),
                    _gap(),
                    TextFormField(
                      controller: _contactController,
                      enabled: !locked,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: context.l10n.partyFormContactPersonOptional,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    _gap(),
                    TextFormField(
                      controller: _phoneController,
                      enabled: !locked,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: context.l10n.partyFormPhone,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (String? value) {
                        final String phone = value?.trim() ?? '';
                        if (phone.isNotEmpty &&
                            !RegExp(r'^[0-9+\-\s()]{6,20}$').hasMatch(phone)) {
                          return context.l10n.partyFormEnterAValidPhone;
                        }
                        return null;
                      },
                    ),
                    _gap(),
                    TextFormField(
                      controller: _emailController,
                      enabled: !locked,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: context.l10n.partyFormEmailOptional,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (String? value) {
                        final String email = value?.trim() ?? '';
                        if (email.isNotEmpty &&
                            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(email)) {
                          return context.l10n.authEmailInvalid;
                        }
                        return null;
                      },
                    ),
                    _gap(),
                    TextFormField(
                      controller: _addressController,
                      enabled: !locked,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: context.l10n.partyFormAddressOptional,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    _gap(),
                    TextFormField(
                      controller: _cityController,
                      enabled: !locked,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: context.l10n.partyFormCityOptional,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    if (_isCustomer) ...<Widget>[
                      _gap(),
                      _birthdayField(context, enabled: !locked),
                      _gap(),
                      TextFormField(
                        controller: _creditController,
                        enabled: !locked,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: context.l10n.partyFormCreditLimit,
                          helperText: context.l10n.partyForm0MeansNoLimit,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (String? value) {
                          final double? parsed =
                              double.tryParse((value ?? '').trim());
                          return (parsed == null || parsed < 0)
                              ? context.l10n.partyFormEnterAValidAmount
                              : null;
                        },
                      ),
                    ],
                    _gap(),
                    TextFormField(
                      controller: _openingController,
                      enabled: !locked,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: InputDecoration(
                        labelText: context.l10n.partyDetailOpeningBalance,
                        helperText: _isCustomer
                            ? context.l10n.partyFormPositiveTheCustomerOwes
                            : context.l10n.partyFormPositiveYouOweThe,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (String? value) =>
                          double.tryParse((value ?? '').trim()) == null
                              ? context.l10n.partyFormEnterAValidAmount
                              : null,
                    ),
                    _gap(),
                    TextFormField(
                      controller: _notesController,
                      enabled: !locked,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: context.l10n.partyFormNotesOptional,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.categoryFormActive),
                      subtitle: Text(context.l10n.partyFormInactivePartiesAreHidden),
                      value: _isActive,
                      onChanged: locked
                          ? null
                          : (bool value) => setState(() => _isActive = value),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: locked ? null : _submit,
                      child: locked
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEdit ? context.l10n.categoryFormSaveChanges : context.l10n.partyFormCreate(noun)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
