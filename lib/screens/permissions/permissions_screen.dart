import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/permission_text.dart';
import 'package:a2_stocks/online/permissions_service.dart';
import 'package:a2_stocks/providers/permission_providers.dart';
import 'package:a2_stocks/providers/users_providers.dart';

/// What managers and staff may do: one switch per role and capability. An admin can always do everything. A change
/// counts at once on the server and reaches each person's device the next time it checks (within minutes).
/// Admin only; needs a connection.
class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  String _busy = '';

  Future<void> _set(String role, String key, bool allowed) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = '$role:$key');
    try {
      await ref.read(permissionsServiceProvider).set(role, key, allowed);
      ref.invalidate(permissionMatrixProvider);
      await ref.read(permissionMatrixProvider.future);
      // The admin's own list of modules may change too (it never does for an admin, but the call is cheap).
      ref.invalidate(currentUserProvider);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
    } finally {
      if (mounted) {
        setState(() => _busy = '');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<PermissionMatrix> matrix = ref.watch(permissionMatrixProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.modulePermissions),
        actions: <Widget>[IconButton(tooltip: l10n.registerRefresh, icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(permissionMatrixProvider))],
      ),
      body: matrix.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(errorMessageOf(error), textAlign: TextAlign.center))),
        data: (PermissionMatrix m) => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(l10n.permissionsIntro, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                const Expanded(child: SizedBox()),
                SizedBox(width: 84, child: Text(l10n.permissionsManagers, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700))),
                SizedBox(width: 84, child: Text(l10n.permissionsStaff, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700))),
              ],
            ),
            for (final PermissionInfo info in m.permissions) ...<Widget>[
              const Divider(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(permissionTitle(l10n, info.key), style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(permissionHint(l10n, info.key), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  for (final String role in const <String>['manager', 'staff'])
                    SizedBox(
                      width: 84,
                      child: Column(
                        children: <Widget>[
                          Switch(
                            key: ValueKey<String>('$role:${info.key}'),
                            value: m.allowed(role, info.key),
                            onChanged: _busy.isNotEmpty ? null : (bool on) => _set(role, info.key, on),
                          ),
                          if (!m.isDefault(role, info)) Text(l10n.permissionsChanged, style: const TextStyle(fontSize: 10, color: AppColors.amber)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Text(l10n.permissionsNote, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
