import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/core/utils/receipt.dart';
import 'package:a2_stocks/core/utils/tax.dart';
import 'package:a2_stocks/core/utils/tax_text.dart';
import 'package:a2_stocks/data/local/app_database.dart';
import 'package:a2_stocks/data/local/collections.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/core/utils/report_builders.dart';
import 'package:a2_stocks/core/utils/report_table.dart';
import 'package:a2_stocks/core/utils/return_plan.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/models/order_return.dart';
import 'package:a2_stocks/models/report_models.dart';
import 'package:a2_stocks/providers/dashboard_providers.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/online/business_service.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/providers/pos_providers.dart';
import 'package:a2_stocks/screens/settings/tax_settings_form.dart';

AppLocalizations get _l10n => lookupAppLocalizations(const Locale('en'));

OrderItem _item(int qty, double price, {double discount = 0}) => OrderItem(
      productId: 'p',
      variantId: 'v',
      productName: 'Bat',
      variantLabel: 'Small',
      sku: 'BAT',
      quantity: qty,
      unitPrice: price,
      discount: discount,
    );

const TaxSettings _gst17 = TaxSettings(enabled: true, gstRate: 17);
const TaxSettings _both = TaxSettings(enabled: true, gstRate: 17, vatRate: 5);

class _FakeBusinessService implements BusinessService {
  final List<Map<String, Object?>> updates = <Map<String, Object?>>[];

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
    updates.add(<String, Object?>{'on': taxEnabled, 'gst': gstRate, 'vat': vatRate, 'includes': pricesIncludeTax, 'number': taxNumber});
    return BusinessInfo(
      id: 't',
      name: 'Ali',
      walkInCustomerId: '',
      taxEnabled: taxEnabled ?? false,
      gstRate: gstRate ?? 0,
      vatRate: vatRate ?? 0,
      pricesIncludeTax: pricesIncludeTax ?? false,
      taxNumber: taxNumber ?? '',
    );
  }

  @override
  Future<BusinessInfo?> saveCurrency(String code) async => null;

  @override
  Future<BusinessInfo?> saveUsesRegister(bool on) async => null;
}

void main() {
  group('the tax rule follows the server to the cent', () {
    test('is nothing when tax is off, or has no rate', () {
      expect(computeTax(300, TaxSettings.none).isNone, isTrue);
      expect(computeTax(300, const TaxSettings(enabled: true)).isNone, isTrue);
      expect(computeTax(300, const TaxSettings(gstRate: 17)).isNone, isTrue); // rates kept, tax off
    });

    test('adds GST, VAT, or both on the same price', () {
      expect(computeTax(300, _gst17).gst, 51);
      expect(computeTax(300, _gst17).added, 51);
      final TaxResult both = computeTax(300, _both);
      expect(<double>[both.gst, both.vat, both.total, both.added], <double>[51, 15, 66, 66]);
      expect(computeTax(300, const TaxSettings(enabled: true, vatRate: 5)).vat, 15);
    });

    test('works the tax out of the price when the prices include it, and adds nothing', () {
      final TaxResult r = computeTax(300, const TaxSettings(enabled: true, gstRate: 17, vatRate: 5, pricesIncludeTax: true));
      expect(<double>[r.gst, r.vat, r.total], <double>[41.8, 12.3, 54.1]);
      expect(r.inclusive, isTrue);
      expect(r.added, 0);
    });

    test('rounds to the cent', () {
      expect(computeTax(3.33, _gst17).gst, 0.57); // 0.5661
      expect(computeTax(0, _gst17).total, 0);
    });
  });

  group('an order', () {
    OrderModel order(TaxSettings settings, {double discount = 0, double shipping = 0}) {
      final OrderModel base = OrderModel(orderNo: 'O', customerId: 'c', customerName: 'Ali', items: <OrderItem>[_item(2, 100)], discount: discount, shippingFee: shipping);
      return base.withTax(computeTax(base.subtotal - discount, settings));
    }

    test('has no tax unless one was charged, so old orders stay as they were', () {
      final OrderModel plain = order(TaxSettings.none);
      expect(plain.totalAmount, 200);
      expect(plain.taxAmount, 0);
      final OrderModel old = OrderModel.fromMap(<String, dynamic>{'id': 'x', 'orderNo': 'O', 'customerId': 'c', 'customerName': 'A'});
      expect(old.taxAmount, 0);
      expect(old.taxInclusive, isFalse);
    });

    test('adds the tax on top of the goods, after discounts, never on the delivery fee', () {
      final OrderModel o = order(const TaxSettings(enabled: true, gstRate: 10), discount: 20, shipping: 50);
      expect(o.taxAmount, 18); // 10% of 180
      expect(o.totalAmount, 248); // 180 + 18 + 50
    });

    test('keeps the total as the price when the prices include the tax', () {
      final OrderModel o = order(const TaxSettings(enabled: true, gstRate: 17, vatRate: 5, pricesIncludeTax: true));
      expect(o.totalAmount, 200);
      expect(o.taxAmount, 36.07); // 200 x 22 / 122, split in two
      expect(o.taxInclusive, isTrue);
    });

    test('keeps its tax through the map, a copy and a status change', () {
      final OrderModel o = order(_both);
      final OrderModel back = OrderModel.fromMap(o.toMap());
      expect(<double>[back.taxAmount, back.gstAmount, back.vatAmount, back.gstRate, back.vatRate], <double>[o.taxAmount, o.gstAmount, o.vatAmount, 17, 5]);
      expect(back.totalAmount, o.totalAmount);
      expect(o.copyWith(status: OrderStatus.shipped).totalAmount, o.totalAmount);
    });

    test('is stored on the device with its tax', () async {
      final AppDatabase db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final LocalCollections local = LocalCollections(db);
      final OrderModel o = order(_both);
      await local.orders.upsertAll(<OrderModel>[o]);
      final OrderModel? back = await local.orders.byId(o.id);
      expect(<double>[back!.gstAmount, back.vatAmount, back.gstRate, back.vatRate, back.totalAmount], <double>[o.gstAmount, o.vatAmount, 17, 5, o.totalAmount]);
      expect(back.taxInclusive, isFalse);
    });
  });

  test('the POS adds the tax to what is payable', () {
    final ProductModel product = ProductModel(id: 'p', name: 'Bat', categoryId: 'c', variants: <VariantModel>[VariantModel(id: 'v', sku: 'BAT', costPrice: 60, salePrice: 100)]);
    final PosCart cart = const PosCart().add(product, product.variants.first, quantity: 3);
    expect(cart.total, 300);
    expect(cart.payable(TaxSettings.none), 300);
    expect(cart.payable(_gst17), 351);
    expect(cart.payable(const TaxSettings(enabled: true, gstRate: 17, pricesIncludeTax: true)), 300);
    expect(cart.withOrderDiscount(100).payable(_gst17), 234); // 200 + 34
  });

  group('what a person reads', () {
    test('rates have no useless zeros', () {
      expect(formatRate(17), '17');
      expect(formatRate(17.5), '17.5');
      expect(formatRate(5.25), '5.25');
    });

    test('the lines say GST or VAT with their rate, or that the price includes them', () {
      final List<MapEntry<String, double>> added = taxLabels(_l10n, computeTax(300, _both));
      expect(added.map((MapEntry<String, double> e) => '${e.key}=${e.value}'), <String>['GST 17%=51.0', 'VAT 5%=15.0']);
      final List<MapEntry<String, double>> inside = taxLabels(_l10n, computeTax(300, const TaxSettings(enabled: true, gstRate: 17, pricesIncludeTax: true)));
      expect(inside.single.key, 'Includes GST 17%');
      expect(taxLabels(_l10n, TaxResult.none), isEmpty);
    });

    test('a receipt shows the tax lines and the tax number', () {
      final OrderModel o = OrderModel(orderNo: 'ORD-1', customerId: 'c', customerName: 'Ali', items: <OrderItem>[_item(3, 100)]).withTax(computeTax(300, _both));
      final ReceiptData receipt = ReceiptData.fromParts(o, payments: const <ReceiptPayment>[], shopName: 'Shop', walkInCustomerId: '', taxNumber: 'NTN 1234');
      expect(receipt.total, 366);
      expect(receipt.taxLines.map((ReceiptTaxLine t) => t.label), <String>['GST 17%', 'VAT 5%']);
      final String text = receipt.toText();
      expect(text, contains('GST 17%: Rs 51'));
      expect(text, contains('Tax no. NTN 1234'));
      expect(ReceiptData.fromParts(OrderModel(orderNo: 'O', customerId: 'c', customerName: 'A', items: <OrderItem>[_item(1, 10)]), payments: const <ReceiptPayment>[], shopName: 'S', walkInCustomerId: '').taxLines, isEmpty);
    });
  });

  test('the business keeps its tax settings, off until said', () {
    final BusinessInfo off = BusinessInfo.tryFromMap(<String, dynamic>{'id': 't', 'name': 'Ali'})!;
    expect(off.taxEnabled, isFalse);
    expect(TaxSettings.of(off).charges, isFalse);
    final BusinessInfo on = BusinessInfo.tryFromMap(<String, dynamic>{
      'id': 't',
      'name': 'Ali',
      'taxEnabled': true,
      'gstRate': 17,
      'vatRate': 5.5,
      'pricesIncludeTax': true,
      'taxNumber': 'NTN 1',
    })!;
    expect(<Object>[on.taxEnabled, on.gstRate, on.vatRate, on.pricesIncludeTax, on.taxNumber], <Object>[true, 17.0, 5.5, true, 'NTN 1']);
    expect(BusinessInfo.tryFromMap(on.toMap()), on);
    expect(on.copyWith(gstRate: 5).vatRate, 5.5);
    expect(TaxSettings.of(on).charges, isTrue);
  });

  group('returns give the tax back', () {
    OrderModel taxed(TaxSettings settings) {
      final OrderModel base = OrderModel(id: 'o', orderNo: 'O', customerId: 'c', customerName: 'Ali', status: OrderStatus.delivered, items: <OrderItem>[OrderItem(id: 'a', productId: 'p', variantId: 'v', productName: 'Bat', variantLabel: '', sku: 'BAT', quantity: 3, unitPrice: 100)]);
      return base.withTax(computeTax(base.subtotal, settings));
    }

    test('tax added on top is credited with the goods', () {
      final OrderModel order = taxed(_gst17); // 300 + 51
      final ReturnPlan plan = ReturnPlan(order: order);
      expect(plan.totalValue(<String, int>{'a': 1}), 100);
      expect(plan.taxOf(<String, int>{'a': 1}), 17);
      expect(plan.creditOf(<String, int>{'a': 1}), 117);
      // Paid in full (351): handing the credit back is what was paid beyond what is left.
      expect(plan.overpaid(settled: 351, credit: 117), 117);
    });

    test('several returns never give back more tax than was charged', () {
      final OrderModel order = taxed(_gst17);
      final ReturnPlan second = ReturnPlan(order: order, alreadyReturned: <String, int>{'a': 1});
      expect(second.taxOf(<String, int>{'a': 2}), 34); // 51 in all
      expect(second.creditOf(<String, int>{'a': 2}), 234);
    });

    test('when the prices include the tax the credit is the price, and the tax inside is still told', () {
      final OrderModel order = taxed(const TaxSettings(enabled: true, gstRate: 17, vatRate: 5, pricesIncludeTax: true));
      final ReturnPlan plan = ReturnPlan(order: order);
      expect(plan.creditOf(<String, int>{'a': 1}), 100);
      expect(plan.taxOf(<String, int>{'a': 1}), 18.03);
    });

    test('an order without tax is as before', () {
      final ReturnPlan plan = ReturnPlan(order: taxed(TaxSettings.none));
      expect(plan.taxOf(<String, int>{'a': 2}), 0);
      expect(plan.creditOf(<String, int>{'a': 2}), 200);
    });

    test('a return from the server says its tax and its credit; an older server says neither', () {
      final OrderReturn r = OrderReturn.fromMap(<String, dynamic>{'id': 'r', 'totalValue': 100, 'taxAmount': 17, 'creditAmount': 117});
      expect(<double>[r.totalValue, r.taxAmount, r.creditAmount], <double>[100, 17, 117]);
      final OrderReturn old = OrderReturn.fromMap(<String, dynamic>{'id': 'r', 'totalValue': 100});
      expect(<double>[old.taxAmount, old.creditAmount], <double>[0, 100]);
    });
  });

  test('the dashboard counts sales before tax: tax is not income', () {
    final OrderModel o = OrderModel(orderNo: 'O', customerId: 'c', customerName: 'A', items: <OrderItem>[_item(3, 100)]).withTax(computeTax(300, _gst17));
    expect(o.totalAmount, 351);
    final DashboardStats stats = computeDashboardStats(orders: <OrderModel>[o], products: const <ProductModel>[], onHand: const <String, int>{}, now: DateTime.now());
    expect(stats.salesToday, 300);
    expect(stats.salesMonth, 300);
  });

  test('the tax report is a table of what was collected, given back and owed', () {
    final TaxReport r = TaxReport.fromMap(<String, dynamic>{
      'period': <String, dynamic>{'from': '2026-11-01', 'to': '2026-11-22'},
      'enabled': true,
      'collected': <String, dynamic>{'gst': 51, 'vat': 15, 'total': 66},
      'returned': <String, dynamic>{'gst': 17, 'vat': 5, 'total': 22},
      'net': <String, dynamic>{'gst': 34, 'vat': 10, 'total': 44},
      'salesWithoutTax': 300,
      'orders': 1,
      'returns': 1,
    });
    final ReportTable t = taxTable(_l10n, r);
    expect(t.title, 'Tax summary');
    expect(t.rows, <List<Object?>>[
      <Object?>['GST', 51.0, 17.0, 34.0],
      <Object?>['VAT', 15.0, 5.0, 10.0],
    ]);
    expect(t.totals, <Object?>['Total', 66.0, 22.0, 44.0]);
    expect(t.toCsv(), contains('Total,66.00,22.00,44.00'));
  });

  group('the tax settings form', () {
    Future<_FakeBusinessService> pump(WidgetTester tester, {required bool canEdit, BusinessInfo? business}) async {
      final _FakeBusinessService service = _FakeBusinessService();
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(ProviderScope(
        overrides: <Override>[
          businessServiceProvider.overrideWithValue(service),
          businessProvider.overrideWithValue(business ?? const BusinessInfo(id: 't', name: 'Ali', walkInCustomerId: '')),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SingleChildScrollView(child: TaxSettingsForm(canEdit: canEdit))),
        ),
      ));
      await tester.pumpAndSettle();
      return service;
    }

    testWidgets('an admin turns it on with a rate, says whether the price includes it, and saves', (WidgetTester tester) async {
      final _FakeBusinessService service = await pump(tester, canEdit: true);
      expect(find.text('GST rate (%)'), findsNothing); // off: no rates to fill
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'GST rate (%)'), '17');
      await tester.enterText(find.widgetWithText(TextField, 'VAT rate (%)'), '5');
      await tester.tap(find.text('Yes, the tax is inside the price'));
      await tester.pump();
      await tester.enterText(find.widgetWithText(TextField, 'Tax registration number (printed on receipts)'), ' NTN 1 ');
      await tester.tap(find.text('Save tax settings'));
      await tester.pumpAndSettle();
      expect(service.updates.single, <String, Object?>{'on': true, 'gst': 17.0, 'vat': 5.0, 'includes': true, 'number': 'NTN 1'});
      expect(find.text('Tax settings saved.'), findsOneWidget);
    });

    testWidgets('refuses to switch on with no rate, and a rate that is not 0 to 100', (WidgetTester tester) async {
      final _FakeBusinessService service = await pump(tester, canEdit: true);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save tax settings'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a GST or VAT rate above 0.'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'GST rate (%)'), '150');
      await tester.tap(find.text('Save tax settings'));
      await tester.pumpAndSettle();
      expect(find.text('A rate is a number from 0 to 100.'), findsOneWidget);
      expect(service.updates, isEmpty);
    });

    testWidgets('someone who is not an admin sees it but cannot change it', (WidgetTester tester) async {
      await pump(tester, canEdit: false, business: const BusinessInfo(id: 't', name: 'Ali', walkInCustomerId: '', taxEnabled: true, gstRate: 17));
      expect(find.text('Only an admin can change the tax settings.'), findsOneWidget);
      expect(find.text('Save tax settings'), findsNothing);
      expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
    });
  });
}
