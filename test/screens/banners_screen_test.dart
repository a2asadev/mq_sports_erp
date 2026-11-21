import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/store_banner.dart';
import 'package:a2_stocks/online/banners_service.dart';
import 'package:a2_stocks/providers/banner_providers.dart';
import 'package:a2_stocks/screens/banners/banners_screen.dart';

class _FakeBanners implements BannersService {
  _FakeBanners(this.items);
  List<StoreBanner> items;
  final List<String> calls = <String>[];

  @override
  Future<List<StoreBanner>> list() async => items;

  @override
  Future<StoreBanner> create({required String title, String subtitle = '', String buttonText = '', String linkUrl = ''}) async {
    calls.add('create:$title');
    return StoreBanner(id: 'new', title: title);
  }

  @override
  Future<StoreBanner> update(String id, {required String title, String subtitle = '', String buttonText = '', String linkUrl = ''}) async {
    calls.add('update:$id');
    return StoreBanner(id: id, title: title);
  }

  @override
  Future<StoreBanner> setActive(String id, bool on) async {
    calls.add('active:$id:$on');
    return items.firstWhere((StoreBanner b) => b.id == id);
  }

  @override
  Future<void> delete(String id) async => calls.add('delete:$id');

  @override
  Future<List<StoreBanner>> reorder(List<String> ids) async {
    calls.add('order:${ids.join(',')}');
    return items;
  }
}

void main() {
  final List<StoreBanner> banners = <StoreBanner>[
    const StoreBanner(id: 'a', title: 'Eid sale', subtitle: 'Up to 20% off', imageUrl: '', position: 0),
    const StoreBanner(id: 'b', title: 'New bats', imageUrl: 'http://x/b.webp', position: 1),
    const StoreBanner(id: 'c', title: 'Old offer', imageUrl: 'http://x/c.webp', position: 2, isActive: false),
  ];

  Future<_FakeBanners> pump(WidgetTester tester, List<StoreBanner> items, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final _FakeBanners fake = _FakeBanners(items);
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[bannersServiceProvider.overrideWithValue(fake)],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BannersScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    return fake;
  }

  for (final Size size in const <Size>[Size(1200, 900), Size(390, 800)]) {
    testWidgets('lists the banners and says which show in the store (${size.width.toInt()} px)', (WidgetTester tester) async {
      await pump(tester, banners, size);
      expect(find.text('Eid sale'), findsOneWidget);
      expect(find.text('Add a picture to show it'), findsOneWidget); // no picture yet
      expect(find.text('Shown in the store'), findsOneWidget);
      expect(find.text('Switched off'), findsOneWidget);
      final Object? problem = tester.takeException();
      expect(problem, isNull, reason: '$problem');
    });
  }

  testWidgets('shows a hint when there are none', (WidgetTester tester) async {
    await pump(tester, <StoreBanner>[], const Size(1000, 800));
    expect(find.textContaining('No banners yet'), findsOneWidget);
  });

  testWidgets('moves a banner and switches one off', (WidgetTester tester) async {
    final _FakeBanners fake = await pump(tester, banners, const Size(1200, 900));
    await tester.tap(find.byTooltip('Move down').first);
    await tester.pumpAndSettle();
    expect(fake.calls, contains('order:b,a,c'));
    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();
    expect(fake.calls, contains('active:b:false'));
  });

  testWidgets('deleting asks first', (WidgetTester tester) async {
    final _FakeBanners fake = await pump(tester, banners, const Size(1200, 900));
    await tester.tap(find.byTooltip('Delete').first);
    await tester.pumpAndSettle();
    expect(find.text('Delete the banner "Eid sale"?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(fake.calls, contains('delete:a'));
  });

  group('the banner model', () {
    test('reads the server\'s answer', () {
      final StoreBanner b = StoreBanner.fromMap(<String, dynamic>{'id': 'x', 'title': 'T', 'imageUrl': 'u', 'position': 2, 'isActive': false});
      expect((b.id, b.title, b.imageUrl, b.position, b.isActive), ('x', 'T', 'u', 2, false));
      expect(b.copyWith(imageUrl: '').imageUrl, '');
    });

    test('accepts only a store page or an https link, like the server', () {
      for (final String ok in <String>['', '/products', '/products?categoryId=1', 'https://example.com/sale']) {
        expect(StoreBanner.isSafeLink(ok), isTrue, reason: ok);
      }
      for (final String bad in <String>['javascript:alert(1)', '//evil.example', 'http://insecure.example', 'products', 'https://a b']) {
        expect(StoreBanner.isSafeLink(bad), isFalse, reason: bad);
      }
    });
  });

  test('a product is featured only when it says so, and keeps that through its map', () {
    final ProductModel plain = ProductModel(name: 'Bat', categoryId: 'c');
    expect(plain.isFeatured, isFalse);
    final ProductModel star = plain.copyWith(isFeatured: true);
    expect(star.isFeatured, isTrue);
    expect(ProductModel.fromMap(star.toMap()).isFeatured, isTrue);
    expect(ProductModel.fromMap(<String, dynamic>{'id': 'p', 'name': 'x', 'categoryId': 'c'}).isFeatured, isFalse);
  });
}
