import 'package:flutter/material.dart';

/// Site copy that is not a plan or a calculator. Every claim here is
/// something the app does today — check before adding one.

class FeatureItem {
  const FeatureItem(this.icon, this.title, this.body, {this.plan});
  final IconData icon;
  final String title;
  final String body;

  /// The cheapest plan that includes it, or null when every plan does.
  final String? plan;
}

const features = <FeatureItem>[
  FeatureItem(
    Icons.swap_horiz_rounded,
    'Any unit in, any unit out',
    'A customer types centimetres while you price per square foot. '
        'Millimetres, centimetres, metres, inches, feet, yards, grams, '
        'kilograms and pounds all convert to whatever you charge by.',
  ),
  FeatureItem(
    Icons.shield_outlined,
    'Minimums that protect margin',
    "The product's own price is always the floor, so a small cut is never "
        'charged as a fraction of a unit. Add a higher minimum wherever you need one.',
  ),
  FeatureItem(
    Icons.lock_outline_rounded,
    "Priced on Shopify's side",
    "The browser's figure is never trusted. Checkout recalculates every line "
        'from the settings you published, so nobody can edit a price in '
        'developer tools and buy at it.',
  ),
  FeatureItem(
    Icons.content_cut_rounded,
    'Wastage and rounding',
    'Add an offcut allowance as a percentage of the measurement, not the money, '
        'then round up, down or to nearest — the way your trade quotes.',
    plan: 'Starter',
  ),
  FeatureItem(
    Icons.height_rounded,
    'Size limits and step sizes',
    'Smallest, largest and the increment you cut in. Nobody orders a size '
        'your machine cannot make.',
    plan: 'Starter',
  ),
  FeatureItem(
    Icons.stacked_bar_chart_rounded,
    'Tiered rates',
    'One rate up to a size and a lower rate above it. As many bands as you '
        'price in, each applied to the whole cut.',
    plan: 'Professional',
  ),
  FeatureItem(
    Icons.percent_rounded,
    'Quantity discounts',
    'A percentage off once a customer orders enough. Ten panes and a hundred '
        'panes can price differently.',
    plan: 'Professional',
  ),
  FeatureItem(
    Icons.history_rounded,
    'Full change history',
    'Every change that affects a price is recorded — what changed, from what '
        'to what, who did it and when.',
  ),
];

class HowStep {
  const HowStep(this.title, this.body);
  final String title;
  final String body;
}

const steps = <HowStep>[
  HowStep(
    'Create a calculator',
    'Choose how the product is measured, the unit customers type in and the '
        'unit you charge by. The live preview shows the price as you go.',
  ),
  HowStep(
    'Apply it to products',
    'Pick products one by one, or apply it to a whole collection. A '
        'product-level rule always beats a collection rule.',
  ),
  HowStep(
    'Switch it on in your theme',
    'Turn on the Measurely app embed in the theme editor. It uses your '
        "theme's own Add to cart button — nothing to drag into place.",
  ),
  HowStep(
    'Customers measure, checkout agrees',
    'The price updates as they type. At checkout Shopify reprices the line '
        'from your settings, and the measurements go onto the order.',
  ),
];

const trades = <String>[
  'Glass & glazing',
  'Fabric & upholstery',
  'Flooring & carpet',
  'Worktops & stone',
  'Blinds & shutters',
  'Signage & print',
  'Timber & sheet materials',
  'Metal & fabrication',
  'Rope, cable & chain',
  'Wallpaper & wall panels',
];

class Faq {
  const Faq(this.q, this.a);
  final String q;
  final String a;
}

const faqs = <Faq>[
  Faq(
    'What does Measurely do?',
    'It lets a Shopify store sell products whose price depends on a '
        'measurement. The customer types a size on the product page, the price '
        'updates as they type, and checkout charges exactly that price.',
  ),
  Faq(
    'Which ways of measuring does it support?',
    'Nine: area from length × width, area typed directly, length, length + '
        'width, perimeter, volume from length × width × height, volume typed '
        'directly, weight and quantity. Every one can be tried on the '
        'Calculators page.',
  ),
  Faq(
    'Can customers type centimetres while I price per square foot?',
    'Yes. Set the input unit to centimetres and the pricing unit to square '
        'feet. The conversion goes through metric internally, so it does not '
        'drift over repeated conversions.',
  ),
  Faq(
    'Why does a small piece cost the same as a bigger one?',
    "That is the floor working. A cut measuring below one whole unit is "
        "charged as one whole unit, because it does not cost you less to make. "
        "It is always on — the product's own Shopify price is the floor.",
  ),
  Faq(
    'Can customers change the price in their browser?',
    'No. The product page shows the price, but checkout never trusts it. '
        "Shopify recalculates every line from the settings you published, on "
        "Shopify's own servers.",
  ),
  Faq(
    'Will it slow my store down?',
    'No. The settings for each product are written onto the product itself, '
        'so the page has everything it needs when it loads. There is no request '
        'to Measurely while a customer is on the page.',
  ),
  Faq(
    'Does it work with my theme?',
    "It is added as an app embed and uses your theme's own Add to cart "
        'button, so there is nothing to drag into place. App embeds need an '
        'Online Store 2.0 theme — every current Shopify theme is one.',
  ),
  Faq(
    'Can one product use different rules from the rest of its collection?',
    'Yes. Apply a calculator to that product directly. A product-level rule '
        'always beats a collection rule.',
  ),
  Faq(
    'How am I billed, and can I cancel?',
    'Through Shopify, on your normal Shopify invoice. Paid plans start with a '
        '14-day free trial. You can change plan or cancel at any time from the '
        'Plans page inside the app, or by uninstalling.',
  ),
  Faq(
    'What happens if I uninstall?',
    'Your products go straight back to ordinary Shopify pricing and the '
        'calculator disappears from their pages. Shopify then asks us to erase '
        'your data, and everything Measurely held for your store is deleted.',
  ),
  Faq(
    'What data does Measurely store?',
    'Your calculator settings and a log of changes to them. No customer '
        'records, no orders, no email addresses, no payment details. The '
        'measurements a shopper types live on the order, inside Shopify.',
  ),
];
