import 'package:drift/drift.dart';

import '../core/activity_types.dart';
import '../data/database.dart';

class TaskService {
  final AppDatabase _db;

  TaskService(this._db);

  // --- Task Projects ---

  Future<List<TaskProject>> getAllProjects() {
    return _db.getAllTaskProjects();
  }

  Stream<List<TaskProject>> watchAllProjects() {
    return _db.watchAllTaskProjects();
  }

  Future<int> createProject(
    String name, {
    SuggestionScope scope = SuggestionScope.workUnpaid,
  }) {
    return _db.insertTaskProject(
      TaskProjectsCompanion.insert(name: name, scope: Value(scope.name)),
    );
  }

  /// Changes the category of a project; its name and tasks stay untouched.
  Future<void> updateProjectScope(int projectId, SuggestionScope scope) {
    return _db.updateTaskProjectScope(projectId, scope.name);
  }

  Future<void> deleteProject(int projectId) {
    return _db.deleteTaskProject(projectId);
  }

  /// Names of the projects of one category, alphabetically.
  Future<List<String>> getProjectNames(SuggestionScope scope) async {
    final projects = await _db.getTaskProjectsAlphabetical();
    return [
      for (final project in projects)
        if (suggestionScopeFromName(project.scope) == scope) project.name,
    ];
  }

  // --- Tasks ---

  Future<List<TaskItem>> getTasksForProject(
    int? projectId, {
    bool includeArchived = false,
  }) {
    return _db.getTasksForProject(projectId, includeArchived: includeArchived);
  }

  Stream<List<TaskItem>> watchTasksForProject(
    int? projectId, {
    bool includeArchived = false,
  }) {
    return _db.watchTasksForProject(projectId, includeArchived: includeArchived);
  }

  Future<int> createTask({
    required String title,
    String? description,
    String? deadline,
    int? projectId,
  }) async {
    final existing = await _db.getTasksForProject(
      projectId,
      includeArchived: true,
    );
    final maxSortPosition = existing.isEmpty
        ? -1
        : existing.map((t) => t.sortPosition).reduce((a, b) => a > b ? a : b);

    return _db.insertTask(TasksCompanion.insert(
      title: title,
      description: Value(description),
      deadline: Value(deadline),
      projectId: Value(projectId),
      sortPosition: Value(maxSortPosition + 1),
    ));
  }

  Future<void> updateTask(
    int taskId, {
    String? title,
    String? description,
    String? deadline,
  }) {
    return _db.updateTaskFields(
      taskId,
      TasksCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        description: Value(description),
        deadline: Value(deadline),
      ),
    );
  }

  Future<void> deleteTask(int taskId) {
    return _db.deleteTask(taskId);
  }

  // --- Reorder, completion, archive ---

  Future<void> reorder(int taskId, int newPosition, int? projectId) async {
    final tasksInGroup = await _db.getTasksForProject(projectId);
    final movedIndex = tasksInGroup.indexWhere((t) => t.id == taskId);
    if (movedIndex == -1) return;

    final moved = tasksInGroup.removeAt(movedIndex);
    final clampedPosition = newPosition.clamp(0, tasksInGroup.length);
    tasksInGroup.insert(clampedPosition, moved);

    await _db.updateTaskSortPositions(tasksInGroup);
  }

  Future<void> toggleComplete(int taskId) async {
    final task = await (_db.select(_db.tasks)
          ..where((t) => t.id.equals(taskId)))
        .getSingleOrNull();
    if (task == null) return;

    if (task.isCompleted) {
      await _db.unmarkTaskCompleted(taskId);
    } else {
      await _db.markTaskCompleted(taskId, DateTime.now());
    }
  }

  Future<void> archiveExpiredTasks() async {
    final expired = await _db.getExpiredCompletedTasks();
    for (final task in expired) {
      await _db.archiveTask(task.id);
    }
  }

  /// Sorts archived tasks by completion timestamp descending (most recently
  /// completed first), falling back to createdAt for tasks with no
  /// completedAt.
  static List<TaskItem> sortArchivedTasks(List<TaskItem> archivedTasks) {
    final sorted = List<TaskItem>.from(archivedTasks);
    sorted.sort((a, b) => (b.completedAt ?? b.createdAt)
        .compareTo(a.completedAt ?? a.createdAt));
    return sorted;
  }

  Future<void> unarchiveTask(int taskId) async {
    final task = await (_db.select(_db.tasks)
          ..where((t) => t.id.equals(taskId)))
        .getSingleOrNull();
    if (task == null) return;

    final existing = await _db.getTasksForProject(
      task.projectId,
      includeArchived: true,
    );
    final maxSortPosition = existing.isEmpty
        ? -1
        : existing.map((t) => t.sortPosition).reduce((a, b) => a > b ? a : b);

    await _db.unarchiveTask(taskId, maxSortPosition + 1);
  }
}
