import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/core/activity_types.dart';
import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/data/stats_data.dart';
import 'package:timelog_app/providers/statistics_provider.dart';

// Feature: activity-subtypes

TimeEntry _entry({
  required String type,
  String? subtype,
  String? project,
  String? customName,
  int minutes = 30,
  int id = 1,
}) {
  final start = DateTime(2026, 3, 2, 8);
  return TimeEntry(
    id: id,
    startTime: start.toIso8601String(),
    endTime: start.add(Duration(minutes: minutes)).toIso8601String(),
    description: 'd',
    activityType: type,
    project: project,
    entertainmentType: null,
    subtype: subtype,
    customName: customName,
    createdAt: start,
  );
}

void main() {
  test('time per subtype and per type', () {
    final stats = computeStats([
      _entry(type: 'Práce', subtype: 'paid', project: 'A', minutes: 60),
      _entry(type: 'Práce', subtype: 'unpaid', project: 'A', minutes: 30),
      _entry(type: 'Cvičení', subtype: 'walk', minutes: 20),
      _entry(type: 'Meeting', minutes: 15),
    ], StatsPeriod.daily);

    expect(stats.byActivityType['Práce'], const Duration(minutes: 90));
    expect(stats.bySubtype['Práce'], {
      'paid': const Duration(minutes: 60),
      'unpaid': const Duration(minutes: 30),
    });
    expect(stats.bySubtype['Cvičení'], {'walk': const Duration(minutes: 20)});
    expect(stats.bySubtype.containsKey('Meeting'), isFalse);
    expect(stats.totalTracked, const Duration(minutes: 125));
  });

  test('"By project" sums a project regardless of subtype', () {
    final stats = computeStats([
      _entry(type: 'Práce', subtype: 'paid', project: 'A', minutes: 60),
      _entry(type: 'Práce', subtype: 'unpaid', project: 'A', minutes: 30),
      _entry(type: 'Domácí práce', project: 'Garage', minutes: 10),
      _entry(type: 'Meeting', project: 'ignored', minutes: 10),
    ], StatsPeriod.daily);

    final byName = {for (final p in stats.byProject) '${p.activityType}/${p.name}': p.duration};
    expect(byName, {
      'Práce/A': const Duration(minutes: 90),
      'Domácí práce/Garage': const Duration(minutes: 10),
    });
    expect(stats.byProject.first.name, 'A');
  });

  test('"Other by name" groups names ignoring case and sorts by time', () {
    final stats = computeStats([
      _entry(type: 'Ostatní', customName: 'Guitar', minutes: 20),
      _entry(type: 'Ostatní', customName: 'guitar', minutes: 25),
      _entry(type: 'Ostatní', customName: 'Photos', minutes: 30),
      _entry(type: 'Ostatní', customName: '  ', minutes: 5),
      _entry(type: 'Ostatní', minutes: 5),
      _entry(type: 'Meeting', customName: 'ignored', minutes: 99),
    ], StatsPeriod.daily);

    expect(stats.byCustomName.map((n) => n.name).toList(), ['Guitar', 'Photos']);
    expect(stats.byCustomName.first.duration, const Duration(minutes: 45));
    expect(stats.byActivityType['Ostatní'], const Duration(minutes: 85));
  });

  test('weekly period aggregates the same way', () {
    final stats = computeStats([
      _entry(type: 'Jídlo', subtype: 'lunch', minutes: 40),
      _entry(type: 'Jídlo', subtype: 'snack', minutes: 10),
    ], StatsPeriod.weekly);
    expect(stats.bySubtype['Jídlo'], {
      'lunch': const Duration(minutes: 40),
      'snack': const Duration(minutes: 10),
    });
  });

  test('an unknown subtype is not listed but counts in the type total', () {
    final stats = computeStats([
      _entry(type: 'Práce', subtype: 'bogus', minutes: 30),
    ], StatsPeriod.daily);
    expect(stats.byActivityType['Práce'], const Duration(minutes: 30));
    expect(stats.bySubtype.containsKey('Práce'), isFalse);
  });

  test('Property 4: statistics partition', () {
    final random = Random(20261123);
    final subtypePool = <String?>[
      null,
      'paid',
      'unpaid',
      'active',
      'walk',
      'study',
      'lunch',
      'bogus',
    ];

    for (var iteration = 0; iteration < 100; iteration++) {
      final entries = <TimeEntry>[
        for (var i = 0; i < random.nextInt(15); i++)
          _entry(
            id: i,
            type: activityTypes[random.nextInt(activityTypes.length)],
            subtype: subtypePool[random.nextInt(subtypePool.length)],
            project: random.nextBool() ? 'P${random.nextInt(3)}' : null,
            customName: random.nextBool() ? 'N${random.nextInt(3)}' : null,
            minutes: 1 + random.nextInt(120),
          ),
      ];
      final stats = computeStats(entries, StatsPeriod.daily);

      final typeSum = stats.byActivityType.values.fold(Duration.zero, (a, b) => a + b);
      expect(typeSum, stats.totalTracked, reason: 'iteration $iteration');

      for (final type in stats.byActivityType.keys) {
        final subtypes = stats.bySubtype[type] ?? const <String, Duration>{};
        final subtypeSum = subtypes.values.fold(Duration.zero, (a, b) => a + b);
        // Time without a (valid) subtype is the rest of the type total.
        final withoutSubtype = entries
            .where((e) =>
                e.activityType == type && subtypeOf(type, e.subtype) == null)
            .fold(Duration.zero, (a, e) =>
                a + DateTime.parse(e.endTime).difference(DateTime.parse(e.startTime)));
        expect(subtypeSum + withoutSubtype, stats.byActivityType[type],
            reason: 'iteration $iteration type $type');
        for (final key in subtypes.keys) {
          expect(subtypeOf(type, key), isNotNull);
        }
      }
    }
  });
}
