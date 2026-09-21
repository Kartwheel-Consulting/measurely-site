import 'package:flutter/material.dart';

import '../data/calculators.dart';
import '../theme.dart';
import '../widgets/calculator_demo.dart';
import '../widgets/common.dart';
import '../widgets/site_page.dart';
import 'home_page.dart';

/// /calculators — every type, filterable by what is being measured.
class CalculatorsPage extends StatefulWidget {
  const CalculatorsPage({super.key});

  @override
  State<CalculatorsPage> createState() => _CalculatorsPageState();
}

/// Filter groups, by what the customer measures.
const _groups = <(String, Set<String>?)>[
  ('All', null),
  ('Area', {'area_lw', 'area'}),
  ('Length', {'length', 'linear_lw', 'perimeter'}),
  ('Volume', {'volume_lwh', 'volume'}),
  ('Weight & count', {'weight', 'quantity'}),
];

class _CalculatorsPageState extends State<CalculatorsPage> {
  int _group = 0;

  @override
  Widget build(BuildContext context) {
    final filter = _groups[_group].$2;
    final shown = filter == null
        ? calculators
        : calculators.where((c) => filter.contains(c.type)).toList();

    return SitePage(
      title: 'Calculators',
      route: '/calculators',
      children: [
        const PageIntro(
          eyebrow: 'Live demos',
          title: 'Nine calculators, one pricing engine.',
          lede: 'Every demo runs the same arithmetic the app runs on a real '
              'store — change a size, a unit or a rate and the price updates '
              'exactly as it would on your product page and at checkout.',
        ),
        Band(
          color: Brand.soft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _groups.length; i++)
                    ChoiceChip(
                      label: Text(_groups[i].$1),
                      selected: _group == i,
                      onSelected: (_) => setState(() => _group = i),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _group == i ? Brand.indigo : Brand.ink,
                      ),
                      side: BorderSide(
                          color: _group == i ? Brand.indigo : Brand.line),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              CalculatorCards(items: shown),
            ],
          ),
        ),
        const CtaBand(),
      ],
    );
  }
}

/// `/calculators/<slug>` — one calculator, fully interactive.
class CalculatorDetailPage extends StatelessWidget {
  const CalculatorDetailPage({super.key, required this.info});

  final CalculatorInfo info;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final others =
        calculators.where((c) => c.slug != info.slug).take(3).toList();

    return SitePage(
      title: '${info.name} calculator',
      route: '/calculators/${info.slug}',
      children: [
        Band(
          color: Brand.white,
          bottom: 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => goTo(context, '/calculators'),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('All calculators'),
                style: TextButton.styleFrom(
                    foregroundColor: Brand.muted, padding: EdgeInsets.zero),
              ),
              const SizedBox(height: 16),
              SectionHeading(
                  eyebrow: info.formula, title: info.name, lede: info.summary),
              const SizedBox(height: 20),
              Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final tr in info.trades) Chip2(tr)]),
            ],
          ),
        ),
        Band(
          color: Brand.white,
          top: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TypeSwitcher(current: info),
              const SizedBox(height: 24),
              CalculatorDemo(key: ValueKey(info.slug), info: info),
            ],
          ),
        ),
        Band(
          color: Brand.soft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeading(title: 'What happens in your store'),
              const SizedBox(height: 28),
              ResponsiveGrid(
                minItemWidth: 260,
                maxColumns: 3,
                children: [
                  for (final (i, item) in const [
                    (
                      Icons.edit_outlined,
                      'On the product page',
                      'The customer types their size and sees the price update as they '
                          'type, above your theme\'s own Add to cart button.',
                    ),
                    (
                      Icons.lock_outline_rounded,
                      'At checkout',
                      'Shopify recalculates the line from your published settings. '
                          'The price the browser showed is never trusted.',
                    ),
                    (
                      Icons.receipt_long_outlined,
                      'On the order',
                      'The measurements travel with the line item, so your workshop '
                          'cuts from the order, not from an email.',
                    ),
                  ].indexed)
                    Panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconTile(item.$1, color: Brand.accents[i]),
                          const SizedBox(height: 16),
                          Text(item.$2, style: t.titleMedium),
                          const SizedBox(height: 8),
                          Text(item.$3, style: t.bodyMedium),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Band(
          color: Brand.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeading(title: 'Other calculators'),
              const SizedBox(height: 28),
              CalculatorCards(items: others),
            ],
          ),
        ),
        const CtaBand(),
      ],
    );
  }
}

/// A page-opening heading block, reused by the other pages.
class PageIntro extends StatelessWidget {
  const PageIntro(
      {super.key,
      required this.eyebrow,
      required this.title,
      this.lede,
      this.center = false});

  final String eyebrow;
  final String title;
  final String? lede;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Band(
      color: Brand.white,
      child: SectionHeading(
          eyebrow: eyebrow, title: title, lede: lede, center: center),
    );
  }
}

/// Every calculator one tap away, so a visitor can compare them without going
/// back to the list. Scrolls sideways on a phone.
class _TypeSwitcher extends StatelessWidget {
  const _TypeSwitcher({required this.current});

  final CalculatorInfo current;

  static const _short = {
    'area': 'Area L×W',
    'area-direct': 'Area',
    'length': 'Length',
    'linear': 'Length + width',
    'perimeter': 'Perimeter',
    'volume': 'Volume L×W×H',
    'volume-direct': 'Volume',
    'weight': 'Weight',
    'quantity': 'Quantity',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final c in calculators)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: Icon(c.icon,
                    size: 18,
                    color: c.slug == current.slug ? Brand.indigo : Brand.muted),
                label: Text(_short[c.slug] ?? c.name),
                selected: c.slug == current.slug,
                onSelected: (_) => goTo(context, '/calculators/${c.slug}'),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: c.slug == current.slug ? Brand.indigo : Brand.ink,
                ),
                side: BorderSide(
                    color: c.slug == current.slug ? Brand.indigo : Brand.line),
              ),
            ),
        ],
      ),
    );
  }
}
