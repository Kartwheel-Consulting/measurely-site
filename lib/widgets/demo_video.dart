import 'package:flutter/material.dart';

import '../theme.dart';
import 'demo_video_stub.dart' if (dart.library.js_interop) 'demo_video_web.dart'
    as platform;

/// One chapter of the product tour, so a visitor can jump to the part they
/// care about instead of watching from the start.
class VideoChapter {
  const VideoChapter(this.label, this.seconds);
  final String label;
  final double seconds;
}

/// The files, relative to the site's base address so they resolve on GitHub
/// Pages (/measurely-site/) and on the company server (/) alike.
class DemoVideoSource {
  DemoVideoSource._();

  static const mp4 = 'video/measurely-demo.mp4';
  static const webm = 'video/measurely-demo.webm';
  static const poster = 'video/measurely-demo-poster.jpg';
  static const seconds = 40.5;

  /// For screen readers, since the video has no narration.
  static const description =
      'Product tour video, 40 seconds, no sound. A merchant creates a '
      r'calculator priced at $85 per square metre and applies it to their glass '
      r'products. A customer types 200 by 100 centimetres and sees $170.00, '
      r'types a small 20 by 10 cut and sees it lifted to the $25.00 product '
      r'price, then orders 120 by 60 centimetres for $61.20. The cart keeps the '
      'measurements, and Shopify recalculates the price at checkout.';

  static const chapters = <VideoChapter>[
    VideoChapter('Create a calculator', 3.6),
    VideoChapter('Apply it to products', 12.2),
    VideoChapter('Customer measures', 17.2),
    VideoChapter('Checkout', 30.4),
  ];
}

/// "0:07"
String clockOf(double seconds) {
  final s = seconds.isFinite ? seconds.floor() : 0;
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

/// The product tour, framed like a screen, with chapter shortcuts beneath.
///
/// On the web it is a real `<video>`: muted, looping, and autoplaying unless
/// the visitor's device asks for reduced motion. Its controls are drawn by
/// Flutter, not the browser — see demo_video_web.dart for why.
class DemoVideo extends StatefulWidget {
  const DemoVideo({super.key});

  @override
  State<DemoVideo> createState() => _DemoVideoState();
}

class _DemoVideoState extends State<DemoVideo> {
  /// Where playback is, in seconds. Written by the player, read by the chips.
  final _position = ValueNotifier<double>(0);

  /// A request to jump to a time. Written by the chips, read by the player.
  final _seek = ValueNotifier<double?>(null);

  @override
  void dispose() {
    _position.dispose();
    _seek.dispose();
    super.dispose();
  }

  void _jump(double seconds) {
    // Cleared first so asking for the same chapter twice still notifies.
    _seek.value = null;
    _seek.value = seconds;
  }

  @override
  Widget build(BuildContext context) {
    const chapters = DemoVideoSource.chapters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          label: DemoVideoSource.description,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.panel + 4),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0x994F46E5),
                  Color(0x557C3AED),
                  Color(0x990D9488)
                ],
              ),
              boxShadow: Shadows.lg,
            ),
            child: Padding(
              // A thin gradient ring around the picture.
              padding: const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Radii.panel + 2),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: platform.PlatformVideo(
                    chapters: chapters,
                    position: _position,
                    seek: _seek,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ValueListenableBuilder<double>(
          valueListenable: _position,
          builder: (context, pos, _) {
            var current = -1;
            for (var i = 0; i < chapters.length; i++) {
              if (pos >= chapters[i].seconds) {
                current = i;
              }
            }
            return Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < chapters.length; i++)
                  _ChapterChip(
                    number: i + 1,
                    chapter: chapters[i],
                    active: i == current,
                    onTap: () => _jump(chapters[i].seconds),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ChapterChip extends StatelessWidget {
  const _ChapterChip({
    required this.number,
    required this.chapter,
    required this.active,
    required this.onTap,
  });

  final int number;
  final VideoChapter chapter;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = Motion.of(context, Motion.base);
    return Semantics(
      button: true,
      selected: active,
      label: 'Jump to chapter $number, ${chapter.label}',
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: d,
            curve: Motion.curve,
            padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
            decoration: BoxDecoration(
              color: active ? Brand.tint : Brand.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: active ? Brand.indigo : Brand.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: d,
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? Brand.indigo : Brand.soft,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: active ? Brand.white : Brand.muted,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    chapter.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: active ? Brand.indigo : Brand.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(clockOf(chapter.seconds),
                    style: const TextStyle(fontSize: 12.5, color: Brand.muted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
