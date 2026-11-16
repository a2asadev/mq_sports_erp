import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/core/utils/starter_pack_plan.dart';
import 'package:mq_sports_erp/models/category_model.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/starter_pack.dart';
import 'package:mq_sports_erp/online/api_client.dart';
import 'package:mq_sports_erp/online/starter_pack_service.dart';
import 'package:mq_sports_erp/online/token_store.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/screens/catalog/categories_screen.dart';
import 'package:mq_sports_erp/screens/catalog/starter_pack_dialog.dart';

const Map<String, dynamic> _sports = <String, dynamic>{
  'id': 'sports',
  'name': 'Sports shop',
  'description': 'Cricket, football and more.',
  'categoryCount': 8,
  'groups': <Map<String, dynamic>>[
    <String, dynamic>{'name': 'Cricket', 'children': <String>['Bats', 'Balls', 'Helmets']},
    <String, dynamic>{'name': 'Football', 'children': <String>['Footballs', 'Boots']},
  ],
};
const Map<String, dynamic> _grocery = <String, dynamic>{
  'id': 'grocery',
  'name': 'Grocery store',
  'description': 'Staples and snacks.',
  'categoryCount': 3,
  'groups': <Map<String, dynamic>>[
    <String, dynamic>{'name': 'Rice', 'children': <String>['Basmati', 'Sella']},
  ],
};

http.Response _json(int status, Object body) =>
    http.Response(jsonEncode(body), status, headers: <String, String>{'content-type': 'application/json'});

class _Categories extends CategoriesNotifier {
  _Categories(this.items);
  final List<CategoryModel> items;
  @override
  Future<List<CategoryModel>> build() async => items;
}

void main() {
  group('the starter pack data', () {
    test('reads the server\'s packs, dropping anything unusable', () {
      final StarterPack pack = StarterPack.tryFromMap(_sports)!;
      expect(pack.id, 'sports');
      expect(pack.groups.map((StarterGroup g) => g.name), <String>['Cricket', 'Football']);
      expect(pack.groups.first.children, <String>['Bats', 'Balls', 'Helmets']);
      expect(pack.categoryCount, 7); // 2 groups + 5 subcategories
      expect(pack.groups.first.categoryCount, 4);

      expect(StarterPack.tryFromMap(null), isNull);
      expect(StarterPack.tryFromMap(<String, dynamic>{'id': '', 'name': 'x'}), isNull);
      expect(StarterPack.tryFromMap(<String, dynamic>{'id': 'a', 'name': ' '}), isNull);
      final StarterPack lenient = StarterPack.tryFromMap(<String, dynamic>{
        'id': 'a',
        'name': 'A',
        'groups': <Object?>[7, <String, dynamic>{'name': ''}, <String, dynamic>{'name': 'G', 'children': <Object?>['x', 3, ' ']}],
      })!;
      expect(lenient.description, '');
      expect(lenient.groups.single.name, 'G');
      expect(lenient.groups.single.children, <String>['x']);
      expect(StarterPackResult.fromMap(<String, dynamic>{'created': 5, 'skipped': 2}).created, 5);
      expect(StarterPackResult.fromMap(<String, dynamic>{}).skipped, 0);
    });

    test('works out what would be added, the way the server does', () {
      final StarterPack pack = StarterPack.tryFromMap(_sports)!;
      expect(StarterPackPlan.compute(pack.groups, <CategoryModel>[]).toAdd, 7);

      final List<CategoryModel> mine = <CategoryModel>[
        CategoryModel(id: 'c', name: 'cricket', isActive: false), // any case, even inactive
        CategoryModel(id: 'b', name: ' BATS ', parentId: 'c'),
        CategoryModel(id: 'x', name: 'Boots', parentId: 'elsewhere'), // another parent: no match
        CategoryModel(id: 'h', name: 'Helmets'), // top level: not the subcategory "Helmets"
      ];
      final StarterPackPlan plan = StarterPackPlan.compute(pack.groups, mine);
      expect(plan.alreadyThere, 2); // Cricket and its Bats
      expect(plan.toAdd, 5); // Balls, Helmets, Football, Footballs, Boots
      expect(StarterPackPlan.hasGroup(pack.groups.first, mine), isTrue);
      expect(StarterPackPlan.hasGroup(pack.groups.last, mine), isFalse);
      // Only the ticked groups count.
      expect(StarterPackPlan.compute(<StarterGroup>[pack.groups.last], mine).toAdd, 3);
      expect(StarterPackPlan.compute(<StarterGroup>[], mine).toAdd, 0);
    });
  });

  group('the service', () {
    test('lists packs and applies one, then brings the categories onto the device', () async {
      final List<http.Request> calls = <http.Request>[];
      int refreshed = 0;
      final ApiClient api = ApiClient(
        httpClient: MockClient((http.Request r) async {
          calls.add(r);
          if (r.method == 'GET') {
            return _json(200, <Object?>[_sports, 'junk', _grocery]);
          }
          return _json(200, <String, dynamic>{'created': 7, 'skipped': 0});
        }),
        baseUrl: 'http://api.test',
        tokens: MemoryTokenStore(),
      );
      final StarterPackService service = StarterPackService(api: api, refresh: () async => refreshed++);

      expect((await service.list()).map((StarterPack p) => p.id), <String>['sports', 'grocery']);
      final StarterPackResult all = await service.apply('sports');
      expect(all.created, 7);
      expect(calls.last.url.path, '/v1/starter-packs/sports/apply');
      expect(jsonDecode(calls.last.body), <String, dynamic>{}); // no groups = the whole pack
      await service.apply('sports', groups: <String>['Cricket']);
      expect(jsonDecode(calls.last.body), <String, dynamic>{'groups': <String>['Cricket']});
      expect(refreshed, 2);
    });

    test('a failed apply is reported and does not pretend to have refreshed', () async {
      int refreshed = 0;
      final ApiClient api = ApiClient(
        httpClient: MockClient((http.Request r) async => _json(400, <String, dynamic>{'message': 'Not in this pack: Space.'})),
        baseUrl: 'http://api.test',
        tokens: MemoryTokenStore(),
      );
      final StarterPackService service = StarterPackService(api: api, refresh: () async => refreshed++);
      await expectLater(service.apply('sports'), throwsA(isA<ValidationException>()));
      expect(refreshed, 0);
    });
  });

  group('the picker', () {
    late List<http.Request> calls;
    late int applyStatus;

    Future<void> pumpDialog(WidgetTester tester, {List<CategoryModel> mine = const <CategoryModel>[]}) async {
      calls = <http.Request>[];
      applyStatus = 200;
      final ApiClient api = ApiClient(
        httpClient: MockClient((http.Request r) async {
          calls.add(r);
          if (r.method == 'GET') {
            return _json(200, <Object?>[_sports, _grocery]);
          }
          return applyStatus == 200
              ? _json(200, <String, dynamic>{'created': 5, 'skipped': 2})
              : _json(applyStatus, <String, dynamic>{'message': 'Something went wrong.'});
        }),
        baseUrl: 'http://api.test',
        tokens: MemoryTokenStore(),
      );
      tester.view.physicalSize = const Size(900, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: <Override>[
          starterPackServiceProvider.overrideWithValue(StarterPackService(api: api, refresh: () async {})),
          categoriesProvider.overrideWith(() => _Categories(mine)),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () async {
                    final StarterPackResult? r = await showStarterPackDialog(context);
                    if (r != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('done ${r.created}/${r.skipped}')));
                    }
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('offers the packs, then the groups of the one you pick, all ticked', (WidgetTester tester) async {
      await pumpDialog(tester);
      expect(find.text('Starter categories'), findsOneWidget);
      expect(find.text('Sports shop'), findsOneWidget);
      expect(find.text('Grocery store'), findsOneWidget);
      expect(find.textContaining('2 groups · 7 categories'), findsOneWidget);

      await tester.tap(find.text('Sports shop'));
      await tester.pumpAndSettle();
      expect(find.text('Cricket'), findsOneWidget);
      expect(find.text('Football'), findsOneWidget);
      expect(find.byType(Checkbox), findsNWidgets(2));
      expect(tester.widgetList<Checkbox>(find.byType(Checkbox)).every((Checkbox c) => c.value == true), isTrue);
      expect(find.text('7 new categories will be added.'), findsOneWidget);
      expect(find.text('Add 7 categories'), findsOneWidget);

      await tester.tap(find.byTooltip('Back to the list'));
      await tester.pumpAndSettle();
      expect(find.text('Grocery store'), findsOneWidget);
    });

    testWidgets('shows the subcategories of a group when it is opened', (WidgetTester tester) async {
      await pumpDialog(tester);
      await tester.tap(find.text('Sports shop'));
      await tester.pumpAndSettle();
      expect(find.text('Helmets'), findsNothing);
      await tester.tap(find.text('Cricket'));
      await tester.pumpAndSettle();
      expect(find.text('Helmets'), findsOneWidget);
      expect(find.text('Bats'), findsOneWidget);
    });

    testWidgets('unticking a group changes the count, and only the ticked groups are sent', (WidgetTester tester) async {
      await pumpDialog(tester);
      await tester.tap(find.text('Sports shop'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox).last); // Football
      await tester.pump();
      expect(find.text('4 new categories will be added.'), findsOneWidget);

      await tester.tap(find.text('Add 4 categories'));
      await tester.pumpAndSettle();
      final http.Request post = calls.singleWhere((http.Request r) => r.method == 'POST');
      expect(post.url.path, '/v1/starter-packs/sports/apply');
      expect(jsonDecode(post.body), <String, dynamic>{'groups': <String>['Cricket']});
      expect(find.text('done 5/2'), findsOneWidget); // the dialog closed with the server's answer
      expect(find.text('Starter categories'), findsNothing);
    });

    testWidgets('ticking everything sends no list: the whole pack', (WidgetTester tester) async {
      await pumpDialog(tester);
      await tester.tap(find.text('Grocery store'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add 3 categories'));
      await tester.pumpAndSettle();
      expect(jsonDecode(calls.singleWhere((http.Request r) => r.method == 'POST').body), <String, dynamic>{});
    });

    testWidgets('counts what you already have, and cannot add nothing', (WidgetTester tester) async {
      await pumpDialog(tester, mine: <CategoryModel>[
        CategoryModel(id: 'c', name: 'Cricket'),
        CategoryModel(id: 'b', name: 'Bats', parentId: 'c'),
        CategoryModel(id: 'f', name: 'Football'),
        CategoryModel(id: 'f1', name: 'Footballs', parentId: 'f'),
        CategoryModel(id: 'f2', name: 'Boots', parentId: 'f'),
        CategoryModel(id: 'c2', name: 'Balls', parentId: 'c'),
        CategoryModel(id: 'c3', name: 'Helmets', parentId: 'c'),
      ]);
      await tester.tap(find.text('Sports shop'));
      await tester.pumpAndSettle();
      expect(find.text('You already have everything you ticked.'), findsOneWidget);
      expect(find.text('Nothing new to add'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Nothing new to add')).onPressed, isNull);
      expect(find.textContaining('you already have this one'), findsNWidgets(2));
      await tester.tap(find.text('Select none'));
      await tester.pump();
      expect(find.text('Tick at least one group.'), findsOneWidget);
    });

    testWidgets('a failure stays in the dialog with the server\'s words, ready to try again', (WidgetTester tester) async {
      await pumpDialog(tester);
      await tester.tap(find.text('Grocery store'));
      await tester.pumpAndSettle();
      applyStatus = 400;
      await tester.tap(find.text('Add 3 categories'));
      await tester.pumpAndSettle();
      expect(find.text('Something went wrong.'), findsOneWidget);
      expect(find.text('Add 3 categories'), findsOneWidget); // not closed, not stuck busy
      expect(find.text('done 5/2'), findsNothing);
    });
  });

  group('the categories screen', () {
    Future<void> pumpScreen(WidgetTester tester, {required bool canManage, List<CategoryModel> items = const <CategoryModel>[]}) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: <Override>[
          categoriesProvider.overrideWith(() => _Categories(items)),
          productsProvider.overrideWith(() => _NoProducts()),
          canManageCatalogProvider.overrideWithValue(canManage),
        ],
        child: const MaterialApp(home: CategoriesScreen()),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('an empty shop is invited to start from a template', (WidgetTester tester) async {
      await pumpScreen(tester, canManage: true);
      expect(find.text('No categories yet.'), findsOneWidget);
      expect(find.text('Start from a template'), findsOneWidget);
      expect(find.text('Starter packs'), findsOneWidget);
    });

    testWidgets('staff see neither the invitation nor the button', (WidgetTester tester) async {
      await pumpScreen(tester, canManage: false);
      expect(find.text('No categories yet.'), findsOneWidget);
      expect(find.text('Start from a template'), findsNothing);
      expect(find.text('Starter packs'), findsNothing);
    });

    testWidgets('a shop with categories still has the Starter packs button', (WidgetTester tester) async {
      await pumpScreen(tester, canManage: true, items: <CategoryModel>[CategoryModel(id: 'c', name: 'Cricket')]);
      expect(find.text('Starter packs'), findsOneWidget);
      expect(find.text('Start from a template'), findsNothing);
    });
  });
}

class _NoProducts extends ProductsNotifier {
  @override
  Future<List<ProductModel>> build() async => <ProductModel>[];
}
