/// Which side of a trade a party is on.
enum PartyType {
  vendor('Vendor'),
  customer('Customer');

  const PartyType(this.label);

  final String label;

  static PartyType fromName(String? name) {
    for (final PartyType type in PartyType.values) {
      if (type.name == name) {
        return type;
      }
    }
    return PartyType.customer;
  }

  /// Wording for a balance. A positive balance means the customer owes us,
  /// or that we owe the vendor.
  String balanceCaption(double balance) {
    if (balance.abs() < 0.005) {
      return 'Settled';
    }
    final bool positive = balance > 0;
    if (this == PartyType.customer) {
      return positive ? 'To receive' : 'Advance received';
    }
    return positive ? 'To pay' : 'Advance paid';
  }
}

/// A ledger entry either raises the balance (charge) or lowers it (payment).
enum LedgerEntryType {
  charge,
  payment;

  static LedgerEntryType fromName(String? name) {
    for (final LedgerEntryType type in LedgerEntryType.values) {
      if (type.name == name) {
        return type;
      }
    }
    return LedgerEntryType.charge;
  }

  String labelFor(PartyType party) {
    switch (this) {
      case LedgerEntryType.charge:
        return party == PartyType.customer ? 'Sale on credit' : 'Purchase on credit';
      case LedgerEntryType.payment:
        return party == PartyType.customer ? 'Payment received' : 'Payment made';
    }
  }
}

enum VendorType {
  manufacturer('Manufacturer'),
  shop('Shop'),
  other('Other');

  const VendorType(this.label);

  final String label;

  static VendorType fromName(String? name) {
    for (final VendorType type in VendorType.values) {
      if (type.name == name) {
        return type;
      }
    }
    return VendorType.other;
  }
}

enum CustomerType {
  retail('Retail'),
  wholesale('Wholesale');

  const CustomerType(this.label);

  final String label;

  static CustomerType fromName(String? name) {
    for (final CustomerType type in CustomerType.values) {
      if (type.name == name) {
        return type;
      }
    }
    return CustomerType.retail;
  }
}
