import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/core/utils/barcode_generator.dart';
import 'package:a2_stocks/core/utils/label_pdf.dart';
import 'package:a2_stocks/core/utils/label_sheet.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/online/business_service.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';
import 'package:a2_stocks/screens/catalog/barcode_choice.dart';
import 'package:a2_stocks/screens/catalog/variant_dialog.dart';
import 'package:a2_stocks/screens/labels/labels_screen.dart';

int _pages(List<int> pdf) => RegExp(r'/Type\s*/Page(?![s\w])').allMatches(String.fromCharCodes(pdf)).length;

ProductModel _product(String id, String name, List<VariantModel> variants) => ProductModel(id: id, name: name, categoryId: 'c', variants: variants);

class _FakeProducts extends ProductsNotifier {
  @override
  Future<List<ProductModel>> build() async => <ProductModel>[
        _product('p1', 'Cricket Bat', <VariantModel>[VariantModel(id: 'v1', sku: 'BAT-S', name: 'Small', barcode: '2000000000015', costPrice: 60, salePrice: 100)]),
        _product('p2', 'Ball', <VariantModel>[VariantModel(id: 'v2', sku: 'BALL-1', costPrice: 5, salePrice: 25)]), // no barcode
      ];
}

class _FakeBusinessService implements BusinessService {
  final List<bool> sent = <bool>[];

  @override
  Future<BusinessInfo?> update({
    String? currency,
    String? brandColor,
    bool? usesRegister,
    bool? requireBarcode,
    bool? taxEnabled,
    double? gstRate,
    double? vatRate,
    bool? pricesIncludeTax,
    String? taxNumber,
  }) async {
    sent.add(requireBarcode ?? false);
    return BusinessInfo(id: 't', name: 'Ali', walkInCustomerId: '', requireBarcode: requireBarcode ?? false);
  }

  @override
  Future<BusinessInfo?> saveCurrency(String code) async => null;

  @override
  Future<BusinessInfo?> saveUsesRegister(bool on) async => null;
}

void main() {
  group('creating a barcode', () {
    test('has the right check digit and starts with the shop\'s own range', () {
      expect(ean13CheckDigit('400638133393'), 1); // 4006381333931 is a real EAN-13
      expect(isValidEan13('4006381333931'), isTrue);
      expect(isValidEan13('4006381333930'), isFalse);
      expect(isValidEan13('12345'), isFalse);
      final String code = generateBarcode(<String>{}, random: Random(1));
      expect(code, hasLength(13));
      expect(code.startsWith('2'), isTrue);
      expect(isValidEan13(code), isTrue);
    });

    test('is never one that is already taken', () {
      // A generator that can only make one code, then another: the taken one is skipped.
      final String first = generateBarcode(<String>{}, random: Random(7));
      final String second = generateBarcode(<String>{first}, random: Random(7));
      expect(second, isNot(first));
      expect(isValidEan13(second), isTrue);
    });
  });

  group('label sizes', () {
    test('a roll has one label to a page, a sheet a grid', () {
      expect(LabelSpec.roll50x30.isSheet, isFalse);
      expect(LabelSpec.roll50x30.perPage, 1);
      expect(LabelSpec.a4x24.isSheet, isTrue);
      expect(LabelSpec.a4x24.perPage, 24);
      expect(LabelSpec.a4x24.labelWidthMm, closeTo((210 - 10) / 3, 0.001));
      expect(LabelSpec.a4x40.perPage, 40);
      expect(LabelSpec.byId('nonsense'), LabelSpec.roll50x30);
      expect(LabelSpec.byId('a4x14').perPage, 14);
    });

    test('pages needed, counting places already used on the sheet', () {
      expect(LabelSpec.a4x24.pagesFor(0), 0);
      expect(LabelSpec.a4x24.pagesFor(24), 1);
      expect(LabelSpec.a4x24.pagesFor(25), 2);
      expect(LabelSpec.a4x24.pagesFor(24, skip: 3), 2); // 3 places gone: the 24th label spills over
      expect(LabelSpec.a4x24.pagesFor(21, skip: 3), 1);
    });
  });

  group('the label PDF', () {
    const LabelItem bat = LabelItem(name: 'Cricket Bat', variantLabel: 'Small', sku: 'BAT-S', price: 100, code: '2000000000015', copies: 3);
    const LabelItem ball = LabelItem(name: 'Ball', variantLabel: 'BALL-1', sku: 'BALL-1', price: 25, code: 'BALL-1', copies: 2);

    test('draws only codes Code 128 can write', () {
      expect(canDrawBars('2000000000015'), isTrue);
      expect(canDrawBars('BALL-1'), isTrue);
      expect(canDrawBars(''), isFalse);
      expect(canDrawBars('Ball ٣'), isFalse); // not plain characters
    });

    test('a roll has a page for every label', () async {
      final bytes = await buildLabelsPdf(<LabelItem>[bat, ball], LabelSpec.roll50x30);
      expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
      expect(_pages(bytes), 5);
    });

    test('a sheet fills a grid page after page, and leaves the places already used empty', () async {
      const LabelItem many = LabelItem(name: 'Bat', variantLabel: '', sku: 'B', price: 1, code: 'B', copies: 25);
      expect(_pages(await buildLabelsPdf(<LabelItem>[many], LabelSpec.a4x24)), 2);
      expect(_pages(await buildLabelsPdf(<LabelItem>[many], LabelSpec.a4x24, skip: 0)), 2);
      const LabelItem one = LabelItem(name: 'Bat', variantLabel: '', sku: 'B', price: 1, code: 'B', copies: 21);
      expect(_pages(await buildLabelsPdf(<LabelItem>[one], LabelSpec.a4x24, skip: 3)), 1);
      expect(_pages(await buildLabelsPdf(<LabelItem>[one], LabelSpec.a4x24, skip: 5)), 2);
    });

    test('an item without a code still gets a label, and nothing at all still builds', () async {
      const LabelItem none = LabelItem(name: 'Ball', variantLabel: '', sku: 'X', price: 5, code: '', copies: 1);
      expect(_pages(await buildLabelsPdf(<LabelItem>[none], LabelSpec.roll40x25, options: const LabelOptions(showSku: true))), 1);
      expect((await buildLabelsPdf(const <LabelItem>[], LabelSpec.roll40x25)).length, greaterThan(100));
    });
  });

  group('the Labels page', () {
    Future<void> pump(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(ProviderScope(
        overrides: <Override>[productsProvider.overrideWith(_FakeProducts.new)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LabelsScreen(),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('lists the items and says what the bar code will be, even for an item without a barcode', (WidgetTester tester) async {
      await pump(tester);
      expect(find.text('Cricket Bat · Small'), findsOneWidget);
      expect(find.textContaining('2000000000015'), findsOneWidget);
      expect(find.text('Rs 25 · SKU as the bar code'), findsOneWidget); // the ball has no barcode
      await tester.tap(find.text('SKU as the bar code when there is no barcode'));
      await tester.pump();
      expect(find.text('Rs 25 · No bar code'), findsOneWidget);
    });

    testWidgets('counts labels and pages, for a roll and for a sheet with places already used', (WidgetTester tester) async {
      await pump(tester);
      expect(find.text('Choose how many labels each item needs.'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Print')).onPressed, isNull);

      await tester.tap(find.text('1 each'));
      await tester.pump();
      expect(find.text('2 labels, 2 pages'), findsOneWidget); // a roll: a page each
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Print')).onPressed, isNotNull);

      await tester.enterText(find.widgetWithText(TextField, 'Labels').first, '30');
      await tester.pump();
      expect(find.text('31 labels, 31 pages'), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('A4 sheet of 24 labels').last);
      await tester.pumpAndSettle();
      expect(find.text('31 labels, 2 pages'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'Places already used'), '20');
      await tester.pump();
      expect(find.text('31 labels, 3 pages'), findsOneWidget); // 20 + 31 = 51 places
    });

    testWidgets('clears the counts, and searches', (WidgetTester tester) async {
      await pump(tester);
      await tester.tap(find.text('1 each'));
      await tester.pump();
      await tester.tap(find.text('Clear'));
      await tester.pump();
      expect(find.text('Choose how many labels each item needs.'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'ball');
      await tester.pump();
      expect(find.text('Cricket Bat · Small'), findsNothing);
      expect(find.text('Ball · BALL-1'), findsOneWidget);
    });
  });

  group('barcodes are optional unless the business says otherwise', () {
    Future<void> openDialog(WidgetTester tester, {required bool required, VariantModel? variant, Set<String> others = const <String>{}}) async {
      await tester.binding.setSurfaceSize(const Size(900, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showVariantDialog(context, variant: variant, readOnly: false, productName: 'Bat', otherSkus: const <String>{}, otherBarcodes: others, requireBarcode: required),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    Future<void> fillAndSave(WidgetTester tester) async {
      await tester.enterText(find.widgetWithText(TextFormField, 'SKU'), 'BAT-1');
      await tester.pump();
      for (final String label in <String>['Cost price', 'Sale price']) {
        final Finder f = find.widgetWithText(TextFormField, label);
        if (f.evaluate().isNotEmpty) {
          await tester.enterText(f, '10');
        }
      }
      await tester.tap(find.text('Save variant'));
      await tester.pumpAndSettle();
    }

    testWidgets('while it is optional the field says so and may stay empty', (WidgetTester tester) async {
      await openDialog(tester, required: false);
      expect(find.text('Barcode (optional)'), findsOneWidget);
      await fillAndSave(tester);
      expect(find.text('A barcode is required. Scan one, type it, or press the wand to create one.'), findsNothing);
    });

    testWidgets('when required it says so, refuses an empty one, and the wand creates a valid one', (WidgetTester tester) async {
      await openDialog(tester, required: true);
      expect(find.text('Barcode'), findsOneWidget);
      await fillAndSave(tester);
      expect(find.text('A barcode is required. Scan one, type it, or press the wand to create one.'), findsOneWidget);
      await tester.tap(find.byTooltip('Create a barcode'));
      await tester.pump();
      final String code = tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Barcode')).controller!.text;
      expect(isValidEan13(code), isTrue);
    });

    testWidgets('an item that already had a barcode cannot lose it, but an older one without can stay without', (WidgetTester tester) async {
      await openDialog(tester, required: true, variant: VariantModel(id: 'v', sku: 'OLD', barcode: '', costPrice: 1, salePrice: 2));
      await tester.tap(find.text('Save variant'));
      await tester.pumpAndSettle();
      expect(find.text('A barcode is required. Scan one, type it, or press the wand to create one.'), findsNothing);
    });

    testWidgets('a barcode another item has is refused', (WidgetTester tester) async {
      await openDialog(tester, required: false, others: <String>{'abc-123'});
      await tester.enterText(find.widgetWithText(TextFormField, 'Barcode (optional)'), 'ABC-123');
      await fillAndSave(tester);
      expect(find.text('Another item already has this barcode.'), findsOneWidget);
    });
  });

  group('the switch', () {
    Future<_FakeBusinessService> pump(WidgetTester tester, {bool enabled = true, bool on = false}) async {
      final _FakeBusinessService service = _FakeBusinessService();
      await tester.pumpWidget(ProviderScope(
        overrides: <Override>[
          businessServiceProvider.overrideWithValue(service),
          businessProvider.overrideWithValue(BusinessInfo(id: 't', name: 'Ali', walkInCustomerId: '', requireBarcode: on)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RequireBarcodeTile(enabled: enabled)),
        ),
      ));
      await tester.pump();
      return service;
    }

    testWidgets('is off to begin with and an admin can switch it on', (WidgetTester tester) async {
      final _FakeBusinessService service = await pump(tester);
      expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isFalse);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(service.sent, <bool>[true]);
    });

    testWidgets('someone who may not change it sees it, but cannot', (WidgetTester tester) async {
      await pump(tester, enabled: false, on: true);
      expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isTrue);
      expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged, isNull);
    });
  });

  test('the business keeps the rule, off until said', () {
    expect(BusinessInfo.tryFromMap(<String, dynamic>{'id': 't', 'name': 'Ali'})!.requireBarcode, isFalse);
    final BusinessInfo on = BusinessInfo.tryFromMap(<String, dynamic>{'id': 't', 'name': 'Ali', 'requireBarcode': true})!;
    expect(on.requireBarcode, isTrue);
    expect(BusinessInfo.tryFromMap(on.toMap()), on);
    expect(on.copyWith(currency: 'USD').requireBarcode, isTrue);
    expect(on.copyWith(requireBarcode: false).requireBarcode, isFalse);
  });
}
