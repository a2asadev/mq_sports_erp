import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/providers/onboarding_providers.dart';
import 'package:a2_stocks/screens/onboarding/onboarding_content.dart';
import 'package:a2_stocks/screens/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final AppLocalizations _en = lookupAppLocalizations(const Locale('en'));

String _allText(UserRole role) => onboardingStepsFor(role, _en)
    .expand((OnboardingStep s) => <String>[s.title, s.body, ...s.points])
    .join('\n');

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('guide content', () {
    test('every role has a short guide that opens with a welcome and ends with the profile page', () {
      for (final UserRole role in UserRole.values) {
        final List<OnboardingStep> steps = onboardingStepsFor(role, _en);
        expect(steps.length, inInclusiveRange(5, 10), reason: role.name);
        expect(steps.first.title, startsWith('Welcome'));
        expect(steps.last.title, 'Your profile');
        for (final OnboardingStep s in steps) {
          expect(s.title.trim(), isNotEmpty);
          expect(s.body.trim(), isNotEmpty);
        }
      }
    });

    test('each role only hears about what it can do', () {
      final String staff = _allText(UserRole.staff);
      final String manager = _allText(UserRole.manager);
      final String admin = _allText(UserRole.admin);
      expect(staff, contains('Sales & Orders'));
      expect(staff, isNot(contains('Purchases')));
      expect(staff, isNot(contains('Users')));
      expect(manager, contains('Purchases'));
      expect(manager, contains('cancel'));
      expect(manager, isNot(contains('First setup checklist')));
      expect(admin, contains('First setup checklist'));
      expect(admin, contains('Users'));
      expect(admin, contains('Send test e-mail'));
      expect(admin, contains('Activity logs'));
    });
  });

  group('seen flag', () {
    test('is remembered per person', () async {
      const OnboardingStore store = OnboardingStore();
      expect(await store.hasSeen('a'), isFalse);
      await store.markSeen('a');
      expect(await store.hasSeen('a'), isTrue);
      expect(await store.hasSeen('b'), isFalse);
    });
  });

  group('screen', () {
    Future<void> openGuide(WidgetTester tester, UserRole role) async {
      await tester.pumpWidget(MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push<bool>(
                  MaterialPageRoute<bool>(builder: (BuildContext c) => OnboardingScreen(role: role)),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('Next walks through every page and Get started closes it', (WidgetTester tester) async {
      await openGuide(tester, UserRole.staff);
      final List<OnboardingStep> steps = onboardingStepsFor(UserRole.staff, _en);
      expect(find.text(steps.first.title), findsOneWidget);
      for (int i = 1; i < steps.length; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        expect(find.text(steps[i].title), findsOneWidget);
      }
      expect(find.text('Next'), findsNothing);
      expect(find.text('Skip'), findsNothing);
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('Skip closes it from the first page', (WidgetTester tester) async {
      await openGuide(tester, UserRole.admin);
      expect(find.text('Welcome · Admin'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
    });
  });

  group('first sign-in gate', () {
    Future<void> pumpGate(WidgetTester tester, UserModel? user) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
          home: OnboardingGate(user: user, child: const Scaffold(body: Text('home'))),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the guide once, then never again for that person', (WidgetTester tester) async {
      final UserModel manager = UserModel(id: 'm1', email: 'm@x.co', role: UserRole.manager);
      await pumpGate(tester, manager);
      expect(find.text('Welcome · Manager'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(find.text('home'), findsOneWidget);
      expect(await const OnboardingStore().hasSeen('m1'), isTrue);

      // The next time the same person opens the app, nothing appears.
      await pumpGate(tester, manager);
      expect(find.textContaining('Welcome'), findsNothing);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('a different person on the same device gets their own guide', (WidgetTester tester) async {
      await const OnboardingStore().markSeen('m1');
      await pumpGate(tester, UserModel(id: 's1', email: 's@x.co', role: UserRole.staff));
      expect(find.text('Welcome · Staff'), findsOneWidget);
    });

    testWidgets('nothing shows before the user is known or for a switched-off login', (WidgetTester tester) async {
      await pumpGate(tester, null);
      expect(find.textContaining('Welcome'), findsNothing);
      await pumpGate(tester, UserModel(id: 'x', email: 'x@x.co', isActive: false));
      expect(find.textContaining('Welcome'), findsNothing);
    });
  });
}
