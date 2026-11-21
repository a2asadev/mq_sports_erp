import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/branch_model.dart';
import 'package:a2_stocks/providers/branch_providers.dart';

/// Which branch this device works in: shown only when the business uses branches and has more than one that is on.
/// New sales, purchases and stock counts belong to it, and the stock shown is its stock. A member of staff with a
/// home branch sees it but cannot change it.
class BranchPickerChip extends ConsumerWidget {
  const BranchPickerChip({super.key});

  Future<void> _choose(BuildContext context, WidgetRef ref) async {
    final List<BranchModel> branches = ref.read(activeBranchesProvider);
    final String current = ref.read(workingBranchIdProvider);
    final String? picked = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Text(sheetContext.l10n.branchPickerTitle, style: Theme.of(sheetContext).textTheme.titleMedium)),
            for (final BranchModel b in branches)
              ListTile(
                leading: Icon(b.id == current ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                title: Text(b.name),
                subtitle: b.address.isEmpty ? null : Text(b.address),
                onTap: () => Navigator.of(sheetContext).pop(b.id),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      await ref.read(savedBranchProvider.notifier).choose(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(usesBranchesProvider) || ref.watch(activeBranchesProvider).length < 2) {
      return const SizedBox.shrink();
    }
    final BranchModel? branch = ref.watch(workingBranchProvider);
    if (branch == null) {
      return const SizedBox.shrink();
    }
    final bool canChoose = ref.watch(canChooseBranchProvider);
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: ActionChip(
        avatar: const Icon(Icons.store_mall_directory_outlined, size: 18),
        label: Text(branch.name, overflow: TextOverflow.ellipsis),
        tooltip: canChoose ? context.l10n.branchPickerTooltip : context.l10n.branchPickerLocked,
        onPressed: canChoose ? () => _choose(context, ref) : null,
      ),
    );
  }
}

/// A line that says whose stock a page shows ("Stock of Lahore"), only when the business uses branches.
class BranchBanner extends ConsumerWidget {
  const BranchBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BranchModel? branch = ref.watch(workingBranchProvider);
    if (!ref.watch(usesBranchesProvider) || branch == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: <Widget>[
          const Icon(Icons.store_mall_directory_outlined, size: 16),
          const SizedBox(width: 6),
          Expanded(child: Text(context.l10n.branchBannerStock(branch.name), style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
