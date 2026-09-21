import 'package:flutter/material.dart';

import '../data/content.dart';
import '../data/plans.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/faq_list.dart';
import '../widgets/plan_card.dart';
import '../widgets/site_page.dart';
import 'calculators_page.dart';
import 'home_page.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  bool _yearly = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return SitePage(
      title: 'Pricing',
      route: '/pricing',
      children: [
        const PageIntro(
          eyebrow: 'Pricing',
          title: 'Choose the plan that fits your catalogue.',
          lede: 'Every plan prices with all nine calculators and reprices at '
              'checkout. Paid plans start with a 14-day free trial and are '
              'billed through Shopify, on your normal Shopify invoice.',
          center: true,
        ),
        Band(
          color: Brand.white,
          top: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: _BillingToggle(
                  yearly: _yearly,
                  onChanged: (v) => setState(() => _yearly = v),
                ),
              ),
              const SizedBox(height: 36),
              ResponsiveGrid(
                minItemWidth: 250,
                children: [
                  for (final p in plans) PlanCard(plan: p, yearly: _yearly)
                ],
              ),
            ],
          ),
        ),
        Band(
          color: Brand.soft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeading(
                  eyebrow: 'Every plan', title: 'Included whatever you pay'),
              const SizedBox(height: 28),
              ResponsiveGrid(
                minItemWidth: 320,
                maxColumns: 2,
                spacing: 14,
                children: [
                  for (final item in alwaysIncluded)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Brand.teal, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(item,
                                style:
                                    t.bodyMedium?.copyWith(color: Brand.ink))),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        const Band(
          color: Brand.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(
                  eyebrow: 'Compare', title: 'Every plan, side by side'),
              SizedBox(height: 28),
              _ComparisonTable(),
            ],
          ),
        ),
        const Band(
          color: Brand.soft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(
                  eyebrow: 'Billing', title: 'Questions about plans'),
              SizedBox(height: 28),
              FaqList(items: _billingFaqs),
            ],
          ),
        ),
        const CtaBand(),
      ],
    );
  }
}

const _billingFaqs = <Faq>[
  Faq(
    'How am I charged?',
    'Through Shopify. The charge appears on your normal Shopify invoice — '
        'Measurely never asks for card details.',
  ),
  Faq(
    'What happens when the trial ends?',
    'Paid plans start with a 14-day free trial. If you keep the plan, Shopify '
        'starts billing when the trial ends. Change plan or cancel before then '
        'and you are not charged.',
  ),
  Faq(
    'Can I change plan later?',
    'Yes, at any time from the Plans page inside the app.',
  ),
  Faq(
    'What happens if I move to a smaller plan?',
    'Nothing you have already set up stops working, and no prices change. You '
        'cannot add more than the smaller plan allows until you are back inside it.',
  ),
];

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable();

  @override
  Widget build(BuildContext context) {
    const head =
        TextStyle(color: Brand.ink, fontSize: 15, fontWeight: FontWeight.w700);
    const label = TextStyle(color: Brand.body, fontSize: 14.5);
    const value = TextStyle(
        color: Brand.ink, fontSize: 14.5, fontWeight: FontWeight.w600);

    // The recommended plan's column is tinted top to bottom, so the eye can
    // follow it down the table.
    final featured = plans.indexWhere((p) => p.recommended);

    Widget cell(Widget child, {bool first = false, int column = -1}) {
      final padded = Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Align(
            alignment: first ? Alignment.centerLeft : Alignment.center,
            child: child),
      );
      if (column != featured) {
        return padded;
      }
      // Only this column fills its cell: a row where every cell is "fill"
      // has no height of its own.
      return TableCell(
        verticalAlignment: TableCellVerticalAlignment.fill,
        child: ColoredBox(
            color: Brand.indigo.withValues(alpha: 0.06), child: padded),
      );
    }

    TableRow row(String name, List<Widget> values, {bool shaded = false}) =>
        TableRow(
          decoration: BoxDecoration(color: shaded ? Brand.soft : Brand.white),
          children: [
            cell(Text(name, style: label), first: true),
            for (var i = 0; i < values.length; i++) cell(values[i], column: i),
          ],
        );

    final rows = <TableRow>[
      TableRow(
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Brand.line))),
        children: [
          cell(const SizedBox(), first: true),
          for (var i = 0; i < plans.length; i++)
            cell(
              Text(plans[i].name,
                  style: head.copyWith(
                      color: i == featured ? Brand.indigo : Brand.ink)),
              column: i,
            ),
        ],
      ),
      row('Monthly price',
          [for (final p in plans) Text(money(p.monthly), style: value)]),
      row(
        'Yearly price',
        [
          for (final p in plans)
            Text(p.yearly == null ? '—' : money(p.yearly!), style: value)
        ],
        shaded: true,
      ),
      row('Calculators', [
        for (final p in plans) Text(limitLabel(p.calculators), style: value)
      ]),
      row(
        'Products or collections',
        [for (final p in plans) Text(limitLabel(p.assignments), style: value)],
        shaded: true,
      ),
      row('Change history', [
        for (final p in plans)
          Text(p.activityDays == null ? 'Full' : '${p.activityDays} days',
              style: value),
      ]),
      for (final (i, f) in Feature.values.indexed)
        row(
          f.comingSoon ? '${f.label} (coming soon)' : f.label,
          [for (final p in plans) Tick(p.has(f))],
          shaded: i.isEven,
        ),
      row('Support', [
        for (final p in plans)
          Text(p.support,
              textAlign: TextAlign.center,
              style: label.copyWith(fontSize: 13.5)),
      ]),
    ];

    final table = Table(
      columnWidths: const {
        0: FlexColumnWidth(2.2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows,
    );

    return LayoutBuilder(
      builder: (context, c) {
        const minWidth = 780.0;
        final framed = Container(
          decoration: BoxDecoration(
            border: Border.all(color: Brand.line),
            borderRadius: BorderRadius.circular(Radii.card),
            boxShadow: Shadows.sm,
          ),
          clipBehavior: Clip.antiAlias,
          child: table,
        );
        if (c.maxWidth >= minWidth) {
          return framed;
        }
        // Narrow screens scroll the table sideways rather than crushing it.
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: minWidth, child: framed),
        );
      },
    );
  }
}

/// Monthly / Yearly as a sliding pill, with the saving stated beside it — the
/// reason to click is on the button, not in the small print.
class _BillingToggle extends StatelessWidget {
  const _BillingToggle({required this.yearly, required this.onChanged});

  final bool yearly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final d = Motion.of(context, Motion.base);

    Widget option(String label, bool value) {
      final on = yearly == value;
      return Expanded(
        child: Semantics(
          button: true,
          selected: on,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onChanged(value),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: d,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: on ? Brand.ink : Brand.muted,
                ),
                child: Text(label),
              ),
            ),
          ),
        ),
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 10,
      children: [
        Container(
          width: 240,
          height: 50,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Brand.soft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Brand.line),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: d,
                curve: Motion.curve,
                alignment:
                    yearly ? Alignment.centerRight : Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Brand.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: Shadows.md,
                    ),
                  ),
                ),
              ),
              Material(
                type: MaterialType.transparency,
                child: Row(children: [
                  option('Monthly', false),
                  option('Yearly', true)
                ]),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: const Text(
            'Save 17% yearly',
            style: TextStyle(
                color: Color(0xFF047857),
                fontSize: 13,
                fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
