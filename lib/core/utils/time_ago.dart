import 'package:a2_stocks/l10n/l10n.dart';

/// "just now", "5 min ago", "3 h ago", "2 d ago" in the language of the app.
String timeAgo(AppLocalizations l10n, DateTime when, {DateTime? now}) {
  final Duration d = (now ?? DateTime.now()).difference(when);
  if (d.inMinutes < 1) {
    return l10n.heldSalesJustNow;
  }
  if (d.inMinutes < 60) {
    return l10n.heldSalesMinAgo(d.inMinutes);
  }
  if (d.inHours < 24) {
    return l10n.heldSalesHAgo(d.inHours);
  }
  return l10n.heldSalesDAgo(d.inDays);
}
