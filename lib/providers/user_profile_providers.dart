import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/models/user_profile_model.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/providers/data_mode.dart';
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
  );
});

/// Personal profile of the signed-in user (null when signed out). It is
/// created from the Firebase account on first login and refreshed on each
/// login. It lives only in Hive and is never sent to Firestore.
class CurrentUserProfileNotifier extends AsyncNotifier<UserProfileModel?> {
  @override
  Future<UserProfileModel?> build() async {
    final String? uid = await ref.watch(authUidProvider.future);
    if (uid == null || ref.watch(dataModeProvider).isOnline) {
      return null;
    }
    final AuthUserData? authUser = ref.read(authServiceProvider).currentUser;
    if (authUser == null || authUser.uid != uid) {
      return null;
    }
    final UserProfileRepository repository =
        ref.read(userProfileRepositoryProvider);
    final UserProfileModel? existing = await repository.findByAuthUid(uid);
    final UserProfileModel profile = existing == null
        ? UserProfileModel(
            authUid: authUser.uid,
            email: authUser.email,
            displayName: authUser.displayName,
            phoneNumber: authUser.phoneNumber,
            photoUrl: authUser.photoUrl,
          )
        : existing.copyWith(
            email: authUser.email,
            displayName: authUser.displayName,
            phoneNumber: authUser.phoneNumber,
            photoUrl: authUser.photoUrl,
            lastLoginAt: DateTime.now(),
          );
    await repository.save(profile);
    return profile;
  }
}

final AsyncNotifierProvider<CurrentUserProfileNotifier, UserProfileModel?>
    currentUserProfileProvider =
    AsyncNotifierProvider<CurrentUserProfileNotifier, UserProfileModel?>(
  CurrentUserProfileNotifier.new,
);
