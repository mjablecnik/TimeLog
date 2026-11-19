import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timelog_app/core/activity_types.dart';
import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/providers/database_provider.dart';
import 'package:timelog_app/providers/task_providers.dart';
import 'package:timelog_app/services/project_service.dart';

// Feature: activity-subtypes

TimeEntry _entry({
  required String type,
  String? subtype,
  String? project,
  String? customName,
  DateTime? end,
}) {
  final endTime = end ?? DateTime.now();
  return TimeEntry(
    id: 1,
    startTime: endTime.subtract(const Duration(hours: 1)).toIso8601String(),
    endTime: endTime.toIso8601String(),
    description: 'd',
    activityType: type,
    project: project,
    entertainmentType: null,
    subtype: subtype,
    customName: customName,
    createdAt: DateTime.now(),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('names are kept separately for each scope', () async {
    final service = ProjectService();
    await service.saveName(SuggestionScope.workPaid, 'Alpha');
    await service.saveName(SuggestionScope.workUnpaid, 'Beta');
    await service.saveName(SuggestionScope.housework, 'Garage');
    await service.saveName(SuggestionScope.other, 'Guitar');

    expect(await service.getKnownNames(SuggestionScope.workPaid), ['Alpha']);
    expect(await service.getKnownNames(SuggestionScope.workUnpaid), ['Beta']);
    expect(await service.getKnownNames(SuggestionScope.housework), ['Garage']);
    expect(await service.getKnownNames(SuggestionScope.other), ['Guitar']);
  });

  test('a name is de-duplicated ignoring case and keeps the latest casing', () async {
    final service = ProjectService();
    await service.saveName(SuggestionScope.other, 'guitar');
    await service.saveName(SuggestionScope.other, 'GUITAR');
    expect(await service.getKnownNames(SuggestionScope.other), ['GUITAR']);
  });

  test('names are sorted by last use, newest first, and blank names are ignored', () async {
    final service = ProjectService();
    await service.saveName(SuggestionScope.other, 'first');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await service.saveName(SuggestionScope.other, 'second');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await service.saveName(SuggestionScope.other, '   ');
    await service.saveName(SuggestionScope.other, 'first');
    expect(await service.getKnownNames(SuggestionScope.other), ['first', 'second']);
  });

  test('names unused for 30 days are removed', () async {
    final old = DateTime.now().subtract(const Duration(days: 31));
    SharedPreferences.setMockInitialValues({
      'known_names_v3_other': jsonEncode([
        {'name': 'stale', 'lastUsed': old.toIso8601String()},
        {'name': 'fresh', 'lastUsed': DateTime.now().toIso8601String()},
      ]),
    });
    expect(await ProjectService().getKnownNames(SuggestionScope.other), ['fresh']);
  });

  test('a corrupt stored list counts as empty and is overwritten on save', () async {
    SharedPreferences.setMockInitialValues({'known_names_v3_other': 'not json'});
    final service = ProjectService();
    expect(await service.getKnownNames(SuggestionScope.other), isEmpty);
    await service.saveName(SuggestionScope.other, 'ok');
    expect(await service.getKnownNames(SuggestionScope.other), ['ok']);
  });

  group('seedFromEntries', () {
    test('fills the scoped lists from entries, removes the legacy keys, runs once', () async {
      SharedPreferences.setMockInitialValues({
        'known_projects': ['legacy'],
        'known_projects_v2': '[]',
      });
      final service = ProjectService();
      final entries = [
        _entry(type: 'Práce', subtype: 'unpaid', project: 'App'),
        _entry(type: 'Práce', subtype: 'paid', project: 'Client'),
        _entry(type: 'Domácí práce', project: 'Garage'),
        _entry(type: 'Ostatní', customName: 'Guitar'),
        _entry(type: 'Meeting'),
        // too old to be offered
        _entry(
          type: 'Práce',
          subtype: 'unpaid',
          project: 'Ancient',
          end: DateTime.now().subtract(const Duration(days: 45)),
        ),
      ];
      await service.seedFromEntries(entries);

      expect(await service.getKnownNames(SuggestionScope.workUnpaid), ['App']);
      expect(await service.getKnownNames(SuggestionScope.workPaid), ['Client']);
      expect(await service.getKnownNames(SuggestionScope.housework), ['Garage']);
      expect(await service.getKnownNames(SuggestionScope.other), ['Guitar']);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('known_projects'), isFalse);
      expect(prefs.containsKey('known_projects_v2'), isFalse);

      // A second call changes nothing, even with different entries.
      await service.seedFromEntries([_entry(type: 'Ostatní', customName: 'Later')]);
      expect(await service.getKnownNames(SuggestionScope.other), ['Guitar']);
    });

    test('uses the latest end time of a name', () async {
      final service = ProjectService();
      final older = DateTime.now().subtract(const Duration(days: 3));
      final newer = DateTime.now().subtract(const Duration(days: 1));
      await service.seedFromEntries([
        _entry(type: 'Ostatní', customName: 'Older', end: older),
        _entry(type: 'Ostatní', customName: 'Newer', end: newer),
        _entry(type: 'Ostatní', customName: 'older', end: newer.subtract(const Duration(hours: 5))),
      ]);
      // "Newer" was used last, then the second "older" (newer than the first).
      final names = await service.getKnownNames(SuggestionScope.other);
      expect(names.first, 'Newer');
      expect(names.map((n) => n.toLowerCase()).toSet(), {'newer', 'older'});
    });
  });

  group('suggestionsProvider', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('merges Task_Project names of the same scope in front, de-duplicated', () async {
      final tasks = container.read(taskServiceProvider);
      await tasks.createProject('Zulu', scope: SuggestionScope.workPaid);
      await tasks.createProject('alpha', scope: SuggestionScope.workPaid);
      await tasks.createProject('Elsewhere', scope: SuggestionScope.housework);
      final store = container.read(projectServiceProvider);
      await store.saveName(SuggestionScope.workPaid, 'ALPHA');
      await store.saveName(SuggestionScope.workPaid, 'Timer only');
      await store.saveName(SuggestionScope.workUnpaid, 'Unpaid only');

      final paid = await container.read(suggestionsProvider(SuggestionScope.workPaid).future);
      expect(paid, ['alpha', 'Zulu', 'Timer only']);

      final housework =
          await container.read(suggestionsProvider(SuggestionScope.housework).future);
      expect(housework, ['Elsewhere']);

      final other = await container.read(suggestionsProvider(SuggestionScope.other).future);
      expect(other, isEmpty);
    });

    test('a deleted Task_Project no longer suggests its name', () async {
      final tasks = container.read(taskServiceProvider);
      final id = await tasks.createProject('Gone', scope: SuggestionScope.other);
      expect(
        await container.read(suggestionsProvider(SuggestionScope.other).future),
        ['Gone'],
      );
      await tasks.deleteProject(id);
      container.invalidate(suggestionsProvider(SuggestionScope.other));
      expect(
        await container.read(suggestionsProvider(SuggestionScope.other).future),
        isEmpty,
      );
    });

    test('changing the category moves the name between the lists', () async {
      final tasks = container.read(taskServiceProvider);
      final id = await tasks.createProject('Mover', scope: SuggestionScope.workUnpaid);
      await tasks.updateProjectScope(id, SuggestionScope.workPaid);
      container.invalidate(suggestionsProvider(SuggestionScope.workPaid));
      container.invalidate(suggestionsProvider(SuggestionScope.workUnpaid));

      expect(
        await container.read(suggestionsProvider(SuggestionScope.workPaid).future),
        ['Mover'],
      );
      expect(
        await container.read(suggestionsProvider(SuggestionScope.workUnpaid).future),
        isEmpty,
      );
    });

    test('seeds from the entries of the database on first use', () async {
      await db.into(db.timeEntries).insert(
            TimeEntriesCompanion.insert(
              startTime: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
              endTime: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
              description: 'x',
            ).copyWith(
              project: const Value('Seeded'),
              subtype: const Value('unpaid'),
            ),
          );
      expect(
        await container.read(suggestionsProvider(SuggestionScope.workUnpaid).future),
        ['Seeded'],
      );
    });
  });

  // Property 5: suggestion isolation
  test('Property 5: a scope lists a name only if it was saved there or belongs to its Task_Project',
      () async {
    final random = Random(20261122);
    const pool = ['Alpha', 'alpha', 'Beta', 'Gamma', 'delta', 'Delta', 'Eta', 'Kappa'];

    for (var iteration = 0; iteration < 100; iteration++) {
      SharedPreferences.setMockInitialValues({});
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      try {
        final tasks = container.read(taskServiceProvider);
        final store = container.read(projectServiceProvider);
        final expected = {
          for (final scope in SuggestionScope.values) scope: <String>{},
        };

        for (var i = 0; i < random.nextInt(6); i++) {
          final scope = SuggestionScope.values[random.nextInt(4)];
          final name = pool[random.nextInt(pool.length)];
          await tasks.createProject(name, scope: scope);
          expected[scope]!.add(name.toLowerCase());
        }
        for (var i = 0; i < random.nextInt(8); i++) {
          final scope = SuggestionScope.values[random.nextInt(4)];
          final name = pool[random.nextInt(pool.length)];
          await store.saveName(scope, name);
          expected[scope]!.add(name.toLowerCase());
        }

        for (final scope in SuggestionScope.values) {
          final list = await container.read(suggestionsProvider(scope).future);
          final lower = list.map((n) => n.toLowerCase()).toList();
          expect(lower.toSet().length, lower.length,
              reason: 'iteration $iteration $scope: duplicates in $list');
          expect(lower.toSet(), expected[scope],
              reason: 'iteration $iteration $scope: $list');
        }
      } finally {
        container.dispose();
        await db.close();
      }
    }
  });
}
