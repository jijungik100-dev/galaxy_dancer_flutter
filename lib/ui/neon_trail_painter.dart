import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class TrailPoint {
  final Offset pos;
  final int timeMs;
  final Color color;
  TrailPoint(this.pos, this.timeMs, this.color);
}

class NeonTrailPainter extends CustomPainter {
  final List<TrailPoint> points;
  static const int trailDurationMs = 550;

  NeonTrailPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now().millisecondsSinceEpoch;

    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final age = now - p1.timeMs;
      if (age > trailDurationMs) continue;

      final alpha = 1.0 - age / trailDurationMs;
      final width = alpha * 8 + 1;

      // Glow layer
      final glowPaint = Paint()
        ..color = p1.color.withOpacity(alpha * 0.85)
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawLine(p0.pos, p1.pos, glowPaint);

      // Core bright line
      final corePaint = Paint()
        ..color = Colors.white.withOpacity(alpha * 0.4)
        ..strokeWidth = width * 0.3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(p0.pos, p1.pos, corePaint);
    }
  }

  @override
  bool shouldRepaint(NeonTrailPainter old) => true;
}

// Trail color based on swipe speed
Color trailColor(double speed) {
  if (speed < 14) return const Color(0xFF00F5FF); // cyan
  if (speed < 28) return const Color(0xFF0088FF); // blue
  if (speed < 42) return const Color(0xFFAA00FF); // purple
  return const Color(0xFFFF00B8);                 // pink
}
