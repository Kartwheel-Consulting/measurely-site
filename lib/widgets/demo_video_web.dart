import 'dart:js_interop';
import 'dart:math' as math;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../theme.dart';
import 'demo_video.dart';

/// The product tour as a native `<video>` element, with Flutter-drawn controls.
///
/// WHY NOT THE BROWSER'S OWN CONTROLS. On Flutter web an HTML element placed
/// in the page swallows the mouse wheel: with the pointer over the video the
/// page would stop scrolling, which feels broken. So the element ignores the
/// pointer entirely (pointer-events: none), and the play button, progress bar
/// and chapter jumps are Flutter widgets drawn on top of it.
///
/// Muted and looping; there is no soundtrack. It autoplays only when the
/// visitor's device does not ask for reduced motion.
class PlatformVideo extends StatefulWidget {
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
  State<PlatformVideo> createState() => _PlatformVideoState();
}

class _PlatformVideoState extends State<PlatformVideo> {
  static const _viewType = 'measurely-demo-video';
  static bool _registered = false;

  /// Elements made by the factory, waiting for their widget to pick them up.
  /// Keeping the typed element from creation avoids casting from Object.
  static final Map<int, web.HTMLVideoElement> _created = {};

  static void _register() {
    if (_registered) {
      return;
    }
    _registered = true;
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final video = web.HTMLVideoElement();
      _created[viewId] = video;
      return video;
    });
  }

  web.HTMLVideoElement? _video;
  bool _playing = false;
  bool _hover = false;
  double _duration = DemoVideoSource.seconds;

  late final bool _reduceMotion =
      web.window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  @override
  void initState() {
    super.initState();
    _register();
    widget.seek.addListener(_onSeek);
  }

  @override
  void dispose() {
    widget.seek.removeListener(_onSeek);
    _video?.pause();
    super.dispose();
  }

  void _onCreated(int viewId) {
    final v = _created.remove(viewId);
    if (v == null) {
      return;
    }
    v
      ..muted = true
      ..loop = true
      ..playsInline = true
      ..controls = false
      ..preload = 'auto'
      ..poster = DemoVideoSource.poster;
    // The attributes as well as the properties: some browsers only honour
    // muted autoplay when the attribute is present in the markup.
    v.setAttribute('muted', '');
    v.setAttribute('playsinline', '');
    // Described once, by the Semantics around the frame.
    v.setAttribute('aria-hidden', 'true');

    v.style
      ..width = '100%'
      ..height = '100%'
      ..display = 'block'
      ..objectFit = 'cover'
      ..backgroundColor = '#1E1B4B'
      ..pointerEvents = 'none';

    // WebM first: smaller, and every browser except Safari picks it. Safari
    // skips it and plays the MP4.
    v.appendChild(web.HTMLSourceElement()
      ..src = DemoVideoSource.webm
      ..type = 'video/webm');
    v.appendChild(web.HTMLSourceElement()
      ..src = DemoVideoSource.mp4
      ..type = 'video/mp4');

    v.addEventListener(
      'timeupdate',
      ((web.Event _) {
        // The browser can still fire this after the page has gone (pausing
        // queues one last event), when the notifier is already disposed.
        if (mounted) {
          widget.position.value = v.currentTime;
        }
      }).toJS,
    );
    v.addEventListener(
      'play',
      ((web.Event _) {
        _setPlaying(true);
      }).toJS,
    );
    v.addEventListener(
      'pause',
      ((web.Event _) {
        _setPlaying(false);
      }).toJS,
    );
    v.addEventListener(
      'loadedmetadata',
      ((web.Event _) {
        final d = v.duration;
        if (d.isFinite && d > 0 && mounted) {
          setState(() => _duration = d);
        }
      }).toJS,
    );

    _video = v;
    if (!_reduceMotion) {
      v.autoplay = true;
      _play();
    }
  }

  void _setPlaying(bool playing) {
    if (mounted && playing != _playing) {
      setState(() => _playing = playing);
    }
  }

  void _play() {
    // play() returns a promise that rejects if the browser blocks it; the
    // big play button stays up in that case, so the rejection is expected.
    _video?.play().toDart.then((_) {}, onError: (Object _) {});
  }

  void _toggle() {
    final v = _video;
    if (v == null) {
      return;
    }
    if (v.paused) {
      _play();
    } else {
      v.pause();
    }
  }

  void _seekTo(double seconds) {
    final v = _video;
    if (v == null) {
      return;
    }
    v.currentTime = seconds.clamp(0.0, _duration);
    widget.position.value = v.currentTime;
    if (v.paused) {
      _play();
    }
  }

  void _onSeek() {
    final s = widget.seek.value;
    if (s != null) {
      _seekTo(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = Motion.of(context, Motion.base);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Stack(
        fit: StackFit.expand,
        children: [
          HtmlElementView(
              viewType: _viewType, onPlatformViewCreated: _onCreated),

          // The whole picture toggles play, like every video player.
          Semantics(
            button: true,
            label:
                _playing ? 'Pause the product tour' : 'Play the product tour',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              child: const MouseRegion(
                  cursor: SystemMouseCursors.click, child: SizedBox.expand()),
            ),
          ),

          // Big play button while paused.
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _playing ? 0 : 1,
              duration: d,
              child: Center(
                child: AnimatedScale(
                  scale: _playing ? 0.8 : 1,
                  duration: d,
                  curve: Motion.curve,
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: const BoxDecoration(
                      color: Brand.white,
                      shape: BoxShape.circle,
                      boxShadow: Shadows.lg,
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        size: 44, color: Brand.indigo),
                  ),
                ),
              ),
            ),
          ),

          // Control bar: always visible while paused, on hover while playing.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: (!_playing || _hover) ? 1 : 0,
              duration: d,
              child: _ControlBar(
                playing: _playing,
                duration: _duration,
                chapters: widget.chapters,
                position: widget.position,
                onToggle: _toggle,
                onSeek: _seekTo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.playing,
    required this.duration,
    required this.chapters,
    required this.position,
    required this.onToggle,
    required this.onSeek,
  });

  final bool playing;
  final double duration;
  final List<VideoChapter> chapters;
  final ValueNotifier<double> position;
  final VoidCallback onToggle;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x000F172A), Color(0xB30F172A)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 28, 16, 8),
        child: Row(
          children: [
            IconButton(
              tooltip: playing ? 'Pause' : 'Play',
              onPressed: onToggle,
              icon: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Brand.white),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: ValueListenableBuilder<double>(
                valueListenable: position,
                builder: (context, pos, _) => _Scrubber(
                  fraction:
                      duration > 0 ? (pos / duration).clamp(0.0, 1.0) : 0.0,
                  marks: [for (final c in chapters) c.seconds / duration],
                  onSeekFraction: (f) => onSeek(f * duration),
                ),
              ),
            ),
            const SizedBox(width: 14),
            ValueListenableBuilder<double>(
              valueListenable: position,
              builder: (context, pos, _) => Text(
                '${clockOf(pos)} / ${clockOf(duration)}',
                style: const TextStyle(
                  color: Brand.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The progress bar, with a tick at each chapter. Click or drag to jump.
class _Scrubber extends StatelessWidget {
  const _Scrubber(
      {required this.fraction,
      required this.marks,
      required this.onSeekFraction});

  final double fraction;
  final List<double> marks;
  final ValueChanged<double> onSeekFraction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        void seekAt(double dx) => onSeekFraction((dx / w).clamp(0.0, 1.0));
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => seekAt(d.localPosition.dx),
            onHorizontalDragUpdate: (d) => seekAt(d.localPosition.dx),
            child: SizedBox(
              height: 28,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: Brand.white.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Container(
                    width: w * fraction,
                    height: 5,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFC7D2FE), Color(0xFF5EEAD4)]),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  for (final m in marks)
                    if (m > 0.001)
                      Positioned(
                        left: (w * m - 1).clamp(0.0, math.max(0.0, w - 2)),
                        child: Container(
                            width: 2,
                            height: 11,
                            color: Brand.white.withValues(alpha: 0.7)),
                      ),
                  Positioned(
                    left: (w * fraction - 7).clamp(0.0, math.max(0.0, w - 14)),
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                          color: Brand.white,
                          shape: BoxShape.circle,
                          boxShadow: Shadows.sm),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
