import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/product_image.dart';
import 'package:a2_stocks/online/photo_service.dart';
import 'package:a2_stocks/providers/core_providers.dart';

/// A picture from the network that never breaks the screen: a placeholder shows
/// while it loads, when it is missing, and when there is no connection.
class NetworkPhoto extends StatelessWidget {
  const NetworkPhoto({
    super.key,
    required this.url,
    this.size,
    this.fit = BoxFit.cover,
    this.placeholder = Icons.image_outlined,
  });

  final String url;
  final double? size;
  final BoxFit fit;
  final IconData placeholder;

  @override
  Widget build(BuildContext context) {
    final Widget empty = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(child: Icon(placeholder, color: Theme.of(context).colorScheme.outline)),
    );
    final Widget child = url.isEmpty
        ? empty
        : Image.network(
            url,
            fit: fit,
            width: size,
            height: size,
            errorBuilder: (BuildContext c, Object e, StackTrace? s) => empty,
            loadingBuilder: (BuildContext c, Widget image, ImageChunkEvent? progress) =>
                progress == null ? image : empty,
          );
    return SizedBox(width: size, height: size, child: child);
  }
}

/// A round picture for lists: the photo, or the first letter of the name.
class PhotoAvatar extends StatelessWidget {
  const PhotoAvatar({super.key, required this.url, required this.label, this.radius = 20});

  final String url;
  final String label;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final Widget letter = Center(
      child: Text(label.isEmpty ? '?' : label.substring(0, 1).toUpperCase()),
    );
    return CircleAvatar(
      radius: radius,
      child: ClipOval(
        child: SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: url.isEmpty
              ? letter
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext c, Object e, StackTrace? s) => letter,
                  loadingBuilder: (BuildContext c, Widget image, ImageChunkEvent? p) => p == null ? image : letter,
                ),
        ),
      ),
    );
  }
}

String _messageOf(Object error) =>
    error is AppException ? error.message : L10n.current.photoWidgetsThePhotoCouldNot;

/// The photo of one record (user, category, customer or vendor) with buttons to
/// add, change and remove it. The upload happens at once, not with "Save".
class PhotoEditor extends ConsumerStatefulWidget {
  const PhotoEditor({
    super.key,
    required this.kind,
    required this.entityId,
    required this.photoUrl,
    required this.onChanged,
    this.title,
    this.enabled = true,
  });

  final PhotoKind kind;
  final String entityId;
  final String photoUrl;

  /// Called with the new address ('' after removing).
  final ValueChanged<String> onChanged;
  final String? title;
  final bool enabled;

  @override
  ConsumerState<PhotoEditor> createState() => _PhotoEditorState();
}

class _PhotoEditorState extends ConsumerState<PhotoEditor> {
  late String _url = widget.photoUrl;
  bool _busy = false;
  String _error = '';

  @override
  void didUpdateWidget(PhotoEditor old) {
    super.didUpdateWidget(old);
    if (old.photoUrl != widget.photoUrl && !_busy) {
      _url = widget.photoUrl;
    }
  }

  Future<void> _run(Future<String> Function(PhotoService service) action) async {
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final String url = await action(ref.read(photoServiceProvider));
      if (!mounted) {
        return;
      }
      setState(() => _url = url);
      widget.onChanged(url);
    } catch (error) {
      if (mounted) {
        setState(() => _error = _messageOf(error));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _choose() => _run((PhotoService service) async {
        final PickedPhoto? photo = await service.pick();
        if (photo == null) {
          return _url;
        }
        return service.setPhoto(widget.kind, widget.entityId, photo);
      });

  Future<void> _remove() => _run((PhotoService service) async {
        await service.removePhoto(widget.kind, widget.entityId);
        return '';
      });

  @override
  Widget build(BuildContext context) {
    final bool locked = _busy || !widget.enabled;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: NetworkPhoto(url: _url, size: 96, placeholder: Icons.add_a_photo_outlined),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(widget.title ?? context.l10n.photoWidgetsPhoto, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  FilledButton.tonalIcon(
                    onPressed: locked ? null : _choose,
                    icon: _busy
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.upload_outlined),
                    label: Text(_url.isEmpty ? context.l10n.photoWidgetsAddPhoto : context.l10n.photoWidgetsChangePhoto),
                  ),
                  if (_url.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: locked ? null : _remove,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(context.l10n.photoWidgetsRemove),
                    ),
                ],
              ),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shown instead of the editor on a record that has not been saved yet.
class PhotoAfterSaveHint extends StatelessWidget {
  const PhotoAfterSaveHint({super.key, this.what});

  final String? what;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(Icons.add_a_photo_outlined),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            context.l10n.photoWidgetsSaveFirstThenOpen(what ?? context.l10n.photoWidgetsAPhoto),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

/// The photos of a product: add several, delete, and choose the main one (first).
class ProductPhotosEditor extends ConsumerStatefulWidget {
  const ProductPhotosEditor({
    super.key,
    required this.productId,
    required this.images,
    required this.onChanged,
    this.enabled = true,
  });

  final String productId;
  final List<ProductImage> images;
  final ValueChanged<List<ProductImage>> onChanged;
  final bool enabled;

  @override
  ConsumerState<ProductPhotosEditor> createState() => _ProductPhotosEditorState();
}

class _ProductPhotosEditorState extends ConsumerState<ProductPhotosEditor> {
  late List<ProductImage> _images = List<ProductImage>.of(widget.images);
  bool _busy = false;
  String _error = '';

  Future<void> _run(Future<void> Function(PhotoService service) action) async {
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      await action(ref.read(photoServiceProvider));
      if (mounted) {
        widget.onChanged(List<ProductImage>.unmodifiable(_images));
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = _messageOf(error));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _add() => _run((PhotoService service) async {
        final PickedPhoto? photo = await service.pick();
        if (photo == null) {
          return;
        }
        final ProductImage added = await service.addProductPhoto(widget.productId, photo);
        setState(() => _images = <ProductImage>[..._images, added]);
      });

  Future<void> _remove(ProductImage image) => _run((PhotoService service) async {
        await service.removeProductPhoto(widget.productId, image.id);
        setState(() => _images = _images.where((ProductImage i) => i.id != image.id).toList());
      });

  Future<void> _makeMain(ProductImage image) => _run((PhotoService service) async {
        final List<String> order = <String>[
          image.id,
          ..._images.where((ProductImage i) => i.id != image.id).map((ProductImage i) => i.id),
        ];
        final List<ProductImage> after = await service.reorderProductPhotos(widget.productId, order);
        setState(() => _images = after);
      });

  @override
  Widget build(BuildContext context) {
    final bool locked = _busy || !widget.enabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(context.l10n.onboardingContentPhotos, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            Text(context.l10n.photoWidgetsOf10(_images.length), style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            FilledButton.tonalIcon(
              onPressed: locked || _images.length >= 10 ? null : _add,
              icon: _busy
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_a_photo_outlined),
              label: Text(context.l10n.photoWidgetsAddPhoto),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_images.isEmpty)
          Text(
            context.l10n.photoWidgetsNoPhotosYetThe,
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              separatorBuilder: (BuildContext c, int i) => const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int index) {
                final ProductImage image = _images[index];
                return Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: NetworkPhoto(url: image.mediumUrl, size: 96),
                        ),
                        if (index == 0)
                          Positioned(
                            left: 4,
                            top: 4,
                            child: Chip(
                              label: Text(context.l10n.photoWidgetsMain),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            ),
                          ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          tooltip: context.l10n.photoWidgetsMakeMainPhoto,
                          visualDensity: VisualDensity.compact,
                          onPressed: locked || index == 0 ? null : () => _makeMain(image),
                          icon: const Icon(Icons.star_outline),
                        ),
                        IconButton(
                          tooltip: context.l10n.photoWidgetsDeletePhoto,
                          visualDensity: VisualDensity.compact,
                          onPressed: locked ? null : () => _remove(image),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        if (_error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
      ],
    );
  }
}

/// Disposes a controller that a dialog was using, after the dialog's closing
/// animation has finished (disposing at once makes the fading dialog throw).
void disposeControllerLater(TextEditingController controller) {
  Future<void>.delayed(const Duration(milliseconds: 500), controller.dispose);
}
