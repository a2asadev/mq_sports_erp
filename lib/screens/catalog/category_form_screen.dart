import 'package:flutter/material.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/online/photo_service.dart';
import 'package:a2_stocks/widgets/photo_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/utils/category_tree.dart';
import 'package:a2_stocks/models/category_model.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';

/// Add or edit a category. [initialParentId] pre-selects the parent when
/// adding a subcategory.
class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({
    super.key,
    this.category,
    this.initialParentId = '',
  });

  final CategoryModel? category;
  final String initialParentId;

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String _parentId;
  late bool _isActive;
  late String _photoUrl;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final CategoryModel? existing = widget.category;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _descriptionController =
        TextEditingController(text: existing?.description ?? '');
    _parentId = existing?.parentId ?? widget.initialParentId;
    _isActive = existing?.isActive ?? true;
    _photoUrl = existing?.photoUrl ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Parents the category may be placed under: never itself or anything
  /// below it, which would create a loop.
  List<MapEntry<String, String>> _parentOptions() {
    final List<CategoryModel> all =
        ref.read(categoriesProvider).valueOrNull ?? <CategoryModel>[];
    final CategoryModel? existing = widget.category;
    final Set<String> exclude = existing == null
        ? <String>{}
        : <String>{existing.id, ...CategoryTree.descendantIds(existing.id, all)};
    return CategoryTree.options(all, exclude: exclude);
  }

  String _resolvedParent(List<MapEntry<String, String>> options) {
    final bool valid = _parentId.isEmpty ||
        options.any((MapEntry<String, String> o) => o.key == _parentId);
    return valid ? _parentId : '';
  }

  Future<void> _submit() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    setState(() => _isSubmitting = true);
    final CategoriesNotifier notifier = ref.read(categoriesProvider.notifier);
    final CategoryModel? existing = widget.category;
    final String parentId = _resolvedParent(_parentOptions());
    final bool succeeded = existing == null
        ? await notifier.createCategory(
            name: _nameController.text,
            parentId: parentId,
            description: _descriptionController.text,
            isActive: _isActive,
          )
        : await notifier.updateCategory(existing.copyWith(
            name: _nameController.text,
            parentId: parentId,
            description: _descriptionController.text,
            isActive: _isActive,
            photoUrl: _photoUrl,
          ));
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    if (succeeded) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(categoriesProvider);
    final bool isEdit = widget.category != null;
    final List<MapEntry<String, String>> options = _parentOptions();
    final String parentValue = _resolvedParent(options);

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? context.l10n.categoryFormEditCategory : context.l10n.categoriesAddCategory)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (widget.category != null)
                      PhotoEditor(
                        kind: PhotoKind.category,
                        entityId: widget.category!.id,
                        photoUrl: _photoUrl,
                        title: context.l10n.categoryFormCategoryPhoto,
                        enabled: !_isSubmitting,
                        onChanged: (String url) => _photoUrl = url,
                      )
                    else
                      const PhotoAfterSaveHint(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      enabled: !_isSubmitting,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: context.l10n.categoryFormName,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (String? value) =>
                          (value == null || value.trim().isEmpty)
                              ? context.l10n.categoryFormNameIsRequired
                              : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: parentValue,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.categoryFormParentCategory,
                        border: const OutlineInputBorder(),
                      ),
                      items: <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(
                          value: '',
                          child: Text(context.l10n.categoryFormNoneTopLevel),
                        ),
                        ...options.map(
                          (MapEntry<String, String> option) =>
                              DropdownMenuItem<String>(
                            value: option.key,
                            child: Text(option.value,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                      onChanged: _isSubmitting
                          ? null
                          : (String? value) =>
                              setState(() => _parentId = value ?? ''),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      enabled: !_isSubmitting,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: context.l10n.categoryFormDescriptionOptional,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: Text(context.l10n.categoryFormActive),
                      value: _isActive,
                      onChanged: _isSubmitting
                          ? null
                          : (bool value) => setState(() => _isActive = value),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEdit ? context.l10n.categoryFormSaveChanges : context.l10n.categoryFormCreateCategory),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
