import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:a2_stocks/core/notify/alert_sound.dart';
import 'package:a2_stocks/core/notify/notification_alerts.dart';
import 'package:a2_stocks/core/notify/system_notifier.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/app_notification.dart';
import 'package:a2_stocks/providers/notification_alert_providers.dart';
import 'package:a2_stocks/screens/settings/notification_settings_card.dart';

class _Sound implements AlertSound {
  final List<AlertSoundKind> played = <AlertSoundKind>[];

  @override
  Future<void> play(AlertSoundKind kind) async => played.add(kind);
}

class _System implements SystemNotifier {
  _System({this.supported = true});

  bool supported;
  bool allowed = true;
  bool grantsWhenAsked = true;
  int asked = 0;
  final List<(String, String)> shown = <(String, String)>[];

  @override
  bool get isSupported => supported;

  @override
  Future<bool> isAllowed() async => allowed;

  @override
  Future<bool> requestPermission() async {
    asked++;
    if (grantsWhenAsked) {
      allowed = true;
    }
    return allowed;
  }

  @override
  Future<void> show({required String title, required String body}) async => shown.add((title, body));
}

AppNotification _order(String id) => AppNotification(
      id: id,
      type: 'order.web_placed',
      params: <String, Object?>{'orderNo': 'ORD-$id', 'customerName': 'Bilal', 'total': 1000},
      entityType: 'order',
      entityId: id,
      createdAt: DateTime.now(),
    );

AppNotification _stock(String id) => AppNotification(
      id: id,
      type: 'stock.low',
      params: <String, Object?>{'productName': 'Bat', 'variantName': '', 'onHand': 2, 'threshold': 5},
      entityType: 'variant',
      entityId: id,
      createdAt: DateTime.now(),
    );

void main() {
  late _Sound sound;
  late _System system;
  AlertPrefs prefs = const AlertPrefs();
  bool focused = false;

  NotificationAlerts alerts() => NotificationAlerts(
        sound: sound,
        system: system,
        prefs: () => prefs,
        isFocused: () => focused,
        l10n: () => lookupAppLocalizations(const Locale('en')),
      );

  setUp(() {
    sound = _Sound();
    system = _System();
    prefs = const AlertPrefs();
    focused = false;
  });

  group('telling the person about new notifications', () {
    test('plays the order chime and, with the window in the background, shows a system notification', () async {
      await alerts().announce(<AppNotification>[_order('1')]);
      expect(sound.played, <AlertSoundKind>[AlertSoundKind.newOrder]);
      expect(system.shown, <(String, String)>[('New online order ORD-1', 'Bilal · Rs 1,000')]);
    });

    test('with the window in front the pop-up in the app is enough: sound only', () async {
      focused = true;
      await alerts().announce(<AppNotification>[_order('1')]);
      expect(sound.played, hasLength(1));
      expect(system.shown, isEmpty);
    });

    test('low stock gets the calmer tone, and an order in the same batch wins', () async {
      await alerts().announce(<AppNotification>[_stock('1')]);
      expect(sound.played, <AlertSoundKind>[AlertSoundKind.stock]);
      sound.played.clear();
      await alerts().announce(<AppNotification>[_stock('2'), _order('3')]);
      expect(sound.played, <AlertSoundKind>[AlertSoundKind.newOrder]); // one sound for the batch
    });

    test('shows at most three system notifications at once', () async {
      await alerts().announce(<AppNotification>[for (int i = 0; i < 6; i++) _order('$i')]);
      expect(system.shown, hasLength(NotificationAlerts.systemLimit));
      expect(sound.played, hasLength(1));
    });

    test('respects what the person switched off', () async {
      prefs = const AlertPrefs(sound: false);
      await alerts().announce(<AppNotification>[_order('1')]);
      expect(sound.played, isEmpty);
      expect(system.shown, hasLength(1));

      system.shown.clear();
      prefs = const AlertPrefs(system: false);
      await alerts().announce(<AppNotification>[_order('2')]);
      expect(sound.played, hasLength(1));
      expect(system.shown, isEmpty);
    });

    test('shows nothing when the system does not allow it, or the device cannot', () async {
      system.allowed = false;
      await alerts().announce(<AppNotification>[_order('1')]);
      expect(system.shown, isEmpty);
      expect(sound.played, hasLength(1)); // the sound still plays

      system = _System(supported: false);
      await alerts().announce(<AppNotification>[_order('2')]);
      expect(system.shown, isEmpty);
    });

    test('says nothing for nothing', () async {
      await alerts().announce(const <AppNotification>[]);
      expect(sound.played, isEmpty);
      expect(system.shown, isEmpty);
    });
  });

  group('the test from Settings', () {
    test('plays the sound and shows a notification now, even with the window in front', () async {
      focused = true;
      expect(await alerts().sendTest(), AlertTestResult.sent);
      expect(sound.played, <AlertSoundKind>[AlertSoundKind.newOrder]);
      expect(system.shown.single.$1, 'Test notification');
    });

    test('says why nothing was shown', () async {
      prefs = const AlertPrefs(system: false);
      expect(await alerts().sendTest(), AlertTestResult.systemOff);
      prefs = const AlertPrefs();
      system.allowed = false;
      expect(await alerts().sendTest(), AlertTestResult.notAllowed);
      system = _System(supported: false);
      expect(await alerts().sendTest(), AlertTestResult.unsupported);
      expect(system.shown, isEmpty);
    });
  });

  group('the choices', () {
    test('are on at first, are kept on this device, and come back after a restart', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(alertPrefsProvider, (AlertPrefs? a, AlertPrefs b) {});
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(alertPrefsProvider).sound, isTrue);
      expect(container.read(alertPrefsProvider).system, isTrue);

      await container.read(alertPrefsProvider.notifier).setSound(false);
      await container.read(alertPrefsProvider.notifier).setSystem(false);
      container.dispose();

      container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(alertPrefsProvider, (AlertPrefs? a, AlertPrefs b) {});
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(alertPrefsProvider).sound, isFalse);
      expect(container.read(alertPrefsProvider).system, isFalse);
    });
  });

  group('Settings > Notifications', () {
    Future<ProviderContainer> pump(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final NotificationAlerts built = alerts();
      await tester.pumpWidget(ProviderScope(
        overrides: <Override>[notificationAlertsProvider.overrideWithValue(built)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SingleChildScrollView(child: NotificationSettingsCard())),
        ),
      ));
      await tester.pumpAndSettle();
      return ProviderScope.containerOf(tester.element(find.byType(NotificationSettingsCard)));
    }

    testWidgets('switches the sound and the desktop notifications, and asks permission when switching on', (WidgetTester tester) async {
      system.allowed = false;
      final ProviderContainer container = await pump(tester);
      expect(find.text('Play a sound'), findsOneWidget);

      await tester.tap(find.text('Play a sound'));
      await tester.pumpAndSettle();
      expect(container.read(alertPrefsProvider).sound, isFalse);

      await tester.tap(find.text('Show desktop notifications')); // on -> off
      await tester.pumpAndSettle();
      expect(container.read(alertPrefsProvider).system, isFalse);
      expect(system.asked, 0);

      await tester.tap(find.text('Show desktop notifications')); // off -> on: the browser asks
      await tester.pumpAndSettle();
      expect(container.read(alertPrefsProvider).system, isTrue);
      expect(system.asked, 1);
      expect(find.textContaining('blocked'), findsNothing);
    });

    testWidgets('says when the browser blocked notifications', (WidgetTester tester) async {
      system
        ..allowed = false
        ..grantsWhenAsked = false;
      await pump(tester);
      await tester.tap(find.text('Show desktop notifications')); // on -> off
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show desktop notifications')); // off -> on: refused
      await tester.pumpAndSettle();
      expect(find.textContaining('blocked'), findsOneWidget);
    });

    testWidgets('a device that cannot show them says so instead of offering a switch', (WidgetTester tester) async {
      system = _System(supported: false);
      await pump(tester);
      expect(find.text('Show desktop notifications'), findsNothing);
      expect(find.text('This device cannot show desktop notifications.'), findsOneWidget);
    });

    testWidgets('the test button plays and shows, and says what happened', (WidgetTester tester) async {
      await pump(tester);
      await tester.tap(find.text('Send a test'));
      await tester.pumpAndSettle();
      expect(sound.played, hasLength(1));
      expect(system.shown, hasLength(1));
      expect(find.textContaining('Test sent'), findsOneWidget);
    });
  });
}
