import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/services/task_service.dart';

// Feature: task-management, Property 10: Mark complete sets status and timestamp
//
// glados (the property-based testing library named in the design doc) requires
// analyzer ^8.0.0+ transitively via `test`, which conflicts with this project's
// pinned freezed ^2.5.7 (analyzer ^6.5.0/^7.0.0) — see .agents/MEMORY.md. This
// hand-rolled randomized loop (100+ iterations, seeded for reproducibility)
// exercises the same property without adding that dependency.
void main() {
  test(
    'Property 10: for any incomplete, non-archived task, toggling completion '
    'sets isCompleted = true and completedAt to a timestamp within 1 second '
    'of the current time',
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

          final taskId = await service.createTask(
            title: 'Task $iteration',
            description: random.nextBool() ? 'Description $iteration' : null,
            deadline: random.nextBool() ? '2025-06-15' : null,
            projectId: projectId,
          );

          final before = await service.getTasksForProject(
            projectId,
            includeArchived: true,
          );
          final beforeTask = before.firstWhere((t) => t.id == taskId);
          expect(
            beforeTask.isCompleted,
            isFalse,
            reason: 'iteration $iteration: newly created task must start '
                'incomplete',
          );
          expect(
            beforeTask.completedAt,
            isNull,
            reason: 'iteration $iteration: newly created task must start '
                'with no completedAt',
          );

          final beforeToggle = DateTime.now();
          await service.toggleComplete(taskId);
          final afterToggle = DateTime.now();

          final after = await service.getTasksForProject(
            projectId,
            includeArchived: true,
          );
          final afterTask = after.firstWhere((t) => t.id == taskId);

          expect(
            afterTask.isCompleted,
            isTrue,
            reason: 'iteration $iteration: toggling an incomplete task must '
                'set isCompleted = true',
          );
          expect(
            afterTask.completedAt,
            isNotNull,
            reason: 'iteration $iteration: toggling an incomplete task must '
                'set a non-null completedAt',
          );

          final completedAt = afterTask.completedAt!;
          expect(
            completedAt.isBefore(
              afterToggle.add(const Duration(seconds: 1)),
            ),
            isTrue,
            reason: 'iteration $iteration: completedAt must not be more '
                'than 1 second after the toggle call completed',
          );
          expect(
            completedAt.isAfter(
              beforeToggle.subtract(const Duration(seconds: 1)),
            ),
            isTrue,
            reason: 'iteration $iteration: completedAt must not be more '
                'than 1 second before the toggle call started',
          );
        } finally {
          await db.close();
        }
      }
    },
  );
}
