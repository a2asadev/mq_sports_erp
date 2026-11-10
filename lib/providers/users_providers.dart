import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/user_role.dart';
import 'package:mq_sports_erp/providers/base_list_notifier.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/repositories/user_repository.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';

final Provider<UserRepository> userRepositoryProvider =
    Provider<UserRepository>((Ref ref) {
  return UserRepository(
    local: HiveLocalRepository<UserModel>(
      boxName: StorageKeys.users,
      fromMap: UserModel.fromMap,
    ),
    remote: ref.watch(firestoreServiceProvider),
    pendingStore: ref.watch(pendingChangeStoreProvider),
    resolveCurrentUser: () => ref.read(currentUserProvider.future),
  );
});

/// The `users` record of the signed-in login: it carries the role and the
/// active flag. Null when signed out or when the login has no user record.
///
/// Read from Hive. Only when this device has no copy yet (first login) is it
/// downloaded once; after that it changes only through a sync.
class CurrentUserNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final String? uid = await ref.watch(authUidProvider.future);
    if (uid == null) {
      return null;
    }
    final UserRepository repository = ref.read(userRepositoryProvider);
    final UserModel? local = await repository.getLocalById(uid);
    if (local != null) {
      return local;
    }
    final UserModel? remote = await repository.fetchRemote(uid);
    if (remote != null) {
      await repository.storeLocal(remote);
    }
    return remote;
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
  UserRepository get repository => ref.read(userRepositoryProvider);

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
      return _fail(const PermissionDeniedException(
          'Only an active admin can add users.'));
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
      return _fail(const PermissionDeniedException(
          'Only an active admin can update users.'));
    }
    final UserModel? existing = _find(updated.id);
    if (existing != null &&
        existing.id == actor.id &&
        (existing.role != updated.role ||
            existing.isActive != updated.isActive)) {
      return _fail(const PermissionDeniedException(
          'You cannot change your own role or active status.'));
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
      return _fail(const PermissionDeniedException('User not found.'));
    }
    return updateUser(existing.copyWith(isActive: isActive));
  }

  /// Removes the user record, which revokes the user's access to the app.
  Future<bool> deleteUser(String id) async {
    final UserModel? actor = _activeAdmin();
    if (actor == null) {
      return _fail(const PermissionDeniedException(
          'Only an active admin can delete users.'));
    }
    if (actor.id == id) {
      return _fail(
          const PermissionDeniedException('You cannot delete your own account.'));
    }
    await remove(id);
    return !state.hasError;
  }
}

final AsyncNotifierProvider<UsersNotifier, List<UserModel>> usersProvider =
    AsyncNotifierProvider<UsersNotifier, List<UserModel>>(UsersNotifier.new);
