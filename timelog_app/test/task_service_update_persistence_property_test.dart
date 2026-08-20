import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/services/task_service.dart';

// Feature: task-management, Property 6: Task update persistence
//
// glados (the property-based testing library named in the design doc) requires
// analyzer ^8.0.0+ transitively via `test`, which conflicts with this project's
// pinned freezed ^2.5.7 (analyzer ^6.5.0/^7.0.0) — see .agents/MEMORY.md. This
// hand-rolled randomized loop (100+ iterations, seeded for reproducibility)
// exercises the same property without adding that dependency.

const _titleChars =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .-';

String _randomString(Random random, int length) {
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => _titleChars.codeUnitAt(random.nextInt(_titleChars.length)),
    ),
  );
}

String _randomIsoDate(Random random) {
  final year = 2024 + random.nextInt(3);
  final month = 1 + random.nextInt(12);
  final day = 1 + random.nextInt(28);
  return '$year-${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}

void main() {
  test(
    'Property 6: for any existing Task and any valid combination of updated '
    'field values, updating the task results in the Task_Database reflecting '
    'exactly those new values while preserving unchanged fields',
    () async {
      final random = Random(20260820);

      for (var iteration = 0; iteration < 100; iteration++) {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        final service = TaskService(db);

        try {
          final projectId = random.nextBool()
              ? await service.createProject('Project $iteration')
              : null;

          final originalTaskId = await service.createTask(
            title: _randomString(random, 1 + random.nextInt(50)),
            description: random.nextBool()
                ? _randomString(random, random.nextInt(200))
                : null,
            deadline: random.nextBool() ? _randomIsoDate(random) : null,
            projectId: projectId,
          );

          // Give the task some non-default state on fields the update call
          // must leave untouched.
          if (random.nextBool()) {
            await service.toggleComplete(originalTaskId);
          }

          final before = (await service.getTasksForProject(
            projectId,
            includeArchived: true,
          )).firstWhere((t) => t.id == originalTaskId);

          final newTitle = _randomString(random, 1 + random.nextInt(200));
          final newDescription =
              random.nextBool() ? _randomString(random, random.nextInt(1000)) : null;
          final newDeadline =
              random.nextBool() ? _randomIsoDate(random) : null;

          await service.updateTask(
            originalTaskId,
            title: newTitle,
            description: newDescription,
            deadline: newDeadline,
          );

          final after = (await service.getTasksForProject(
            projectId,
            includeArchived: true,
          )).firstWhere((t) => t.id == originalTaskId);

          expect(
            after.title,
            newTitle,
            reason: 'iteration $iteration: title must reflect the update',
          );
          expect(
            after.description,
            newDescription,
            reason:
                'iteration $iteration: description must reflect the update '
                '(including clearing to null)',
          );
          expect(
            after.deadline,
            newDeadline,
            reason: 'iteration $iteration: deadline must reflect the update '
                '(including clearing to null)',
          );

          // Fields not part of the update call must be preserved exactly.
          expect(after.id, before.id);
          expect(after.projectId, before.projectId);
          expect(after.sortPosition, before.sortPosition);
          expect(after.isCompleted, before.isCompleted);
          expect(after.completedAt, before.completedAt);
          expect(after.isArchived, before.isArchived);
          expect(after.createdAt, before.createdAt);
        } finally {
          await db.close();
        }
      }
    },
  );
}
