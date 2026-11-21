import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/permissions.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/providers/data_mode.dart';
import 'package:a2_stocks/providers/sync_controller.dart';
import 'package:a2_stocks/providers/users_providers.dart';

/// How often a signed-in device asks the server what its person may do now.
const Duration permissionCheckInterval = Duration(minutes: 5);

bool _sameList(List<String>? a, List<String>? b) {
  if (a == null || b == null) {
    return a == b;
  }
  return a.length == b.length && a.toSet().containsAll(b);
}

/// Asks the server what the signed-in person may do now. When it changed, the screens follow at once; when the
/// change opens or closes records the server sends to the device (vendors and purchases, stock audits), the device
/// downloads everything again, because it never received the older records it was not allowed to have.
/// Returns whether the permissions changed.
Future<bool> refreshPermissions(Ref ref) async {
  final UserModel? before = ref.read(currentUserProvider).valueOrNull;
  if (before == null) {
    return false;
  }
  final UserModel? after = await ref.read(apiAuthServiceProvider).fetchCurrentUser();
  if (after == null || _sameList(before.permissions, after.permissions)) {
    return false;
  }
  ref.invalidate(currentUserProvider);
  if (Permissions.affectSync.any((String key) => before.can(key) != after.can(key))) {
    if (ref.read(dataModeProvider).isOnline) {
      await ref.read(remoteStoreProvider).reloadAll();
    } else {
      await ref.read(syncControllerProvider.notifier).downloadEverythingAgain();
    }
  }
  return true;
}

/// Keeps the permissions fresh while the app is open (watched by the signed-in shell).
final Provider<void> permissionRefreshProvider = Provider<void>((Ref ref) {
  bool disposed = false;
  final Timer timer = Timer.periodic(permissionCheckInterval, (Timer _) {
    if (!disposed) {
      unawaited(refreshPermissions(ref).catchError((Object _) => false));
    }
  });
  ref.onDispose(() {
    disposed = true;
    timer.cancel();
  });
});
