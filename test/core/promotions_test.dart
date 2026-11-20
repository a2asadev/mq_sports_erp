import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/core/utils/promotion_engine.dart';
import 'package:a2_stocks/core/utils/promotion_text.dart';
import 'package:a2_stocks/models/promotion.dart';

// The same cases as the server's test/promotion-engine.spec.ts: the two engines must agree to the cent.

Promotion rule({
  String id = 'p1',
  String name = 'Promo',
  PromotionKind kind = PromotionKind.percent,
  double value = 10,
  PromotionScope scope = PromotionScope.category,
  String? targetId = 'cricket',
  int minQuantity = 1,
  double minAmount = 0,
  String code = '',
  List<String> channels = const <String>['pos', 'web'],
  String? startsOn,
  String? endsOn,
  bool isActive = true,
}) =>
    Promotion(
      id: id,
      name: name,
      kind: kind,
      value: value,
      scope: scope,
      targetId: targetId,
      minQuantity: minQuantity,
      minAmount: minAmount,
      code: code,
      channels: channels,
      startsOn: startsOn,
      endsOn: endsOn,
      isActive: isActive,
    );

PromoLine line(String key, String productId, List<String> categories, int quantity, double unitPrice, [double discount = 0]) =>
    PromoLine(key: key, productId: productId, categoryIds: categories, quantity: quantity, unitPrice: unitPrice, discount: discount);

const String today = '2026-12-10';
final PromoLine bat = line('bat', 'p-bat', <String>['cricket', 'sports'], 3, 100);
final PromoLine ball = line('ball', 'p-ball', <String>['football', 'sports'], 2, 50);

PromoResult run(List<Promotion> rules, List<PromoLine> lines, {String coupon = ''}) =>
    evaluatePromotions(rules, lines, today: today, channel: 'pos', couponCode: coupon);

List<double> discounts(PromoResult r) => r.lines.map((PromoLineResult l) => l.discount).toList();

void main() {
  group('which promotions can apply', () {
    bool eligible(Promotion p, {String coupon = ''}) => promotionIsEligible(p, today: today, channel: 'pos', couponCode: coupon);

    test('must be active, on this channel, inside its dates, with no code or the right one', () {
      expect(eligible(rule()), isTrue);
      expect(eligible(rule(isActive: false)), isFalse);
      expect(eligible(rule(channels: <String>['web'])), isFalse);
      expect(eligible(rule(startsOn: '2026-12-11')), isFalse);
      expect(eligible(rule(startsOn: today, endsOn: today)), isTrue);
      expect(eligible(rule(endsOn: '2026-12-09')), isFalse);
      expect(eligible(rule(code: 'EID10')), isFalse);
      expect(eligible(rule(code: 'EID10'), coupon: ' eid10 '), isTrue);
    });

    test('tells a good coupon from a bad one', () {
      final List<Promotion> rules = <Promotion>[rule(code: 'EID10'), rule(id: 'p2', code: 'OLD', endsOn: '2026-01-01')];
      bool valid(String c) => couponIsValid(rules, today: today, channel: 'pos', couponCode: c);
      expect(valid('eid10'), isTrue);
      expect(valid('OLD'), isFalse);
      expect(valid('NOPE'), isFalse);
      expect(valid(''), isFalse);
    });
  });

  group('line promotions', () {
    test('percent off a category and its sub-categories', () {
      final PromoResult r = run(<Promotion>[rule(targetId: 'sports')], <PromoLine>[bat, ball]);
      expect(discounts(r), <double>[30, 10]);
      expect(r.total, 40);
      expect(r.applied.single.amount, 40);
      expect(discounts(run(<Promotion>[rule()], <PromoLine>[bat, ball])), <double>[30, 0]);
    });

    test('percent off a product, or an amount off every unit', () {
      expect(discounts(run(<Promotion>[rule(scope: PromotionScope.product, targetId: 'p-ball', value: 20)], <PromoLine>[bat, ball])), <double>[0, 20]);
      expect(discounts(run(<Promotion>[rule(scope: PromotionScope.product, targetId: 'p-bat', kind: PromotionKind.amount, value: 15)], <PromoLine>[bat, ball])), <double>[45, 0]);
    });

    test('bulk tier counts the units of all matching lines together', () {
      final Promotion tier = rule(targetId: 'sports', minQuantity: 6);
      expect(run(<Promotion>[tier], <PromoLine>[bat, ball]).total, 0);
      expect(run(<Promotion>[tier], <PromoLine>[bat, line('ball', 'p-ball', <String>['football', 'sports'], 3, 50)]).total, 45);
    });

    test('each line gets the single best of several tiers, never the sum', () {
      final List<Promotion> tiers = <Promotion>[
        rule(id: 't5', minQuantity: 5, value: 5),
        rule(id: 't10', minQuantity: 10, value: 10),
        rule(id: 'all', value: 3),
      ];
      PromoLineResult first(int qty) => run(tiers, <PromoLine>[line('bat', 'p-bat', <String>['cricket'], qty, 100)]).lines.first;
      expect(first(10).discount, 100);
      expect(first(10).promotionId, 't10');
      expect(first(6).discount, 30);
      expect(first(6).promotionId, 't5');
      expect(first(2).discount, 6);
      expect(first(2).promotionId, 'all');
    });

    test('works after the line\'s own discount and never goes below zero', () {
      expect(run(<Promotion>[rule(value: 50)], <PromoLine>[line('bat', 'p-bat', <String>['cricket'], 2, 100, 40)]).lines.first.discount, 80);
      expect(run(<Promotion>[rule(kind: PromotionKind.amount, value: 500)], <PromoLine>[line('bat', 'p-bat', <String>['cricket'], 1, 100)]).lines.first.discount, 100);
    });

    test('does not touch items outside its target', () {
      expect(run(<Promotion>[rule(targetId: 'tennis')], <PromoLine>[bat, ball]).total, 0);
      expect(run(<Promotion>[rule(targetId: null)], <PromoLine>[bat]).total, 0);
    });
  });

  group('order promotions', () {
    test('percent or flat amount from a minimum amount, never more than the order', () {
      final Promotion tenPercent = rule(scope: PromotionScope.order, targetId: null, minAmount: 400);
      expect(run(<Promotion>[tenPercent], <PromoLine>[bat, ball]).orderDiscount, 40);
      expect(run(<Promotion>[tenPercent], <PromoLine>[bat]).orderDiscount, 0);
      final Promotion flat = rule(scope: PromotionScope.order, targetId: null, kind: PromotionKind.amount, value: 50);
      expect(run(<Promotion>[flat], <PromoLine>[bat]).orderDiscount, 50);
      expect(run(<Promotion>[flat], <PromoLine>[line('x', 'p', <String>[], 1, 20)]).orderDiscount, 20);
    });

    test('counts the subtotal after line promotions and picks the best order promotion', () {
      final Promotion lineOff = rule(id: 'l', targetId: 'sports', value: 25);
      final Promotion order = rule(id: 'o1', scope: PromotionScope.order, targetId: null, minAmount: 350);
      expect(run(<Promotion>[lineOff, order], <PromoLine>[bat, ball]).orderDiscount, 0);
      final PromoResult r = run(
        <Promotion>[rule(id: 'a', scope: PromotionScope.order, targetId: null, value: 5), rule(id: 'b', scope: PromotionScope.order, targetId: null, value: 8)],
        <PromoLine>[bat, ball],
      );
      expect(r.orderPromotionId, 'b');
      expect(r.orderDiscount, 32);
    });

    test('stacks after a line promotion, on what is left', () {
      final PromoResult r = run(
        <Promotion>[rule(id: 'l', name: 'Cricket'), rule(id: 'o', name: 'Big order', scope: PromotionScope.order, targetId: null, minAmount: 100)],
        <PromoLine>[bat, ball],
      );
      expect(discounts(r), <double>[30, 0]);
      expect(r.orderDiscount, 37);
      expect(r.total, 67);
      expect(r.lineTotal, 30);
      expect(r.applied.map((AppliedPromotion a) => a.name).toList(), <String>['Cricket', 'Big order']);
    });
  });

  test('rounds to the cent and copes with nothing to do', () {
    expect(run(<Promotion>[rule(value: 15)], <PromoLine>[line('bat', 'p-bat', <String>['cricket'], 1, 33.33)]).lines.first.discount, 5);
    expect(run(<Promotion>[], <PromoLine>[bat]).total, 0);
    expect(run(<Promotion>[rule()], <PromoLine>[]).total, 0);
  });

  group('the model and its text', () {
    test('round-trips through the API map and tolerates missing fields', () {
      final Promotion p = Promotion.fromMap(<String, dynamic>{
        'id': 'x',
        'name': 'Cricket week',
        'kind': 'amount',
        'value': 15,
        'scope': 'product',
        'targetId': 'p1',
        'minQuantity': 5,
        'code': 'EID',
        'channels': <String>['pos'],
        'startsOn': '2026-12-01',
        'endsOn': null,
      });
      expect(p.kind, PromotionKind.amount);
      expect(p.scope, PromotionScope.product);
      expect(p.isCoupon, isTrue);
      expect(p.endsOn, isNull);
      expect(Promotion.fromMap(p.toMap()).toMap(), p.toMap());
      final Promotion bare = Promotion.fromMap(<String, dynamic>{'id': 'y'});
      expect(bare.scope, PromotionScope.order);
      expect(bare.channels, <String>['pos', 'web']);
      expect(bare.isActive, isTrue);
    });

    test('says whether a promotion is working today', () {
      expect(promotionState(rule(), today), PromotionState.on);
      expect(promotionState(rule(isActive: false), today), PromotionState.off);
      expect(promotionState(rule(startsOn: '2026-12-11'), today), PromotionState.scheduled);
      expect(promotionState(rule(endsOn: '2026-12-09'), today), PromotionState.ended);
    });
  });
}
