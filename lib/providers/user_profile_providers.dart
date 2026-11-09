import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/user_profile_model.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/repositories/user_profile_repository.dart';
import 'package:mq_sports_erp/services/auth_service.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';

final Provider<UserProfileRepository> userProfileRepositoryProvider =
    Provider<UserProfileRepository>((Ref ref) {
  return UserProfileRepository(
    local: HiveLocalRepository<UserProfileModel>(
      boxName: StorageKeys.userProfiles,
      fromMap: UserProfileModel.fromMap,
    ),
    remote: ref.watch(firestoreServiceProvider),
  );
});

/// Profile of the signed-in user (null when signed out).
///
/// - Returns the Hive copy instantly when one exists.
/// - Otherwise loads the profile from Firestore, or creates it from the
///   Firebase account data on the user's first login.
/// - In the background it pulls a newer cloud copy and records the login
///   (`lastLoginAt`, plus email/name/phone/photo from the Firebase account).
class CurrentUserProfileNotifier extends AsyncNotifier<UserProfileModel?> {
  int _generation = 0;

  @override
  Future<UserProfileModel?> build() async {
    ref.onDispose(() => _generation++);
    final int generation = _generation;
    final String? uid = await ref.watch(authUidProvider.future);
    if (uid == null) {
      return null;
    }
    final UserProfileRepository repository =
        ref.read(userProfileRepositoryProvider);
    final UserProfileModel? local = await repository.findLocalByAuthUid(uid);
    if (local != null) {
      unawaited(_refresh(generation, uid, local));
      return local;
    }
    return _loadOrCreate(uid, repository);
  }

  Future<UserProfileModel?> _loadOrCreate(
    String uid,
    UserProfileRepository repository,
  ) async {
    final AuthUserData? authUser = ref.read(authServiceProvider).currentUser;
    if (authUser == null || authUser.uid != uid) {
      return null;
    }
    final UserProfileModel? remote = await repository.fetchRemoteByAuthUid(uid);
    if (remote != null) {
      await repository.storeLocal(remote);
      return remote;
    }
    final UserProfileModel created = UserProfileModel(
      authUid: authUser.uid,
      email: authUser.email,
      displayName: authUser.displayName,
      phoneNumber: authUser.phoneNumber,
      photoUrl: authUser.photoUrl,
    );
    await repository.save(created);
    return created;
  }

  Future<void> _refresh(
    int generation,
    String uid,
    UserProfileModel current,
  ) async {
    UserProfileModel latest = current;
    try {
      final UserProfileRepository repository =
          ref.read(userProfileRepositoryProvider);
      final UserProfileModel? remote =
          await repository.fetchRemoteByAuthUid(uid);
      if (generation != _generation) {
        return;
      }
      if (remote != null && remote.updatedAt.isAfter(latest.updatedAt)) {
        await repository.storeLocal(remote);
        latest = remote;
      }
      final AuthUserData? authUser = ref.read(authServiceProvider).currentUser;
      if (authUser == null || authUser.uid != uid) {
        return;
      }
      final UserProfileModel updated = latest.copyWith(
        email: authUser.email,
        displayName: authUser.displayName,
        phoneNumber: authUser.phoneNumber,
        photoUrl: authUser.photoUrl,
        lastLoginAt: DateTime.now(),
      );
      state = AsyncData<UserProfileModel?>(updated);
      await repository.save(updated);
    } on AppException {
      // Background refresh must never disturb the UI: fall back to the last
      // good copy (the repository already reverted the failed local write).
      if (generation == _generation) {
        state = AsyncData<UserProfileModel?>(latest);
      }
    }
  }
}

final AsyncNotifierProvider<CurrentUserProfileNotifier, UserProfileModel?>
    currentUserProfileProvider =
    AsyncNotifierProvider<CurrentUserProfileNotifier, UserProfileModel?>(
  CurrentUserProfileNotifier.new,
);
