import 'package:flutter/material.dart';

import '../../core/activity_types.dart';
import '../../core/theme.dart';
import '../../data/database.dart' show TimeEntry;

/// Draws a single-day timeline bar: a full-width track in [theme.track]
/// with colored blocks for each entry (color from [activityTypeColor]),
/// positioned and sized proportionally within [startHour]–[endHour].
/// Gaps between entries are left as bare track. Hour markers are drawn
/// below the bar for reference.
class TimelinePainter extends CustomPainter {
  final List<TimeEntry> entries;
  final DateTime day;
  final AppThemeData theme;
  final int startHour;
  final int endHour;
  final bool isDark;

  static const double _markerAreaHeight = 16;
  static const double _barCornerRadius = 6;

  const TimelinePainter({
    required this.entries,
    required this.day,
    required this.theme,
    this.startHour = 6,
    this.endHour = 24,
    this.isDark = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barHeight = (size.height - _markerAreaHeight).clamp(0.0, size.height);
    final barRect = Rect.fromLTWH(0, 0, size.width, barHeight);
    final radius = Radius.circular(_barCornerRadius);

    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, radius),
      Paint()..color = theme.track,
    );

    final rangeStart = DateTime(day.year, day.month, day.day, startHour);
    final rangeEnd = DateTime(day.year, day.month, day.day, endHour);
    final totalMs = rangeEnd.difference(rangeStart).inMilliseconds;
    if (totalMs <= 0) return;

    for (final entry in entries) {
      final entryStart = DateTime.parse(entry.startTime);
      final entryEnd = DateTime.parse(entry.endTime);
      final clampedStart = entryStart.isBefore(rangeStart) ? rangeStart : entryStart;
      final clampedEnd = entryEnd.isAfter(rangeEnd) ? rangeEnd : entryEnd;
      if (!clampedEnd.isAfter(clampedStart)) continue;

      final x1 = size.width *
          clampedStart.difference(rangeStart).inMilliseconds /
          totalMs;
      final x2 = size.width *
          clampedEnd.difference(rangeStart).inMilliseconds /
          totalMs;

      canvas.drawRect(
        Rect.fromLTRB(x1, 0, x2, barHeight),
        Paint()..color = activityTypeColor(entry.activityType, isDark: isDark),
      );
    }

    _paintHourMarkers(canvas, size, barHeight);
  }

  void _paintHourMarkers(Canvas canvas, Size size, double barHeight) {
    final span = endHour - startHour;
    if (span <= 0) return;
    final step = span <= 6 ? 1 : (span <= 12 ? 2 : 3);

    for (var hour = startHour; hour <= endHour; hour += step) {
      final fraction = (hour - startHour) / span;
      final x = size.width * fraction;
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${hour % 24}',
          style: TextStyle(color: theme.faint, fontFamily: 'Sora', fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final dx = (x - textPainter.width / 2).clamp(
        0.0,
        (size.width - textPainter.width).clamp(0.0, size.width),
      );
      textPainter.paint(canvas, Offset(dx, barHeight + 2));
    }
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) =>
      oldDelegate.entries != entries ||
      oldDelegate.day != day ||
      oldDelegate.theme != theme ||
      oldDelegate.startHour != startHour ||
      oldDelegate.endHour != endHour ||
      oldDelegate.isDark != isDark;
}
