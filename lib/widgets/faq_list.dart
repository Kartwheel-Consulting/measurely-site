import 'package:flutter/material.dart';

import '../data/content.dart';
import '../theme.dart';

/// Questions as an accordion of separate cards.
///
/// The first starts open so the visitor sees the pattern without clicking.
/// Several can be open at once — closing one to read another is a chore.
/// The open card is outlined in the brand colour and its chevron turns.
class FaqList extends StatefulWidget {
  const FaqList({super.key, required this.items});

  final List<Faq> items;

  @override
  State<FaqList> createState() => _FaqListState();
}

class _FaqListState extends State<FaqList> {
  final Set<int> _open = {0};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < widget.items.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _FaqItem(
            faq: widget.items[i],
            open: _open.contains(i),
            onToggle: () => setState(
                () => _open.contains(i) ? _open.remove(i) : _open.add(i)),
          ),
        ],
      ],
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem(
      {required this.faq, required this.open, required this.onToggle});

  final Faq faq;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final d = Motion.of(context, Motion.base);
    final radius = BorderRadius.circular(Radii.card - 2);

    return AnimatedContainer(
      duration: d,
      curve: Motion.curve,
      decoration: BoxDecoration(
        color: Brand.white,
        borderRadius: radius,
        border: Border.all(
            color: open ? Brand.indigo.withValues(alpha: 0.35) : Brand.line),
        boxShadow: open ? Shadows.md : Shadows.sm,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              button: true,
              expanded: open,
              child: InkWell(
                borderRadius: radius,
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 16, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          faq.q,
                          style: const TextStyle(
                            color: Brand.ink,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedContainer(
                        duration: d,
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: open ? Brand.indigo : Brand.soft,
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedRotation(
                          turns: open ? 0.5 : 0,
                          duration: d,
                          curve: Motion.curve,
                          child: Icon(
                            Icons.expand_more_rounded,
                            size: 20,
                            color: open ? Brand.white : Brand.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: d,
              curve: Motion.curve,
              alignment: Alignment.topCenter,
              child: open
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 60, 22),
                      child: Text(faq.a,
                          style: Theme.of(context).textTheme.bodyMedium),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
