import 'package:flutter/material.dart';

import '../pricing/pricing.dart';

/// One calculator type, as the site presents it.
///
/// Only the nine types the app's pricing engine actually prices are listed.
/// The app's type dropdown names more (rolls, boxes, room walls and others);
/// those are not priced yet, so they are not advertised here.
class CalculatorInfo {
  const CalculatorInfo({
    required this.type,
    required this.slug,
    required this.name,
    required this.formula,
    required this.summary,
    required this.example,
    required this.trades,
    required this.icon,
    required this.demo,
    required this.productPrice,
    required this.demoValues,
    this.demoTiers = const [],
  });

  /// The app's internal type key — what the pricing engine reads.
  final String type;

  /// URL segment: `/calculators/<slug>`.
  final String slug;
  final String name;

  /// How the measurement is worked out, in words a merchant uses.
  final String formula;
  final String summary;

  /// The product the live demo pretends to be.
  final String example;
  final List<String> trades;
  final IconData icon;

  /// The calculator the demo starts with. Rates are in cents.
  final PricingConfig demo;

  /// The demo product's own Shopify price, in cents — which is also the floor.
  final int productPrice;
  final List<double> demoValues;

  /// Bands offered when a visitor switches on tiered rates. In the pricing unit.
  final List<TierRule> demoTiers;

  TypeSpec get spec => specFor(type)!;
}

/// Quantity bands the demo offers when discounts are switched on.
const demoDiscounts = <QuantityRule>[
  QuantityRule(10, 49, '5'),
  QuantityRule(50, null, '10'),
];

const calculators = <CalculatorInfo>[
  CalculatorInfo(
    type: 'area_lw',
    slug: 'area',
    name: 'Area — length × width',
    formula: 'Length × Width',
    summary:
        'The customer types two sides and pays for the area. The most common '
        'calculator for anything cut from a sheet.',
    example: 'Toughened glass, cut to size',
    trades: [
      'Glass & glazing',
      'Worktops & stone',
      'Signage & print',
      'Blinds'
    ],
    icon: Icons.crop_square_rounded,
    demo: PricingConfig(
      type: 'area_lw',
      inputUnit: 'cm',
      pricingUnit: 'm2',
      ratePerUnit: 8500,
    ),
    productPrice: 2500,
    demoValues: [120, 60],
    demoTiers: [TierRule('0', '1', 9500), TierRule('1', null, 8000)],
  ),
  CalculatorInfo(
    type: 'area',
    slug: 'area-direct',
    name: 'Area — direct entry',
    formula: 'Area, as typed',
    summary:
        'For customers who already know the area they need — a room measured '
        'in square metres or square feet.',
    example: 'Engineered oak flooring',
    trades: [
      'Flooring & carpet',
      'Wallpaper & wall panels',
      'Turf & landscaping'
    ],
    icon: Icons.grid_view_rounded,
    demo: PricingConfig(
      type: 'area',
      inputUnit: 'm',
      pricingUnit: 'm2',
      ratePerUnit: 3200,
    ),
    productPrice: 3200,
    demoValues: [14.5],
    demoTiers: [TierRule('0', '20', 3200), TierRule('20', null, 2800)],
  ),
  CalculatorInfo(
    type: 'length',
    slug: 'length',
    name: 'Length',
    formula: 'Length',
    summary: 'One measurement, priced per metre or per foot.',
    example: 'Braided rope, cut from the reel',
    trades: ['Rope, cable & chain', 'Fabric by the metre', 'Trims & edging'],
    icon: Icons.straighten_rounded,
    demo: PricingConfig(
      type: 'length',
      inputUnit: 'm',
      pricingUnit: 'm',
      ratePerUnit: 450,
    ),
    productPrice: 450,
    demoValues: [12],
    demoTiers: [TierRule('0', '25', 450), TierRule('25', null, 380)],
  ),
  CalculatorInfo(
    type: 'linear_lw',
    slug: 'linear',
    name: 'Linear — length + width',
    formula: 'Length + Width',
    summary: 'Two sides added together, for products priced on an L-shaped run '
        'rather than the area inside it.',
    example: 'Corner worktop edging',
    trades: ['Worktops & stone', 'Timber & sheet materials'],
    icon: Icons.turn_right_rounded,
    demo: PricingConfig(
      type: 'linear_lw',
      inputUnit: 'cm',
      pricingUnit: 'm',
      ratePerUnit: 1200,
    ),
    productPrice: 1500,
    demoValues: [240, 90],
  ),
  CalculatorInfo(
    type: 'perimeter',
    slug: 'perimeter',
    name: 'Perimeter',
    formula: '2 × (Length + Width)',
    summary:
        'The distance all the way round — for frames, borders and anything '
        'that runs along every edge.',
    example: 'Hardwood picture-frame moulding',
    trades: ['Framing', 'Timber & sheet materials', 'Metal & fabrication'],
    icon: Icons.check_box_outline_blank_rounded,
    demo: PricingConfig(
      type: 'perimeter',
      inputUnit: 'cm',
      pricingUnit: 'm',
      ratePerUnit: 1800,
    ),
    productPrice: 2000,
    demoValues: [60, 40],
  ),
  CalculatorInfo(
    type: 'volume_lwh',
    slug: 'volume',
    name: 'Volume — L × W × H',
    formula: 'Length × Width × Height',
    summary: 'Three sides, priced per cubic metre or cubic foot.',
    example: 'High-density foam, cut to size',
    trades: ['Fabric & upholstery', 'Packaging', 'Timber & sheet materials'],
    icon: Icons.view_in_ar_rounded,
    demo: PricingConfig(
      type: 'volume_lwh',
      inputUnit: 'cm',
      pricingUnit: 'm3',
      ratePerUnit: 22000,
    ),
    productPrice: 1500,
    demoValues: [180, 60, 10],
  ),
  CalculatorInfo(
    type: 'volume',
    slug: 'volume-direct',
    name: 'Volume — direct entry',
    formula: 'Volume, as typed',
    summary: 'For loose materials ordered by the cubic metre.',
    example: 'Screened topsoil, loose',
    trades: ['Aggregates & soil', 'Landscaping', 'Concrete'],
    icon: Icons.inventory_2_outlined,
    demo: PricingConfig(
      type: 'volume',
      inputUnit: 'm',
      pricingUnit: 'm3',
      ratePerUnit: 6500,
    ),
    productPrice: 6500,
    demoValues: [3],
  ),
  CalculatorInfo(
    type: 'weight',
    slug: 'weight',
    name: 'Weight',
    formula: 'Weight, as typed',
    summary:
        'Priced per kilogram or per pound — whatever the customer asks for.',
    example: 'Single-origin coffee beans',
    trades: ['Food & drink', 'Metal & fabrication', 'Aggregates'],
    icon: Icons.scale_outlined,
    demo: PricingConfig(
      type: 'weight',
      inputUnit: 'kg',
      pricingUnit: 'kg',
      ratePerUnit: 2400,
    ),
    productPrice: 800,
    demoValues: [2.5],
  ),
  CalculatorInfo(
    type: 'quantity',
    slug: 'quantity',
    name: 'Quantity',
    formula: 'Number of items',
    summary: 'A price per item with the same floor, cap and discount rules as '
        'every other calculator.',
    example: 'Custom printed labels',
    trades: ['Signage & print', 'Packaging', 'Promotional goods'],
    icon: Icons.tag_rounded,
    demo: PricingConfig(
      type: 'quantity',
      inputUnit: 'm',
      pricingUnit: 'count',
      ratePerUnit: 35,
    ),
    productPrice: 1000,
    demoValues: [250],
  ),
];

CalculatorInfo? calculatorBySlug(String slug) {
  for (final c in calculators) {
    if (c.slug == slug) {
      return c;
    }
  }
  return null;
}

/// What a customer can type in, for a given dimension.
List<String> inputUnitsFor(Dimension dim) {
  switch (dim) {
    case Dimension.mass:
      return const ['g', 'kg', 'lb'];
    case Dimension.count:
      return const [];
    default:
      return const ['mm', 'cm', 'm', 'in', 'ft', 'yd'];
  }
}

/// What a merchant can price by, for a given dimension.
List<String> pricingUnitsFor(Dimension dim) {
  switch (dim) {
    case Dimension.area:
      return const ['m2', 'ft2'];
    case Dimension.length:
      return const ['m', 'ft'];
    case Dimension.volume:
      return const ['m3', 'ft3'];
    case Dimension.mass:
      return const ['kg', 'lb'];
    case Dimension.count:
      return const ['count'];
  }
}

const unitNames = <String, String>{
  'mm': 'mm',
  'cm': 'cm',
  'm': 'm',
  'in': 'in',
  'ft': 'ft',
  'yd': 'yd',
  'g': 'g',
  'kg': 'kg',
  'lb': 'lb',
  'm2': 'm²',
  'ft2': 'ft²',
  'm3': 'm³',
  'ft3': 'ft³',
  'count': 'item',
};
