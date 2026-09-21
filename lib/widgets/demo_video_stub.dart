import 'package:flutter/material.dart';

import '../theme.dart';
import 'demo_video.dart';

/// Stands in for the video wherever there is no browser — the widget tests.
///
/// Draws what the visitor sees before playback starts, without touching the
/// network or the page, so every page can still be tested on the VM.
class PlatformVideo extends StatelessWidget {
  const PlatformVideo({
    super.key,
    required this.chapters,
    required this.position,
    required this.seek,
  });

  final List<VideoChapter> chapters;
  final ValueNotifier<double> position;
  final ValueNotifier<double?> seek;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: Brand.heroGradient),
      child: Center(
        child: Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
              color: Brand.white,
              shape: BoxShape.circle,
              boxShadow: Shadows.lg),
          child: const Icon(Icons.play_arrow_rounded,
              size: 40, color: Brand.indigo),
        ),
      ),
    );
  }
}
