import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/online/api_client.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/token_store.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/providers/users_providers.dart';
import 'package:a2_stocks/screens/settings/settings_screen.dart';

class _FakeCurrentUser extends CurrentUserNotifier {
  _FakeCurrentUser(this._user);

  final UserModel _user;

  @override
  Future<UserModel?> build() async => _user;
}

http.Response _json(int status, String body) =>
    http.Response(body, status, headers: <String, String>{'content-type': 'application/json'});

const BusinessInfo _withStore = BusinessInfo(id: 't1', name: 'MQ Sports', walkInCustomerId: 'w1');
const BusinessInfo _withoutStore = BusinessInfo(id: 't2', name: 'Ali Traders', walkInCustomerId: 'w2', hasOnlineStore: false);

void main() {
  late List<http.Request> calls;

  Future<void> pumpSettings(WidgetTester tester, {required UserRole role, required BusinessInfo business}) async {
    calls = <http.Request>[];
    final MockClient mock = MockClient((http.Request r) async {
      calls.add(r);
      if (r.url.path == '/v1/store-settings') {
        if (r.method == 'PUT') {
          return _json(200, r.body);
        }
        return _json(
          200,
          jsonEncode(<String, dynamic>{
            'enabled': false,
            'storeName': 'Ali Traders',
            'contactPhone': '0300-1',
            'notifyEmail': 'alerts@ali.test',
            'checkoutNote': 'Call first',
            'deliveryFee': 120,
            'freeDeliveryAbove': 3000,
            'lowStockBelow': 7,
          }),
        );
      }
      if (r.url.path == '/v1/business' && r.method == 'PUT') {
        final Map<String, dynamic> sent = jsonDecode(r.body) as Map<String, dynamic>;
        return _json(200, jsonEncode(<String, dynamic>{'id': 't2', 'name': 'Ali Traders', ...sent}));
      }
      return _json(200, '{}');
    });
    final ApiClient api = ApiClient(httpClient: mock, baseUrl: 'http://api.test', tokens: MemoryTokenStore());
    final UserModel user = UserModel(id: 'u1', email: 'boss@ali.test', displayName: 'Boss', role: role);
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        apiClientProvider.overrideWithValue(api),
        currentUserProvider.overrideWith(() => _FakeCurrentUser(user)),
        businessProvider.overrideWithValue(business),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('the business that runs the online store sees Online store, and Shop details for its currency only', (WidgetTester tester) async {
    await pumpSettings(tester, role: UserRole.admin, business: _withStore);
    expect(find.text('Online store'), findsOneWidget);
    expect(find.text('Shop details'), findsOneWidget);
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Help & guide'), findsOneWidget);

    await tester.tap(find.text('Shop details'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(DropdownButtonFormField<String>, 'Currency'), findsOneWidget);
    // Its name and phone are edited under Online store, so they are not asked for twice.
    expect(find.widgetWithText(TextFormField, 'Shop name'), findsNothing);
    expect(calls.where((http.Request r) => r.url.path == '/v1/store-settings'), isEmpty);
  });

  testWidgets('choosing another currency saves it on the server, and only it', (WidgetTester tester) async {
    await pumpSettings(tester, role: UserRole.admin, business: _withStore);
    await tester.tap(find.text('Shop details'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AED · UAE dirham (AED)').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final http.Request put = calls.singleWhere((http.Request r) => r.method == 'PUT');
    expect(put.url.path, '/v1/business');
    expect(jsonDecode(put.body), <String, dynamic>{'currency': 'AED'});
    expect(find.text('Saved.'), findsOneWidget);
  });

  testWidgets('saving without changing the currency does not call the currency endpoint', (WidgetTester tester) async {
    await pumpSettings(tester, role: UserRole.admin, business: _withStore);
    await tester.tap(find.text('Shop details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(calls.where((http.Request r) => r.method == 'PUT'), isEmpty);
  });

  testWidgets('another business does not see the Online store section, but can set its shop details', (WidgetTester tester) async {
    await pumpSettings(tester, role: UserRole.admin, business: _withoutStore);
    expect(find.text('Online store'), findsNothing);
    expect(find.text('Shop details'), findsOneWidget);

    await tester.tap(find.text('Shop details'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Shop name'), findsOneWidget);
    expect(find.text('Send test e-mail'), findsNothing);

    await tester.enterText(find.widgetWithText(TextFormField, 'Shop name'), 'Ali Store');
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone'), '0300-9');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final http.Request put = calls.singleWhere((http.Request r) => r.method == 'PUT');
    final Map<String, dynamic> sent = jsonDecode(put.body) as Map<String, dynamic>;
    expect(sent['storeName'], 'Ali Store');
    expect(sent['contactPhone'], '0300-9');
    // Everything else in the record stays as the server had it.
    expect(sent['notifyEmail'], 'alerts@ali.test');
    expect(sent['checkoutNote'], 'Call first');
    expect(sent['deliveryFee'], 120);
    expect(sent['freeDeliveryAbove'], 3000);
    expect(sent['lowStockBelow'], 7);
    expect(sent['enabled'], isFalse);
    expect(find.text('Saved.'), findsOneWidget);
    // The currency was not touched, so only the store record was written.
    expect(calls.where((http.Request r) => r.url.path == '/v1/business'), isEmpty);
  });

  testWidgets('an empty shop name is caught before anything is sent', (WidgetTester tester) async {
    await pumpSettings(tester, role: UserRole.admin, business: _withoutStore);
    await tester.tap(find.text('Shop details'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Shop name'), '  ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter the shop name.'), findsOneWidget);
    expect(calls.where((http.Request r) => r.method == 'PUT'), isEmpty);
  });

  testWidgets('a manager sees the shop details but cannot change them; staff see neither section', (WidgetTester tester) async {
    await pumpSettings(tester, role: UserRole.manager, business: _withoutStore);
    await tester.tap(find.text('Shop details'));
    await tester.pumpAndSettle();
    expect(find.text('Only an admin can change these.'), findsOneWidget);
    expect(find.text('Save'), findsNothing);
  });

  testWidgets('staff see neither the online store nor the shop details', (WidgetTester tester) async {
    await pumpSettings(tester, role: UserRole.staff, business: _withoutStore);
    expect(find.text('Online store'), findsNothing);
    expect(find.text('Shop details'), findsNothing);
    await pumpSettings(tester, role: UserRole.staff, business: _withStore);
    expect(find.text('Online store'), findsNothing);
    expect(find.text('Shop details'), findsNothing);
  });

  testWidgets('picking a brand colour saves just the colour', (WidgetTester tester) async {
    await pumpSettings(tester, role: UserRole.admin, business: _withStore);
    await tester.tap(find.text('Shop details'));
    await tester.pumpAndSettle();
    expect(find.text('Brand colour'), findsOneWidget);
    expect(find.byType(BrandSwatch), findsNWidgets(brandChoices.length));

    await tester.tap(find.byTooltip('Blue'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final http.Request put = calls.singleWhere((http.Request r) => r.method == 'PUT');
    expect(put.url.path, '/v1/business');
    expect(jsonDecode(put.body), <String, dynamic>{'brandColor': '#2563EB'});
    expect(find.text('Saved.'), findsOneWidget);
  });

  testWidgets('going back to the A2 Stocks teal sends an empty colour', (WidgetTester tester) async {
    await pumpSettings(
      tester,
      role: UserRole.admin,
      business: const BusinessInfo(id: 't1', name: 'MQ Sports', walkInCustomerId: 'w1', brandColor: '#2563EB'),
    );
    await tester.tap(find.text('Shop details'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('A2 Stocks teal'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(jsonDecode(calls.singleWhere((http.Request r) => r.method == 'PUT').body), <String, dynamic>{'brandColor': ''});
  });

  testWidgets('currency and colour changed together go in one request', (WidgetTester tester) async {
    await pumpSettings(tester, role: UserRole.admin, business: _withStore);
    await tester.tap(find.text('Shop details'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Green'));
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AED · UAE dirham (AED)').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final List<http.Request> puts = calls.where((http.Request r) => r.method == 'PUT').toList();
    expect(puts, hasLength(1));
    expect(jsonDecode(puts.single.body), <String, dynamic>{'currency': 'AED', 'brandColor': '#16A34A'});
  });

  testWidgets('the logo can be changed by an admin only', (WidgetTester tester) async {
    await pumpSettings(tester, role: UserRole.admin, business: _withStore);
    await tester.tap(find.text('Shop details'));
    await tester.pumpAndSettle();
    expect(find.text('Logo'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('a manager cannot change the logo or the colour', (WidgetTester tester) async {
    await pumpSettings(tester, role: UserRole.manager, business: _withStore);
    await tester.tap(find.text('Shop details'));
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsNothing);
    // A manager's tap on a colour changes nothing that can be saved.
    await tester.tap(find.byTooltip('Blue'));
    await tester.pump();
    expect(calls.where((http.Request r) => r.method == 'PUT'), isEmpty);
  });

  testWidgets('Help & guide says what this software is and who made it', (WidgetTester tester) async {
    await pumpSettings(tester, role: UserRole.staff, business: _withStore);
    await tester.tap(find.text('Help & guide'));
    await tester.pumpAndSettle();
    expect(find.text('A2 Stocks'), findsOneWidget);
    expect(find.text('POS & Inventory Software'), findsOneWidget);
    expect(find.text('Crafted with love by A2 Devs.'), findsOneWidget);
    expect(find.text('Welcome guide'), findsOneWidget);
  });
}
