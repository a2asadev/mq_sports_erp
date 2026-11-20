import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/starter_pack_plan.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/category_model.dart';
import 'package:a2_stocks/models/starter_pack.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';
import 'package:a2_stocks/providers/core_providers.dart';

/// The server's starter packs (needs a connection).
final AutoDisposeFutureProvider<List<StarterPack>> starterPacksProvider =
    FutureProvider.autoDispose<List<StarterPack>>((Ref ref) => ref.watch(starterPackServiceProvider).list());

/// Opens the starter-pack picker. Returns what was added, or null when nothing was.
Future<StarterPackResult?> showStarterPackDialog(BuildContext context) {
  return showDialog<StarterPackResult>(
    context: context,
    builder: (BuildContext context) => const StarterPackDialog(),
  );
}

/// Pick a type of business, tick the groups wanted, and add them as categories.
/// Categories the business already has are left alone, and the dialog says how
/// many that is before anything is added.
class StarterPackDialog extends ConsumerStatefulWidget {
  const StarterPackDialog({super.key});

  @override
  ConsumerState<StarterPackDialog> createState() => _StarterPackDialogState();
}

class _StarterPackDialogState extends ConsumerState<StarterPackDialog> {
  StarterPack? _pack;
  Set<String> _selected = <String>{};
  bool _busy = false;
  String _error = '';

  void _choose(StarterPack pack) => setState(() {
        _pack = pack;
        _selected = <String>{for (final StarterGroup g in pack.groups) g.name};
        _error = '';
      });

  List<StarterGroup> _chosenGroups(StarterPack pack) =>
      pack.groups.where((StarterGroup g) => _selected.contains(g.name)).toList();

  Future<void> _apply(StarterPack pack) async {
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final bool everything = _selected.length == pack.groups.length;
      final StarterPackResult result = await ref.read(starterPackServiceProvider).apply(
            pack.id,
            groups: everything ? null : <String>[for (final StarterGroup g in _chosenGroups(pack)) g.name],
          );
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = errorMessageOf(error));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final StarterPack? pack = _pack;
    final Size screen = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 680, maxHeight: screen.height * 0.88),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: <Widget>[
                  if (pack != null)
                    IconButton(
                      tooltip: context.l10n.starterPackBackToTheList,
                      onPressed: _busy ? null : () => setState(() => _pack = null),
                      icon: const Icon(Icons.arrow_back),
                    )
                  else
                    const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      pack?.name ?? context.l10n.starterPackStarterCategories,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.starterPackClose,
                    onPressed: _busy ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(child: pack == null ? _packList() : _groupPicker(pack)),
          ],
        ),
      ),
    );
  }

  Widget _packList() {
    final AsyncValue<List<StarterPack>> packs = ref.watch(starterPacksProvider);
    return packs.when(
      loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
      error: (Object error, StackTrace stack) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              context.l10n.starterPackStarterPacksNeedA(errorMessageOf(error)),
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(starterPacksProvider),
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.commonTryAgain),
            ),
          ],
        ),
      ),
      data: (List<StarterPack> list) {
        final List<CategoryModel> existing = ref.watch(categoriesProvider).valueOrNull ?? <CategoryModel>[];
        final ({List<StarterPackMatch> suggested, List<StarterPackMatch> others}) split =
            StarterPackMatch.split(list, existing);
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(12),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              child: Text(
                context.l10n.starterPackPickTheKindOf,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ),
            if (split.suggested.isNotEmpty) ...<Widget>[
              _sectionTitle(context.l10n.starterPackStoresLikeYours),
              for (final StarterPackMatch m in split.suggested) _packCard(m, suggested: true),
              if (split.others.isNotEmpty) _sectionTitle(context.l10n.starterPackOtherKindsOfStore),
            ],
            for (final StarterPackMatch m in split.others) _packCard(m, suggested: false),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
      );

  Widget _packCard(StarterPackMatch m, {required bool suggested}) {
    final StarterPack p = m.pack;
    final bool complete = m.alreadyThere >= m.total;
    final String size =
        context.l10n.starterPackSizeLine(context.l10n.countGroups(p.groups.length), context.l10n.countCategories(p.categoryCount));
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(suggested ? Icons.auto_awesome : Icons.category_outlined, color: AppColors.primary),
        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          suggested
              ? (complete
                  ? context.l10n.starterPackSimilarAll(m.matchedText(context.l10n))
                  : context.l10n.starterPackSimilarSome(m.matchedText(context.l10n), m.alreadyThere, m.total))
              : '${p.description}\n$size',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _choose(p),
      ),
    );
  }

  Widget _groupPicker(StarterPack pack) {
    final List<CategoryModel> existing = ref.watch(categoriesProvider).valueOrNull ?? <CategoryModel>[];
    final StarterPackPlan plan = StarterPackPlan.compute(_chosenGroups(pack), existing);
    final bool all = _selected.length == pack.groups.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 0),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(pack.description, style: const TextStyle(color: AppColors.textMuted))),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() => _selected = all ? <String>{} : <String>{for (final StarterGroup g in pack.groups) g.name}),
                child: Text(all ? context.l10n.starterPackSelectNone : context.l10n.starterPackSelectAll),
              ),
            ],
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: <Widget>[
              for (final StarterGroup group in pack.groups) _groupTile(group, existing),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                plan.toAdd == 0
                    ? (_selected.isEmpty ? context.l10n.starterPackTickAtLeastOne : context.l10n.starterPackYouAlreadyHaveEverything)
                    : (plan.alreadyThere > 0
                        ? context.l10n.starterPackWillAddLeft(plan.toAdd, plan.alreadyThere)
                        : context.l10n.starterPackWillAdd(plan.toAdd)),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _busy || plan.toAdd == 0 ? null : () => _apply(pack),
                icon: _busy
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.add),
                label: Text(plan.toAdd == 0 ? context.l10n.starterPackNothingNewToAdd : context.l10n.starterPackAddCategories(plan.toAdd)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _groupTile(StarterGroup group, List<CategoryModel> existing) {
    final bool has = StarterPackPlan.hasGroup(group, existing);
    return ExpansionTile(
      shape: const Border(),
      collapsedShape: const Border(),
      leading: Checkbox(
        value: _selected.contains(group.name),
        onChanged: _busy
            ? null
            : (bool? on) => setState(() {
                  if (on ?? false) {
                    _selected = <String>{..._selected, group.name};
                  } else {
                    _selected = <String>{..._selected}..remove(group.name);
                  }
                }),
      ),
      title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        has
            ? context.l10n.starterPackGroupHave(context.l10n.countSubcategories(group.children.length))
            : context.l10n.countSubcategories(group.children.length),
        style: const TextStyle(fontSize: 12),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
      expandedAlignment: Alignment.centerLeft,
      children: <Widget>[
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: <Widget>[
            for (final String child in group.children)
              Chip(
                label: Text(child, style: const TextStyle(fontSize: 12)),
                visualDensity: VisualDensity.compact,
                backgroundColor: AppColors.primarySoft,
                side: BorderSide.none,
              ),
          ],
        ),
      ],
    );
  }
}
