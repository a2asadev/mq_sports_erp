import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/user_role.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';

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
    final bool isSelf = isEdit && existing.id == myId;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit user' : 'Add user')),
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
                    TextFormField(
                      controller: _nameController,
                      enabled: !_isSubmitting,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (String? value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Name is required.'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      enabled: !_isSubmitting && !isEdit,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Email (login)',
                        helperText:
                            isEdit ? 'The login email cannot be changed.' : null,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (String? value) {
                        final String email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return 'Email is required.';
                        }
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(email)) {
                          return 'Enter a valid email address.';
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
                          labelText: 'Initial password',
                          helperText:
                              'Share it with the user so they can sign in.',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (String? value) =>
                            (value == null || value.length < 6)
                                ? 'Use at least 6 characters.'
                                : null,
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      enabled: !_isSubmitting,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Phone (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<UserRole>(
                      value: _role,
                      decoration: InputDecoration(
                        labelText: 'Role',
                        helperText: isSelf
                            ? 'You cannot change your own role.'
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
                        title: const Text('Active'),
                        subtitle: Text(isSelf
                            ? 'You cannot deactivate yourself.'
                            : 'Inactive users cannot use the app.'),
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
                          : Text(isEdit ? 'Save changes' : 'Create user'),
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
