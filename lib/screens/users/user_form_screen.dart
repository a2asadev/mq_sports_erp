import 'package:flutter/material.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/online/photo_service.dart';
import 'package:a2_stocks/widgets/photo_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/providers/users_providers.dart';

/// Add-user form (when [user] is null) or edit form for an existing user.
class UserFormScreen extends ConsumerStatefulWidget {
  const UserFormScreen({super.key, this.user});

  final UserModel? user;

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final TextEditingController _passwordController = TextEditingController();
  late UserRole _role;
  late bool _isActive;
  late String _photoUrl;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final UserModel? existing = widget.user;
    _nameController = TextEditingController(text: existing?.displayName ?? '');
    _emailController = TextEditingController(text: existing?.email ?? '');
    _phoneController = TextEditingController(text: existing?.phoneNumber ?? '');
    _role = existing?.role ?? UserRole.staff;
    _isActive = existing?.isActive ?? true;
    _photoUrl = existing?.photoUrl ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    setState(() => _isSubmitting = true);
    final UsersNotifier notifier = ref.read(usersProvider.notifier);
    final UserModel? existing = widget.user;
    final String name = _nameController.text.trim();
    final String phone = _phoneController.text.trim();
    final bool succeeded = existing == null
        ? await notifier.createUser(
            email: _emailController.text.trim().toLowerCase(),
            password: _passwordController.text,
            displayName: name,
            phoneNumber: phone,
            role: _role,
          )
        : await notifier.updateUser(existing.copyWith(
            displayName: name,
            phoneNumber: phone,
            role: _role,
            isActive: _isActive,
            photoUrl: _photoUrl,
          ));
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    if (succeeded) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? existing = widget.user;
    final bool isEdit = existing != null;
    final String? myId = ref.watch(currentUserProvider).valueOrNull?.id;
    final bool isSelf = existing != null && existing.id == myId;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? context.l10n.userFormEditUser : context.l10n.usersAddUser)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (existing != null)
                      PhotoEditor(
                        kind: PhotoKind.user,
                        entityId: existing.id,
                        photoUrl: _photoUrl,
                        title: context.l10n.userFormProfilePhoto,
                        enabled: !_isSubmitting,
                        onChanged: (String url) => _photoUrl = url,
                      )
                    else
                      const PhotoAfterSaveHint(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      enabled: !_isSubmitting,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: context.l10n.userFormFullName,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (String? value) =>
                          (value == null || value.trim().isEmpty)
                              ? context.l10n.categoryFormNameIsRequired
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      enabled: !_isSubmitting && !isEdit,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: context.l10n.userFormEmailLogin,
                        helperText:
                            isEdit ? context.l10n.userFormTheLoginEmailCannot : null,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (String? value) {
                        final String email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return context.l10n.authEmailRequired;
                        }
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(email)) {
                          return context.l10n.authEmailInvalid;
                        }
                        return null;
                      },
                    ),
                    if (!isEdit) ...<Widget>[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        enabled: !_isSubmitting,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: context.l10n.userFormInitialPassword,
                          helperText:
                              context.l10n.userFormShareItWithThe,
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? context.l10n.authShowPassword
                                : context.l10n.authHidePassword,
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (String? value) =>
                            (value == null || value.length < 6)
                                ? context.l10n.userFormUseAtLeast6
                                : null,
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      enabled: !_isSubmitting,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: context.l10n.userFormPhoneOptional,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<UserRole>(
                      value: _role,
                      decoration: InputDecoration(
                        labelText: context.l10n.userFormRole,
                        helperText: isSelf
                            ? context.l10n.userFormYouCannotChangeYour
                            : null,
                        border: const OutlineInputBorder(),
                      ),
                      items: UserRole.values
                          .map((UserRole role) => DropdownMenuItem<UserRole>(
                                value: role,
                                child: Text(role.label),
                              ))
                          .toList(),
                      onChanged: (_isSubmitting || isSelf)
                          ? null
                          : (UserRole? value) {
                              if (value != null) {
                                setState(() => _role = value);
                              }
                            },
                    ),
                    if (isEdit) ...<Widget>[
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: Text(context.l10n.categoryFormActive),
                        subtitle: Text(isSelf
                            ? context.l10n.userFormYouCannotDeactivateYourself
                            : context.l10n.userFormInactiveUsersCannotUse),
                        value: _isActive,
                        onChanged: (_isSubmitting || isSelf)
                            ? null
                            : (bool value) => setState(() => _isActive = value),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEdit ? context.l10n.categoryFormSaveChanges : context.l10n.userFormCreateUser),
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
