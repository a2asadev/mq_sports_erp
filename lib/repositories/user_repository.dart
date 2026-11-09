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
}
