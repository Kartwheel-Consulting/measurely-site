/// Mirror of app/plans.ts in the Measurely app.
///
/// The app is the source of truth — it is what Shopify bills and what the
/// server enforces. If a price or limit changes there, change it here in the
/// same commit, or the site promises something the app does not do.
class Plan {
  const Plan({
    required this.handle,
    required this.name,
    required this.tagline,
    required this.monthly,
    required this.yearly,
    required this.trialDays,
    required this.calculators,
    required this.assignments,
    required this.activityDays,
    required this.features,
    required this.support,
    this.recommended = false,
  });

  final String handle;
  final String name;
  final String tagline;
  final double monthly;
  final double? yearly;
  final int trialDays;

  /// Null means unlimited.
  final int? calculators;
  final int? assignments;
  final int? activityDays;
  final Set<Feature> features;
  final String support;
  final bool recommended;

  bool has(Feature f) => features.contains(f);

  int? get yearlySaving {
    if (yearly == null || monthly == 0) {
      return null;
    }
    final saving = monthly * 12 - yearly!;
    return saving > 0 ? saving.round() : null;
  }
}

enum Feature {
  collections('Apply to whole collections'),
  storeWide('One rule for the whole store'),
  wastageAndRounding('Wastage allowance and rounding'),
  sizeLimits('Size limits and step sizes'),
  buttonStyling('Custom button label and colour'),
  tieredRates('Tiered rates by size'),
  quantityDiscounts('Quantity discounts'),
  customFormulas('Custom pricing formulas', comingSoon: true);

  const Feature(this.label, {this.comingSoon = false});

  final String label;

  /// Listed on the Unlimited plan in the app but not yet built. Shown as
  /// "Coming soon" so the site never sells a feature that does not work.
  /// Set to false once custom formulas ship in the app.
  final bool comingSoon;
}

const trialDays = 14;

const plans = <Plan>[
  Plan(
    handle: 'free',
    name: 'Free',
    tagline: 'Prove it works on a few products before you pay anything.',
    monthly: 0,
    yearly: null,
    trialDays: 0,
    calculators: 1,
    assignments: 5,
    activityDays: 7,
    features: <Feature>{},
    support: 'Documentation',
  ),
  Plan(
    handle: 'starter',
    name: 'Starter',
    tagline: 'A single-trade shop with a manageable catalogue.',
    monthly: 9.99,
    yearly: 99,
    trialDays: trialDays,
    calculators: 3,
    assignments: 50,
    activityDays: null,
    features: {
      Feature.wastageAndRounding,
      Feature.sizeLimits,
      Feature.buttonStyling
    },
    support: 'Email support',
  ),
  Plan(
    handle: 'professional',
    name: 'Professional',
    tagline: 'A growing catalogue where whole collections price the same way.',
    monthly: 19.99,
    yearly: 199,
    trialDays: trialDays,
    calculators: 15,
    assignments: 500,
    activityDays: null,
    features: {
      Feature.collections,
      Feature.storeWide,
      Feature.wastageAndRounding,
      Feature.sizeLimits,
      Feature.buttonStyling,
      Feature.tieredRates,
      Feature.quantityDiscounts,
    },
    support: 'Priority email support',
    recommended: true,
  ),
  Plan(
    handle: 'unlimited',
    name: 'Unlimited',
    tagline: 'Large catalogues, or pricing that needs its own formula.',
    monthly: 39.99,
    yearly: 399,
    trialDays: trialDays,
    calculators: null,
    assignments: null,
    activityDays: null,
    features: {
      Feature.collections,
      Feature.storeWide,
      Feature.wastageAndRounding,
      Feature.sizeLimits,
      Feature.buttonStyling,
      Feature.tieredRates,
      Feature.quantityDiscounts,
      Feature.customFormulas,
    },
    support: 'Priority support and a setup call',
  ),
];

/// In every plan. Only things the app actually does today.
const alwaysIncluded = <String>[
  'Nine ways to measure',
  'Metric and imperial units, converted automatically',
  "The product's own price always acts as a floor",
  'Minimum and maximum price',
  'Prices recalculated at checkout, never trusted from the browser',
  "Works with your theme's own Add to cart button",
  'Measurements carried through to the order',
];

String money(double amount) => amount % 1 == 0
    ? '\$${amount.toStringAsFixed(0)}'
    : '\$${amount.toStringAsFixed(2)}';

String limitLabel(int? n) => n == null ? 'Unlimited' : '$n';
