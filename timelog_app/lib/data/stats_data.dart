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

/// A custom name of an `Ostatní` entry in the statistics breakdown.
@immutable
class NameStat {
  final String name;
  final Duration duration;

  const NameStat({required this.name, required this.duration});
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

  /// Time per subtype: type key -> subtype key -> duration. Time of a type
  /// that has no subtype is not listed here (it is the difference to
  /// [byActivityType]).
  final Map<String, Map<String, Duration>> bySubtype;

  /// Time of `Ostatní` entries per custom name, longest first. Names are
  /// compared ignoring letter case.
  final List<NameStat> byCustomName;

  /// Raw entries for the period, used by the timeline widget.
  final List<TimeEntry> entries;

  const StatsData({
    required this.totalTracked,
    required this.untrackedTime,
    required this.byActivityType,
    required this.byProject,
    this.bySubtype = const {},
    this.byCustomName = const [],
    required this.entries,
  });
}
