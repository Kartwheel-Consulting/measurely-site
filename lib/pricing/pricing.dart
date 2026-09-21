/// The pricing rule — a Dart port of app/pricing.ts in the Measurely app.
///
/// The live demos on this site must quote exactly what a real store would
/// charge, so this is a line-for-line port, not a re-implementation. The
/// cases in test/pricing_test.dart are the same cases as app/pricing.test.ts;
/// if one of them fails, this file has drifted from the app.
///
/// Money is integer minor units (cents) throughout. Measurements are doubles.
///
/// One runtime difference, checked and harmless: JavaScript's Math.round
/// rounds .5 towards +infinity, Dart's round() rounds .5 away from zero. The
/// two agree for every positive number, and every amount here is positive.
library;

import 'dart:math' as math;

const Map<String, double> linearToM = {
  'mm': 0.001,
  'cm': 0.01,
  'm': 1,
  'in': 0.0254,
  'ft': 0.3048,
  'yd': 0.9144,
};

const Map<String, double> massToKg = {
  'g': 0.001,
  'kg': 1,
  'lb': 0.45359237,
};

enum Dimension { area, length, volume, mass, count }

class PricingUnitInfo {
  const PricingUnitInfo(this.dim, this.factor, this.label,
      {this.divide = false});

  final Dimension dim;
  final double factor;
  final String label;

  /// ft and lb divide by the factor; the others multiply. Kept as data so the
  /// table can be const.
  final bool divide;

  double fromSI(double v) => divide ? v / factor : v * factor;
}

const Map<String, PricingUnitInfo> pricingUnitInfo = {
  'm2': PricingUnitInfo(Dimension.area, 1, 'm²'),
  'ft2': PricingUnitInfo(Dimension.area, 10.7639104167, 'ft²'),
  'm': PricingUnitInfo(Dimension.length, 1, 'm'),
  'ft': PricingUnitInfo(Dimension.length, 0.3048, 'ft', divide: true),
  'm3': PricingUnitInfo(Dimension.volume, 1, 'm³'),
  'ft3': PricingUnitInfo(Dimension.volume, 35.3146667215, 'ft³'),
  'kg': PricingUnitInfo(Dimension.mass, 1, 'kg'),
  'lb': PricingUnitInfo(Dimension.mass, 0.45359237, 'lb', divide: true),
  'count': PricingUnitInfo(Dimension.count, 1, ''),
};

class TypeSpec {
  const TypeSpec(this.fields, this.dim, this._measure, {this.direct = false});

  final List<String> fields;
  final Dimension dim;
  final double Function(List<double>) _measure;

  /// The customer types the pricing unit directly, so nothing is converted.
  final bool direct;

  double measure(List<double> v) => _measure(v);
}

double _areaLw(List<double> v) => v[0] * v[1];
double _first(List<double> v) => v[0];
double _linearLw(List<double> v) => v[0] + v[1];
double _perimeter(List<double> v) => 2 * (v[0] + v[1]);
double _volumeLwh(List<double> v) => v[0] * v[1] * v[2];

const Map<String, TypeSpec> typeSpecs = {
  'area_lw': TypeSpec(['Length', 'Width'], Dimension.area, _areaLw),
  'area': TypeSpec(['Area'], Dimension.area, _first, direct: true),
  'length': TypeSpec(['Length'], Dimension.length, _first),
  'linear_lw': TypeSpec(['Length', 'Width'], Dimension.length, _linearLw),
  'perimeter': TypeSpec(['Length', 'Width'], Dimension.length, _perimeter),
  'volume_lwh':
      TypeSpec(['Length', 'Width', 'Height'], Dimension.volume, _volumeLwh),
  'volume': TypeSpec(['Volume'], Dimension.volume, _first, direct: true),
  'weight': TypeSpec(['Weight'], Dimension.mass, _first, direct: true),
  'quantity': TypeSpec(['Quantity'], Dimension.count, _first, direct: true),
};

TypeSpec? specFor(String type) => typeSpecs[type];

/// One band of a tiered rate. Flat, not progressive: a measurement inside a
/// band is priced entirely at that band's rate.
class TierRule {
  const TierRule(this.minValue, this.maxValue, this.unitPrice);

  /// Inclusive lower bound, in the pricing unit. Exact decimal string.
  final String minValue;

  /// Exclusive upper bound. Null means "and above".
  final String? maxValue;

  /// Minor units per pricing unit inside this band.
  final int unitPrice;
}

class QuantityRule {
  const QuantityRule(this.minQty, this.maxQty, this.percent);

  final int minQty;
  final int? maxQty;
  final String percent;
}

class PricingConfig {
  const PricingConfig({
    required this.type,
    required this.inputUnit,
    required this.pricingUnit,
    required this.ratePerUnit,
    this.basePrice = 0,
    this.minPrice = 0,
    this.maxPrice,
    this.overagePct,
    this.roundingMode = 'nearest',
    this.tiers = const [],
    this.quantityDiscounts = const [],
  });

  final String type;
  final String inputUnit;
  final String pricingUnit;

  /// Minor units. Zero means "use the product's own price as the rate".
  final int ratePerUnit;
  final int basePrice;
  final int minPrice;
  final int? maxPrice;
  final String? overagePct;
  final String roundingMode;
  final List<TierRule> tiers;
  final List<QuantityRule> quantityDiscounts;

  PricingConfig copyWith({
    String? type,
    String? inputUnit,
    String? pricingUnit,
    int? ratePerUnit,
    int? basePrice,
    int? minPrice,
    int? maxPrice,
    bool clearMaxPrice = false,
    String? overagePct,
    bool clearOverage = false,
    String? roundingMode,
    List<TierRule>? tiers,
    List<QuantityRule>? quantityDiscounts,
  }) {
    return PricingConfig(
      type: type ?? this.type,
      inputUnit: inputUnit ?? this.inputUnit,
      pricingUnit: pricingUnit ?? this.pricingUnit,
      ratePerUnit: ratePerUnit ?? this.ratePerUnit,
      basePrice: basePrice ?? this.basePrice,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      overagePct: clearOverage ? null : (overagePct ?? this.overagePct),
      roundingMode: roundingMode ?? this.roundingMode,
      tiers: tiers ?? this.tiers,
      quantityDiscounts: quantityDiscounts ?? this.quantityDiscounts,
    );
  }
}

/// The outcome of pricing one item.
///
/// [ok] false carries a [reason] and nothing else. The extra fields beyond the
/// app's PriceResult ([orderedMeasure], [floorApplied], [capped]) exist only
/// so the demo can explain the price; they do not change the arithmetic.
class PriceResult {
  const PriceResult.fail(this.reason)
      : ok = false,
        measure = 0,
        orderedMeasure = 0,
        minor = 0,
        rateMinor = 0,
        discountPct = 0,
        floorApplied = false,
        capped = false;

  const PriceResult.success({
    required this.measure,
    required this.orderedMeasure,
    required this.minor,
    required this.rateMinor,
    required this.discountPct,
    required this.floorApplied,
    required this.capped,
  })  : ok = true,
        reason = '';

  final bool ok;
  final String reason;

  /// In the pricing unit, after wastage.
  final double measure;

  /// In the pricing unit, as ordered — before wastage.
  final double orderedMeasure;

  /// The price of ONE item, in minor units.
  final int minor;
  final int rateMinor;
  final double discountPct;
  final bool floorApplied;
  final bool capped;
}

double _parse(String? s) => double.tryParse((s ?? '').trim()) ?? double.nan;

/// Which rate applies to a measurement of this size. Overlapping bands resolve
/// to the highest matching lower bound, so their order never matters.
int rateForMeasure(List<TierRule>? tiers, double measure, int fallbackMinor) {
  if (tiers == null || tiers.isEmpty) {
    return fallbackMinor;
  }

  TierRule? best;
  var bestMin = double.negativeInfinity;

  for (final tier in tiers) {
    final min = _parse(tier.minValue);
    if (!min.isFinite || measure < min) {
      continue;
    }

    final max = tier.maxValue == null ? double.infinity : _parse(tier.maxValue);
    if (max.isFinite && measure >= max) {
      continue;
    }

    if (min > bestMin) {
      best = tier;
      bestMin = min;
    }
  }

  if (best == null || !(best.unitPrice > 0)) {
    return fallbackMinor;
  }
  return best.unitPrice;
}

/// The percentage off for this quantity, or 0.
double discountFor(List<QuantityRule>? rules, int quantity) {
  if (rules == null || rules.isEmpty) {
    return 0;
  }
  if (quantity < 1) {
    return 0;
  }

  double best = 0;
  int? bestMin;

  for (final rule in rules) {
    if (quantity < rule.minQty) {
      continue;
    }
    if (rule.maxQty != null && quantity > rule.maxQty!) {
      continue;
    }

    final percent = _parse(rule.percent);
    if (!percent.isFinite || percent <= 0 || percent >= 100) {
      continue;
    }

    if (bestMin == null || rule.minQty > bestMin) {
      best = percent;
      bestMin = rule.minQty;
    }
  }

  return best;
}

double _toSI(PricingConfig config, TypeSpec spec, double value) {
  if (spec.dim == Dimension.count) {
    return value;
  }
  if (spec.direct) {
    return value;
  }
  if (spec.dim == Dimension.mass) {
    return value * (massToKg[config.inputUnit] ?? 1);
  }
  return value * (linearToM[config.inputUnit] ?? 0.01);
}

/// One measurement, one price — for ONE item. The cart line is this times the
/// quantity; the quantity only matters here for choosing a discount band.
PriceResult computePrice(
  PricingConfig config,
  List<double> values,
  int fallbackRateMinor, [
  int quantity = 1,
]) {
  final spec = specFor(config.type);
  if (spec == null) {
    return PriceResult.fail('Unsupported calculator type: ${config.type}');
  }

  final unit = pricingUnitInfo[config.pricingUnit];
  if (unit == null) {
    return PriceResult.fail('Unknown pricing unit: ${config.pricingUnit}');
  }

  if (values.length != spec.fields.length) {
    return const PriceResult.fail('Wrong number of measurements');
  }
  for (final value in values) {
    if (!value.isFinite || value <= 0) {
      return const PriceResult.fail('Measurements must be greater than zero');
    }
  }

  final flatRate =
      config.ratePerUnit > 0 ? config.ratePerUnit : fallbackRateMinor;

  final si = values.map((v) => _toSI(config, spec, v)).toList();
  final rawMeasure = spec.measure(si);
  var measure = spec.direct ? rawMeasure : unit.fromSI(rawMeasure);
  final ordered = measure;

  // Chosen against the ordered size, before wastage.
  final rateMinor = rateForMeasure(config.tiers, measure, flatRate);
  if (!(rateMinor > 0)) {
    return const PriceResult.fail('No rate to price against');
  }

  // Wastage is applied to the measurement, not to the money.
  final overage =
      config.overagePct == null ? double.nan : _parse(config.overagePct);
  if (overage.isFinite && overage > 0) {
    measure = measure * (1 + overage / 100);
  }

  final grossExact = measure * rateMinor;
  final int gross;
  if (config.roundingMode == 'up') {
    gross = grossExact.ceil();
  } else if (config.roundingMode == 'down') {
    gross = grossExact.floor();
  } else {
    gross = grossExact.round();
  }

  var minor = gross + config.basePrice;

  // The product's own price is always a floor.
  var floorApplied = false;
  final floor = math.max(config.minPrice, fallbackRateMinor);
  if (floor > 0 && minor < floor) {
    minor = floor;
    floorApplied = true;
  }

  // A quantity discount comes after the floor — a deliberate choice, see the app.
  final percent = discountFor(config.quantityDiscounts, quantity);
  if (percent > 0) {
    minor = (minor * (1 - percent / 100)).round();
  }

  // The cap is applied last and always wins.
  var capped = false;
  if (config.maxPrice != null && minor > config.maxPrice!) {
    minor = config.maxPrice!;
    capped = true;
  }

  return PriceResult.success(
    measure: measure,
    orderedMeasure: ordered,
    minor: minor,
    rateMinor: rateMinor,
    discountPct: percent,
    floorApplied: floorApplied,
    capped: capped,
  );
}

/// 37500 -> "$375.00". Thousands separated, always two decimals.
String formatMinor(int minor, {String symbol = r'$'}) {
  final negative = minor < 0;
  final abs = minor.abs();
  final whole = (abs ~/ 100).toString();
  final cents = (abs % 100).toString().padLeft(2, '0');
  final buf = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) {
      buf.write(',');
    }
    buf.write(whole[i]);
  }
  return '${negative ? '-' : ''}$symbol$buf.$cents';
}

/// A measurement for display: up to three decimals, trailing zeros removed.
String formatMeasure(double v) {
  var s = v.toStringAsFixed(3);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
  }
  return s;
}
