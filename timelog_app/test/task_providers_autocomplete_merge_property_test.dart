import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/providers/database_provider.dart';
import 'package:timelog_app/providers/task_providers.dart';
import 'package:timelog_app/services/project_service.dart';

// Feature: task-management, Property 15: Merged autocomplete list — unique names, task projects first
//
// glados (the property-based testing library named in the design doc) requires
// analyzer ^8.0.0+ transitively via `test`, which conflicts with this project's
// pinned freezed ^2.5.7 (analyzer ^6.5.0/^7.0.0) — see .agents/MEMORY.md. This
// hand-rolled randomized loop (100+ iterations, seeded for reproducibility)
// exercises the same property without adding that dependency.
void main() {
  test(
    'Property 15: autocompleteProjectsProvider merges Task_Project names and '
    'ProjectService names into a case-insensitively unique list with all '
    'Task_Project names before ProjectService-only names',
    () async {
      final random = Random(20260820);
      const namePool = [
        'Alpha',
        'alpha',
        'ALPHA',
        'Beta',
        'beta',
        'Gamma',
        'Delta',
        'delta',
        'Epsilon',
        'Zeta',
        'ETA',
        'eta',
        'Theta',
        'Iota',
        'Kappa',
        'kappa',
      ];

      for (var iteration = 0; iteration < 100; iteration++) {
        SharedPreferences.setMockInitialValues({});
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        final container = ProviderContainer(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
        );

        try {
          final taskProjectCount = random.nextInt(6); // 0..5
          final timerProjectCount = random.nextInt(6); // 0..5

          final taskService = container.read(taskServiceProvider);
          for (var i = 0; i < taskProjectCount; i++) {
            await taskService
                .createProject(namePool[random.nextInt(namePool.length)]);
          }

          final projectService = ProjectService();
          for (var i = 0; i < timerProjectCount; i++) {
            await projectService
                .saveProject(namePool[random.nextInt(namePool.length)]);
          }

          final taskProjectNames = await taskService.getProjectNames();
          final timerProjectNames = await projectService.getKnownProjects();

          final merged =
              await container.read(autocompleteProjectsProvider.future);
          final mergedLower = merged.map((n) => n.toLowerCase()).toList();

          // Uniqueness: no two entries share a case-insensitive name.
          expect(
            mergedLower.toSet().length,
            mergedLower.length,
            reason: 'iteration $iteration: merged list must be '
                'case-insensitively unique, got $merged',
          );

          // Completeness: every distinct (case-insensitive) name from either
          // source is present exactly once.
          final expectedLower = {
            ...taskProjectNames.map((n) => n.toLowerCase()),
            ...timerProjectNames.map((n) => n.toLowerCase()),
          };
          expect(
            mergedLower.toSet(),
            expectedLower,
            reason: 'iteration $iteration: merged list must contain every '
                'unique source name, got $merged',
          );

          // Ordering: all Task_Project-sourced names precede any
          // ProjectService-only name.
          final taskLower =
              taskProjectNames.map((n) => n.toLowerCase()).toSet();
          var seenNonTaskSourced = false;
          for (final name in mergedLower) {
            if (taskLower.contains(name)) {
              expect(
                seenNonTaskSourced,
                isFalse,
                reason: 'iteration $iteration: Task_Project name "$name" '
                    'appeared after a ProjectService-only name in $merged',
              );
            } else {
              seenNonTaskSourced = true;
            }
          }
        } finally {
          container.dispose();
          await db.close();
        }
      }
    },
  );
}
