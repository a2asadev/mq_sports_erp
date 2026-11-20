import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/notification_text.dart';
import 'package:a2_stocks/models/app_notification.dart';
import 'package:a2_stocks/online/notification_service.dart';
import 'package:a2_stocks/providers/core_providers.dart';
import 'package:a2_stocks/providers/notification_providers.dart';
import 'package:a2_stocks/widgets/notification_bell.dart';

AppNotification _note(String id, String type, Map<String, Object?> params, {String entityType = 'order', DateTime? at}) => AppNotification(
      id: id,
      type: type,
      params: params,
      entityType: entityType,
      entityId: 'e-$id',
      createdAt: at ?? DateTime.now(),
    );

final AppNotification _order = _note('n1', 'order.web_placed', <String, Object?>{'orderNo': 'ORD-1', 'customerName': 'Bilal Khan', 'total': 2150});
final AppNotification _low = _note(
  'n2',
  'stock.low',
  <String, Object?>{'productName': 'Cricket Bat', 'variantName': 'Small', 'onHand': 4, 'threshold': 5},
  entityType: 'variant',
);

class _FakeService implements NotificationService {
  _FakeService(this.lists);

  final List<NotificationList> lists;
  int calls = 0;
  int reads = 0;
  bool failing = false;

  @override
  Future<NotificationList> list({int limit = 50}) async {
    if (failing) {
      throw Exception('offline');
    }
    return lists[calls++ < lists.length ? calls - 1 : lists.length - 1];
  }

  @override
  Future<NotificationList> markAllRead() async {
    reads++;
    return const NotificationList(items: <AppNotification>[], unread: 0);
  }
}

ProviderContainer _container(_FakeService service) {
  final ProviderContainer container = ProviderContainer(overrides: <Override>[
    authUidProvider.overrideWith((Ref ref) => Stream<String?>.value('user-1')),
    notificationServiceProvider.overrideWithValue(service),
  ]);
  addTearDown(container.dispose);
  return container;
}

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  final AppLocalizations en = lookupAppLocalizations(const Locale('en'));

  group('the notification data', () {
    test('reads what the server sends and drops what is unusable', () {
      final NotificationList list = NotificationList.fromMap(<String, dynamic>{
        'unread': 2,
        'items': <Object?>[
          <String, dynamic>{
            'id': 'a',
            'type': 'order.web_placed',
            'params': <String, dynamic>{'orderNo': 'ORD-1', 'total': 100.5},
            'entityType': 'order',
            'entityId': 'o1',
            'createdAt': '2026-11-20T18:00:00.000Z',
          },
          'junk',
          <String, dynamic>{'id': '', 'type': 'x', 'createdAt': '2026-11-20T18:00:00.000Z'},
          <String, dynamic>{'id': 'b', 'type': 'x', 'createdAt': 'not a date'},
        ],
      });
      expect(list.unread, 2);
      expect(list.items, hasLength(1));
      expect(list.items.single.text('orderNo'), 'ORD-1');
      expect(list.items.single.number('total'), 100.5);
      expect(list.items.single.number('missing'), 0);
    });

    test('is written in the app\'s language from its type and values', () {
      final NotificationText order = notificationText(en, _order);
      expect(order.title, 'New online order ORD-1');
      expect(order.detail, 'Bilal Khan · Rs 2,150');

      final NotificationText low = notificationText(en, _low);
      expect(low.title, 'Cricket Bat · Small is running low');
      expect(low.detail, '4 left · alert level 5');

      final NotificationText out = notificationText(
          en, _note('n3', 'stock.out', <String, Object?>{'productName': 'Ball', 'variantName': '', 'threshold': 5}, entityType: 'variant'));
      expect(out.title, 'Ball is out of stock');

      // A kind a newer server adds is still shown, never an empty row.
      expect(notificationText(en, _note('n4', 'invoice.paid', const <String, Object?>{})).title, 'New notification');
    });
  });

  group('the bell\'s state', () {
    test('loads for the signed-in person, and the first load is not announced', () async {
      final _FakeService service = _FakeService(<NotificationList>[
        NotificationList(items: <AppNotification>[_order], unread: 1),
      ]);
      final ProviderContainer container = _container(service);
      container.listen(notificationsProvider, (NotificationsState? a, NotificationsState b) {});
      await _settle();

      final NotificationsState state = container.read(notificationsProvider);
      expect(state.loaded, isTrue);
      expect(state.unread, 1);
      expect(state.items.single.id, 'n1');
      expect(state.announce, isEmpty);
    });

    test('announces only what arrives afterwards', () async {
      final _FakeService service = _FakeService(<NotificationList>[
        NotificationList(items: <AppNotification>[_order], unread: 1),
        NotificationList(items: <AppNotification>[_low, _order], unread: 2),
        NotificationList(items: <AppNotification>[_low, _order], unread: 2),
      ]);
      final ProviderContainer container = _container(service);
      container.listen(notificationsProvider, (NotificationsState? a, NotificationsState b) {});
      await _settle();

      await container.read(notificationsProvider.notifier).refresh();
      expect(container.read(notificationsProvider).announce.map((AppNotification n) => n.id), <String>['n2']);
      expect(container.read(notificationsProvider).unread, 2);

      // The same list again: nothing new, nothing announced.
      await container.read(notificationsProvider.notifier).refresh();
      expect(container.read(notificationsProvider).announce, isEmpty);
    });

    test('marking as read clears the number at once and tells the server', () async {
      final _FakeService service = _FakeService(<NotificationList>[
        NotificationList(items: <AppNotification>[_order, _low], unread: 2),
      ]);
      final ProviderContainer container = _container(service);
      container.listen(notificationsProvider, (NotificationsState? a, NotificationsState b) {});
      await _settle();

      final Future<void> reading = container.read(notificationsProvider.notifier).markAllRead();
      expect(container.read(notificationsProvider).unread, 0); // before the server answered
      await reading;
      expect(service.reads, 1);
      expect(container.read(notificationsProvider).items, hasLength(2)); // still listed
      // Nothing to mark: no call.
      await container.read(notificationsProvider.notifier).markAllRead();
      expect(service.reads, 1);
    });

    test('says it failed when the server cannot be reached and nothing was loaded', () async {
      final _FakeService service = _FakeService(<NotificationList>[])..failing = true;
      final ProviderContainer container = _container(service);
      container.listen(notificationsProvider, (NotificationsState? a, NotificationsState b) {});
      await _settle();
      expect(container.read(notificationsProvider).failed, isTrue);
      expect(container.read(notificationsProvider).loaded, isFalse);

      service
        ..failing = false
        ..lists.add(NotificationList(items: <AppNotification>[_order], unread: 1));
      await container.read(notificationsProvider.notifier).refresh();
      expect(container.read(notificationsProvider).loaded, isTrue);
      expect(container.read(notificationsProvider).failed, isFalse);
    });
  });

  group('the bell and its list', () {
    Widget host(_FakeService service, {void Function(AppNotification)? onOpen}) => ProviderScope(
          overrides: <Override>[
            authUidProvider.overrideWith((Ref ref) => Stream<String?>.value('user-1')),
            notificationServiceProvider.overrideWithValue(service),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              appBar: AppBar(actions: const <Widget>[NotificationBell()]),
              body: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) => Column(children: <Widget>[
                  Expanded(child: NotificationsPanel(onOpen: onOpen ?? (AppNotification n) {})),
                ]),
              ),
            ),
          ),
        );

    testWidgets('the bell shows how many are unread', (WidgetTester tester) async {
      final _FakeService service = _FakeService(<NotificationList>[
        NotificationList(items: <AppNotification>[_order, _low], unread: 2),
      ]);
      await tester.pumpWidget(host(service));
      await tester.pumpAndSettle();
      expect(find.descendant(of: find.byType(NotificationBell), matching: find.text('2')), findsOneWidget);
    });

    testWidgets('the list shows each notification, newest first, and opens the one tapped', (WidgetTester tester) async {
      final _FakeService service = _FakeService(<NotificationList>[
        NotificationList(items: <AppNotification>[_order, _low], unread: 1),
      ]);
      final List<String> opened = <String>[];
      await tester.pumpWidget(host(service, onOpen: (AppNotification n) => opened.add(n.id)));
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsWidgets);
      expect(find.text('New online order ORD-1'), findsOneWidget);
      expect(find.textContaining('Bilal Khan · Rs 2,150'), findsOneWidget);
      expect(find.text('Cricket Bat · Small is running low'), findsOneWidget);
      expect(find.text('Mark all as read'), findsOneWidget); // there is something unread

      await tester.tap(find.text('Cricket Bat · Small is running low'));
      expect(opened, <String>['n2']);
    });

    testWidgets('an empty bell says what will show there', (WidgetTester tester) async {
      await tester.pumpWidget(host(_FakeService(<NotificationList>[const NotificationList(items: <AppNotification>[], unread: 0)])));
      await tester.pumpAndSettle();
      expect(find.textContaining('Nothing new'), findsOneWidget);
      expect(find.text('Mark all as read'), findsNothing);
    });

    testWidgets('a bell that cannot load offers to try again', (WidgetTester tester) async {
      final _FakeService service = _FakeService(<NotificationList>[])..failing = true;
      await tester.pumpWidget(host(service));
      await tester.pumpAndSettle();
      expect(find.textContaining('could not be loaded'), findsOneWidget);
      service
        ..failing = false
        ..lists.add(NotificationList(items: <AppNotification>[_order], unread: 0));
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('New online order ORD-1'), findsOneWidget);
    });
  });
}
