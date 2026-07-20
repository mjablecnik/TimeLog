import 'package:flutter/foundation.dart';

import 'database.dart';

/// Aggregation period for the statistics screen.
enum StatsPeriod { daily, weekly }

/// A single project entry in the statistics breakdown.
@immutable
class ProjectStat {
  final String name;
  final String activityType;
  final Duration duration;

  const ProjectStat({
    required this.name,
    required this.activityType,
    required this.duration,
  });
}

/// Aggregated time-tracking statistics for a given period.
@immutable
class StatsData {
  final Duration totalTracked;
  final Duration untrackedTime;
  final Map<String, Duration> byActivityType;

  /// Project breakdown — includes entries from both `Práce` and
  /// `Domácí práce` activity types.
  final List<ProjectStat> byProject;

  /// Breakdown of `Zábava` (entertainment) time by sub-type
  /// (`Aktivní zábava` / `Pasivní zábava`).
  final Map<String, Duration> byEntertainmentType;

  /// Raw entries for the period, used by the timeline widget.
  final List<TimeEntry> entries;

  const StatsData({
    required this.totalTracked,
    required this.untrackedTime,
    required this.byActivityType,
    required this.byProject,
    this.byEntertainmentType = const {},
    required this.entries,
  });
}
