import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/category_stats.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/category_model.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';
import 'package:a2_stocks/models/starter_pack.dart';
import 'package:a2_stocks/screens/catalog/category_form_screen.dart';
import 'package:a2_stocks/screens/catalog/starter_pack_dialog.dart';
import 'package:a2_stocks/widgets/photo_widgets.dart';
import 'package:a2_stocks/widgets/stat_strip.dart';

enum _CategoryAction { addChild, edit, delete }

enum _Sort { name, subcategories, products }

/// Categories as two data tables: the top-level categories (with how many
/// subcategories and products they hold) and the subcategories grouped under
/// their category (with their product counts).
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  _Sort _sort = _Sort.name;
  bool _ascending = true;

  /// 0 = Categories, 1 = Subcategories.
  int _tab = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// A ready-made set of categories for a type of business.
  Future<void> _openStarterPacks() async {
    final StarterPackResult? result = await showStarterPackDialog(context);
    if (result == null || !mounted) {
      return;
    }
    final String already = result.skipped > 0 ? context.l10n.categoriesYouAlreadyHadWere(result.skipped) : '';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.categoriesAddedCategories(result.created, already))));
  }

  void _openForm({CategoryModel? category, String parentId = ''}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            CategoryFormScreen(category: category, initialParentId: parentId),
      ),
    );
  }

  Future<void> _confirmDelete(CategoryModel category) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(context.l10n.categoriesDeleteCategory),
        content: Text(context.l10n.categoriesDelete2(category.name)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.categoriesCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.categoriesDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(categoriesProvider.notifier).deleteCategory(category.id);
    }
  }

  void _setSort(_Sort sort, bool ascending) => setState(() {
        _sort = sort;
        _ascending = ascending;
      });

  Widget _actions(CategoryModel category) => PopupMenuButton<_CategoryAction>(
        tooltip: context.l10n.categoriesActions,
        icon: const Icon(Icons.more_horiz, size: 20),
        onSelected: (_CategoryAction action) async {
          switch (action) {
            case _CategoryAction.addChild:
              _openForm(parentId: category.id);
            case _CategoryAction.edit:
              _openForm(category: category);
            case _CategoryAction.delete:
              await _confirmDelete(category);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<_CategoryAction>>[
          PopupMenuItem<_CategoryAction>(value: _CategoryAction.addChild, child: Text(context.l10n.categoriesAddSubcategory)),
          PopupMenuItem<_CategoryAction>(value: _CategoryAction.edit, child: Text(context.l10n.categoriesEdit)),
          PopupMenuItem<_CategoryAction>(value: _CategoryAction.delete, child: Text(context.l10n.categoriesDelete)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<CategoryModel>> async = ref.watch(categoriesProvider);
    final List<ProductModel> products = ref.watch(productsProvider).valueOrNull ?? <ProductModel>[];
    final bool canManage = ref.watch(canManageCatalogProvider);

    ref.listen<AsyncValue<List<CategoryModel>>>(categoriesProvider,
        (AsyncValue<List<CategoryModel>>? previous, AsyncValue<List<CategoryModel>> next) {
      final Object? error = next.error;
      if (error != null && !identical(error, previous?.error)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
      }
    });

    final List<CategoryModel>? categories = async.valueOrNull;
    Widget body;
    if (categories == null) {
      final Object? error = async.error;
      body = Center(
        child: error != null ? Text(errorMessageOf(error)) : const CircularProgressIndicator(),
      );
    } else if (categories.isEmpty) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(context.l10n.categoriesNoCategoriesYet),
            if (canManage) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                context.l10n.categoriesStartFromAReady,
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _openStarterPacks,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: Text(context.l10n.categoriesStartFromATemplate),
              ),
            ],
          ],
        ),
      );
    } else {
      final List<CategoryStat> stats = computeCategoryStats(categories: categories, products: products);
      final int mainCount = stats.where((CategoryStat s) => s.depth == 0).length;
      final int emptyCount = stats.where((CategoryStat s) => s.totalProducts == 0).length;
      body = Column(
        children: <Widget>[
          StatStrip(
            items: <StatItem>[
              StatItem(
                icon: Icons.category_outlined,
                color: AppColors.primary,
                label: context.l10n.categoriesMainCategories,
                value: '$mainCount',
              ),
              StatItem(
                icon: Icons.subdirectory_arrow_right,
                color: AppColors.sky,
                label: context.l10n.categoriesSubcategoriesInTotal,
                value: '${stats.length - mainCount}',
              ),
              StatItem(
                icon: Icons.inventory_2_outlined,
                color: AppColors.teal,
                label: context.l10n.categoriesProducts,
                value: '${products.length}',
              ),
              StatItem(
                icon: Icons.folder_off_outlined,
                color: emptyCount > 0 ? AppColors.amber : AppColors.textMuted,
                label: context.l10n.categoriesWithoutProducts,
                value: '$emptyCount',
                caption: emptyCount > 0 ? context.l10n.categoriesCategoriesWithNothingIn : '',
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Wrap(
              spacing: 16,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: <ButtonSegment<int>>[
                    ButtonSegment<int>(value: 0, label: Text(context.l10n.categoriesCategories), icon: const Icon(Icons.category_outlined, size: 18)),
                    ButtonSegment<int>(
                        value: 1, label: Text(context.l10n.categoriesSubcategories), icon: const Icon(Icons.account_tree_outlined, size: 18)),
                  ],
                  selected: <int>{_tab},
                  onSelectionChanged: (Set<int> value) => setState(() => _tab = value.first),
                ),
                SizedBox(
                width: 340,
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: context.l10n.categoriesSearchCategories,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                  onChanged: (String v) => setState(() => _query = v.trim().toLowerCase()),
                ),
              ),
              ],
            ),
          ),
          Expanded(
            // A short fade instead of a sideways page swipe.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              // The default layout centres the child, which pushed a short
              // table down and left a gap under the switch: pin it to the top.
              layoutBuilder: (Widget? current, List<Widget> previous) => Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[...previous, if (current != null) current],
              ),
              child: KeyedSubtree(
                key: ValueKey<int>(_tab),
                child: _tab == 0
                    ? _CategoriesTable(
                        stats: stats,
                        query: _query,
                        sort: _sort,
                        ascending: _ascending,
                        onSort: _setSort,
                        canManage: canManage,
                        actions: _actions,
                        onEdit: (CategoryModel c) => _openForm(category: c),
                      )
                    : _SubcategoriesTable(
                        stats: stats,
                        query: _query,
                        canManage: canManage,
                        actions: _actions,
                        onEdit: (CategoryModel c) => _openForm(category: c),
                      ),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.categoriesCategories),
        actions: <Widget>[
          if (canManage)
            TextButton.icon(
              onPressed: _openStarterPacks,
              icon: const Icon(Icons.auto_awesome_outlined, size: 18),
              label: Text(context.l10n.categoriesStarterPacks),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: body,
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.categoriesAddCategory),
            )
          : null,
    );
  }
}

// ---- shared table pieces ------------------------------------------------------

/// A card holding a table that stretches to the width and scrolls both ways.
class _TableCard extends StatelessWidget {
  const _TableCard({required this.table});

  final Widget table;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) => SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: box.maxWidth),
                child: table,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

DataTableThemeData _tableTheme() => const DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll<Color>(AppColors.mutedFill),
      headingTextStyle: TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: AppColors.text,
      ),
      dataRowMinHeight: 54,
      dataRowMaxHeight: 62,
      columnSpacing: 28,
      horizontalMargin: 16,
      dividerThickness: 1,
      dataTextStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13.5, color: AppColors.text),
    );

class _NameCell extends StatelessWidget {
  const _NameCell({required this.category, this.indent = 0});

  final CategoryModel category;
  final double indent;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.only(left: indent),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 36,
                height: 36,
                child: category.photoUrl.isNotEmpty
                    ? NetworkPhoto(url: category.photoUrl, size: 36, placeholder: Icons.category_outlined)
                    : const ColoredBox(
                        color: AppColors.mutedFill,
                        child: Icon(Icons.category_outlined, size: 18, color: AppColors.textMuted),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (category.description.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: Text(
                      category.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color color = active ? AppColors.teal : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        active ? context.l10n.categoryFormActive : context.l10n.productsInactive,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// A count that shows [message] when the pointer rests on it (long-press on
/// a touch screen).
class _CountWithTip extends StatelessWidget {
  const _CountWithTip({required this.count, required this.message, this.icon});

  final int count;
  final InlineSpan? message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: count == 0 ? AppColors.mutedFill : AppColors.skySoft,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: count == 0 ? AppColors.textMuted : AppColors.sky),
            const SizedBox(width: 6),
          ],
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: count == 0 ? AppColors.textMuted : AppColors.navy,
            ),
          ),
        ],
      ),
    );
    if (message == null) {
      return chip;
    }
    return Tooltip(
      richMessage: message,
      waitDuration: const Duration(milliseconds: 120),
      showDuration: const Duration(seconds: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 360),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white, fontSize: 12.5, height: 1.5),
      child: MouseRegion(cursor: SystemMouseCursors.help, child: chip),
    );
  }
}

/// "Bats — 12 products" lines of a category's subcategories.
InlineSpan _subcategoryTip(AppLocalizations l10n, CategoryStat stat, Map<String, CategoryStat> byId) {
  final List<InlineSpan> lines = <InlineSpan>[
    TextSpan(
      text: l10n.categoriesTipHeader(stat.category.name, l10n.countSubcategories(stat.subcategoryCount)),
      style: const TextStyle(fontWeight: FontWeight.w800),
    ),
  ];
  for (final CategoryModel child in stat.children) {
    final int n = byId[child.id]?.totalProducts ?? 0;
    lines.add(TextSpan(text: '\n${l10n.categoriesTipChild(child.name, l10n.countProducts(n))}'));
  }
  lines.add(TextSpan(
    text: '\n${l10n.categoriesTipTotal(l10n.countProducts(stat.totalProducts), stat.directProducts, stat.category.name)}',
    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFD9DEE5)),
  ));
  return TextSpan(children: lines);
}

// ---- categories table ---------------------------------------------------------

class _CategoriesTable extends StatelessWidget {
  const _CategoriesTable({
    required this.stats,
    required this.query,
    required this.sort,
    required this.ascending,
    required this.onSort,
    required this.canManage,
    required this.actions,
    required this.onEdit,
  });

  final List<CategoryStat> stats;
  final String query;
  final _Sort sort;
  final bool ascending;
  final void Function(_Sort, bool) onSort;
  final bool canManage;
  final Widget Function(CategoryModel) actions;
  final ValueChanged<CategoryModel> onEdit;

  @override
  Widget build(BuildContext context) {
    final Map<String, CategoryStat> byId = <String, CategoryStat>{
      for (final CategoryStat s in stats) s.category.id: s,
    };
    final List<CategoryStat> rows = stats
        .where((CategoryStat s) =>
            s.depth == 0 && (query.isEmpty || s.category.name.toLowerCase().contains(query)))
        .toList();
    rows.sort((CategoryStat a, CategoryStat b) {
      final int c = switch (sort) {
        _Sort.name => a.category.name.toLowerCase().compareTo(b.category.name.toLowerCase()),
        _Sort.subcategories => a.subcategoryCount.compareTo(b.subcategoryCount),
        _Sort.products => a.totalProducts.compareTo(b.totalProducts),
      };
      return ascending ? c : -c;
    });
    if (rows.isEmpty) {
      return Center(child: Text(context.l10n.categoriesNoCategoriesMatch));
    }
    final int sortIndex = _Sort.values.indexOf(sort);
    return _TableCard(
      table: Theme(
        data: Theme.of(context).copyWith(dataTableTheme: _tableTheme()),
        child: DataTable(
          sortColumnIndex: sortIndex,
          sortAscending: ascending,
          showCheckboxColumn: false,
          columns: <DataColumn>[
            DataColumn(
              label: Text(context.l10n.categoriesCategory),
              onSort: (int i, bool asc) => onSort(_Sort.name, asc),
            ),
            DataColumn(
              label: Text(context.l10n.categoriesSubcategories),
              numeric: true,
              onSort: (int i, bool asc) => onSort(_Sort.subcategories, asc),
            ),
            DataColumn(
              label: Text(context.l10n.categoriesProducts),
              numeric: true,
              onSort: (int i, bool asc) => onSort(_Sort.products, asc),
            ),
            DataColumn(label: Text(context.l10n.categoriesStatus)),
            if (canManage) const DataColumn(label: Text('')),
          ],
          rows: <DataRow>[
            for (final CategoryStat s in rows)
              DataRow(
                cells: <DataCell>[
                  DataCell(
                    _NameCell(category: s.category),
                    onTap: canManage ? () => onEdit(s.category) : null,
                  ),
                  DataCell(
                    _CountWithTip(
                      count: s.subcategoryCount,
                      icon: Icons.account_tree_outlined,
                      message: s.subcategoryCount == 0 ? null : _subcategoryTip(context.l10n, s, byId),
                    ),
                  ),
                  DataCell(
                    _CountWithTip(
                      count: s.totalProducts,
                      icon: Icons.inventory_2_outlined,
                      message: s.subcategoryCount == 0
                          ? null
                          : TextSpan(
                              text: context.l10n.categoriesDirectlyInInIts(s.directProducts, s.category.name, s.productsInSubcategories),
                            ),
                    ),
                  ),
                  DataCell(_StatusChip(active: s.category.isActive)),
                  if (canManage) DataCell(actions(s.category)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ---- subcategories grouped by category ------------------------------------------

class _SubcategoriesTable extends StatelessWidget {
  const _SubcategoriesTable({
    required this.stats,
    required this.query,
    required this.canManage,
    required this.actions,
    required this.onEdit,
  });

  final List<CategoryStat> stats;
  final String query;
  final bool canManage;
  final Widget Function(CategoryModel) actions;
  final ValueChanged<CategoryModel> onEdit;

  @override
  Widget build(BuildContext context) {
    // Groups in tree order: a top-level category followed by everything below it.
    final List<(CategoryStat, List<CategoryStat>)> groups = <(CategoryStat, List<CategoryStat>)>[];
    for (final CategoryStat s in stats) {
      if (s.depth == 0) {
        groups.add((s, <CategoryStat>[]));
      } else if (groups.isNotEmpty) {
        groups.last.$2.add(s);
      }
    }
    bool matches(CategoryStat s) => query.isEmpty || s.category.name.toLowerCase().contains(query);

    final List<DataRow> rows = <DataRow>[];
    for (final (CategoryStat head, List<CategoryStat> subs) in groups) {
      if (subs.isEmpty) {
        continue; // Nothing to group.
      }
      final List<CategoryStat> shown = matches(head) ? subs : subs.where(matches).toList();
      if (shown.isEmpty) {
        continue;
      }
      rows.add(DataRow(
        color: const WidgetStatePropertyAll<Color>(AppColors.background),
        cells: <DataCell>[
          DataCell(Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.folder_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(head.category.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(width: 10),
              Text(
                context.l10n.countSubcategories(head.subcategoryCount),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          )),
          const DataCell(Text('')),
          DataCell(_CountWithTip(count: head.totalProducts, icon: Icons.inventory_2_outlined, message: null)),
          DataCell(_StatusChip(active: head.category.isActive)),
          if (canManage) DataCell(actions(head.category)),
        ],
      ));
      for (final CategoryStat s in shown) {
        rows.add(DataRow(
          cells: <DataCell>[
            DataCell(
              _NameCell(category: s.category, indent: 18.0 * s.depth),
              onTap: canManage ? () => onEdit(s.category) : null,
            ),
            DataCell(Text(s.parentName, style: const TextStyle(color: AppColors.textMuted))),
            DataCell(
              _CountWithTip(
                count: s.totalProducts,
                icon: Icons.inventory_2_outlined,
                message: s.subcategoryCount == 0
                    ? null
                    : TextSpan(
                        text: context.l10n.categoriesDirectlyInInIts(s.directProducts, s.category.name, s.productsInSubcategories),
                      ),
              ),
            ),
            DataCell(_StatusChip(active: s.category.isActive)),
            if (canManage) DataCell(actions(s.category)),
          ],
        ));
      }
    }

    if (rows.isEmpty) {
      return Center(
        child: Text(query.isEmpty ? context.l10n.categoriesNoSubcategoriesYet : context.l10n.categoriesNoSubcategoriesMatch),
      );
    }
    return _TableCard(
      table: Theme(
        data: Theme.of(context).copyWith(dataTableTheme: _tableTheme()),
        child: DataTable(
          showCheckboxColumn: false,
          columns: <DataColumn>[
            DataColumn(label: Text(context.l10n.categoriesCategorySubcategory)),
            DataColumn(label: Text(context.l10n.categoriesParent)),
            DataColumn(label: Text(context.l10n.categoriesProducts), numeric: true),
            DataColumn(label: Text(context.l10n.categoriesStatus)),
            if (canManage) const DataColumn(label: Text('')),
          ],
          rows: rows,
        ),
      ),
    );
  }
}
