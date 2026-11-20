/// The end of a day at the cash register: what should have been in the drawer
/// against what was counted. Written by the server (`/v1/register`).
class RegisterClosing {
  const RegisterClosing({
    required this.id,
    required this.date,
    required this.openingCash,
    required this.expectedCash,
    required this.countedCash,
    required this.difference,
    required this.note,
    required this.closedByName,
    required this.closedAt,
  });

  final String id;

  /// The day, "YYYY-MM-DD", in the business's own time zone.
  final String date;
  final double openingCash;
  final double expectedCash;
  final double countedCash;

  /// Counted minus expected: negative means cash is missing.
  final double difference;
  final String note;
  final String closedByName;
  final DateTime closedAt;

  bool get balanced => difference.abs() < 0.005;

  factory RegisterClosing.fromMap(Map<String, dynamic> map) => RegisterClosing(
        id: '${map['id'] ?? ''}',
        date: '${map['date'] ?? ''}',
        openingCash: _money(map['openingCash']),
        expectedCash: _money(map['expectedCash']),
        countedCash: _money(map['countedCash']),
        difference: _money(map['difference']),
        note: '${map['note'] ?? ''}',
        closedByName: '${map['closedByName'] ?? ''}',
        closedAt: DateTime.tryParse('${map['closedAt'] ?? ''}')?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0),
      );
}

/// One day at the register: the cash that should be there and, when the day is
/// closed, its closing.
class RegisterDay {
  const RegisterDay({
    required this.date,
    required this.isToday,
    required this.openingCash,
    required this.cashReceived,
    required this.cashPaid,
    required this.cashRefunded,
    this.cashExpenses = 0,
    required this.expectedCash,
    required this.bankReceived,
    required this.easypaisaReceived,
    required this.jazzcashReceived,
    required this.salesTotal,
    required this.salesCount,
    this.closing,
  });

  /// "YYYY-MM-DD" in the business's own time zone.
  final String date;
  final bool isToday;

  /// What the last closing counted (0 before the first one).
  final double openingCash;

  /// Cash received from customers, and cash paid to vendors, during the day.
  final double cashReceived;
  final double cashPaid;

  /// Cash handed back to customers for returned goods.
  final double cashRefunded;

  /// Cash spent on expenses (rent, salaries...).
  final double cashExpenses;

  /// Opening + received - paid - refunded - spent.
  final double expectedCash;
  final double bankReceived;
  final double easypaisaReceived;
  final double jazzcashReceived;
  final double salesTotal;
  final int salesCount;
  final RegisterClosing? closing;

  bool get isClosed => closing != null;

  /// Money that came in by other means than cash.
  double get otherReceived => bankReceived + easypaisaReceived + jazzcashReceived;

  factory RegisterDay.fromMap(Map<String, dynamic> map) {
    final Object? other = map['otherReceived'];
    final Map<String, dynamic> others = other is Map<String, dynamic> ? other : const <String, dynamic>{};
    final Object? closing = map['closing'];
    return RegisterDay(
      date: '${map['date'] ?? ''}',
      isToday: map['isToday'] == true,
      openingCash: _money(map['openingCash']),
      cashReceived: _money(map['cashReceived']),
      cashPaid: _money(map['cashPaid']),
      cashRefunded: _money(map['cashRefunded']),
      cashExpenses: _money(map['cashExpenses']),
      expectedCash: _money(map['expectedCash']),
      bankReceived: _money(others['bank']),
      easypaisaReceived: _money(others['easypaisa']),
      jazzcashReceived: _money(others['jazzcash']),
      salesTotal: _money(map['salesTotal']),
      salesCount: (map['salesCount'] is num) ? (map['salesCount'] as num).toInt() : 0,
      closing: closing is Map<String, dynamic> ? RegisterClosing.fromMap(closing) : null,
    );
  }
}

double _money(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse('${value ?? ''}') ?? 0;
}
