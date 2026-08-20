import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/services/task_service.dart';

// Feature: task-management, Property 9: Reorder produces valid contiguous positions
//
// glados (the property-based testing library named in the design doc) requires
// analyzer ^8.0.0+ transitively via `test`, which conflicts with this project's
// pinned freezed ^2.5.7 (analyzer ^6.5.0/^7.0.0) — see .agents/MEMORY.md. This
// hand-rolled randomized loop (100+ iterations, seeded for reproducibility)
// exercises the same property without adding that dependency.
void main() {
  test(
    'Property 9: for any list of N tasks in a group and any valid move '
    '(source index, destination index where 0 <= indices < N), after '
    'reordering, all tasks in the group have contiguous sort positions '
    '(0, 1, 2, ..., N-1) reflecting the new visual order',
    () async {
      final random = Random(20260820);

      for (var iteration = 0; iteration < 100; iteration++) {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        final service = TaskService(db);

        try {
          final useProject = random.nextBool();
          final int? groupProjectId = useProject
              ? await service.createProject('Group $iteration')
              : null;
          final otherProjectId =
              await service.createProject('Other $iteration');

          final taskCount = 1 + random.nextInt(10); // 1..10
          for (var i = 0; i < taskCount; i++) {
            await service.createTask(
              title: 'Task $i',
              projectId: groupProjectId,
            );
          }

          // Noise in an unrelated group must not influence the target
          // group's reorder outcome.
          final noiseCount = random.nextInt(6); // 0..5
          for (var i = 0; i < noiseCount; i++) {
            await service.createTask(
              title: 'Noise task $i',
              projectId: otherProjectId,
            );
          }

          final before =
              await service.getTasksForProject(groupProjectId);
          final beforeIds = before.map((t) => t.id).toList();

          final sourceIndex = random.nextInt(taskCount);
          final destIndex = random.nextInt(taskCount);
          final movedId = beforeIds[sourceIndex];

          await service.reorder(movedId, destIndex, groupProjectId);

          final after = await service.getTasksForProject(groupProjectId);

          final expectedIds = List<int>.from(beforeIds)
            ..removeAt(sourceIndex);
          final clampedDest = destIndex.clamp(0, expectedIds.length);
          expectedIds.insert(clampedDest, movedId);

          expect(
            after.map((t) => t.sortPosition).toList(),
            List<int>.generate(taskCount, (i) => i),
            reason: 'iteration $iteration: sort positions must be '
                'contiguous (0..N-1) after reorder',
          );
          expect(
            after.map((t) => t.id).toList(),
            expectedIds,
            reason: 'iteration $iteration: reordered task ids must match '
                'moving task $movedId from index $sourceIndex to '
                '$destIndex',
          );

          // Noise group must be untouched.
          final noiseAfter =
              await service.getTasksForProject(otherProjectId);
          expect(
            noiseAfter.map((t) => t.sortPosition).toList(),
            List<int>.generate(noiseCount, (i) => i),
            reason: 'iteration $iteration: unrelated group sort positions '
                'must remain unaffected by reorder in another group',
          );
        } finally {
          await db.close();
        }
      }
    },
  );
}
