import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/store_banner.dart';
import 'package:a2_stocks/providers/banner_providers.dart';
import 'package:a2_stocks/screens/banners/banner_form_screen.dart';
import 'package:a2_stocks/widgets/photo_widgets.dart';

/// The pictures at the top of the online store's home page: add, change, switch off, delete and put in order.
/// A banner without a picture is not shown in the store. Admin and manager; needs a connection.
class BannersScreen extends ConsumerWidget {
  const BannersScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, {StoreBanner? banner}) async {
    await Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (BuildContext context) => BannerFormScreen(banner: banner)));
    ref.invalidate(bannersProvider);
  }

  Future<void> _run(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      ref.invalidate(bannersProvider);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
    }
  }

  Future<void> _move(BuildContext context, WidgetRef ref, List<StoreBanner> all, int from, int to) {
    final List<String> ids = <String>[for (final StoreBanner b in all) b.id];
    ids.insert(to, ids.removeAt(from));
    return _run(context, ref, () => ref.read(bannersServiceProvider).reorder(ids));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, StoreBanner b) async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        content: Text(dialogContext.l10n.bannerDeleteConfirm(b.title)),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(dialogContext.l10n.expensesCancel)),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.danger), onPressed: () => Navigator.pop(dialogContext, true), child: Text(dialogContext.l10n.categoriesDelete)),
        ],
      ),
    );
    if (yes == true && context.mounted) {
      await _run(context, ref, () => ref.read(bannersServiceProvider).delete(b.id));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<StoreBanner>> list = ref.watch(bannersProvider);
    final AppLocalizations l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.moduleBanners),
        actions: <Widget>[IconButton(tooltip: l10n.registerRefresh, icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(bannersProvider))],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _edit(context, ref), icon: const Icon(Icons.add), label: Text(l10n.bannerNew)),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(errorMessageOf(error), textAlign: TextAlign.center))),
        data: (List<StoreBanner> items) => items.isEmpty
            ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.bannerNone, textAlign: TextAlign.center)))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: <Widget>[
                  Padding(padding: const EdgeInsets.only(top: 4, bottom: 4), child: Text(l10n.bannerHint, style: const TextStyle(color: AppColors.textMuted))),
                  for (int i = 0; i < items.length; i++) _card(context, ref, items, i),
                ],
              ),
      ),
    );
  }

  Widget _card(BuildContext context, WidgetRef ref, List<StoreBanner> all, int index) {
    final StoreBanner b = all[index];
    final AppLocalizations l10n = context.l10n;
    final bool shown = b.isActive && b.imageUrl.isNotEmpty;
    return Card(
      margin: const EdgeInsets.only(top: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _edit(context, ref, banner: b),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 160, height: 90, child: NetworkPhoto(url: b.imageUrl, placeholder: Icons.add_photo_alternate_outlined)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (b.subtitle.isNotEmpty) Text(b.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Text(
                      shown ? l10n.bannerShownInStore : (b.imageUrl.isEmpty ? l10n.bannerNeedsPicture : l10n.bannerSwitchedOff),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: shown ? AppColors.teal : AppColors.amber),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Switch(value: b.isActive, onChanged: (bool on) => _run(context, ref, () => ref.read(bannersServiceProvider).setActive(b.id, on))),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(visualDensity: VisualDensity.compact, tooltip: l10n.bannerMoveUp, icon: const Icon(Icons.arrow_upward, size: 18), onPressed: index == 0 ? null : () => _move(context, ref, all, index, index - 1)),
                    IconButton(visualDensity: VisualDensity.compact, tooltip: l10n.bannerMoveDown, icon: const Icon(Icons.arrow_downward, size: 18), onPressed: index == all.length - 1 ? null : () => _move(context, ref, all, index, index + 1)),
                    IconButton(visualDensity: VisualDensity.compact, tooltip: l10n.categoriesDelete, icon: const Icon(Icons.delete_outline, size: 18), onPressed: () => _delete(context, ref, b)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
