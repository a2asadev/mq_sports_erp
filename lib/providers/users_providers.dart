import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/data/local_repositories.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/providers/local_data_providers.dart';
import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/providers/base_list_notifier.dart';
import 'package:a2_stocks/providers/core_providers.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/online_repositories.dart';
import 'package:a2_stocks/providers/data_mode.dart';
import 'package:a2_stocks/repositories/repository.dart';


/// Users: from the API on the web, from the device elsewhere.
final Provider<Repository<UserModel>> userRepositoryProvider =
    Provider<Repository<UserModel>>((Ref ref) {
  if (ref.watch(dataModeProvider).isOnline) {
    return OnlineUserRepository(
      ref.watch(apiClientProvider),
      ref.watch(remoteStoreProvider),
    );
  }
  return LocalUserRepository(
    collection: ref.watch(localCollectionsProvider).users,
    outbox: ref.watch(outboxStoreProvider),
  );
});

/// The record of the signed-in login: it carries the role and the active flag.
/// Null when signed out.
///
/// The server's answer when it can be reached; without a connection, the record
/// saved at the last sign-in, so the app opens and works offline.
class CurrentUserNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final String? uid = await ref.watch(authUidProvider.future);
    if (uid == null) {
      return null;
    }
    return ref.read(apiAuthServiceProvider).fetchCurrentUser();
  }
}

final AsyncNotifierProvider<CurrentUserNotifier, UserModel?>
    currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, UserModel?>(
  CurrentUserNotifier.new,
);

/// Admin-only user management. Every action re-checks that the signed-in
/// user is an active admin (Firestore rules enforce the same on the server).
class UsersNotifier extends BaseListNotifier<UserModel> {
  @override
  Repository<UserModel> get repository => ref.read(userRepositoryProvider);

  UserModel? _activeAdmin() {
    final UserModel? actor = ref.read(currentUserProvider).valueOrNull;
    if (actor != null && actor.isActive && actor.role == UserRole.admin) {
      return actor;
    }
    return null;
  }

  UserModel? _find(String id) {
    final List<UserModel> users = state.valueOrNull ?? <UserModel>[];
    return users.where((UserModel user) => user.id == id).firstOrNull;
  }

  bool _fail(AppException error) {
    final List<UserModel> previous = state.valueOrNull ?? <UserModel>[];
    state = AsyncValue<List<UserModel>>.error(error, StackTrace.current)
        .copyWithPrevious(AsyncData<List<UserModel>>(previous));
    return false;
  }

  /// Creates the Firebase Authentication login and the Firestore user record.
  /// Returns true on success.
  Future<bool> createUser({
    required String email,
    required String password,
    required String displayName,
    required String phoneNumber,
    required UserRole role,
  }) async {
    if (_activeAdmin() == null) {
      return _fail(PermissionDeniedException(
          L10n.current.usersOnlyAnActiveAdmin3));
    }
    final List<UserModel> previous = state.valueOrNull ?? <UserModel>[];
    try {
      await ref.read(authAdminServiceProvider).createAccount(
        email: email,
        password: password,
        displayName: displayName,
        onCreated: (String uid) async {
          final UserModel user = UserModel(
            id: uid,
            email: email,
            displayName: displayName,
            phoneNumber: phoneNumber,
            role: role,
          );
          state = AsyncData<List<UserModel>>(<UserModel>[...previous, user]);
          await repository.save(user);
        },
      );
      return true;
    } on AppException catch (e, st) {
      state = AsyncValue<List<UserModel>>.error(e, st)
          .copyWithPrevious(AsyncData<List<UserModel>>(previous));
      return false;
    }
  }

  /// Updates name, phone, role and active flag. Admins cannot change their
  /// own role or active status, so the system always keeps an active admin.
  Future<bool> updateUser(UserModel updated) async {
    final UserModel? actor = _activeAdmin();
    if (actor == null) {
      return _fail(PermissionDeniedException(
          L10n.current.usersOnlyAnActiveAdmin2));
    }
    final UserModel? existing = _find(updated.id);
    if (existing != null &&
        existing.id == actor.id &&
        (existing.role != updated.role ||
            existing.isActive != updated.isActive)) {
      return _fail(PermissionDeniedException(
          L10n.current.usersYouCannotChangeYour));
    }
    await updateItem(updated);
    final bool succeeded = !state.hasError;
    if (succeeded && updated.id == actor.id) {
      ref.invalidate(currentUserProvider);
    }
    return succeeded;
  }

  Future<bool> setActive(String id, {required bool isActive}) async {
    final UserModel? existing = _find(id);
    if (existing == null) {
      return _fail(PermissionDeniedException(L10n.current.usersUserNotFound));
    }
    return updateUser(existing.copyWith(isActive: isActive));
  }

  /// Removes the user record, which revokes the user's access to the app.
  Future<bool> deleteUser(String id) async {
    final UserModel? actor = _activeAdmin();
    if (actor == null) {
      return _fail(PermissionDeniedException(
          L10n.current.usersOnlyAnActiveAdmin));
    }
    if (actor.id == id) {
      return _fail(
          PermissionDeniedException(L10n.current.usersYouCannotDeleteYour));
    }
    await remove(id);
    return !state.hasError;
  }
}

final AsyncNotifierProvider<UsersNotifier, List<UserModel>> usersProvider =
    AsyncNotifierProvider<UsersNotifier, List<UserModel>>(UsersNotifier.new);
