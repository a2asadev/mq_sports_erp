import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';
import 'package:mq_sports_erp/services/firestore_service.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';

class UserRepository extends BaseRepository<UserModel> {
  UserRepository({
    required HiveLocalRepository<UserModel> local,
    required FirestoreService remote,
  })  : _local = local,
        _remote = remote,
        super(
          collectionName: StorageKeys.users,
          local: local,
          remote: remote,
          fromMap: UserModel.fromMap,
        );

  final HiveLocalRepository<UserModel> _local;
  final FirestoreService _remote;

  Future<UserModel?> fetchRemote(String id) async {
    final Map<String, dynamic>? map =
        await _remote.fetchById(StorageKeys.users, id);
    return map == null ? null : UserModel.fromMap(map);
  }

  Future<void> storeLocal(UserModel user) => _local.put(user);

  Future<void> deleteLocal(String id) => _local.delete(id);

  /// Admin-side full sync. Besides adding and updating records, it removes
  /// local users that no longer exist in the cloud (deleted by an admin).
  @override
  Future<void> syncFromCloud() async {
    final List<Map<String, dynamic>> maps =
        await _remote.fetchAll(StorageKeys.users);
    final List<UserModel> remoteUsers =
        maps.map(UserModel.fromMap).toList();
    final List<UserModel> localUsers = await _local.getAll();
    final Map<String, UserModel> localById = <String, UserModel>{
      for (final UserModel user in localUsers) user.id: user,
    };
    final Set<String> remoteIds = <String>{
      for (final UserModel user in remoteUsers) user.id,
    };
    final List<UserModel> toStore = <UserModel>[];
    for (final UserModel remoteUser in remoteUsers) {
      final UserModel? localUser = localById[remoteUser.id];
      if (localUser == null ||
          remoteUser.updatedAt.isAfter(localUser.updatedAt)) {
        toStore.add(remoteUser);
      }
    }
    await _local.putAll(toStore);
    for (final UserModel localUser in localUsers) {
      if (!remoteIds.contains(localUser.id)) {
        await _local.delete(localUser.id);
      }
    }
  }
}
