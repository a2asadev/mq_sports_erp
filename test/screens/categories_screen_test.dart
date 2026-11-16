import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/core/utils/category_stats.dart';
import 'package:a2_stocks/models/category_model.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';
import 'package:a2_stocks/screens/catalog/categories_screen.dart';

class _Categories extends CategoriesNotifier {
  _Categories(this.items);
  final List<CategoryModel> items;
  @override
  Future<List<CategoryModel>> build() async => items;
}

class _Products extends ProductsNotifier {
  _Products(this.items);
  final List<ProductModel> items;
  @override
  Future<List<ProductModel>> build() async => items;
}

void main() {
  final List<CategoryModel> categories = <CategoryModel>[
    CategoryModel(id: 'cricket', name: 'Cricket'),
    CategoryModel(id: 'bats', name: 'Bats', parentId: 'cricket'),
    CategoryModel(id: 'balls', name: 'Balls', parentId: 'cricket'),
    CategoryModel(id: 'kashmir', name: 'Kashmir Willow', parentId: 'bats'),
    CategoryModel(id: 'football', name: 'Football'),
  ];
  ProductModel product(String id, String categoryId) =>
      ProductModel(id: id, name: 'P$id', categoryId: categoryId);
  final List<ProductModel> products = <ProductModel>[
    product('1', 'cricket'),
    product('2', 'bats'),
    product('3', 'bats'),
    product('4', 'kashmir'),
    product('5', 'balls'),
    product('6', 'football'),
  ];

  test('computeCategoryStats counts subcategories and products, own and including everything below', () {
    final Map<String, CategoryStat> stats = <String, CategoryStat>{
      for (final CategoryStat s in computeCategoryStats(categories: categories, products: products))
        s.category.id: s,
    };
    final CategoryStat cricket = stats['cricket']!;
    expect(cricket.subcategoryCount, 2); // direct children only
    expect(cricket.directProducts, 1);
    expect(cricket.totalProducts, 5);
    expect(cricket.productsInSubcategories, 4);
    expect(cricket.children.map((CategoryModel c) => c.name), <String>['Balls', 'Bats']);
    expect(stats['bats']!.totalProducts, 3); // 2 + 1 in Kashmir Willow
    expect(stats['bats']!.parentName, 'Cricket');
    expect(stats['bats']!.depth, 1);
    expect(stats['kashmir']!.depth, 2);
    expect(stats['football']!.subcategoryCount, 0);
  });

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        categoriesProvider.overrideWith(() => _Categories(categories)),
        productsProvider.overrideWith(() => _Products(products)),
        canManageCatalogProvider.overrideWithValue(true),
      ],
      child: const MaterialApp(home: CategoriesScreen()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('the categories table lists top-level categories with counts', (WidgetTester tester) async {
    await pump(tester);
    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Subcategories'), findsWidgets); // column heading (and the tab)
    expect(find.text('Cricket'), findsOneWidget);
    expect(find.text('Football'), findsOneWidget);
    expect(find.text('Bats'), findsNothing); // subcategories are on the other tab
    final Object? problem = tester.takeException();
    expect(problem, isNull, reason: '$problem');
  });

  testWidgets('stat cards sit above the tables: main, sub, products and empty categories', (WidgetTester tester) async {
    await pump(tester);
    expect(find.text('Main categories'), findsOneWidget);
    expect(find.text('Subcategories in total'), findsOneWidget);
    expect(find.text('Products'), findsWidgets); // the card and the column heading
    expect(find.text('Without products'), findsOneWidget);
    // They stay when switching the view, and the switch is not a page swipe.
    expect(find.byType(TabBarView), findsNothing);
    await tester.tap(find.descendant(of: find.byType(SegmentedButton<int>), matching: find.text('Subcategories')));
    await tester.pumpAndSettle();
    expect(find.text('Main categories'), findsOneWidget);
  });

  testWidgets('hovering the subcategory count lists each subcategory with its product count', (WidgetTester tester) async {
    await pump(tester);
    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    // Cricket's subcategory chip shows 2; football's shows 0 (no tip).
    await mouse.moveTo(tester.getCenter(
        find.descendant(of: find.byType(DataTable), matching: find.text('2')).first));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Cricket · 2 subcategories', findRichText: true), findsOneWidget);
    expect(find.textContaining('Bats — 3 products', findRichText: true), findsOneWidget);
    expect(find.textContaining('Balls — 1 product', findRichText: true), findsOneWidget);
    expect(find.textContaining('Total: 5 products', findRichText: true), findsOneWidget);
  });

  testWidgets('the subcategories tab groups rows under their category with product counts', (WidgetTester tester) async {
    await pump(tester);
    await tester.tap(find.descendant(of: find.byType(SegmentedButton<int>), matching: find.text('Subcategories')));
    await tester.pumpAndSettle();
    expect(find.text('Cricket'), findsNWidgets(3)); // group heading + the Parent column of its two rows
    expect(find.text('Bats'), findsNWidgets(2)); // its own row + Parent of Kashmir Willow
    expect(find.text('Balls'), findsOneWidget);
    expect(find.text('Kashmir Willow'), findsOneWidget);
    expect(find.text('Football'), findsNothing); // no subcategories, so no group
    expect(find.text('3 subcategories'), findsNothing);
    expect(find.text('2 subcategories'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'kashmir');
    await tester.pumpAndSettle();
    expect(find.text('Kashmir Willow'), findsOneWidget);
    expect(find.text('Balls'), findsNothing);
  });
}
