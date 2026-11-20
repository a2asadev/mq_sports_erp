import 'package:flutter/material.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/widgets/photo_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/page_stats.dart';
import 'package:a2_stocks/widgets/stat_strip.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/providers/users_providers.dart';
import 'package:a2_stocks/screens/users/user_form_screen.dart';

enum _UserAction { edit, toggleActive, delete }

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  String _errorText(Object error) {
    return error is AppException ? error.message : L10n.current.commonSomethingWentWrong;
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
          title: Text(context.l10n.usersDeleteUser),
          content: Text(
            context.l10n.usersDeleteUserMessage(user.displayName.isNotEmpty ? user.displayName : user.email),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.categoriesCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.l10n.categoriesDelete),
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
      body = Center(child: Text(context.l10n.usersNoUsersYet));
    } else {
      final List<UserModel> users = <UserModel>[...loaded]..sort(
          (UserModel a, UserModel b) => (a.displayName.isNotEmpty
                  ? a.displayName
                  : a.email)
              .toLowerCase()
              .compareTo((b.displayName.isNotEmpty ? b.displayName : b.email)
                  .toLowerCase()),
        );
      final UserStats stats = computeUserStats(loaded);
      final Widget list = ListView.separated(
        itemCount: users.length,
        separatorBuilder: (BuildContext context, int index) =>
            const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          final UserModel user = users[index];
          final bool isSelf = user.id == myId;
          final String name =
              user.displayName.isNotEmpty ? user.displayName : user.email;
          return ListTile(
            leading: PhotoAvatar(url: user.photoUrl, label: name),
            title: Text(isSelf ? context.l10n.usersYou(name) : name),
            subtitle: Text('${user.email}\n${user.role.label}'),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (!user.isActive)
                  Chip(
                    label: Text(context.l10n.productsInactive),
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
                    PopupMenuItem<_UserAction>(
                      value: _UserAction.edit,
                      child: Text(context.l10n.categoriesEdit),
                    ),
                    if (!isSelf)
                      PopupMenuItem<_UserAction>(
                        value: _UserAction.toggleActive,
                        child: Text(user.isActive ? context.l10n.usersDeactivate : context.l10n.usersActivate),
                      ),
                    if (!isSelf)
                      PopupMenuItem<_UserAction>(
                        value: _UserAction.delete,
                        child: Text(context.l10n.categoriesDelete),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      );
      body = Column(
        children: <Widget>[
          StatStrip(
            items: <StatItem>[
              StatItem(
                icon: Icons.people_alt_outlined,
                color: AppColors.primary,
                label: context.l10n.usersUsers,
                value: '${stats.total}',
              ),
              StatItem(
                icon: Icons.check_circle_outline,
                color: AppColors.teal,
                label: context.l10n.categoryFormActive,
                value: '${stats.active}',
                caption: stats.total > stats.active ? context.l10n.usersTurnedOff(stats.total - stats.active) : '',
              ),
              StatItem(
                icon: Icons.admin_panel_settings_outlined,
                color: AppColors.navy,
                label: context.l10n.usersAdmins,
                value: '${stats.admins}',
              ),
              StatItem(
                icon: Icons.badge_outlined,
                color: AppColors.sky,
                label: context.l10n.usersManagersStaff,
                value: '${stats.managers + stats.staff}',
                caption: context.l10n.usersManagerSStaff(stats.managers, stats.staff),
              ),
            ],
          ),
          Expanded(child: list),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.usersUsers)),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const UserFormScreen(),
          ),
        ),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(context.l10n.usersAddUser),
      ),
    );
  }
}
