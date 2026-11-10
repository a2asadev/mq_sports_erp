import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/user_role.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';
import 'package:mq_sports_erp/services/firestore_service.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';
import 'package:mq_sports_erp/services/pending_change_store.dart';

class UserRepository extends BaseRepository<UserModel> {
  UserRepository({
    required HiveLocalRepository<UserModel> local,
    required FirestoreService remote,
    required PendingChangeStore pendingStore,
    required Future<UserModel?> Function() resolveCurrentUser,
  })  : _local = local,
        _remote = remote,
        _resolveCurrentUser = resolveCurrentUser,
        super(
          collectionName: StorageKeys.users,
          entityLabel: 'User',
          local: local,
          pendingStore: pendingStore,
          fromMap: UserModel.fromMap,
          labelOf: (UserModel user) =>
              user.displayName.isNotEmpty ? user.displayName : user.email,
        );

  final HiveLocalRepository<UserModel> _local;
  final FirestoreService _remote;
  final Future<UserModel?> Function() _resolveCurrentUser;

  /// Used once, at login, when this device has no copy of the user's own
  /// record yet.
  Future<UserModel?> fetchRemote(String id) async {
    final Map<String, dynamic>? map =
        await _remote.fetchById(StorageKeys.users, id);
    return map == null ? null : UserModel.fromMap(map);
  }

  Future<void> storeLocal(UserModel user) => _local.put(user);

  /// Admins download every user; everyone else only their own record, as the
  /// Firestore rules only allow that.
  @override
  Future<RemotePull> pullFromCloud(FirestoreService remote) async {
    final UserModel? current = await _resolveCurrentUser();
    if (current == null) {
      return const RemotePull(<Map<String, dynamic>>[], isFullSnapshot: false);
    }
    if (current.isActive && current.role == UserRole.admin) {
      return super.pullFromCloud(remote);
    }
    final Map<String, dynamic>? own =
        await remote.fetchById(StorageKeys.users, current.id);
    return RemotePull(
      own == null ? <Map<String, dynamic>>[] : <Map<String, dynamic>>[own],
      isFullSnapshot: false,
    );
  }
}
