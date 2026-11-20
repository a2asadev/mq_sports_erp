/// Which side of a trade a party is on.
enum PartyType {
  vendor,
  customer;

  static PartyType fromName(String? name) {
    for (final PartyType type in PartyType.values) {
      if (type.name == name) {
        return type;
      }
    }
    return PartyType.customer;
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
}

enum VendorType {
  manufacturer,
  shop,
  other;

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
  retail,
  wholesale;

  static CustomerType fromName(String? name) {
    for (final CustomerType type in CustomerType.values) {
      if (type.name == name) {
        return type;
      }
    }
    return CustomerType.retail;
  }
}
