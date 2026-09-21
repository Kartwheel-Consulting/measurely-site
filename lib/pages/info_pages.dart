import 'package:flutter/material.dart';

import '../config.dart';
import '../data/content.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/faq_list.dart';
import '../widgets/site_page.dart';
import 'calculators_page.dart';
import 'home_page.dart';

// ==========================================================================
// /faq
// ==========================================================================

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Not a const list: ConstrainedBox has no const constructor.
    return SitePage(
      title: 'FAQ',
      route: '/faq',
      children: [
        const PageIntro(
          eyebrow: 'FAQ',
          title: 'Frequently asked questions',
          lede: "If yours isn't here, email us — a real person replies.",
        ),
        Band(
          color: Brand.white,
          top: 0,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: const FaqList(items: faqs),
            ),
          ),
        ),
        const _SupportStrip(),
        const CtaBand(),
      ],
    );
  }
}

// ==========================================================================
// /contact
// ==========================================================================

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget card(IconData icon, Color color, String title, String body,
        String action, String href) {
      return Panel(
        padding: const EdgeInsets.all(28),
        onTap: () => openLink(href),
        semanticLabel: '$title: $action',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconTile(icon, color: color),
            const SizedBox(height: 18),
            Text(title, style: t.titleLarge),
            const SizedBox(height: 8),
            Text(body, style: t.bodyMedium),
            const SizedBox(height: 20),
            ArrowLink(label: action, onTap: () => openLink(href)),
          ],
        ),
      );
    }

    const mail = 'mailto:${SiteConfig.supportEmail}';

    return SitePage(
      title: 'Contact',
      route: '/contact',
      children: [
        const PageIntro(
          eyebrow: 'Contact',
          title: 'Talk to the people who build it.',
          lede: 'Measurely is built and supported by ${SiteConfig.publisher}. '
              'Every email is read by a person and answered ${SiteConfig.responseTime}.',
        ),
        Band(
          color: Brand.white,
          top: 0,
          child: ResponsiveGrid(
            minItemWidth: 280,
            maxColumns: 3,
            children: [
              card(
                Icons.support_agent_rounded,
                Brand.accents[0],
                'Support',
                'Something not pricing the way you expect? Send the product link '
                    'and what you expected to see.',
                SiteConfig.supportEmail,
                '$mail?subject=${Uri.encodeComponent('Measurely support')}',
              ),
              card(
                Icons.calendar_month_outlined,
                Brand.accents[2],
                'Setup help',
                'Moving from another calculator app, or pricing something unusual? '
                    'We will look at your store with you.',
                'Ask for a setup call',
                '$mail?subject=${Uri.encodeComponent('Measurely setup call')}',
              ),
              card(
                Icons.business_outlined,
                Brand.accents[4],
                SiteConfig.publisher,
                'The team behind Measurely. Shopify Partners, working from '
                    '${SiteConfig.locations}.',
                'Visit kartwheelconsulting.com',
                SiteConfig.publisherWebsite,
              ),
            ],
          ),
        ),
        const CtaBand(),
      ],
    );
  }
}

class _SupportStrip extends StatelessWidget {
  const _SupportStrip();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Band(
      color: Brand.soft,
      child: Column(
        children: [
          Text('Still have a question?',
              style: t.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
            'Email ${SiteConfig.supportEmail} — we reply ${SiteConfig.responseTime}.',
            style: t.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Email support',
            onPressed: () => openLink('mailto:${SiteConfig.supportEmail}'),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// /privacy
// ==========================================================================

/// The privacy policy. Written from what the app actually stores — see
/// prisma/schema.prisma and webhooks.compliance.tsx in the app. Have it
/// reviewed before the App Store submission: this is a factual draft, not
/// legal advice.
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  static const updated = '21 September 2026';

  static const sections = <(String, String)>[
    (
      'Who we are',
      'Measurely is a Shopify app published by ${SiteConfig.publisher} '
          '(“we”, “us”). This policy explains what the app collects when a '
          'merchant installs it, why, and what happens to it. For questions, '
          'email ${SiteConfig.supportEmail}.',
    ),
    (
      'What we collect',
      'When you install Measurely, Shopify gives us your store’s domain and an '
          'access token that lets the app act on your store within the permissions '
          'you approved. We then store the calculators you create, which products '
          'and collections they are applied to, and a history of changes to them — '
          'including the name or email of the staff member who made a change, when '
          'Shopify provides it.',
    ),
    (
      'What we do not collect',
      'Measurely does not collect or store your customers’ names, email addresses, '
          'addresses, orders or payment details. The measurements a shopper enters '
          'are saved on the order inside Shopify, not by us.',
    ),
    (
      'Why we use it',
      'Only to run the app: to show your calculators in the admin, to write the '
          'resolved settings onto your products, and to reprice cart lines at '
          'checkout. We do not sell data, use it for advertising, or share it with '
          'anyone except the service providers needed to host the app.',
    ),
    (
      'Permissions the app requests',
      'Products (read and write) — to read each product’s price and write the '
          'calculator settings onto products you assign. Cart transforms (write) — '
          'to register the pricing function that reprices cart lines at checkout.',
    ),
    (
      'Where it is stored',
      'On our application server and a managed PostgreSQL database. Access is '
          'restricted to the people who maintain the app.',
    ),
    (
      'How long we keep it',
      'For as long as the app is installed. When you uninstall, Shopify notifies '
          'us, and 48 hours later sends a request to erase your store’s data. We '
          'then delete everything Measurely holds for your store.',
    ),
    (
      'Your rights',
      'You can ask for a copy of the data we hold about your store, or for it to '
          'be deleted, by emailing ${SiteConfig.supportEmail}. If you are in the UK '
          'or the EU you also have the right to complain to your data protection '
          'authority.',
    ),
    (
      'Changes to this policy',
      'If this policy changes, the date at the top of this page changes with it.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SitePage(
      title: 'Privacy policy',
      route: '/privacy',
      children: [
        const PageIntro(eyebrow: 'Legal', title: 'Privacy policy'),
        Band(
          color: Brand.white,
          top: 0,
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Last updated $updated', style: t.bodySmall),
                  const SizedBox(height: 32),
                  for (final s in sections) ...[
                    Text(s.$1, style: t.headlineSmall),
                    const SizedBox(height: 10),
                    Text(s.$2, style: t.bodyMedium),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================================================
// 404
// ==========================================================================

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SitePage(
      title: 'Page not found',
      route: '',
      children: [
        Band(
          color: Brand.white,
          top: 120,
          bottom: 120,
          child: Column(
            children: [
              const SectionHeading(
                eyebrow: '404',
                title: 'That page does not exist.',
                lede: 'The link may be old, or mistyped.',
                center: true,
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                  label: 'Back to the home page',
                  onPressed: () => goTo(context, '/')),
            ],
          ),
        ),
      ],
    );
  }
}
