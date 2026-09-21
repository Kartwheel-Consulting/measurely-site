import 'package:flutter/material.dart';

import '../config.dart';
import '../data/plans.dart';
import '../theme.dart';
import 'common.dart';

/// One plan. [yearly] switches the headline price to the annual one.
class PlanCard extends StatelessWidget {
  const PlanCard({super.key, required this.plan, this.yearly = false});

  final Plan plan;
  final bool yearly;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final showYearly = yearly && plan.yearly != null;
    final price = showYearly ? plan.yearly! : plan.monthly;
    final per =
        plan.monthly == 0 ? 'forever' : (showYearly ? '/ year' : '/ month');

    final highlights = <String>[
      '${limitLabel(plan.calculators)} calculator${plan.calculators == 1 ? '' : 's'}',
      '${limitLabel(plan.assignments)} products or collections',
      plan.activityDays == null
          ? 'Full change history'
          : '${plan.activityDays}-day change history',
      for (final f in Feature.values)
        if (plan.has(f)) f.comingSoon ? '${f.label} (coming soon)' : f.label,
      plan.support,
    ];

    final card = Panel(
      padding: const EdgeInsets.all(26),
      borderColor: plan.recommended ? Brand.indigo : Brand.line,
      borderWidth: plan.recommended ? 2 : 1,
      shadow: plan.recommended ? Shadows.lg : Shadows.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wrap, not Row: in a four-column layout the name and the badge do
          // not fit side by side, and the badge should drop below, not the
          // name break mid-word.
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(plan.name, style: t.headlineSmall),
              if (plan.recommended)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: Brand.markGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Most popular',
                    style: TextStyle(
                        color: Brand.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(plan.tagline, style: t.bodySmall),
          const SizedBox(height: 20),
          // Scales down rather than overflowing when a card is narrow. Not
          // baseline-aligned: cards sit in rows sized by intrinsic height, and
          // Flutter cannot measure a baseline row that way.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.bottomLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  money(price),
                  style: const TextStyle(
                    color: Brand.ink,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(per, style: t.bodySmall),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 20,
            child: Text(
              showYearly && plan.yearlySaving != null
                  ? 'Save \$${plan.yearlySaving} a year'
                  : plan.trialDays > 0
                      ? '${plan.trialDays}-day free trial'
                      : 'No card needed',
              style: const TextStyle(
                  color: Brand.teal,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: plan.recommended
                ? PrimaryButton(
                    label: _cta,
                    onPressed: () => openLink(SiteConfig.installHref),
                  )
                : GhostButton(
                    label: _cta,
                    onPressed: () => openLink(SiteConfig.installHref),
                  ),
          ),
          const SizedBox(height: 22),
          const Divider(),
          const SizedBox(height: 18),
          for (final h in highlights)
            Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child:
                        Icon(Icons.check_rounded, size: 18, color: Brand.teal),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(h,
                        style: const TextStyle(
                            color: Brand.ink, fontSize: 14.5, height: 1.45)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    return card;
  }

  String get _cta {
    if (!SiteConfig.isListed) {
      return 'Request early access';
    }
    return plan.monthly == 0 ? 'Start free' : 'Start free trial';
  }
}
