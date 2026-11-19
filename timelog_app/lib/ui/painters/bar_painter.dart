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

/// One coloured part of a [StackedBarPainter] bar.
class BarSegment {
  final Color color;

  /// Relative size; only the ratio to the other segments matters.
  final double weight;

  const BarSegment({required this.color, required this.weight});
}

/// A horizontal bar whose filled part is split into coloured [segments], used
/// for an activity type that has subtypes. [progress] is the filled fraction of
/// the whole bar width.
class StackedBarPainter extends CustomPainter {
  final double progress;
  final List<BarSegment> segments;
  final AppThemeData theme;

  const StackedBarPainter({
    required this.progress,
    required this.segments,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = theme.track,
    );

    final fillWidth = size.width * progress.clamp(0.0, 1.0);
    final totalWeight = segments.fold<double>(0, (sum, s) => sum + s.weight);
    if (fillWidth <= 0 || totalWeight <= 0) return;

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, fillWidth, size.height),
        radius,
      ),
    );
    var x = 0.0;
    for (final segment in segments) {
      final width = fillWidth * segment.weight / totalWeight;
      canvas.drawRect(
        Rect.fromLTWH(x, 0, width, size.height),
        Paint()..color = segment.color,
      );
      x += width;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(StackedBarPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.segments != segments ||
      oldDelegate.theme != theme;
}
