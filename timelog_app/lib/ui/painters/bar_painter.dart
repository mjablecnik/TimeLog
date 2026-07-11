import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Draws a horizontal percentage bar: a full-width track in [theme.track]
/// with a rounded fill in [color] proportional to [progress] (0.0–1.0).
class BarPainter extends CustomPainter {
  final double progress;
  final Color color;
  final AppThemeData theme;

  const BarPainter({
    required this.progress,
    required this.color,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);

    final trackPaint = Paint()..color = theme.track;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      trackPaint,
    );

    final fillWidth = size.width * progress.clamp(0.0, 1.0);
    if (fillWidth > 0) {
      final fillPaint = Paint()..color = color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, fillWidth, size.height),
          radius,
        ),
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(BarPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.theme != theme;
}
