import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/receipt.dart';
import 'package:a2_stocks/core/utils/receipt_pdf.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/online/api_client.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/token_store.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/providers/users_providers.dart';
import 'package:a2_stocks/widgets/brand_logo.dart';
import 'package:a2_stocks/widgets/business_brand.dart';

class _FakeCurrentUser extends CurrentUserNotifier {
  @override
  Future<UserModel?> build() async => UserModel(id: 'u1', email: 'a@b.c');
}

http.Response _json(int status, String body) =>
    http.Response(body, status, headers: <String, String>{'content-type': 'application/json'});

void main() {
  // The accent is process-wide: every test starts and ends on the A2 Stocks teal.
  setUp(() => AppColors.useBrand(null));
  tearDown(() => AppColors.useBrand(null));

  group('the business accent colour', () {
    test('is the A2 Stocks teal until a business picks its own', () {
      expect(AppColors.primary, AppColors.a2Primary);
      expect(AppColors.a2Primary, const Color(0xFF008293));
      AppColors.useBrand(const Color(0xFF2563EB));
      expect(AppColors.primary, isNot(AppColors.a2Primary));
      AppColors.useBrand(null);
      expect(AppColors.primary, AppColors.a2Primary);
      expect(AppColors.primaryDark, const Color(0xFF00697A));
      expect(AppColors.primarySoft, const Color(0xFFE0F1F4));
    });

    test('a business colour sets the whole accent family, and the theme follows', () {
      AppColors.useBrand(const Color(0xFF2563EB));
      final Color primary = AppColors.primary;
      expect(primary, const Color(0xFF2563EB)); // already readable: kept as chosen
      expect(AppColors.primaryDark.computeLuminance(), lessThan(primary.computeLuminance()));
      expect(AppColors.primarySoft.computeLuminance(), greaterThan(primary.computeLuminance()));
      final ThemeData theme = AppTheme.light();
      expect(theme.colorScheme.primary, primary);
      expect(theme.colorScheme.primaryContainer, AppColors.primarySoft);
      // Red stays red whatever the brand: it only ever means "wrong".
      expect(theme.colorScheme.error, AppColors.danger);
    });

    test('a colour too light for white text is darkened until it is readable', () {
      double contrast(Color c) => 1.05 / (c.computeLuminance() + 0.05);
      for (final Color light in <Color>[const Color(0xFFFFEB3B), const Color(0xFFCA8A04), const Color(0xFF90CAF9), Colors.white]) {
        AppColors.useBrand(light);
        expect(contrast(AppColors.primary), greaterThanOrEqualTo(4.5), reason: '$light');
      }
      // A colour that is already fine is left alone.
      AppColors.useBrand(const Color(0xFF0F766E));
      expect(AppColors.primary, const Color(0xFF0F766E));
    });

    test('reads and writes the server\'s #RRGGBB form, and refuses anything else', () {
      expect(AppColors.tryParseHex('#2563EB'), const Color(0xFF2563EB));
      expect(AppColors.tryParseHex('#2563eb'), const Color(0xFF2563EB));
      expect(AppColors.tryParseHex(''), isNull);
      expect(AppColors.tryParseHex(null), isNull);
      expect(AppColors.tryParseHex('2563EB'), isNull);
      expect(AppColors.tryParseHex('#12345'), isNull);
      expect(AppColors.tryParseHex('red'), isNull);
      expect(AppColors.toHex(const Color(0xFF2563EB)), '#2563EB');
      expect(AppColors.toHex(const Color(0xFF00010A)), '#00010A');
    });
  });

  group('the business in the app', () {
    test('reads the logo and colour, keeping only a proper #RRGGBB', () {
      BusinessInfo read(Map<String, dynamic> extra) =>
          BusinessInfo.tryFromMap(<String, dynamic>{'id': 't', 'name': 'Ali', ...extra})!;
      expect(read(<String, dynamic>{}).logoUrl, '');
      expect(read(<String, dynamic>{}).brandColor, '');
      expect(read(<String, dynamic>{'logoUrl': 'http://m/logo.webp', 'brandColor': '#2563eb'}).brandColor, '#2563EB');
      expect(read(<String, dynamic>{'logoUrl': 'http://m/logo.webp'}).logoUrl, 'http://m/logo.webp');
      expect(read(<String, dynamic>{'brandColor': 'blue'}).brandColor, '');
      expect(read(<String, dynamic>{'brandColor': 7}).brandColor, '');
      final BusinessInfo full = read(<String, dynamic>{'logoUrl': 'http://m/l.webp', 'brandColor': '#2563EB'});
      expect(BusinessInfo.tryFromMap(full.toMap()), full);
      expect(full.copyWith(brandColor: ''), isNot(full));
      expect(full.copyWith(name: 'X').logoUrl, 'http://m/l.webp');
    });

    test('reading the business points the accent at its colour, and a change applies at once', () async {
      final ApiClient api = ApiClient(
        httpClient: MockClient((http.Request r) async => _json(
              200,
              '{"accessToken":"a","refreshToken":"r","user":{"id":"u1","email":"a@b.c","displayName":"A","role":"admin","isActive":true,'
              '"createdAt":"2026-11-01T00:00:00.000Z","updatedAt":"2026-11-01T00:00:00.000Z"},'
              '"tenant":{"id":"t1","name":"Ali","phone":"","walkInCustomerId":"w1","brandColor":"#7C3AED"}}',
            )),
        baseUrl: 'http://api.test',
        tokens: MemoryTokenStore(),
      );
      await api.login('a@b.c', 'x');
      final ProviderContainer c = ProviderContainer(overrides: <Override>[
        apiClientProvider.overrideWithValue(api),
        currentUserProvider.overrideWith(_FakeCurrentUser.new),
      ]);
      addTearDown(c.dispose);

      expect(AppColors.primary, AppColors.a2Primary);
      expect(c.read(businessProvider).brandColor, '#7C3AED');
      expect(AppColors.primary, const Color(0xFF7C3AED));

      await c.read(businessUpdaterProvider)(c.read(businessProvider).copyWith(brandColor: ''));
      expect(c.read(businessProvider).brandColor, '');
      expect(AppColors.primary, AppColors.a2Primary); // back to the default theme
    });
  });

  group('the header and the footer', () {
    Future<void> pumpWith(WidgetTester tester, BusinessInfo business, Widget child) async {
      await tester.pumpWidget(ProviderScope(
        overrides: <Override>[businessProvider.overrideWithValue(business)],
        child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, theme: AppTheme.light(), home: Scaffold(body: Center(child: child))),
      ));
      await tester.pump();
    }

    testWidgets('a business without a logo shows the A2 Stocks mark and its own name', (WidgetTester tester) async {
      await pumpWith(tester, const BusinessInfo(id: 't', name: 'Ali Traders', walkInCustomerId: ''), const BusinessLockup());
      expect(find.text('Ali Traders'), findsOneWidget);
      expect(find.byType(BrandLogo), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      // It is the mark, not a network picture.
      expect((tester.widget<Image>(find.byType(Image)).image), isA<AssetImage>());
    });

    testWidgets('a business with a logo asks for that picture instead', (WidgetTester tester) async {
      await pumpWith(
        tester,
        const BusinessInfo(id: 't', name: 'Ali Traders', walkInCustomerId: '', logoUrl: 'http://media.test/logo.webp'),
        const BusinessLockup(markHeight: 40),
      );
      final Image image = tester.widget<Image>(find.byType(Image).first);
      expect(image.image, isA<NetworkImage>());
      expect((image.image as NetworkImage).url, 'http://media.test/logo.webp');
      expect(find.text('Ali Traders'), findsOneWidget);
    });

    testWidgets('the name can be left out for narrow places', (WidgetTester tester) async {
      await pumpWith(tester, const BusinessInfo(id: 't', name: 'Ali Traders', walkInCustomerId: ''), const BusinessLockup(showName: false));
      expect(find.text('Ali Traders'), findsNothing);
    });

    testWidgets('the footer credits the product and its makers', (WidgetTester tester) async {
      await pumpWith(tester, BusinessInfo.mqSports, const PoweredByFooter());
      expect(find.text('Powered by'), findsOneWidget);
      expect(find.text('A2 Stocks'), findsOneWidget);
      expect(find.text('Crafted with love by'), findsOneWidget);
      expect(find.text('A2 Devs'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('the footer fits a phone without overflowing, whatever the accent', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(300, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      AppColors.useBrand(const Color(0xFFDC2626));
      await pumpWith(tester, BusinessInfo.mqSports, const PoweredByFooter());
      expect(tester.takeException(), isNull);
      // The credit keeps the A2 Stocks teal: it is the product's, not the business's.
      final Text name = tester.widget<Text>(find.text('A2 Stocks'));
      expect(name.style?.color, AppColors.a2Primary);
    });
  });

  group('the logo on a receipt', () {
    final OrderModel order = OrderModel(
      orderNo: 'ORD-1',
      customerId: 'c1',
      customerName: 'Bilal',
      items: <OrderItem>[
        OrderItem(productId: 'p', variantId: 'v', productName: 'Bat', variantLabel: 'S', sku: 'B', quantity: 1, unitPrice: 1000),
      ],
    );
    ReceiptData receipt({String logoUrl = ''}) => ReceiptData.fromParts(
          order,
          payments: const <ReceiptPayment>[],
          shopName: 'Ali Traders',
          walkInCustomerId: '',
          logoUrl: logoUrl,
        );

    test('the receipt carries the business logo address through both builders', () {
      expect(receipt().logoUrl, '');
      expect(receipt(logoUrl: 'http://m/l.webp').logoUrl, 'http://m/l.webp');
      final ReceiptData fromOrder = ReceiptData.fromOrder(
        order,
        ledger: const [],
        shopName: 'Ali',
        walkInCustomerId: '',
        logoUrl: 'http://m/l.webp',
      );
      expect(fromOrder.logoUrl, 'http://m/l.webp');
    });

    test('the PDF draws a WebP logo (re-encoded, since the PDF library cannot read WebP)', () async {
      final Uint8List webp = File('test/fixtures/logo.webp').readAsBytesSync();
      final List<String> asked = <String>[];
      final Uint8List plain = await buildReceiptPdf(receipt());
      final Uint8List withLogo = await buildReceiptPdf(
        receipt(logoUrl: 'http://m/l.webp'),
        fetchLogo: (String url) async {
          asked.add(url);
          return webp;
        },
      );
      expect(asked, <String>['http://m/l.webp']);
      expect(String.fromCharCodes(withLogo.take(5)), '%PDF-');
      expect(withLogo.length, greaterThan(plain.length + 1000)); // the picture is in there
    });

    test('a logo that cannot be fetched or read leaves the receipt complete, not broken', () async {
      final Uint8List plain = await buildReceiptPdf(receipt());
      for (final Future<Uint8List?> Function(String) fetch in <Future<Uint8List?> Function(String)>[
        (String url) async => null, // offline
        (String url) async => Uint8List.fromList(<int>[1, 2, 3, 4]), // not a picture
        (String url) async => throw Exception('boom'),
      ]) {
        final Uint8List pdf = await buildReceiptPdf(receipt(logoUrl: 'http://m/l.webp'), fetchLogo: fetch);
        expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
        expect((pdf.length - plain.length).abs(), lessThan(500));
      }
      // No logo address: the fetcher is never called.
      bool called = false;
      await buildReceiptPdf(receipt(), fetchLogo: (String url) async {
        called = true;
        return null;
      });
      expect(called, isFalse);
    });
  });
}
