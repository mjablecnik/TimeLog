import 'package:flutter/material.dart';

import '../../core/activity_types.dart';
import '../../core/config.dart';
import '../../core/theme.dart';
import '../../data/database.dart' show TimeEntry;

/// Draws a single-day timeline bar: a full-width track in [theme.track]
/// with colored blocks for each entry (color from [activityTypeColor]),
/// positioned and sized proportionally within the resolved hour range.
/// Gaps between entries are left as bare track. Hour markers are drawn
/// below the bar for reference.
///
/// [startHour]/[endHour] force an explicit range. Left null (the default),
/// the range is [_defaultStartHour]–[_defaultEndHour], widened to fit any
/// entry that starts earlier or ends later than that window.
class TimelinePainter extends CustomPainter {
  final List<TimeEntry> entries;
  final DateTime day;
  final AppThemeData theme;
  final int? startHour;
  final int? endHour;
  final bool isDark;

  static const double _markerAreaHeight = 16;
  static const double _barCornerRadius = 6;
  static const double _minBlockWidth = 3;
  /// The default visible window: full logical day from [dayStartHour] to
  /// [dayStartHour] next day (24h span).
  static const int _defaultStartHour = dayStartHour;
  static const int _defaultEndHour = dayStartHour + 24;

  const TimelinePainter({
    required this.entries,
    required this.day,
    required this.theme,
    this.startHour,
    this.endHour,
    this.isDark = true,
  });

  /// The start of this logical day (6:00 on [day]).
  DateTime get _logicalDayStart =>
      DateTime(day.year, day.month, day.day, dayStartHour);

  /// Resolves the hour range to paint: an explicit override if both
  /// [startHour]/[endHour] are given, otherwise the default window widened
  /// to cover any entry that falls outside it.
  ///
  /// Hours are expressed as clock hours where values > 24 represent hours
  /// past midnight into the next calendar day (e.g. 25 = 1:00 AM next day).
  (int, int) _resolveRange() {
    if (startHour != null && endHour != null) return (startHour!, endHour!);
    if (entries.isEmpty) return (_defaultStartHour, _defaultEndHour);

    final logicalStart = _logicalDayStart;
    var rangeStartHour = _defaultStartHour;
    var rangeEndHour = _defaultEndHour;

    for (final entry in entries) {
      final entryStart = DateTime.parse(entry.startTime);
      final entryEnd = DateTime.parse(entry.endTime);
      // Hours since dayStartHour, then shift back to clock hours
      final clockStart =
          dayStartHour + entryStart.difference(logicalStart).inMinutes / 60.0;
      final clockEnd =
          dayStartHour + entryEnd.difference(logicalStart).inMinutes / 60.0;

      if (clockStart < rangeStartHour) rangeStartHour = clockStart.floor();
      if (clockEnd > rangeEndHour) rangeEndHour = clockEnd.ceil();
    }

    // Clamp to a sensible range: never below 0, max dayStartHour + 24 (full logical day)
    rangeStartHour = rangeStartHour.clamp(0, _defaultEndHour - 1);
    rangeEndHour = rangeEndHour.clamp(rangeStartHour + 1, dayStartHour + 24);
    return (rangeStartHour, rangeEndHour);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final barHeight = (size.height - _markerAreaHeight).clamp(0.0, size.height);
    final barRect = Rect.fromLTWH(0, 0, size.width, barHeight);
    final radius = Radius.circular(_barCornerRadius);

    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, radius),
      Paint()..color = theme.track,
    );

    final (rangeStartHour, rangeEndHour) = _resolveRange();
    // Convert display hours back to real DateTimes relative to this day.
    // Dart handles hours > 23 by rolling over to the next calendar day.
    final rangeStart = DateTime(day.year, day.month, day.day, rangeStartHour);
    final rangeEnd = DateTime(day.year, day.month, day.day, rangeEndHour);
    final totalMs = rangeEnd.difference(rangeStart).inMilliseconds;
    if (totalMs <= 0) return;

    // Sorted so overlapping entries stack in a deterministic order (the
    // later-starting one paints on top) instead of following list order.
    final sortedEntries = [...entries]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    for (final entry in sortedEntries) {
      final entryStart = DateTime.parse(entry.startTime);
      final entryEnd = DateTime.parse(entry.endTime);
      final clampedStart = entryStart.isBefore(rangeStart) ? rangeStart : entryStart;
      final clampedEnd = entryEnd.isAfter(rangeEnd) ? rangeEnd : entryEnd;
      if (clampedEnd.isBefore(clampedStart)) continue;

      var x1 = size.width *
          clampedStart.difference(rangeStart).inMilliseconds /
          totalMs;
      var x2 = size.width *
          clampedEnd.difference(rangeStart).inMilliseconds /
          totalMs;
      // Zero (or near-zero) duration entries still get a visible sliver
      // instead of disappearing entirely.
      if (x2 - x1 < _minBlockWidth) {
        x2 = (x1 + _minBlockWidth).clamp(0.0, size.width);
        x1 = (x2 - _minBlockWidth).clamp(0.0, size.width);
      }

      canvas.drawRect(
        Rect.fromLTRB(x1, 0, x2, barHeight),
        Paint()..color = activityTypeColor(entry.activityType, isDark: isDark),
      );
    }

    _paintHourMarkers(canvas, size, barHeight, rangeStartHour, rangeEndHour);
  }

  void _paintHourMarkers(
    Canvas canvas,
    Size size,
    double barHeight,
    int startHour,
    int endHour,
  ) {
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
