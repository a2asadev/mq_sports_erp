import 'package:mq_sports_erp/models/user_profile_model.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';

/// Personal profile of the signed-in user. Stored only on this device: it is
/// never uploaded, so it costs no Firestore calls.
class UserProfileRepository {
  UserProfileRepository({required HiveLocalRepository<UserProfileModel> local})
      : _local = local;

  final HiveLocalRepository<UserProfileModel> _local;

  Future<UserProfileModel?> findByAuthUid(String authUid) async {
    final List<UserProfileModel> all = await _local.getAll();
    for (final UserProfileModel profile in all) {
      if (profile.authUid == authUid) {
        return profile;
      }
    }
    return null;
  }

  Future<void> save(UserProfileModel profile) => _local.put(profile);
}
