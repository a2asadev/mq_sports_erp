import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/l10n/app_localizations_en.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/online/api_client.dart';
import 'package:a2_stocks/online/api_error_text.dart';

/// A stand-in for a translated language: only the words differ.
class _Spanish extends AppLocalizationsEn {
  @override
  String get apiErrorOrdersOrderNotFound => 'Pedido no encontrado';

  @override
  String apiErrorOrdersThisOrderWouldTakeOverThe(String name, String limit, String balance) =>
      'Este pedido dejaría a $name por encima del límite ($limit, saldo $balance).';
}

void main() {
  final AppLocalizations en = lookupAppLocalizations(const Locale('en'));

  group('an API error with a code', () {
    test('is written in the app\'s language from its code and values', () {
      expect(apiErrorText(en, 'orders.order_not_found', const <String, Object?>{}), 'Order not found');
      expect(
        apiErrorText(en, 'categories.a_category_named_already_exists_here', <String, Object?>{'name': 'Bats'}),
        'A category named "Bats" already exists here.',
      );
      expect(apiErrorText(en, 'categories.delete_used_by_products', <String, Object?>{'count': 1}),
          'This category cannot be deleted because it is used by 1 product.');
      expect(apiErrorText(en, 'categories.delete_used_by_products', <String, Object?>{'count': 3}),
          'This category cannot be deleted because it is used by 3 products.');
    });

    test('shows order statuses in the app\'s language too', () {
      expect(apiErrorText(en, 'orders.cannot_cancel_in_status', <String, Object?>{'status': 'delivered'}),
          'A delivered order cannot be cancelled.');
      expect(apiErrorText(en, 'orders.an_order_cannot_move_from_to', <String, Object?>{'from': 'Pending', 'to': 'Delivered'}),
          'An order cannot move from Pending to Delivered.');
    });

    test('follows another language once its words exist', () {
      final AppLocalizations es = _Spanish();
      expect(apiErrorText(es, 'orders.order_not_found', const <String, Object?>{}), 'Pedido no encontrado');
      expect(
        apiErrorText(es, 'orders.this_order_would_take_over_the', <String, Object?>{'name': 'Ali', 'limit': '500.00', 'balance': '600.00'}),
        'Este pedido dejaría a Ali por encima del límite (500.00, saldo 600.00).',
      );
    });

    test('an unknown code keeps the server\'s own English message', () {
      expect(apiErrorText(en, 'brand.new_code', const <String, Object?>{}), isNull);
      final AppException error = exceptionFor(409, <String, dynamic>{
        'statusCode': 409,
        'message': 'Something only a newer server knows.',
        'code': 'brand.new_code',
        'params': <String, dynamic>{},
      });
      expect(error, isA<ValidationException>());
      expect(error.message, 'Something only a newer server knows.');
      expect(error.code, 'brand.new_code');
    });

    test('exceptionFor uses the code, keeps it for logic, and still copes with an old server', () {
      final AppException known = exceptionFor(404, <String, dynamic>{
        'message': 'Order not found',
        'code': 'orders.order_not_found',
        'params': <String, dynamic>{},
      });
      expect(known, isA<ValidationException>());
      expect(known.message, 'Order not found');
      expect(known.code, 'orders.order_not_found');

      final AppException old = exceptionFor(409, <String, dynamic>{'message': 'Order not found'});
      expect(old.message, 'Order not found');
      expect(old.code, '');

      expect(exceptionFor(401, <String, dynamic>{'code': 'auth.invalid_email_or_password', 'message': 'x'}), isA<AuthFailureException>());
      expect(exceptionFor(403, <String, dynamic>{'code': 'auth.you_do_not_have_permission_for', 'message': 'x'}), isA<PermissionDeniedException>());
    });
  });
}
