/// Display-ready summary of a vendor or customer, used by lists and pickers.
class PartyListItem {
  const PartyListItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.phone,
    required this.typeKey,
    required this.typeLabel,
    required this.balance,
    required this.creditLimit,
    required this.isActive,
    required this.searchText,
  });

  final String id;
  final String title;
  final String subtitle;
  final String phone;

  /// Machine value of the party type (for filtering) and its label.
  final String typeKey;
  final String typeLabel;

  /// Opening balance plus ledger entries.
  final double balance;

  /// 0 = no limit.
  final double creditLimit;
  final bool isActive;

  /// Lowercased text the search box matches against.
  final String searchText;

  bool get hasBalance => balance.abs() >= 0.005;

  bool get isOverLimit => creditLimit > 0 && balance > creditLimit;
}
