/// Text the server itself writes into records. The app compares with it, so it
/// is not translated: it is data, not something the app says.
class ServerText {
  const ServerText._();

  /// Start of the description of the ledger entry that reverses a cancelled order.
  static const String cancelledOrderLedgerPrefix = 'Cancelled order';
}
