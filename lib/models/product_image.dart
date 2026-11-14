/// One published photo of a product (made by the server in three sizes).
/// Photos are changed only through the photo upload, never by saving the product.
class ProductImage {
  const ProductImage({
    required this.id,
    this.variantId = '',
    this.position = 0,
    this.width = 0,
    this.height = 0,
    this.thumbUrl = '',
    this.mediumUrl = '',
    this.largeUrl = '',
  });

  final String id;

  /// The variant this photo shows, or '' for the product in general.
  final String variantId;
  final int position;
  final int width;
  final int height;

  /// 200, 600 and 1600 pixels on the longest side.
  final String thumbUrl;
  final String mediumUrl;
  final String largeUrl;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'variantId': variantId,
      'position': position,
      'width': width,
      'height': height,
      'thumbUrl': thumbUrl,
      'mediumUrl': mediumUrl,
      'largeUrl': largeUrl,
    };
  }

  factory ProductImage.fromMap(Map<String, dynamic> map) {
    return ProductImage(
      id: map['id'] as String? ?? '',
      variantId: map['variantId'] as String? ?? '',
      position: (map['position'] as num?)?.toInt() ?? 0,
      width: (map['width'] as num?)?.toInt() ?? 0,
      height: (map['height'] as num?)?.toInt() ?? 0,
      thumbUrl: map['thumbUrl'] as String? ?? '',
      mediumUrl: map['mediumUrl'] as String? ?? '',
      largeUrl: map['largeUrl'] as String? ?? '',
    );
  }
}
