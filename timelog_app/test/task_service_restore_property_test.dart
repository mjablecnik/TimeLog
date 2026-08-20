import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/services/task_service.dart';

// Feature: task-management, Property 12: Restoring tasks clears completion fields
//
// glados (the property-based testing library named in the design doc) requires
// analyzer ^8.0.0+ transitively via `test`, which conflicts with this project's
// pinned freezed ^2.5.7 (analyzer ^6.5.0/^7.0.0) — see .agents/MEMORY.md. This
// hand-rolled randomized loop (100+ iterations, seeded for reproducibility)
// exercises the same property without adding that dependency.
void main() {
  test(
    'Property 12: uncompleting a completed non-archived task sets '
    'isCompleted = false and completedAt = null; unarchiving an archived '
    'task sets isCompleted = false, completedAt = null, and '
    'isArchived = false',
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

          final restoreViaArchive = random.nextBool();
          final taskId = await service.createTask(
            title: 'Task $iteration',
            projectId: projectId,
          );

          final completedAt = DateTime.now().subtract(
            Duration(minutes: 1 + random.nextInt(1000)),
          );
          await db.markTaskCompleted(taskId, completedAt);

          if (restoreViaArchive) {
            await db.archiveTask(taskId);
            await service.unarchiveTask(taskId);
          } else {
            await service.toggleComplete(taskId);
          }

          final all = await service.getTasksForProject(
            projectId,
            includeArchived: true,
          );
          final restored = all.firstWhere((t) => t.id == taskId);

          expect(
            restored.isCompleted,
            isFalse,
            reason: 'iteration $iteration: isCompleted must be false after '
                'restore (via ${restoreViaArchive ? 'unarchive' : 'toggle'})',
          );
          expect(
            restored.completedAt,
            isNull,
            reason: 'iteration $iteration: completedAt must be null after '
                'restore (via ${restoreViaArchive ? 'unarchive' : 'toggle'})',
          );
          expect(
            restored.isArchived,
            isFalse,
            reason: 'iteration $iteration: isArchived must be false after '
                'restore (via ${restoreViaArchive ? 'unarchive' : 'toggle'})',
          );
        } finally {
          await db.close();
        }
      }
    },
  );
}
