import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/models/payment_method.dart';
import 'package:a2_stocks/screens/pos/pos_payment_dialog.dart';

void main() {
  PosPaymentResult? result;
  bool closed = false;

  Future<void> open(WidgetTester tester, {double total = 1000, bool allowCredit = false}) async {
    result = null;
    closed = false;
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (BuildContext context) => TextButton(
          onPressed: () async {
            result = await showPosPaymentDialog(context, total: total, allowCredit: allowCredit);
            closed = true;
          },
          child: const Text('pay'),
        ),
      ),
    ));
    await tester.tap(find.text('pay'));
    await tester.pumpAndSettle();
  }

  testWidgets('cash over the total gives change and the sale is completed with the owed amount', (WidgetTester tester) async {
    await open(tester, total: 850);
    await tester.enterText(find.byType(TextField).first, '1000');
    await tester.tap(find.text('Add payment'));
    await tester.pumpAndSettle();
    expect(find.text('Fully paid'), findsOneWidget);
    expect(find.text('Give change: Rs 150'), findsOneWidget);
    await tester.tap(find.text('Complete sale'));
    await tester.pumpAndSettle();
    expect(result?.change, 150);
    expect(result?.lines.single.amount, 850);
    expect(result?.lines.single.method, PaymentMethod.cash);
  });

  testWidgets('a split between cash, Easypaisa and bank asks for the references', (WidgetTester tester) async {
    await open(tester, total: 1000);
    expect(find.widgetWithText(FilledButton, 'Complete sale'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Complete sale')).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, '400');
    await tester.tap(find.text('Add payment'));
    await tester.pumpAndSettle();
    expect(find.text('Left to pay: Rs 600'), findsOneWidget);

    await tester.tap(find.text('Easypaisa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add payment')); // no transaction number yet
    await tester.pumpAndSettle();
    expect(find.text('Enter the Easypaisa transaction number.'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Transaction no.'), 'EP-77');
    await tester.enterText(find.widgetWithText(TextField, 'Amount'), '350');
    await tester.tap(find.text('Add payment'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bank transfer'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Bank and transaction no.'), 'HBL 5');
    await tester.tap(find.text('Add payment')); // amount defaults to what is left (250)
    await tester.pumpAndSettle();
    expect(find.text('Fully paid'), findsOneWidget);

    await tester.tap(find.text('Complete sale'));
    await tester.pumpAndSettle();
    expect(result?.lines.map((PaymentLine l) => '${l.method.name}:${l.amount}:${l.reference}'),
        <String>['cash:400.0:', 'easypaisa:350.0:EP-77', 'bank:250.0:HBL 5']);
  });

  testWidgets('only a named customer may be sold to on credit', (WidgetTester tester) async {
    await open(tester, allowCredit: false);
    expect(find.textContaining('Sell on credit'), findsNothing);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
    expect(result, isNull);

    await open(tester, allowCredit: true);
    await tester.enterText(find.byType(TextField).first, '300');
    await tester.tap(find.text('Add payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sell with Rs 700 due'));
    await tester.pumpAndSettle();
    expect(result?.lines.single.amount, 300);
    expect(result?.change, 0);
  });
}
