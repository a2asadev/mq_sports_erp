import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/l10n/l10n.dart';

/// Clean, user-facing text for any error.
String errorMessageOf(Object error) {
  return error is AppException ? error.message : L10n.current.commonSomethingWentWrong;
}
