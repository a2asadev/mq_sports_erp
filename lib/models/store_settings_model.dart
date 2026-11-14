/// What the owner can change about the online store (`/v1/store-settings`).
/// One record for the whole shop; it is not synced offline.
class StoreSettingsModel {
  const StoreSettingsModel({
    this.enabled = true,
    this.storeName = 'MQ Sports',
    this.contactPhone = '',
    this.notifyEmail = '',
    this.checkoutNote = 'Cash on delivery.',
    this.deliveryFee = 250,
    this.freeDeliveryAbove = 5000,
    this.lowStockBelow = 5,
  });

  /// When false the store shows a closed notice and takes no orders.
  final bool enabled;
  final String storeName;
  final String contactPhone;

  /// New online orders are e-mailed here ('' = no alerts).
  final String notifyEmail;

  /// Shown to shoppers at checkout.
  final String checkoutNote;

  /// Flat delivery charge.
  final double deliveryFee;

  /// Orders whose items cost at least this much are delivered free (0 = never free).
  final double freeDeliveryAbove;

  /// At or below this many units a product shows "Low stock" in the store.
  final int lowStockBelow;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'enabled': enabled,
      'storeName': storeName,
      'contactPhone': contactPhone,
      'notifyEmail': notifyEmail,
      'checkoutNote': checkoutNote,
      'deliveryFee': deliveryFee,
      'freeDeliveryAbove': freeDeliveryAbove,
      'lowStockBelow': lowStockBelow,
    };
  }

  factory StoreSettingsModel.fromMap(Map<String, dynamic> map) {
    const StoreSettingsModel d = StoreSettingsModel();
    return StoreSettingsModel(
      enabled: map['enabled'] as bool? ?? d.enabled,
      storeName: map['storeName'] as String? ?? d.storeName,
      contactPhone: map['contactPhone'] as String? ?? '',
      notifyEmail: map['notifyEmail'] as String? ?? '',
      checkoutNote: map['checkoutNote'] as String? ?? '',
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? d.deliveryFee,
      freeDeliveryAbove: (map['freeDeliveryAbove'] as num?)?.toDouble() ?? d.freeDeliveryAbove,
      lowStockBelow: (map['lowStockBelow'] as num?)?.toInt() ?? d.lowStockBelow,
    );
  }

  StoreSettingsModel copyWith({
    bool? enabled,
    String? storeName,
    String? contactPhone,
    String? notifyEmail,
    String? checkoutNote,
    double? deliveryFee,
    double? freeDeliveryAbove,
    int? lowStockBelow,
  }) {
    return StoreSettingsModel(
      enabled: enabled ?? this.enabled,
      storeName: storeName ?? this.storeName,
      contactPhone: contactPhone ?? this.contactPhone,
      notifyEmail: notifyEmail ?? this.notifyEmail,
      checkoutNote: checkoutNote ?? this.checkoutNote,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      freeDeliveryAbove: freeDeliveryAbove ?? this.freeDeliveryAbove,
      lowStockBelow: lowStockBelow ?? this.lowStockBelow,
    );
  }
}

/// Result of "Send test e-mail".
class TestEmailResult {
  const TestEmailResult({required this.configured, required this.sent});

  /// The server has an e-mail account set up (SMTP).
  final bool configured;

  /// The message was handed to the mail server.
  final bool sent;

  factory TestEmailResult.fromMap(Map<String, dynamic> map) => TestEmailResult(
        configured: map['configured'] as bool? ?? false,
        sent: map['sent'] as bool? ?? false,
      );
}
