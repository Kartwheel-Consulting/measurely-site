import 'package:flutter/material.dart';

import '../theme.dart';

/// The Measurely mark, drawn rather than loaded so it is sharp at every size
/// and costs nothing to download. Same geometry as LogoMark in app/ui-kit.tsx
/// (a 48 × 48 box).
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Measurely',
      image: true,
      child: CustomPaint(size: Size.square(size), painter: _MarkPainter()),
    );
  }
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 48;
    canvas.scale(s);

    const box = Rect.fromLTWH(0, 0, 48, 48);
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(12)),
      Paint()..shader = Brand.markGradient.createShader(box),
    );

    final m = Paint()
      ..color = Brand.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(13.5, 30.5)
        ..lineTo(13.5, 15.5)
        ..lineTo(24, 25.5)
        ..lineTo(34.5, 15.5)
        ..lineTo(34.5, 30.5),
      m,
    );

    final rule = Paint()
      ..color = Brand.white.withValues(alpha: 0.62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(11, 38), const Offset(37, 38), rule);
    canvas.drawLine(const Offset(11, 38), const Offset(11, 34.2), rule);
    canvas.drawLine(const Offset(24, 38), const Offset(24, 35.6), rule);
    canvas.drawLine(const Offset(37, 38), const Offset(37, 34.2), rule);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Mark plus wordmark.
class Logo extends StatelessWidget {
  const Logo({super.key, this.size = 34, this.onDark = false});

  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoMark(size: size),
        SizedBox(width: size * 0.3),
        Text(
          'Measurely',
          style: TextStyle(
            fontSize: size * 0.6,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: onDark ? Brand.white : Brand.ink,
          ),
        ),
      ],
    );
  }
}
