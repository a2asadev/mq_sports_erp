import 'package:mq_sports_erp/core/errors/app_exceptions.dart';

/// Clean, user-facing text for any error.
String errorMessageOf(Object error) {
  return error is AppException ? error.message : 'Something went wrong.';
}
