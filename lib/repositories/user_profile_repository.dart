import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/models/user_profile_model.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';
import 'package:mq_sports_erp/services/firestore_service.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';

/// Repository for user profiles. Profiles are looked up per Firebase uid
/// instead of being bulk-synced, so a device only ever stores profiles of
/// users who signed in on it.
class UserProfileRepository extends BaseRepository<UserProfileModel> {
  UserProfileRepository({
    required HiveLocalRepository<UserProfileModel> local,
    required FirestoreService remote,
  })  : _local = local,
        _remote = remote,
        super(
          collectionName: StorageKeys.userProfiles,
          local: local,
          remote: remote,
          fromMap: UserProfileModel.fromMap,
        );

  final HiveLocalRepository<UserProfileModel> _local;
  final FirestoreService _remote;

  Future<UserProfileModel?> findLocalByAuthUid(String authUid) async {
    final List<UserProfileModel> all = await _local.getAll();
    for (final UserProfileModel profile in all) {
      if (profile.authUid == authUid) {
        return profile;
      }
    }
    return null;
  }

  Future<UserProfileModel?> fetchRemoteByAuthUid(String authUid) async {
    final List<Map<String, dynamic>> maps = await _remote.fetchWhereEquals(
      StorageKeys.userProfiles,
      'authUid',
      authUid,
    );
    if (maps.isEmpty) {
      return null;
    }
    return UserProfileModel.fromMap(maps.first);
  }

  Future<void> storeLocal(UserProfileModel profile) => _local.put(profile);
}
