import 'package:flutter/material.dart';

import '../config.dart';
import '../theme.dart';
import 'common.dart';
import 'logo.dart';

class NavItem {
  const NavItem(this.label, this.route);
  final String label;
  final String route;
}

const navItems = <NavItem>[
  NavItem('Calculators', '/calculators'),
  NavItem('Pricing', '/pricing'),
  NavItem('FAQ', '/faq'),
  NavItem('Contact', '/contact'),
];

/// Every page: sticky header, scrolling content, footer, back-to-top button,
/// and the browser tab title.
class SitePage extends StatefulWidget {
  const SitePage({
    super.key,
    required this.title,
    required this.route,
    required this.children,
  });

  /// Shown in the browser tab as `<title> · Measurely`.
  final String title;

  /// Which nav item to highlight.
  final String route;
  final List<Widget> children;

  @override
  State<SitePage> createState() => _SitePageState();
}

class _SitePageState extends State<SitePage> {
  final _scroll = ScrollController();

  /// The header gains a shadow once the page moves, so it reads as floating
  /// above the content rather than part of it.
  bool _scrolled = false;

  /// Long pages get a way back up without dragging the scrollbar.
  bool _showTop = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scroll.offset;
    final scrolled = offset > 4;
    final showTop = offset > 900;
    if (scrolled != _scrolled || showTop != _showTop) {
      setState(() {
        _scrolled = scrolled;
        _showTop = showTop;
      });
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _toTop() {
    final d = Motion.of(context, const Duration(milliseconds: 500));
    if (d == Duration.zero) {
      _scroll.jumpTo(0);
    } else {
      _scroll.animateTo(0, duration: d, curve: Curves.easeInOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title == SiteConfig.product
        ? '${SiteConfig.product} · ${SiteConfig.tagline}'
        : '${widget.title} · ${SiteConfig.product}';

    return Title(
      title: title,
      color: Brand.indigo,
      child: Scaffold(
        appBar: _Header(route: widget.route, elevated: _scrolled),
        endDrawer: _MobileMenu(route: widget.route),
        floatingActionButton: _BackToTop(visible: _showTop, onPressed: _toTop),
        body: SelectionArea(
          child: Scrollbar(
            controller: _scroll,
            child: SingleChildScrollView(
              controller: _scroll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [...widget.children, const _Footer()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackToTop extends StatelessWidget {
  const _BackToTop({required this.visible, required this.onPressed});

  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final d = Motion.of(context, Motion.base);
    // Hidden means hidden to screen readers and clicks too, not just invisible.
    return ExcludeSemantics(
      excluding: !visible,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: d,
          child: AnimatedScale(
            scale: visible ? 1 : 0.85,
            duration: d,
            curve: Motion.curve,
            child: Tooltip(
              message: 'Back to top',
              child: DecoratedBox(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, boxShadow: Shadows.md),
                child: Material(
                  color: Brand.white,
                  shape:
                      const CircleBorder(side: BorderSide(color: Brand.line)),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onPressed,
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(Icons.arrow_upward_rounded,
                          color: Brand.ink, semanticLabel: 'Back to top'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget implements PreferredSizeWidget {
  const _Header({required this.route, required this.elevated});

  final String route;
  final bool elevated;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  bool _active(NavItem item) => route.startsWith(item.route);

  @override
  Widget build(BuildContext context) {
    final compact = Layout.isTablet(context);
    return AnimatedContainer(
      duration: Motion.of(context, Motion.base),
      decoration: BoxDecoration(
        color: Brand.white,
        border: Border(
          bottom: BorderSide(color: elevated ? Colors.transparent : Brand.line),
        ),
        boxShadow: elevated ? Shadows.md : const [],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 72,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Layout.gutter(context)),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: Layout.maxWidth),
                  child: Row(
                    children: [
                      Semantics(
                        label: 'Measurely home',
                        button: true,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => goTo(context, '/'),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 2),
                            child: Logo(size: 32),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (!compact) ...[
                        for (final item in navItems)
                          _NavLink(
                            label: item.label,
                            active: _active(item),
                            onTap: () => goTo(context, item.route),
                          ),
                        const SizedBox(width: 16),
                        FilledButton(
                          onPressed: () => openLink(SiteConfig.installHref),
                          style: FilledButton.styleFrom(
                            backgroundColor: Brand.indigo,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(Radii.control)),
                          ),
                          child: Text(SiteConfig.installLabel),
                        ),
                      ] else
                        Builder(
                          builder: (context) => IconButton(
                            tooltip: 'Menu',
                            icon: const Icon(Icons.menu_rounded,
                                color: Brand.ink),
                            onPressed: () =>
                                Scaffold.of(context).openEndDrawer(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A header link with an underline that marks the current page and slides in
/// on hover.
class _NavLink extends StatefulWidget {
  const _NavLink(
      {required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final on = widget.active || _hover;
    final d = Motion.of(context, Motion.fast);
    return Semantics(
      link: true,
      selected: widget.active,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(8),
        hoverColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: d,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: widget.active ? FontWeight.w700 : FontWeight.w500,
                  color: on ? Brand.indigo : Brand.ink,
                ),
                child: Text(widget.label),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: d,
                curve: Motion.curve,
                height: 2,
                width: widget.active ? 20 : (_hover ? 12 : 0),
                decoration: BoxDecoration(
                  color: Brand.indigo,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileMenu extends StatelessWidget {
  const _MobileMenu({required this.route});

  final String route;

  static const _icons = <String, IconData>{
    '/': Icons.home_outlined,
    '/calculators': Icons.calculate_outlined,
    '/pricing': Icons.sell_outlined,
    '/faq': Icons.help_outline_rounded,
    '/contact': Icons.mail_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Brand.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.horizontal(left: Radius.circular(Radii.panel)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Padding(
                      padding: EdgeInsets.only(left: 8), child: Logo(size: 30)),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close menu',
                    icon: const Icon(Icons.close_rounded, color: Brand.ink),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              for (final item in [const NavItem('Home', '/'), ...navItems])
                Builder(builder: (context) {
                  final active = route == item.route ||
                      (item.route != '/' && route.startsWith(item.route));
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      selected: active,
                      selectedTileColor: Brand.tint,
                      selectedColor: Brand.indigo,
                      iconColor: Brand.muted,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Radii.control)),
                      leading:
                          Icon(_icons[item.route] ?? Icons.circle_outlined),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w600,
                          color: active ? Brand.indigo : Brand.ink,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: Brand.line),
                      onTap: () {
                        Navigator.of(context).pop();
                        goTo(context, item.route);
                      },
                    ),
                  );
                }),
              const Spacer(),
              PrimaryButton(
                label: SiteConfig.installLabel,
                onPressed: () => openLink(SiteConfig.installHref),
              ),
              const SizedBox(height: 10),
              Text(
                'Free plan · 14-day trial on paid plans',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final mobile = Layout.isMobile(context);
    const heading = TextStyle(
      color: Brand.white,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    );

    Widget link(String label, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: onTap,
            child: Text(
              label,
              style: TextStyle(
                  color: Brand.white.withValues(alpha: 0.72), fontSize: 15),
            ),
          ),
        );

    Widget column(String title, List<Widget> links) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(), style: heading),
            const SizedBox(height: 16),
            ...links
          ],
        );

    final brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Logo(size: 30, onDark: true),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            'Measurement-based pricing for Shopify. Sell by the metre, the '
            'square foot or the kilogram — and charge exactly that at checkout.',
            style: TextStyle(
                color: Brand.white.withValues(alpha: 0.72),
                fontSize: 15,
                height: 1.6),
          ),
        ),
      ],
    );

    final product = column('Product', [
      link('Calculators', () => goTo(context, '/calculators')),
      link('Pricing', () => goTo(context, '/pricing')),
      link(SiteConfig.installLabel, () => openLink(SiteConfig.installHref)),
    ]);
    final resources = column('Resources', [
      link('FAQ', () => goTo(context, '/faq')),
      link('Contact', () => goTo(context, '/contact')),
      link('Privacy policy', () => goTo(context, '/privacy')),
    ]);
    final support = column('Support', [
      link(SiteConfig.supportEmail,
          () => openLink('mailto:${SiteConfig.supportEmail}')),
      Text(
        'Replies ${SiteConfig.responseTime}.',
        style: TextStyle(
            color: Brand.white.withValues(alpha: 0.55),
            fontSize: 14,
            height: 1.5),
      ),
    ]);

    return Band(
      color: Brand.deep,
      top: 64,
      bottom: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mobile) ...[
            brand,
            const SizedBox(height: 36),
            product,
            const SizedBox(height: 24),
            resources,
            const SizedBox(height: 24),
            support,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: brand),
                Expanded(flex: 2, child: product),
                Expanded(flex: 2, child: resources),
                Expanded(flex: 3, child: support),
              ],
            ),
          const SizedBox(height: 48),
          Divider(color: Brand.white.withValues(alpha: 0.12)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                '© ${DateTime.now().year} ${SiteConfig.publisher}. All rights reserved.',
                style: TextStyle(
                    color: Brand.white.withValues(alpha: 0.55), fontSize: 13.5),
              ),
              Text(
                SiteConfig.locations,
                style: TextStyle(
                    color: Brand.white.withValues(alpha: 0.55), fontSize: 13.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
