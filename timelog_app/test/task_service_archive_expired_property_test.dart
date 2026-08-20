import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/services/task_service.dart';

// Feature: task-management, Property 11: Archive check archives expired tasks
//
// glados (the property-based testing library named in the design doc) requires
// analyzer ^8.0.0+ transitively via `test`, which conflicts with this project's
// pinned freezed ^2.5.7 (analyzer ^6.5.0/^7.0.0) — see .agents/MEMORY.md. This
// hand-rolled randomized loop (100+ iterations, seeded for reproducibility)
// exercises the same property without adding that dependency.
void main() {
  test(
    'Property 11: for any set of completed, non-archived tasks, calling '
    'archiveExpiredTasks() sets isArchived = true for exactly those whose '
    'completedAt is more than 12 hours in the past, and leaves tasks whose '
    'completedAt is less than 12 hours ago (or that are incomplete, or '
    'already archived) unaffected',
    () async {
      final random = Random(20260820);

      for (var iteration = 0; iteration < 100; iteration++) {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        final service = TaskService(db);

        try {
          final useProject = random.nextBool();
          final int? projectId = useProject
              ? await service.createProject('Project $iteration')
              : null;
          final now = DateTime.now();

          final taskCount = 1 + random.nextInt(8); // 1..8
          final expectedArchived = <int, bool>{};

          for (var i = 0; i < taskCount; i++) {
            final taskId = await service.createTask(
              title: 'Task $i',
              projectId: projectId,
            );

            // 0: incomplete, 1: completed >12h ago (expired), 2: completed
            // <12h ago (not expired), 3: already archived.
            final kind = random.nextInt(4);
            switch (kind) {
              case 0:
                expectedArchived[taskId] = false;
                break;
              case 1:
                final hoursAgo = 12.01 + random.nextDouble() * 100;
                await db.markTaskCompleted(
                  taskId,
                  now.subtract(
                    Duration(
                      milliseconds: (hoursAgo * 3600 * 1000).round(),
                    ),
                  ),
                );
                expectedArchived[taskId] = true;
                break;
              case 2:
                final hoursAgo = random.nextDouble() * 11.98;
                await db.markTaskCompleted(
                  taskId,
                  now.subtract(
                    Duration(
                      milliseconds: (hoursAgo * 3600 * 1000).round(),
                    ),
                  ),
                );
                expectedArchived[taskId] = false;
                break;
              case 3:
                final hoursAgo = 12.01 + random.nextDouble() * 100;
                await db.markTaskCompleted(
                  taskId,
                  now.subtract(
                    Duration(
                      milliseconds: (hoursAgo * 3600 * 1000).round(),
                    ),
                  ),
                );
                await db.archiveTask(taskId);
                expectedArchived[taskId] = true;
                break;
            }
          }

          await service.archiveExpiredTasks();

          final after = await service.getTasksForProject(
            projectId,
            includeArchived: true,
          );

          for (final entry in expectedArchived.entries) {
            final task = after.firstWhere((t) => t.id == entry.key);
            expect(
              task.isArchived,
              entry.value,
              reason: 'iteration $iteration: task ${entry.key} archived '
                  'state must be ${entry.value} after archiveExpiredTasks()',
            );
          }
        } finally {
          await db.close();
        }
      }
    },
  );
}
