import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../pricing/pricing.dart';
import '../theme.dart';

/// A live, to-scale drawing of what the customer has typed.
///
/// The single most reassuring thing a made-to-measure shopper can see: the
/// numbers they entered turned into the shape they have in mind. A 120 × 60
/// pane is drawn twice as wide as it is tall; swap the numbers and it turns.
/// Edges that are priced (a perimeter, an L-shaped run) are highlighted, so
/// the drawing also explains the calculator.
class ShapePreview extends StatelessWidget {
  const ShapePreview({
    super.key,
    required this.type,
    required this.values,
    required this.unit,
    this.height = 150,
  });

  final String type;

  /// In the unit the customer typed.
  final List<double> values;
  final String unit;
  final double height;

  static const _supported = {
    'area_lw',
    'perimeter',
    'linear_lw',
    'length',
    'volume_lwh'
  };

  static bool supports(String type) => _supported.contains(type);

  bool get _valid =>
      values.isNotEmpty && values.every((v) => v.isFinite && v > 0);

  String get _description {
    if (!_valid) {
      return 'Diagram: enter a size to see it drawn';
    }
    final parts = values.map((v) => '${formatMeasure(v)} $unit').join(' by ');
    return 'Diagram of $parts';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: _description,
      image: true,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Brand.soft,
          borderRadius: BorderRadius.circular(Radii.control + 2),
          border: Border.all(color: Brand.line),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Radii.control + 2),
          child: CustomPaint(
            painter: _ShapePainter(
                type: type, values: values, unit: unit, valid: _valid),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter({
    required this.type,
    required this.values,
    required this.unit,
    required this.valid,
  });

  final String type;
  final List<double> values;
  final String unit;
  final bool valid;

  static const _labelStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Brand.body,
  );

  String _fmt(double v) => '${formatMeasure(v)} $unit';

  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas, size);

    if (!valid) {
      _text(canvas, 'Enter a size to see it drawn', size.center(Offset.zero),
          style: _labelStyle.copyWith(color: Brand.muted));
      return;
    }

    // Room for labels: above the shape and to its right.
    final area = Rect.fromLTRB(20, 38, size.width - 44, size.height - 18);
    if (area.width <= 0 || area.height <= 0) {
      return;
    }

    switch (type) {
      case 'length':
        _paintLength(canvas, area);
      case 'volume_lwh':
        _paintBox(
            canvas, Rect.fromLTRB(16, 16, size.width - 16, size.height - 16));
      default:
        _paintRect(canvas, area);
    }
  }

  void _paintGrid(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Brand.line.withValues(alpha: 0.7)
      ..strokeWidth = 1;
    for (var x = 12.0; x < size.width; x += 16) {
      for (var y = 12.0; y < size.height; y += 16) {
        canvas.drawCircle(Offset(x, y), 0.8, p);
      }
    }
  }

  // ---------------------------------------------------------------- rectangle

  void _paintRect(Canvas canvas, Rect area) {
    final l = values[0];
    final w = values.length > 1 ? values[1] : values[0];
    final ratio = (l / w).clamp(0.2, 5.0);

    double rw, rh;
    if (area.width / area.height > ratio) {
      rh = area.height;
      rw = rh * ratio;
    } else {
      rw = area.width;
      rh = rw / ratio;
    }
    final r = Rect.fromCenter(center: area.center, width: rw, height: rh);
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(3));

    canvas.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Brand.indigo.withValues(alpha: type == 'area_lw' ? 0.20 : 0.07),
            Brand.teal.withValues(alpha: type == 'area_lw' ? 0.14 : 0.05),
          ],
        ).createShader(r),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..color = Brand.indigo.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final accent = Paint()
      ..color = Brand.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    if (type == 'perimeter') {
      canvas.drawRRect(rr, accent);
    } else if (type == 'linear_lw') {
      canvas.drawLine(r.topLeft, r.topRight, accent);
      canvas.drawLine(r.topRight, r.bottomRight, accent);
    }

    // Length: a dimension line above the top edge.
    _dimension(canvas, Offset(r.left, r.top - 12), Offset(r.right, r.top - 12));
    _text(canvas, _fmt(l), Offset(r.center.dx, r.top - 26));

    // Width: a dimension line beside the right edge, label turned to follow it.
    _dimension(
        canvas, Offset(r.right + 12, r.top), Offset(r.right + 12, r.bottom));
    canvas.save();
    canvas.translate(r.right + 28, r.center.dy);
    canvas.rotate(-math.pi / 2);
    _text(canvas, _fmt(w), Offset.zero);
    canvas.restore();
  }

  // ------------------------------------------------------------------- length

  void _paintLength(Canvas canvas, Rect area) {
    final y = area.center.dy + 8;
    final a = Offset(area.left + 4, y);
    final b = Offset(area.right + 20, y);

    final bar = Paint()
      ..shader = const LinearGradient(colors: [Brand.indigo, Brand.teal])
          .createShader(Rect.fromPoints(a, b))
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(a, b, bar);

    // Ruler ticks under the bar.
    final tick = Paint()
      ..color = Brand.muted.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    const steps = 20;
    for (var i = 0; i <= steps; i++) {
      final x = a.dx + (b.dx - a.dx) * i / steps;
      final long = i % 5 == 0;
      canvas.drawLine(Offset(x, y + 9), Offset(x, y + (long ? 20 : 14)), tick);
    }

    _text(canvas, _fmt(values[0]), Offset((a.dx + b.dx) / 2, y - 24));
  }

  // ---------------------------------------------------------------------- box

  void _paintBox(Canvas canvas, Rect area) {
    final maxV = values.reduce(math.max);
    final l = (values[0] / maxV).clamp(0.15, 1.0);
    final w = (values[1] / maxV).clamp(0.15, 1.0);
    final h = (values[2] / maxV).clamp(0.15, 1.0);

    const c = 0.866; // cos 30°
    const s = 0.5; //   sin 30°
    Offset iso(double x, double y, double z) =>
        Offset((x - z) * c, (x + z) * s - y);

    final corners = [
      for (final x in [0.0, l])
        for (final y in [0.0, h])
          for (final z in [0.0, w]) iso(x, y, z),
    ];
    final minX = corners.map((p) => p.dx).reduce(math.min);
    final maxX = corners.map((p) => p.dx).reduce(math.max);
    final minY = corners.map((p) => p.dy).reduce(math.min);
    final maxY = corners.map((p) => p.dy).reduce(math.max);

    // Leave room for the three labels.
    final inner = area.deflate(22);
    final k =
        math.min(inner.width / (maxX - minX), inner.height / (maxY - minY));
    final origin =
        inner.center - Offset((minX + maxX) / 2 * k, (minY + maxY) / 2 * k);
    Offset p(double x, double y, double z) => origin + iso(x, y, z) * k;

    Path face(List<Offset> pts) => Path()..addPolygon(pts, true);
    final edge = Paint()
      ..color = Brand.indigo.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeJoin = StrokeJoin.round;

    final top = face([p(0, h, 0), p(l, h, 0), p(l, h, w), p(0, h, w)]);
    final right = face([p(l, 0, 0), p(l, 0, w), p(l, h, w), p(l, h, 0)]);
    final left = face([p(0, 0, w), p(l, 0, w), p(l, h, w), p(0, h, w)]);

    canvas.drawPath(top, Paint()..color = Brand.indigo.withValues(alpha: 0.10));
    canvas.drawPath(
        left, Paint()..color = Brand.indigo.withValues(alpha: 0.22));
    canvas.drawPath(right, Paint()..color = Brand.teal.withValues(alpha: 0.20));
    for (final f in [top, left, right]) {
      canvas.drawPath(f, edge);
    }

    _text(canvas, _fmt(values[0]),
        Offset.lerp(p(0, 0, w), p(l, 0, w), 0.5)! + const Offset(-14, 14));
    _text(canvas, _fmt(values[1]),
        Offset.lerp(p(l, 0, 0), p(l, 0, w), 0.5)! + const Offset(18, 12));
    _text(canvas, _fmt(values[2]),
        Offset.lerp(p(l, 0, 0), p(l, h, 0), 0.5)! + const Offset(30, 0));
  }

  // ------------------------------------------------------------------ helpers

  void _dimension(Canvas canvas, Offset a, Offset b) {
    final p = Paint()
      ..color = Brand.muted
      ..strokeWidth = 1;
    canvas.drawLine(a, b, p);
    final horizontal = (a.dy - b.dy).abs() < 0.5;
    final t = horizontal ? const Offset(0, 4) : const Offset(4, 0);
    canvas.drawLine(a - t, a + t, p);
    canvas.drawLine(b - t, b + t, p);
  }

  /// Draws [text] centred on [at], on a small white chip so it stays legible
  /// over the shape and the grid.
  void _text(Canvas canvas, String text, Offset at,
      {TextStyle style = _labelStyle}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final box = Rect.fromCenter(
        center: at, width: tp.width + 12, height: tp.height + 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(6)),
      Paint()..color = Brand.white.withValues(alpha: 0.92),
    );
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
    tp.dispose();
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.unit != unit ||
      oldDelegate.valid != valid ||
      !listEquals(oldDelegate.values, values);
}
