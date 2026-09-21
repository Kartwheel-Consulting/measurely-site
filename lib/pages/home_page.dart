import 'package:flutter/material.dart';

import '../config.dart';
import '../data/calculators.dart';
import '../data/content.dart';
import '../data/plans.dart';
import '../theme.dart';
import '../widgets/calculator_demo.dart';
import '../widgets/common.dart';
import '../widgets/demo_video.dart';
import '../widgets/faq_list.dart';
import '../widgets/plan_card.dart';
import '../widgets/site_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SitePage(
      title: SiteConfig.product,
      route: '/',
      children: [
        _Hero(),
        _Facts(),
        _ProductTour(),
        _CalculatorGrid(),
        _HowItWorks(),
        _Features(),
        _Trades(),
        _PricingPreview(),
        _FaqPreview(),
        CtaBand(),
      ],
    );
  }
}

// --------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final mobile = Layout.isMobile(context);
    final stacked = Layout.isTablet(context);

    final headline = TextStyle(
      color: Brand.white,
      fontSize: mobile ? 40 : 60,
      fontWeight: FontWeight.w800,
      letterSpacing: mobile ? -1.2 : -2,
      height: 1.04,
    );

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Measurement-based pricing for Shopify', onDark: true),
        const SizedBox(height: 22),
        Text('Sell by the metre.', style: headline),
        // The promise, picked out in the brand's light gradient.
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (r) => const LinearGradient(
            colors: [Color(0xFFC7D2FE), Color(0xFF5EEAD4)],
          ).createShader(r),
          child: Text('Charge exactly that.', style: headline),
        ),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Text(
            'Customers type their own size on the product page. The price '
            'follows as they type — and checkout charges exactly that, '
            "recalculated on Shopify's side.",
            style: TextStyle(
              color: Brand.white.withValues(alpha: 0.80),
              fontSize: mobile ? 17 : 19,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 34),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            PrimaryButton(
              label: SiteConfig.installLabel,
              onDark: true,
              icon: Icons.arrow_forward_rounded,
              onPressed: () => openLink(SiteConfig.installHref),
            ),
            GhostButton(
              label: 'Try the live demos',
              onDark: true,
              onPressed: () => goTo(context, '/calculators'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Wrap(
          spacing: 20,
          runSpacing: 10,
          children: [
            _Assurance('Free plan available'),
            _Assurance('14-day trial on paid plans'),
            _Assurance('Billed through Shopify'),
          ],
        ),
      ],
    );

    final demo = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: CalculatorDemo(info: calculators.first, compact: true),
    );

    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
              decoration: BoxDecoration(gradient: Brand.heroGradient)),
        ),
        const Positioned.fill(child: CustomPaint(painter: _HeroPattern())),
        Band(
          top: mobile ? 56 : 104,
          bottom: mobile ? 72 : 120,
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    copy,
                    const SizedBox(height: 48),
                    Center(child: demo)
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 6, child: copy),
                    const SizedBox(width: 56),
                    Expanded(
                        flex: 5,
                        child: Align(
                            alignment: Alignment.centerRight, child: demo)),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Assurance extends StatelessWidget {
  const _Assurance(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_rounded,
            size: 18, color: Color(0xFF5EEAD4)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
                color: Brand.white.withValues(alpha: 0.78),
                fontSize: 14.5,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

/// The hero's backdrop: a faint measuring grid, two soft glows, and a ruler
/// along the bottom edge — the product's idea, drawn quietly behind it.
class _HeroPattern extends CustomPainter {
  const _HeroPattern();

  @override
  void paint(Canvas canvas, Size size) {
    // Glows.
    void glow(Offset c, double r, Color color) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(colors: [color, color.withValues(alpha: 0)])
              .createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    glow(Offset(size.width * 0.85, size.height * 0.15), size.shortestSide * 0.7,
        const Color(0x3314B8A6));
    glow(Offset(size.width * 0.05, size.height * 0.95), size.shortestSide * 0.6,
        const Color(0x337C3AED));

    // Grid.
    final grid = Paint()
      ..color = Brand.white.withValues(alpha: 0.045)
      ..strokeWidth = 1;
    const step = 48.0;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Ruler.
    final tick = Paint()
      ..color = Brand.white.withValues(alpha: 0.22)
      ..strokeWidth = 1;
    final base = size.height;
    for (var i = 0; i * 8.0 <= size.width; i++) {
      final x = i * 8.0;
      final len = i % 10 == 0 ? 18.0 : (i % 5 == 0 ? 11.0 : 6.0);
      canvas.drawLine(Offset(x, base), Offset(x, base - len), tick);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --------------------------------------------------------------------------

class _Facts extends StatelessWidget {
  const _Facts();

  @override
  Widget build(BuildContext context) {
    // Only facts that are true of the product today. No invented metrics.
    const facts = [
      (Icons.straighten_rounded, '9', 'ways to measure'),
      (Icons.swap_horiz_rounded, '9', 'units, converted automatically'),
      (Icons.bolt_rounded, '0', 'requests to us while a customer shops'),
      (
        Icons.event_available_rounded,
        '14',
        'day free trial on every paid plan'
      ),
    ];
    return Band(
      color: Brand.white,
      top: 48,
      bottom: 24,
      child: ResponsiveGrid(
        minItemWidth: 220,
        children: [
          for (final (i, f) in facts.indexed)
            Panel(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  IconTile(f.$1,
                      color: Brand.accents[i * 2 % Brand.accents.length],
                      size: 46),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.$2,
                          style: const TextStyle(
                            color: Brand.ink,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(f.$3,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------

/// The 40-second product tour: set-up to checkout, with chapter jumps.
class _ProductTour extends StatelessWidget {
  const _ProductTour();

  @override
  Widget build(BuildContext context) {
    return Band(
      color: Brand.white,
      top: Layout.isMobile(context) ? 40 : 64,
      child: Column(
        children: [
          const SectionHeading(
            eyebrow: 'Product tour · 40 seconds',
            title: 'From set-up to checkout, in one short video.',
            lede: 'Create a calculator, apply it to products, then watch a '
                'customer measure and the price follow — right through to the cart.',
            center: true,
          ),
          const SizedBox(height: 40),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: const DemoVideo(),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------

class _CalculatorGrid extends StatelessWidget {
  const _CalculatorGrid();

  @override
  Widget build(BuildContext context) {
    return Band(
      color: Brand.soft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeading(
            eyebrow: 'Calculators',
            title: 'Nine ways to measure. Every one works live.',
            lede: 'Pick the one that matches how your trade quotes. Each card '
                'opens a working demo running the same pricing engine as the app.',
          ),
          const SizedBox(height: 40),
          const CalculatorCards(items: calculators),
        ],
      ),
    );
  }
}

/// The calculator cards, shared by the home page and the Calculators page.
class CalculatorCards extends StatelessWidget {
  const CalculatorCards({super.key, required this.items});

  final List<CalculatorInfo> items;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ResponsiveGrid(
      minItemWidth: 300,
      maxColumns: 3,
      children: [
        for (var i = 0; i < items.length; i++)
          Panel(
            onTap: () => goTo(context, '/calculators/${items[i].slug}'),
            semanticLabel: 'Open the ${items[i].name} calculator',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconTile(items[i].icon,
                    color: Brand.accents[i % Brand.accents.length]),
                const SizedBox(height: 18),
                Text(items[i].name, style: t.titleLarge),
                const SizedBox(height: 6),
                Text(
                  items[i].formula,
                  style: const TextStyle(
                    color: Brand.indigo,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(items[i].summary, style: t.bodyMedium),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Text(
                      'Try it live',
                      style: TextStyle(
                          color: Brand.indigo,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded,
                        size: 17, color: Brand.indigo),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// --------------------------------------------------------------------------

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Band(
      color: Brand.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeading(
            eyebrow: 'How it works',
            title: 'Set up once. Every order after that prices itself.',
          ),
          const SizedBox(height: 44),
          ResponsiveGrid(
            minItemWidth: 230,
            children: [
              for (var i = 0; i < steps.length; i++)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: Brand.markGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Brand.indigo.withValues(alpha: 0.28),
                              blurRadius: 16,
                              offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                            color: Brand.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(steps[i].title, style: t.titleLarge),
                    const SizedBox(height: 8),
                    Text(steps[i].body, style: t.bodyMedium),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 44),
          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: [Brand.tint, Color(0xFFF0FDFA)]),
              borderRadius: BorderRadius.circular(Radii.card),
              border: Border.all(color: const Color(0xFFE0E7FF)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, color: Brand.indigo),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('The rule underneath all of it',
                          style: t.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        "A product's own price is always the floor. A cut smaller "
                        'than one whole unit is still charged as one, because half '
                        'a square metre of cut glass does not cost half as much to '
                        'make. Above that, the measurement decides the price.',
                        style: t.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------

class _Features extends StatelessWidget {
  const _Features();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Band(
      color: Brand.soft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeading(
            eyebrow: 'Features',
            title: 'Built for the way made-to-measure trades quote.',
          ),
          const SizedBox(height: 40),
          ResponsiveGrid(
            minItemWidth: 250,
            children: [
              for (var i = 0; i < features.length; i++)
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconTile(features[i].icon,
                          color: Brand.accents[i % Brand.accents.length]),
                      const SizedBox(height: 16),
                      Text(features[i].title, style: t.titleMedium),
                      const SizedBox(height: 8),
                      Text(features[i].body,
                          style: t.bodySmall?.copyWith(color: Brand.body)),
                      if (features[i].plan != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          '${features[i].plan} and above',
                          style: const TextStyle(
                            color: Brand.indigo,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------

class _Trades extends StatelessWidget {
  const _Trades();

  @override
  Widget build(BuildContext context) {
    return Band(
      color: Brand.white,
      child: Column(
        children: [
          const SectionHeading(
            eyebrow: 'Who it is for',
            title: 'Anywhere the customer supplies the size.',
            center: true,
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [for (final t in trades) Chip2(t)],
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------

class _PricingPreview extends StatelessWidget {
  const _PricingPreview();

  @override
  Widget build(BuildContext context) {
    return Band(
      color: Brand.soft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeading(
            eyebrow: 'Pricing',
            title: 'Start free. Upgrade when the catalogue grows.',
            lede:
                'Every plan includes all nine calculators and checkout repricing. '
                'Paid plans start with a 14-day free trial, billed through Shopify.',
          ),
          const SizedBox(height: 40),
          ResponsiveGrid(
            minItemWidth: 250,
            children: [for (final p in plans) PlanCard(plan: p)],
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: ArrowLink(
                label: 'Compare every plan',
                onTap: () => goTo(context, '/pricing')),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------

class _FaqPreview extends StatelessWidget {
  const _FaqPreview();

  @override
  Widget build(BuildContext context) {
    final mobile = Layout.isTablet(context);
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(eyebrow: 'FAQ', title: 'Common questions'),
        const SizedBox(height: 16),
        ArrowLink(label: 'All questions', onTap: () => goTo(context, '/faq')),
      ],
    );
    final list = FaqList(items: faqs.take(5).toList());
    return Band(
      color: Brand.white,
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [heading, const SizedBox(height: 32), list],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: heading),
                const SizedBox(width: 48),
                Expanded(flex: 7, child: list),
              ],
            ),
    );
  }
}

// --------------------------------------------------------------------------

/// The closing call to action, used at the foot of most pages.
class CtaBand extends StatelessWidget {
  const CtaBand({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = Layout.isMobile(context);
    return Band(
      color: Brand.white,
      top: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: mobile ? 24 : 56, vertical: mobile ? 40 : 64),
        decoration: BoxDecoration(
          gradient: Brand.heroGradient,
          borderRadius: BorderRadius.circular(Radii.panel + 4),
          boxShadow: Shadows.lg,
        ),
        child: Column(
          children: [
            Text(
              'Price your first product today.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Brand.white,
                fontSize: mobile ? 28 : 38,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Free plan, no card. Paid plans start with a 14-day trial.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Brand.white.withValues(alpha: 0.8), fontSize: 17),
            ),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                PrimaryButton(
                  label: SiteConfig.installLabel,
                  onDark: true,
                  onPressed: () => openLink(SiteConfig.installHref),
                ),
                GhostButton(
                  label: 'Talk to us',
                  onDark: true,
                  onPressed: () => goTo(context, '/contact'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
