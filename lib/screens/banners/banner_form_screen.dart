import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/store_banner.dart';
import 'package:a2_stocks/online/photo_service.dart';
import 'package:a2_stocks/providers/banner_providers.dart';
import 'package:a2_stocks/widgets/photo_widgets.dart';

/// A banner: its words, where the button leads, and its picture. The picture is uploaded at once and needs the
/// banner to exist on the server, so a new banner is saved first and then stays open for the picture.
class BannerFormScreen extends ConsumerStatefulWidget {
  const BannerFormScreen({super.key, this.banner});

  final StoreBanner? banner;

  @override
  ConsumerState<BannerFormScreen> createState() => _BannerFormScreenState();
}

class _BannerFormScreenState extends ConsumerState<BannerFormScreen> {
  late final TextEditingController _title = TextEditingController(text: widget.banner?.title ?? '');
  late final TextEditingController _subtitle = TextEditingController(text: widget.banner?.subtitle ?? '');
  late final TextEditingController _button = TextEditingController(text: widget.banner?.buttonText ?? '');
  late final TextEditingController _link = TextEditingController(text: widget.banner?.linkUrl ?? '');
  late StoreBanner? _saved = widget.banner;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    _button.dispose();
    _link.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final AppLocalizations l10n = context.l10n;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (_title.text.trim().isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.bannerNeedTitle)));
      return;
    }
    if (!StoreBanner.isSafeLink(_link.text.trim())) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.bannerBadLink)));
      return;
    }
    setState(() => _busy = true);
    try {
      final service = ref.read(bannersServiceProvider);
      final StoreBanner? existing = _saved;
      final StoreBanner result = existing == null
          ? await service.create(title: _title.text, subtitle: _subtitle.text, buttonText: _button.text, linkUrl: _link.text)
          : await service.update(existing.id, title: _title.text, subtitle: _subtitle.text, buttonText: _button.text, linkUrl: _link.text);
      if (!mounted) {
        return;
      }
      setState(() => _saved = result.copyWith(imageUrl: existing?.imageUrl));
      messenger.showSnackBar(SnackBar(content: Text(existing == null ? l10n.bannerCreatedAddPicture : l10n.bannerSaved)));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final StoreBanner? saved = _saved;
    return Scaffold(
      appBar: AppBar(title: Text(widget.banner == null && saved == null ? l10n.bannerNew : l10n.bannerEdit)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (saved == null)
            Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(l10n.bannerSaveFirst, style: Theme.of(context).textTheme.bodySmall))
          else ...<Widget>[
            PhotoEditor(
              kind: PhotoKind.banner,
              entityId: saved.id,
              photoUrl: saved.imageUrl,
              title: l10n.bannerPicture,
              onChanged: (String url) => setState(() => _saved = saved.copyWith(imageUrl: url)),
            ),
            Padding(padding: const EdgeInsets.only(top: 6, bottom: 16), child: Text(l10n.bannerPictureHint, style: Theme.of(context).textTheme.bodySmall)),
          ],
          TextField(controller: _title, enabled: !_busy, maxLength: 80, decoration: InputDecoration(labelText: l10n.bannerTitle, border: const OutlineInputBorder())),
          const SizedBox(height: 4),
          TextField(controller: _subtitle, enabled: !_busy, maxLength: 160, decoration: InputDecoration(labelText: l10n.bannerSubtitle, border: const OutlineInputBorder())),
          const SizedBox(height: 4),
          TextField(controller: _button, enabled: !_busy, maxLength: 30, decoration: InputDecoration(labelText: l10n.bannerButtonText, border: const OutlineInputBorder())),
          const SizedBox(height: 4),
          TextField(
            controller: _link,
            enabled: !_busy,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(labelText: l10n.bannerLink, helperText: l10n.bannerLinkHint, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy ? null : _save,
            icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
            label: Text(l10n.bannerSave),
          ),
        ],
      ),
    );
  }
}
