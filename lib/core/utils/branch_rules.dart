import 'package:a2_stocks/models/branch_model.dart';
import 'package:a2_stocks/models/stock_ledger_model.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';

/// The branch the person works in right now ('' = the business does not use branches, so everything belongs to the
/// default one). Pure, so it is easy to test:
///
/// - Branches off: ''.
/// - A member of staff with a home branch is tied to it (the server refuses any other).
/// - Otherwise the branch they chose last, when it is still there and switched on; else their home branch; else the
///   default branch; else the first one that is on.
String resolveWorkingBranch({
  required bool usesBranches,
  required UserModel? user,
  required List<BranchModel> branches,
  String saved = '',
}) {
  if (!usesBranches) {
    return '';
  }
  final List<BranchModel> open = branches.where((BranchModel b) => b.isActive).toList();
  bool isOpen(String id) => id.isNotEmpty && open.any((BranchModel b) => b.id == id);
  final String home = user?.branchId ?? '';
  if (user != null && user.role == UserRole.staff && isOpen(home)) {
    return home;
  }
  if (isOpen(saved)) {
    return saved;
  }
  if (isOpen(home)) {
    return home;
  }
  for (final BranchModel b in open) {
    if (b.isDefault) {
      return b.id;
    }
  }
  return open.isEmpty ? '' : open.first.id;
}

/// Whether this person may pick another branch (staff with a home branch may not).
bool mayChooseBranch(UserModel? user, List<BranchModel> branches) {
  if (user == null) {
    return false;
  }
  final bool tied = user.role == UserRole.staff && user.branchId.isNotEmpty && branches.any((BranchModel b) => b.id == user.branchId && b.isActive);
  return !tied && branches.where((BranchModel b) => b.isActive).length > 1;
}

/// Stock on hand per variant. With a [branchId] only that branch's movements count (a movement with no branch belongs
/// to the default branch, [defaultBranchId]); without one it is the business-wide total.
Map<String, int> stockByVariant(List<StockLedgerModel> entries, {String? branchId, String defaultBranchId = ''}) {
  final Map<String, int> totals = <String, int>{};
  for (final StockLedgerModel e in entries) {
    if (branchId != null && branchId.isNotEmpty) {
      final String of = e.branchId.isEmpty ? defaultBranchId : e.branchId;
      if (of != branchId) {
        continue;
      }
    }
    totals[e.variantId] = (totals[e.variantId] ?? 0) + e.quantity;
  }
  return totals;
}

/// The branch's name for a record's branch id ('' = the default branch); '' when unknown.
String branchName(List<BranchModel> branches, String branchId) {
  for (final BranchModel b in branches) {
    if (branchId.isEmpty ? b.isDefault : b.id == branchId) {
      return b.name;
    }
  }
  return '';
}
