import 'package:a2_stocks/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:a2_stocks/core/utils/branch_rules.dart';
import 'package:a2_stocks/data/local_repositories.dart';
import 'package:a2_stocks/models/branch_model.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/online/branches_service.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/online_repositories.dart';
import 'package:a2_stocks/providers/base_list_notifier.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/providers/data_mode.dart';
import 'package:a2_stocks/providers/local_data_providers.dart';
import 'package:a2_stocks/providers/users_providers.dart';
import 'package:a2_stocks/repositories/repository.dart';

final Provider<Repository<BranchModel>> branchRepositoryProvider = Provider<Repository<BranchModel>>((Ref ref) {
  if (ref.watch(dataModeProvider).isOnline) {
    return OnlineBranchRepository(ref.watch(apiClientProvider), ref.watch(remoteStoreProvider));
  }
  return LocalBranchRepository(collection: ref.watch(localCollectionsProvider).branches, outbox: ref.watch(outboxStoreProvider));
});

/// Read-only list of the business's branches (an admin changes them with [branchesServiceProvider]).
class BranchesNotifier extends BaseListNotifier<BranchModel> {
  @override
  Repository<BranchModel> get repository => ref.read(branchRepositoryProvider);
}

final AsyncNotifierProvider<BranchesNotifier, List<BranchModel>> branchesProvider = AsyncNotifierProvider<BranchesNotifier, List<BranchModel>>(BranchesNotifier.new);

final Provider<BranchesService> branchesServiceProvider = Provider<BranchesService>((Ref ref) => BranchesService(ref.watch(apiClientProvider)));

/// The business works with several branches.
final Provider<bool> usesBranchesProvider = Provider<bool>((Ref ref) => ref.watch(businessProvider.select((BusinessInfo b) => b.usesBranches)));

/// The branches that are switched on, the default one first.
final Provider<List<BranchModel>> activeBranchesProvider = Provider<List<BranchModel>>((Ref ref) {
  final List<BranchModel> all = ref.watch(branchesProvider).valueOrNull ?? <BranchModel>[];
  return all.where((BranchModel b) => b.isActive).toList()..sort((BranchModel a, BranchModel b) => a.isDefault == b.isDefault ? a.name.toLowerCase().compareTo(b.name.toLowerCase()) : (a.isDefault ? -1 : 1));
});

/// The id of the business's default branch ('' until the branches have loaded).
final Provider<String> defaultBranchIdProvider = Provider<String>((Ref ref) {
  for (final BranchModel b in ref.watch(branchesProvider).valueOrNull ?? <BranchModel>[]) {
    if (b.isDefault) {
      return b.id;
    }
  }
  return '';
});

/// The branch this device was last set to work in, kept in the device's preferences ('' = not chosen).
class SavedBranchNotifier extends Notifier<String> {
  static const String storageKey = 'working_branch';

  @override
  String build() {
    _load();
    return '';
  }

  Future<void> _load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String saved = prefs.getString(storageKey) ?? '';
      if (saved.isNotEmpty && state.isEmpty) {
        state = saved;
      }
    } catch (_) {
      // Unreadable storage: the default branch is used.
    }
  }

  Future<void> choose(String branchId) async {
    state = branchId;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(storageKey, branchId);
    } catch (_) {
      // The choice still holds for this session.
    }
  }
}

final NotifierProvider<SavedBranchNotifier, String> savedBranchProvider = NotifierProvider<SavedBranchNotifier, String>(SavedBranchNotifier.new);

/// The branch new sales, purchases and counts on this device belong to: '' when the business does not use branches
/// (they then belong to the default branch), otherwise [resolveWorkingBranch].
final Provider<String> workingBranchIdProvider = Provider<String>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  return resolveWorkingBranch(
    usesBranches: ref.watch(usesBranchesProvider),
    user: user,
    branches: ref.watch(branchesProvider).valueOrNull ?? <BranchModel>[],
    saved: ref.watch(savedBranchProvider),
  );
});

final Provider<BranchModel?> workingBranchProvider = Provider<BranchModel?>((Ref ref) {
  final String id = ref.watch(workingBranchIdProvider);
  for (final BranchModel b in ref.watch(branchesProvider).valueOrNull ?? <BranchModel>[]) {
    if (b.id == id) {
      return b;
    }
  }
  return null;
});

/// Whether this person may switch branch.
final Provider<bool> canChooseBranchProvider = Provider<bool>((Ref ref) {
  return ref.watch(usesBranchesProvider) && mayChooseBranch(ref.watch(currentUserProvider).valueOrNull, ref.watch(branchesProvider).valueOrNull ?? <BranchModel>[]);
});

/// Brings what an online action changed on the server (a new branch, a stock transfer) onto this device: the web copy is
/// refreshed, the others pull.
final Provider<Future<void> Function()> serverChangesProvider = Provider<Future<void> Function()>((Ref ref) {
  final bool online = ref.watch(dataModeProvider).isOnline;
  return () async {
    try {
      if (online) {
        await ref.read(remoteStoreProvider).refresh();
      } else {
        await ref.read(syncEngineProvider).pull();
      }
      ref.read(syncTickProvider.notifier).increment();
    } catch (_) {
      // The change is saved on the server; the next sync brings it here.
    }
  };
});
