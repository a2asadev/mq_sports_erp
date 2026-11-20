import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:a2_stocks/l10n/app_localizations.dart';

export 'package:a2_stocks/l10n/app_localizations.dart';

/// `context.l10n.authSignIn`: the app's text in the current language.
///
/// Every word the user reads belongs in `lib/l10n/app_en.arb`, not in the code,
/// so a new language is one more .arb file (see `l10n.yaml`).
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// The app's text for code that has no [BuildContext] (providers, models, error
/// messages, receipts). Prefer `context.l10n` in widgets. `MqSportsApp` keeps
/// [current] in step with the language the app is showing; until the app has
/// started it is the template language.
class L10n {
  L10n._();

  static final Set<String> _dateLocales = <String>{};

  static AppLocalizations current = _initial();

  static AppLocalizations _initial() {
    const Locale template = Locale('en');
    _registerDates(template.languageCode);
    return lookupAppLocalizations(template);
  }

  /// Called by the app whenever its localizations are (re)resolved.
  static void use(AppLocalizations localizations) {
    _registerDates(localizations.localeName);
    current = localizations;
  }

  /// Month and weekday names for code that formats dates without a context
  /// (the chart labels). Only the language in use is registered, once: the names
  /// of every language are not kept in memory. (The Material widgets register
  /// theirs on their own; this covers code that runs before or outside them.)
  static void _registerDates(String localeName) {
    if (_dateLocales.add(localeName)) {
      // The names are built into the intl package, so this finishes at once.
      unawaited(initializeDateFormatting(localeName));
    }
  }
}
