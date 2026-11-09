import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/utils/category_tree.dart';
import 'package:mq_sports_erp/core/utils/error_text.dart';
import 'package:mq_sports_erp/models/category_model.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
import 'package:mq_sports_erp/screens/catalog/category_form_screen.dart';

enum _CategoryAction { addChild, edit, delete }

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  void _openForm(
    BuildContext context, {
    CategoryModel? category,
    String parentId = '',
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => CategoryFormScreen(
          category: category,
          initialParentId: parentId,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete category'),
          content: Text('Delete "${category.name}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await ref.read(categoriesProvider.notifier).deleteCategory(category.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CategoryModel>> async = ref.watch(categoriesProvider);
    final bool canManage = ref.watch(canManageCatalogProvider);

    ref.listen<AsyncValue<List<CategoryModel>>>(categoriesProvider,
        (AsyncValue<List<CategoryModel>>? previous,
            AsyncValue<List<CategoryModel>> next) {
      final Object? error = next.error;
      if (error != null && !identical(error, previous?.error)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
      }
    });

    final List<CategoryModel>? categories = async.valueOrNull;
    Widget body;
    if (categories == null) {
      final Object? error = async.error;
      body = Center(
        child: error != null
            ? Text(errorMessageOf(error))
            : const CircularProgressIndicator(),
      );
    } else if (categories.isEmpty) {
      body = const Center(child: Text('No categories yet.'));
    } else {
      final List<CategoryNode> nodes = CategoryTree.flatten(categories);
      body = ListView.separated(
        itemCount: nodes.length,
        separatorBuilder: (BuildContext context, int index) =>
            const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          final CategoryNode node = nodes[index];
          final CategoryModel category = node.category;
          return ListTile(
            contentPadding:
                EdgeInsets.only(left: 16 + node.depth * 24.0, right: 8),
            leading: Icon(node.depth == 0
                ? Icons.folder_outlined
                : Icons.subdirectory_arrow_right),
            title: Text(category.name),
            subtitle:
                category.description.isEmpty ? null : Text(category.description),
            onTap: canManage
                ? () => _openForm(context, category: category)
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (!category.isActive)
                  const Chip(
                    label: Text('Inactive'),
                    visualDensity: VisualDensity.compact,
                  ),
                if (canManage)
                  PopupMenuButton<_CategoryAction>(
                    onSelected: (_CategoryAction action) async {
                      switch (action) {
                        case _CategoryAction.addChild:
                          _openForm(context, parentId: category.id);
                        case _CategoryAction.edit:
                          _openForm(context, category: category);
                        case _CategoryAction.delete:
                          await _confirmDelete(context, ref, category);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        const <PopupMenuEntry<_CategoryAction>>[
                      PopupMenuItem<_CategoryAction>(
                        value: _CategoryAction.addChild,
                        child: Text('Add subcategory'),
                      ),
                      PopupMenuItem<_CategoryAction>(
                        value: _CategoryAction.edit,
                        child: Text('Edit'),
                      ),
                      PopupMenuItem<_CategoryAction>(
                        value: _CategoryAction.delete,
                        child: Text('Delete'),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: body,
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Add category'),
            )
          : null,
    );
  }
}
