import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mq_sports_erp/models/store_settings_model.dart';
import 'package:mq_sports_erp/online/api_client.dart';
import 'package:mq_sports_erp/online/online_providers.dart';
import 'package:mq_sports_erp/online/token_store.dart';
import 'package:mq_sports_erp/screens/settings/settings_screen.dart';

const String _admin =
    '{"id":"u1","email":"boss@shop.co","displayName":"Boss","phoneNumber":"","role":"admin","isActive":true,'
    '"photoUrl":"","createdAt":"2026-11-01T00:00:00.000Z","updatedAt":"2026-11-01T00:00:00.000Z"}';

http.Response _json(int status, String body) =>
    http.Response(body, status, headers: <String, String>{'content-type': 'application/json'});

void main() {
  late List<http.Request> calls;
  late Map<String, dynamic> testEmailAnswer;

  Future<ProviderContainer> pumpForm(WidgetTester tester, {required bool canEdit}) async {
    calls = <http.Request>[];
    testEmailAnswer = <String, dynamic>{'configured': true, 'sent': true};
    final MockClient mock = MockClient((http.Request r) async {
      if (r.url.path == '/v1/auth/login') {
        return _json(200, '{"accessToken":"a","refreshToken":"r","user":$_admin}');
      }
      calls.add(r);
      if (r.url.path == '/v1/store-settings/test-email') {
        return _json(200, jsonEncode(testEmailAnswer));
      }
      if (r.method == 'PUT') {
        return _json(200, r.body);
      }
      return _json(200, '{}');
    });
    final ApiClient api = ApiClient(httpClient: mock, baseUrl: 'http://api.test', tokens: MemoryTokenStore());
    await api.login('boss@shop.co', 'x');
    final ProviderContainer container = ProviderContainer(overrides: [apiClientProvider.overrideWithValue(api)]);
    addTearDown(container.dispose);
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StoreSettingsForm(
              initial: const StoreSettingsModel(deliveryFee: 250, freeDeliveryAbove: 5000),
              canEdit: canEdit,
              myEmail: 'boss@shop.co',
            ),
          ),
        ),
      ),
    ));
    return container;
  }

  testWidgets('an admin saves the settings; the server gets the exact values', (WidgetTester tester) async {
    await pumpForm(tester, canEdit: true);
    await tester.enterText(find.widgetWithText(TextFormField, 'Store name'), 'Sports Hub');
    await tester.enterText(find.widgetWithText(TextFormField, 'Delivery fee'), '300.5');
    await tester.enterText(find.widgetWithText(TextFormField, 'Free delivery from'), '0');
    await tester.enterText(find.widgetWithText(TextFormField, 'Send new-order alerts to (e-mail)'), 'owner@shop.co');
    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.tap(find.text('Save settings'));
    await tester.pumpAndSettle();

    final http.Request put = calls.singleWhere((http.Request r) => r.method == 'PUT');
    expect(put.url.path, '/v1/store-settings');
    final Map<String, dynamic> sent = jsonDecode(put.body) as Map<String, dynamic>;
    expect(sent['storeName'], 'Sports Hub');
    expect(sent['deliveryFee'], 300.5);
    expect(sent['freeDeliveryAbove'], 0);
    expect(sent['notifyEmail'], 'owner@shop.co');
    expect(sent['enabled'], isFalse);
    expect(find.textContaining('The store is closed'), findsOneWidget);
  });

  testWidgets('bad values are caught before anything is sent', (WidgetTester tester) async {
    await pumpForm(tester, canEdit: true);
    await tester.enterText(find.widgetWithText(TextFormField, 'Delivery fee'), '-5');
    await tester.enterText(find.widgetWithText(TextFormField, 'Send new-order alerts to (e-mail)'), 'not-an-email');
    await tester.enterText(find.widgetWithText(TextFormField, 'Store name'), '  ');
    await tester.tap(find.text('Save settings'));
    await tester.pumpAndSettle();
    expect(find.text('Enter an amount of 0 or more.'), findsOneWidget);
    expect(find.text('Enter a valid e-mail address.'), findsOneWidget);
    expect(find.text('Enter the store name.'), findsOneWidget);
    expect(calls.where((http.Request r) => r.method == 'PUT'), isEmpty);
  });

  testWidgets('a manager sees the settings but cannot change or save them', (WidgetTester tester) async {
    await pumpForm(tester, canEdit: false);
    expect(find.text('Only an admin can change these.'), findsOneWidget);
    expect(find.text('Save settings'), findsNothing);
    expect(find.text('Send test e-mail'), findsNothing);
    final TextField name = tester.widget<TextField>(find.descendant(
      of: find.widgetWithText(TextFormField, 'Store name'),
      matching: find.byType(TextField),
    ));
    expect(name.enabled, isFalse);
  });

  testWidgets('the test e-mail button reports success and an unset mail server', (WidgetTester tester) async {
    await pumpForm(tester, canEdit: true);
    await tester.tap(find.text('Send test e-mail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Test e-mail sent to boss@shop.co'), findsOneWidget);
    expect(jsonDecode(calls.last.body), <String, dynamic>{'to': 'boss@shop.co'});

    testEmailAnswer = <String, dynamic>{'configured': false, 'sent': false};
    await tester.tap(find.text('Send test e-mail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(find.textContaining('not set up on the server'), findsOneWidget);
  });
}
