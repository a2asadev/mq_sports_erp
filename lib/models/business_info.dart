import 'package:mq_sports_erp/core/constants/walk_in.dart';

/// The business the signed-in person works for, as the server describes it at
/// sign-in: what to print on receipts, and which customer record is this
/// business's walk-in customer (every business has its own).
///
/// It is saved with the session, so the app knows it without a connection.
class BusinessInfo {
  const BusinessInfo({
    required this.id,
    required this.name,
    required this.walkInCustomerId,
    this.phone = '',
    this.hasOnlineStore = true,
    this.currency = 'PKR',
  });

  /// The tenant id on the server.
  final String id;

  /// The shop's name for receipts and messages.
  final String name;
  final String phone;

  /// Whether the public online store is this business's. Only one business runs
  /// it; the others do not see the Online store settings. Assumed true when the
  /// server does not say (it only knew one business then).
  final bool hasOnlineStore;

  /// ISO 4217 code of the business's money ("PKR"); see `CurrencyInfo`.
  final String currency;

  /// The customer record behind counter sales to people who just walk in. Empty
  /// when the business has none.
  final String walkInCustomerId;

  /// MQ Sports, the first business on the server. Used until the server has told
  /// the app otherwise: a session saved before businesses existed can only be MQ
  /// Sports'.
  static const BusinessInfo mqSports = BusinessInfo(
    id: '00000000-0000-4000-8000-0000000000a1',
    name: 'MQ Sports',
    walkInCustomerId: mqSportsWalkInCustomerId,
  );

  /// Whether [customerId] is this business's walk-in customer.
  bool isWalkIn(String customerId) => walkInCustomerId.isNotEmpty && customerId == walkInCustomerId;

  /// Reads the server's `tenant` object; null when it is missing or incomplete.
  static BusinessInfo? tryFromMap(Object? map) {
    if (map is! Map<String, dynamic>) {
      return null;
    }
    final Object? id = map['id'];
    final Object? name = map['name'];
    if (id is! String || id.isEmpty || name is! String || name.trim().isEmpty) {
      return null;
    }
    final Object? phone = map['phone'];
    final Object? walkIn = map['walkInCustomerId'];
    final Object? store = map['hasOnlineStore'];
    final Object? currency = map['currency'];
    return BusinessInfo(
      id: id,
      name: name.trim(),
      phone: phone is String ? phone.trim() : '',
      walkInCustomerId: walkIn is String ? walkIn : '',
      hasOnlineStore: store is bool ? store : true,
      currency: currency is String && RegExp(r'^[A-Z]{3}$').hasMatch(currency) ? currency : 'PKR',
    );
  }

  BusinessInfo copyWith({String? name, String? phone, String? currency}) => BusinessInfo(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        walkInCustomerId: walkInCustomerId,
        hasOnlineStore: hasOnlineStore,
        currency: currency ?? this.currency,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'name': name,
        'phone': phone,
        'walkInCustomerId': walkInCustomerId,
        'hasOnlineStore': hasOnlineStore,
        'currency': currency,
      };

  @override
  bool operator ==(Object other) =>
      other is BusinessInfo &&
      other.id == id &&
      other.name == name &&
      other.phone == phone &&
      other.walkInCustomerId == walkInCustomerId &&
      other.hasOnlineStore == hasOnlineStore &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(id, name, phone, walkInCustomerId, hasOnlineStore, currency);
}
