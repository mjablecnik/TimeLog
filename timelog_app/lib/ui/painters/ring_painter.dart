import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme.dart';

class RingPainter extends CustomPainter {
  final double progress;
  final AppThemeData theme;

  const RingPainter({required this.progress, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 9) / 2;
    const strokeWidth = 9.0;
    const startAngle = -pi / 2;

    final trackPaint = Paint()
      ..color = theme.track
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
      final rect = Rect.fromCircle(center: center, radius: radius);

      final glowPaint = Paint()
        ..color = theme.glow
        ..strokeWidth = strokeWidth + 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);

      final progressPaint = Paint()
        ..color = theme.accent
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.theme != theme;
}
