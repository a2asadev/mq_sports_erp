import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';
import 'package:mq_sports_erp/screens/users/user_form_screen.dart';

enum _UserAction { edit, toggleActive, delete }

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  String _errorText(Object error) {
    return error is AppException ? error.message : 'Something went wrong.';
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete user'),
          content: Text(
            'Delete ${user.displayName.isNotEmpty ? user.displayName : user.email}? '
            'They will lose access to the app immediately. Their login '
            'remains in Firebase Authentication but cannot open the app. '
            'To block access but keep the record, deactivate the user instead.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await ref.read(usersProvider.notifier).deleteUser(user.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<UserModel>> usersAsync = ref.watch(usersProvider);
    final String? myId = ref.watch(currentUserProvider).valueOrNull?.id;

    ref.listen<AsyncValue<List<UserModel>>>(usersProvider,
        (AsyncValue<List<UserModel>>? previous, AsyncValue<List<UserModel>> next) {
      final Object? error = next.error;
      if (error != null && !identical(error, previous?.error)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_errorText(error))));
      }
    });

    final List<UserModel>? loaded = usersAsync.valueOrNull;
    Widget body;
    if (loaded == null) {
      final Object? error = usersAsync.error;
      body = Center(
        child: error != null
            ? Text(_errorText(error))
            : const CircularProgressIndicator(),
      );
    } else if (loaded.isEmpty) {
      body = const Center(child: Text('No users yet.'));
    } else {
      final List<UserModel> users = <UserModel>[...loaded]..sort(
          (UserModel a, UserModel b) => (a.displayName.isNotEmpty
                  ? a.displayName
                  : a.email)
              .toLowerCase()
              .compareTo((b.displayName.isNotEmpty ? b.displayName : b.email)
                  .toLowerCase()),
        );
      body = ListView.separated(
        itemCount: users.length,
        separatorBuilder: (BuildContext context, int index) =>
            const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          final UserModel user = users[index];
          final bool isSelf = user.id == myId;
          final String name =
              user.displayName.isNotEmpty ? user.displayName : user.email;
          return ListTile(
            leading: CircleAvatar(
              child: Text(name.isEmpty ? '?' : name.substring(0, 1).toUpperCase()),
            ),
            title: Text(isSelf ? '$name (you)' : name),
            subtitle: Text('${user.email}\n${user.role.label}'),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (!user.isActive)
                  const Chip(
                    label: Text('Inactive'),
                    visualDensity: VisualDensity.compact,
                  ),
                PopupMenuButton<_UserAction>(
                  onSelected: (_UserAction action) async {
                    switch (action) {
                      case _UserAction.edit:
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                UserFormScreen(user: user),
                          ),
                        );
                      case _UserAction.toggleActive:
                        await ref.read(usersProvider.notifier).setActive(
                              user.id,
                              isActive: !user.isActive,
                            );
                      case _UserAction.delete:
                        await _confirmDelete(context, ref, user);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<_UserAction>>[
                    const PopupMenuItem<_UserAction>(
                      value: _UserAction.edit,
                      child: Text('Edit'),
                    ),
                    if (!isSelf)
                      PopupMenuItem<_UserAction>(
                        value: _UserAction.toggleActive,
                        child: Text(user.isActive ? 'Deactivate' : 'Activate'),
                      ),
                    if (!isSelf)
                      const PopupMenuItem<_UserAction>(
                        value: _UserAction.delete,
                        child: Text('Delete'),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const UserFormScreen(),
          ),
        ),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add user'),
      ),
    );
  }
}
