import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';

/// Open another page of this site.
void goTo(BuildContext context, String route) {
  final current = ModalRoute.of(context)?.settings.name;
  if (current == route) {
    return;
  }
  Navigator.of(context).pushNamed(route);
}

/// Open an external link or a mailto:. Email opens in place; websites open
/// in a new tab so the visitor does not lose this site.
Future<void> openLink(String href) async {
  final uri = Uri.parse(href);
  final sameTab = uri.scheme == 'mailto';
  await launchUrl(uri, webOnlyWindowName: sameTab ? '_self' : '_blank');
}

/// A full-width horizontal band with centred, width-limited content.
class Band extends StatelessWidget {
  const Band({
    super.key,
    required this.child,
    this.color,
    this.gradient,
    this.top,
    this.bottom,
  });

  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final double? top;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    final gap = Layout.sectionGap(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: color, gradient: gradient),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Layout.gutter(context),
          top ?? gap / 2,
          Layout.gutter(context),
          bottom ?? gap / 2,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Layout.maxWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Small label above a heading, set in a tinted pill with a dot.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text,
      {super.key, this.color = Brand.indigo, this.onDark = false});

  final String text;
  final Color color;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final fg = onDark ? const Color(0xFFC7D2FE) : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: onDark
            ? Brand.white.withValues(alpha: 0.10)
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: onDark
              ? Brand.white.withValues(alpha: 0.18)
              : color.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: onDark ? const Color(0xFF5EEAD4) : color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Eyebrow + heading + optional lede, left-aligned or centred.
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    this.eyebrow,
    required this.title,
    this.lede,
    this.center = false,
  });

  final String? eyebrow;
  final String title;
  final String? lede;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final mobile = Layout.isMobile(context);
    final align = center ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[Eyebrow(eyebrow!), const SizedBox(height: 12)],
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            title,
            textAlign: align,
            style: mobile ? t.headlineMedium : t.displaySmall,
          ),
        ),
        if (lede != null) ...[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Text(lede!, textAlign: align, style: t.bodyLarge),
          ),
        ],
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.onDark = false,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final bool onDark;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: onDark ? Brand.white : Brand.indigo,
        foregroundColor: onDark ? Brand.deep : Brand.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.control)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Flexible so a long label wraps inside a narrow card instead of
          // overflowing it.
          Flexible(child: Text(label, textAlign: TextAlign.center)),
          if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 18)],
        ],
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.onDark = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final fg = onDark ? Brand.white : Brand.ink;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        side: BorderSide(
            color: onDark ? Brand.white.withValues(alpha: 0.45) : Brand.line),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.control)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}

/// A text link with an arrow, for "See all" style navigation.
class ArrowLink extends StatelessWidget {
  const ArrowLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Brand.indigo,
        padding: EdgeInsets.zero,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(label)),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward_rounded, size: 17),
        ],
      ),
    );
  }
}

/// A white card with a hairline border and a soft shadow.
///
/// When it has an [onTap] it behaves like a link: the pointer becomes a hand,
/// and on hover the card lifts, its shadow deepens and its border takes the
/// brand colour — so it is obvious the whole card is clickable, not just the
/// words on it. Keyboard focus gets the same treatment.
class Panel extends StatefulWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(26),
    this.color = Brand.white,
    this.borderColor = Brand.line,
    this.borderWidth = 1,
    this.shadow = Shadows.sm,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow> shadow;
  final VoidCallback? onTap;

  /// Read by screen readers for a clickable card, e.g. "Open the area calculator".
  final String? semanticLabel;

  @override
  State<Panel> createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  bool _hover = false;
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;
    final lifted = interactive && (_hover || _focus);
    final radius = BorderRadius.circular(Radii.card);

    Widget content = Padding(padding: widget.padding, child: widget.child);
    if (interactive) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: widget.onTap,
          onHover: (v) => setState(() => _hover = v),
          onFocusChange: (v) => setState(() => _focus = v),
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Brand.indigo.withValues(alpha: 0.06),
          highlightColor: Brand.indigo.withValues(alpha: 0.03),
          child: content,
        ),
      );
    }

    final card = AnimatedContainer(
      duration: Motion.of(context, Motion.fast),
      curve: Motion.curve,
      transform: Matrix4.translationValues(0, lifted ? -4 : 0, 0),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: radius,
        border: Border.all(
          color: lifted
              ? Brand.indigo.withValues(alpha: 0.45)
              : widget.borderColor,
          width: widget.borderWidth,
        ),
        boxShadow: lifted ? Shadows.lg : widget.shadow,
      ),
      child: content,
    );

    if (!interactive) {
      return card;
    }
    return Semantics(button: true, label: widget.semanticLabel, child: card);
  }
}

/// A rounded square with an icon, tinted by an accent colour.
class IconTile extends StatelessWidget {
  const IconTile(this.icon, {super.key, required this.color, this.size = 44});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.16),
            color.withValues(alpha: 0.06)
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

class Chip2 extends StatelessWidget {
  const Chip2(this.label, {super.key, this.onDark = false});

  final String label;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: onDark ? Brand.white.withValues(alpha: 0.12) : Brand.soft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: onDark ? Brand.white.withValues(alpha: 0.22) : Brand.line,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: onDark ? Brand.white : Brand.ink,
        ),
      ),
    );
  }
}

/// Lays children out in equal-width columns whose count follows the width,
/// with every card in a row stretched to the tallest.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 260,
    this.maxColumns = 4,
    this.spacing = 20,
  });

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        var cols = ((w + spacing) / (minItemWidth + spacing)).floor();
        cols = cols.clamp(1, maxColumns);

        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += cols) {
          final cells = <Widget>[];
          for (var j = 0; j < cols; j++) {
            if (j > 0) {
              cells.add(SizedBox(width: spacing));
            }
            final k = i + j;
            cells.add(Expanded(
                child: k < children.length ? children[k] : const SizedBox()));
          }
          if (rows.isNotEmpty) {
            rows.add(SizedBox(height: spacing));
          }
          rows.add(
            IntrinsicHeight(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: cells),
            ),
          );
        }
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
      },
    );
  }
}

/// A check or a cross, for plan lists and the comparison table.
class Tick extends StatelessWidget {
  const Tick(this.on, {super.key, this.size = 20});

  final bool on;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      on ? Icons.check_circle_rounded : Icons.remove_rounded,
      size: size,
      color: on ? Brand.teal : Brand.line,
      semanticLabel: on ? 'Included' : 'Not included',
    );
  }
}
