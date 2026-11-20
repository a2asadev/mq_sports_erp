import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/core/erp_module.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/models/register_day.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/online/register_service.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/providers/module_registry_provider.dart';
import 'package:a2_stocks/providers/register_providers.dart';
import 'package:a2_stocks/providers/users_providers.dart';
import 'package:a2_stocks/screens/register/register_choice.dart';
import 'package:a2_stocks/screens/register/register_screen.dart';

const Map<String, dynamic> _openDay = <String, dynamic>{
  'date': '2026-11-22',
  'isToday': true,
  'openingCash': 1000,
  'cashReceived': 500,
  'cashPaid': 100,
  'expectedCash': 1400,
  'otherReceived': <String, dynamic>{'bank': 200, 'easypaisa': 0, 'jazzcash': 0},
  'salesTotal': 900,
  'salesCount': 3,
  'closing': null,
};

class _FakeService implements RegisterService {
  _FakeService(this.current);

  RegisterDay current;
  final List<Map<String, Object?>> closed = <Map<String, Object?>>[];

  @override
  Future<RegisterDay> day({String? date}) async => current;

  @override
  Future<RegisterDay> close({required String date, required double countedCash, double? openingCash, String note = ''}) async {
    closed.add(<String, Object?>{'date': date, 'counted': countedCash, 'opening': openingCash, 'note': note});
    final double expected = (openingCash ?? current.openingCash) + current.cashReceived - current.cashPaid;
    current = RegisterDay.fromMap(<String, dynamic>{
      ..._openDay,
      'closing': <String, dynamic>{
        'id': 'c1',
        'date': date,
        'openingCash': openingCash ?? current.openingCash,
        'expectedCash': expected,
        'countedCash': countedCash,
        'difference': countedCash - expected,
        'note': note,
        'closedByName': 'Test admin',
        'closedAt': '2026-11-22T18:00:00.000Z',
      },
    });
    return current;
  }

  @override
  Future<List<RegisterClosing>> closings({int limit = 60}) async => <RegisterClosing>[];
}

UserRole _signedInRole = UserRole.staff;

class _FakeUser extends CurrentUserNotifier {
  @override
  Future<UserModel?> build() async => UserModel(id: 'u1', email: 'a@b.test', role: _signedInRole);
}

void main() {
  group('the model', () {
    test('reads a day, with and without a closing', () {
      final RegisterDay open = RegisterDay.fromMap(_openDay);
      expect(open.isClosed, isFalse);
      expect(open.expectedCash, 1400);
      expect(open.bankReceived, 200);
      expect(open.otherReceived, 200);
      expect(open.salesCount, 3);

      final RegisterDay closed = RegisterDay.fromMap(<String, dynamic>{
        ..._openDay,
        'closing': <String, dynamic>{
          'id': 'c',
          'date': '2026-11-22',
          'openingCash': 1000,
          'expectedCash': 1400,
          'countedCash': 1380,
          'difference': -20,
          'note': 'short',
          'closedByName': 'Ali',
          'closedAt': '2026-11-22T18:00:00.000Z',
        },
      });
      expect(closed.isClosed, isTrue);
      expect(closed.closing!.balanced, isFalse);
      expect(closed.closing!.difference, -20);
    });

    test('tolerates numbers sent as text and missing parts', () {
      final RegisterDay day = RegisterDay.fromMap(<String, dynamic>{'date': '2026-11-22', 'cashReceived': '12.50'});
      expect(day.cashReceived, 12.5);
      expect(day.expectedCash, 0);
      expect(day.closing, isNull);
    });

    test('the business says whether it keeps a register, off until said, and keeps it when saved', () {
      final BusinessInfo off = BusinessInfo.tryFromMap(<String, dynamic>{'id': 't', 'name': 'Ali'})!;
      expect(off.usesRegister, isFalse);
      final BusinessInfo on = BusinessInfo.tryFromMap(<String, dynamic>{'id': 't', 'name': 'Ali', 'usesRegister': true})!;
      expect(on.usesRegister, isTrue);
      expect(BusinessInfo.tryFromMap(on.toMap()), on);
      expect(on.copyWith(usesRegister: false).usesRegister, isFalse);
      expect(on.copyWith(currency: 'USD').usesRegister, isTrue);
    });
  });

  group('the Cash register page is listed only for a business that keeps one', () {
    Future<List<String>> visibleFor(bool usesRegister, UserRole role) async {
      _signedInRole = role;
      final ProviderContainer container = ProviderContainer(overrides: <Override>[
        businessProvider.overrideWithValue(BusinessInfo(id: 't', name: 'Ali', walkInCustomerId: '', usesRegister: usesRegister)),
        currentUserProvider.overrideWith(_FakeUser.new),
      ]);
      addTearDown(container.dispose);
      await container.read(currentUserProvider.future);
      return container.read(visibleModulesProvider).map((ErpModule m) => m.id).toList();
    }

    test('hidden while off, shown for every role while on', () async {
      for (final UserRole role in UserRole.values) {
        expect(await visibleFor(false, role), isNot(contains('register')));
        expect(await visibleFor(true, role), contains('register'));
      }
    });
  });

  group('the screen', () {
    Future<_FakeService> pump(WidgetTester tester, {int unsent = 0, UserRole role = UserRole.staff}) async {
      _signedInRole = role;
      final _FakeService service = _FakeService(RegisterDay.fromMap(_openDay));
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(ProviderScope(
        overrides: <Override>[
          registerServiceProvider.overrideWithValue(service),
          registerUnsentProvider.overrideWithValue(unsent),
          currentUserProvider.overrideWith(_FakeUser.new),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RegisterScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      return service;
    }

    testWidgets('shows what should be in the drawer and says short or over as the cash is typed', (WidgetTester tester) async {
      await pump(tester);
      expect(find.text('Cash that should be in the drawer'), findsOneWidget);
      expect(find.text('Rs 1,400'), findsWidgets);

      await tester.enterText(find.widgetWithText(TextField, 'Cash counted'), '1380');
      await tester.pump();
      expect(find.text('Rs 20 short'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Cash counted'), '1450');
      await tester.pump();
      expect(find.text('Rs 50 over'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Cash counted'), '1400');
      await tester.pump();
      expect(find.text('The cash matches'), findsOneWidget);
    });

    testWidgets('closes the day with the counted cash and then shows the closing', (WidgetTester tester) async {
      final _FakeService service = await pump(tester);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull); // nothing counted yet
      await tester.enterText(find.widgetWithText(TextField, 'Cash counted'), '1380');
      await tester.enterText(find.widgetWithText(TextField, 'Note (optional)'), 'Rs 20 short');
      await tester.pump();
      await tester.tap(find.text('Close the day'));
      await tester.pumpAndSettle();

      expect(service.closed.single, <String, Object?>{'date': '2026-11-22', 'counted': 1380.0, 'opening': null, 'note': 'Rs 20 short'});
      expect(find.text('Closed'), findsOneWidget);
      expect(find.text('Rs 20 short'), findsWidgets);
      expect(find.text('Count again'), findsOneWidget);
    });

    testWidgets('sends the opening cash only when the person changed it', (WidgetTester tester) async {
      final _FakeService service = await pump(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Opening cash'), '1200');
      await tester.enterText(find.widgetWithText(TextField, 'Cash counted'), '1600');
      await tester.pump();
      expect(find.text('The cash matches'), findsOneWidget); // 1200 + 500 - 100 = 1600
      await tester.tap(find.text('Close the day'));
      await tester.pumpAndSettle();
      expect(service.closed.single['opening'], 1200.0);
    });

    testWidgets('waits while this device still has unsent work', (WidgetTester tester) async {
      await pump(tester, unsent: 2);
      expect(find.textContaining('2 actions on this device not sent'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'Cash counted'), '1400');
      await tester.pump();
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    });
  });

  group('the switch', () {
    testWidgets('shows the current choice and cannot be changed by someone who may not', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: <Override>[
          businessProvider.overrideWithValue(const BusinessInfo(id: 't', name: 'Ali', walkInCustomerId: '', usesRegister: true)),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RegisterChoiceTile(enabled: false)),
        ),
      ));
      await tester.pump();
      expect(find.text('I use a cash register'), findsOneWidget);
      final SwitchListTile tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(tile.value, isTrue);
      expect(tile.onChanged, isNull);
    });
  });
}
