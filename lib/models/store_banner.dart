/// A picture at the top of the online store's home page (`/v1/banners`).
class StoreBanner {
  const StoreBanner({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.buttonText = '',
    this.linkUrl = '',
    this.imageUrl = '',
    this.position = 0,
    this.isActive = true,
  });

  final String id;
  final String title;
  final String subtitle;
  final String buttonText;

  /// A page of the store ("/products") or an https address; '' = no link.
  final String linkUrl;

  /// '' while the banner has no picture (it is not shown in the store without one).
  final String imageUrl;
  final int position;
  final bool isActive;

  factory StoreBanner.fromMap(Map<String, dynamic> m) => StoreBanner(
        id: '${m['id'] ?? ''}',
        title: '${m['title'] ?? ''}',
        subtitle: '${m['subtitle'] ?? ''}',
        buttonText: '${m['buttonText'] ?? ''}',
        linkUrl: '${m['linkUrl'] ?? ''}',
        imageUrl: '${m['imageUrl'] ?? ''}',
        position: (m['position'] as num?)?.toInt() ?? 0,
        isActive: m['isActive'] != false,
      );

  StoreBanner copyWith({String? imageUrl}) => StoreBanner(
        id: id,
        title: title,
        subtitle: subtitle,
        buttonText: buttonText,
        linkUrl: linkUrl,
        imageUrl: imageUrl ?? this.imageUrl,
        position: position,
        isActive: isActive,
      );

  /// Whether a link is one the server accepts: nothing, a page of the store (starting with a single "/"), or https.
  static bool isSafeLink(String link) => link.isEmpty || RegExp(r'^/(?!/)\S*$').hasMatch(link) || RegExp(r'^https://\S+$', caseSensitive: false).hasMatch(link);
}
