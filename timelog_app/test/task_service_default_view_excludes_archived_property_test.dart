import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/services/task_service.dart';

// Feature: task-management, Property 13: Default view excludes archived tasks
//
// glados (the property-based testing library named in the design doc) requires
// analyzer ^8.0.0+ transitively via `test`, which conflicts with this project's
// pinned freezed ^2.5.7 (analyzer ^6.5.0/^7.0.0) — see .agents/MEMORY.md. This
// hand-rolled randomized loop (100+ iterations, seeded for reproducibility)
// exercises the same property without adding that dependency.
void main() {
  test(
    'Property 13: for any set of tasks in a group including both archived '
    'and non-archived tasks, the default task list (includeArchived: false) '
    'contains zero archived tasks',
    () async {
      final random = Random(20260820);

      for (var iteration = 0; iteration < 100; iteration++) {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        final service = TaskService(db);

        try {
          final projectId = random.nextBool()
              ? await service.createProject('Project $iteration')
              : null;

          final taskCount = 1 + random.nextInt(15); // 1..15 tasks
          final nonArchivedIds = <int>[];
          var archivedCount = 0;

          for (var i = 0; i < taskCount; i++) {
            final taskId = await service.createTask(
              title: 'Task $iteration-$i',
              projectId: projectId,
            );
            if (random.nextBool()) {
              await db.archiveTask(taskId);
              archivedCount++;
            } else {
              nonArchivedIds.add(taskId);
            }
          }

          final defaultView = await service.getTasksForProject(projectId);

          expect(
            defaultView.any((t) => t.isArchived),
            isFalse,
            reason: 'iteration $iteration: default view must contain zero '
                'archived tasks (created $archivedCount archived of '
                '$taskCount total)',
          );
          expect(
            defaultView.map((t) => t.id).toSet(),
            nonArchivedIds.toSet(),
            reason: 'iteration $iteration: default view must contain '
                'exactly the non-archived tasks',
          );

          // Sanity check: includeArchived: true still returns everything,
          // confirming the exclusion above is a real filter, not an
          // accidental empty group.
          final fullView = await service.getTasksForProject(
            projectId,
            includeArchived: true,
          );
          expect(fullView.length, taskCount);
        } finally {
          await db.close();
        }
      }
    },
  );
}
