import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/services/task_service.dart';

// Feature: task-management, Property 14: Archived tasks ordered by
// completion timestamp descending
//
// glados (the property-based testing library named in the design doc) requires
// analyzer ^8.0.0+ transitively via `test`, which conflicts with this project's
// pinned freezed ^2.5.7 (analyzer ^6.5.0/^7.0.0) — see .agents/MEMORY.md. This
// hand-rolled randomized loop (100+ iterations, seeded for reproducibility)
// exercises the same property without adding that dependency.
//
// TaskService.sortArchivedTasks is a pure function extracted from
// TasksScreen's archive-section sort, so this test constructs TaskItem
// instances directly rather than going through a database.
void main() {
  test(
    'Property 14: for any set of archived tasks, sortArchivedTasks orders '
    'them by completedAt descending (most recently completed first), '
    'falling back to createdAt when completedAt is null',
    () {
      final random = Random(20260820);

      for (var iteration = 0; iteration < 100; iteration++) {
        final now = DateTime(2026, 8, 20, 12);
        final taskCount = random.nextInt(20); // 0..19 tasks

        final tasks = List<TaskItem>.generate(taskCount, (i) {
          final hasCompletedAt = random.nextBool();
          final createdAt = now.subtract(
            Duration(minutes: 1 + random.nextInt(100000)),
          );
          final completedAt = hasCompletedAt
              ? now.subtract(Duration(minutes: random.nextInt(100000)))
              : null;
          return TaskItem(
            id: i,
            title: 'Task $iteration-$i',
            sortPosition: i,
            isCompleted: true,
            completedAt: completedAt,
            isArchived: true,
            createdAt: createdAt,
          );
        });

        final sorted = TaskService.sortArchivedTasks(tasks);

        expect(
          sorted.map((t) => t.id).toSet(),
          tasks.map((t) => t.id).toSet(),
          reason: 'iteration $iteration: sorting must not add or drop tasks',
        );
        expect(
          sorted.length,
          tasks.length,
          reason: 'iteration $iteration: sorting must not duplicate tasks',
        );

        for (var i = 0; i < sorted.length - 1; i++) {
          final currentKey = sorted[i].completedAt ?? sorted[i].createdAt;
          final nextKey = sorted[i + 1].completedAt ?? sorted[i + 1].createdAt;
          expect(
            currentKey.isBefore(nextKey),
            isFalse,
            reason: 'iteration $iteration: task at index $i '
                '(key $currentKey) must not be ordered before task at '
                'index ${i + 1} (key $nextKey)',
          );
        }
      }
    },
  );

  test(
    'Property 14: sortArchivedTasks does not mutate the input list',
    () {
      final now = DateTime(2026, 8, 20, 12);
      final tasks = [
        TaskItem(
          id: 1,
          title: 'A',
          sortPosition: 0,
          isCompleted: true,
          completedAt: now.subtract(const Duration(hours: 1)),
          isArchived: true,
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        TaskItem(
          id: 2,
          title: 'B',
          sortPosition: 1,
          isCompleted: true,
          completedAt: now.subtract(const Duration(hours: 2)),
          isArchived: true,
          createdAt: now.subtract(const Duration(days: 2)),
        ),
      ];
      final originalOrder = tasks.map((t) => t.id).toList();

      TaskService.sortArchivedTasks(tasks);

      expect(tasks.map((t) => t.id).toList(), originalOrder);
    },
  );
}
