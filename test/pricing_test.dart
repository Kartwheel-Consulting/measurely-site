// The same cases as app/pricing.test.ts in the Measurely app, with the same
// expected numbers. If any fails, the site's demo quotes a different price
// from what a real store charges — fix lib/pricing/pricing.dart, never the
// expected value.

import 'package:flutter_test/flutter_test.dart';
import 'package:measurely_site/pricing/pricing.dart';

const glass = PricingConfig(
  type: 'area_lw',
  inputUnit: 'cm',
  pricingUnit: 'm2',
  ratePerUnit: 75000,
);

int priceOf(PricingConfig c, List<double> v, [int fallback = 0, int qty = 1]) {
  final r = computePrice(c, v, fallback, qty);
  expect(r.ok, isTrue, reason: r.reason);
  return r.minor;
}

const tiers = [
  TierRule('0', '1', 80000),
  TierRule('1', null, 65000),
];

const bands = [
  QuantityRule(10, 49, '5'),
  QuantityRule(50, null, '10'),
];

void main() {
  group('core rule', () {
    test('100 x 50 cm at 750 per square metre is 375.00', () {
      expect(priceOf(glass, [100, 50]), 37500);
    });
    test('a small piece is lifted to the minimum price', () {
      expect(priceOf(glass.copyWith(minPrice: 75000), [15, 10]), 75000);
    });
    test("a rate of zero uses the product's own price as the rate", () {
      expect(
          priceOf(glass.copyWith(ratePerUnit: 0), [200, 100], 75000), 150000);
    });
    test('a non-zero rate is used for the measurement', () {
      expect(priceOf(glass, [100, 50], 10000), 37500);
    });
    test('no rate anywhere is refused', () {
      expect(computePrice(glass.copyWith(ratePerUnit: 0), [100, 50], 0).ok,
          isFalse);
    });
    test('base price is added once', () {
      expect(priceOf(glass.copyWith(basePrice: 500), [100, 50]), 38000);
    });
    test('the maximum price caps the line', () {
      expect(priceOf(glass.copyWith(maxPrice: 10000), [100, 50]), 10000);
    });
    test('overage is applied to the measurement, not the money', () {
      expect(priceOf(glass.copyWith(overagePct: '10'), [100, 50]), 41250);
    });
    test('rounding up and down differ by exactly one cent', () {
      final odd = glass.copyWith(ratePerUnit: 33333);
      final up = priceOf(odd.copyWith(roundingMode: 'up'), [100, 50]);
      final down = priceOf(odd.copyWith(roundingMode: 'down'), [100, 50]);
      expect(up - down, 1);
    });
    test('imperial input against a metric rate converts', () {
      expect(
          priceOf(glass.copyWith(inputUnit: 'in'), [39.3701, 39.3701]), 75000);
    });
    test('per square foot uses square feet', () {
      expect(
          priceOf(
              glass.copyWith(pricingUnit: 'ft2', ratePerUnit: 100), [100, 100]),
          1076);
    });
    test('a direct-entry type takes the pricing unit as typed', () {
      expect(priceOf(glass.copyWith(type: 'area'), [2]), 150000);
    });
    test('quantity prices per item', () {
      final each = glass.copyWith(
          type: 'quantity', pricingUnit: 'count', ratePerUnit: 250);
      expect(priceOf(each, [4]), 1000);
    });
    test('zero and negative measurements are refused', () {
      expect(computePrice(glass, [0, 50], 0).ok, isFalse);
      expect(computePrice(glass, [-1, 50], 0).ok, isFalse);
    });
    test('an unknown type is refused', () {
      expect(computePrice(glass.copyWith(type: 'not_a_type'), [1], 1000).ok,
          isFalse);
    });
    test('the wrong number of measurements is refused', () {
      expect(computePrice(glass, [100], 0).ok, isFalse);
    });
  });

  group("the product's price is a floor", () {
    final usesProductPrice = glass.copyWith(ratePerUnit: 0);
    test('a cut below it is charged the product price', () {
      expect(priceOf(usesProductPrice, [50, 50], 16697), 16697);
    });
    test('a cut above it is charged its measured price', () {
      expect(priceOf(usesProductPrice, [200, 100], 16697), 33394);
    });
    test('exactly one unit lands on the floor', () {
      expect(priceOf(usesProductPrice, [100, 100], 16697), 16697);
    });
    test('a higher fixed minimum still wins', () {
      expect(
          priceOf(usesProductPrice.copyWith(minPrice: 20000), [50, 50], 16697),
          20000);
    });
    test('the floor applies with a separate rate', () {
      expect(priceOf(glass.copyWith(ratePerUnit: 1000), [50, 50], 5000), 5000);
    });
    test('a maximum still wins over the floor', () {
      expect(
          priceOf(usesProductPrice.copyWith(maxPrice: 10000), [50, 50], 16697),
          10000);
    });
  });

  group('tiered rates', () {
    test('a band prices the whole measurement', () {
      expect(priceOf(glass.copyWith(tiers: tiers), [150, 100]), 97500);
    });
    test('first band uses the first rate', () {
      expect(priceOf(glass.copyWith(tiers: tiers), [100, 50]), 40000);
    });
    test('lower bound inclusive, upper exclusive', () {
      expect(rateForMeasure(tiers, 1, 999), 65000);
      expect(rateForMeasure(tiers, 0.999, 999), 80000);
    });
    test('no tiers means the flat rate', () {
      expect(rateForMeasure(const [], 5, 75000), 75000);
      expect(rateForMeasure(null, 5, 75000), 75000);
    });
    test('below every band falls back', () {
      expect(
          rateForMeasure(const [TierRule('10', null, 1000)], 2, 75000), 75000);
    });
    test('overlaps resolve to the highest lower bound, in any order', () {
      const messy = [TierRule('0', null, 80000), TierRule('2', null, 50000)];
      expect(rateForMeasure(messy, 3, 999), 50000);
      expect(rateForMeasure(messy.reversed.toList(), 3, 999), 50000);
    });
    test('a band with no rate falls back', () {
      expect(rateForMeasure(const [TierRule('0', null, 0)], 1, 75000), 75000);
    });
    test('the tier is chosen before wastage', () {
      final r = computePrice(
          glass.copyWith(tiers: tiers, overagePct: '10'), [95, 100], 0);
      expect(r.ok, isTrue);
      expect(r.rateMinor, 80000);
    });
  });

  group('quantity discounts', () {
    test('below the first band there is none', () {
      expect(discountFor(bands, 9), 0);
    });
    test('each band applies from its own minimum', () {
      expect(discountFor(bands, 10), 5);
      expect(discountFor(bands, 49), 5);
      expect(discountFor(bands, 50), 10);
      expect(discountFor(bands, 5000), 10);
    });
    test('a discount comes off the line price', () {
      expect(
          priceOf(glass.copyWith(quantityDiscounts: bands), [100, 50], 0, 10),
          35625);
    });
    test('none at quantity one', () {
      expect(
          priceOf(glass.copyWith(quantityDiscounts: bands), [100, 50]), 37500);
    });
    test('nonsense percentages are ignored', () {
      for (final p in ['0', '100', '-5', 'abc']) {
        expect(discountFor([QuantityRule(1, null, p)], 5), 0, reason: p);
      }
    });
    test("a discount may go below the product's own price", () {
      final d = glass.copyWith(ratePerUnit: 0, quantityDiscounts: bands);
      expect(priceOf(d, [50, 50], 16697, 50), 15027);
    });
    test('the maximum wins over a tier and a discount', () {
      final capped = glass.copyWith(
          tiers: tiers, quantityDiscounts: bands, maxPrice: 10000);
      expect(priceOf(capped, [200, 200], 0, 100), 10000);
    });
  });

  group('formatting', () {
    test('money has separators and two decimals', () {
      expect(formatMinor(37500), r'$375.00');
      expect(formatMinor(123456789), r'$1,234,567.89');
      expect(formatMinor(5), r'$0.05');
    });
    test('measurements drop trailing zeros', () {
      expect(formatMeasure(0.5), '0.5');
      expect(formatMeasure(2), '2');
      expect(formatMeasure(1.0764), '1.076');
    });
  });
}
