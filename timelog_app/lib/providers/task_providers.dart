import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database.dart';
import '../services/task_service.dart';
import 'database_provider.dart';

const _lastTaskProjectIdKey = 'last_task_project_id';

final taskServiceProvider = Provider<TaskService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TaskService(db);
});

final taskProjectsProvider = StreamProvider<List<TaskProject>>((ref) {
  final service = ref.watch(taskServiceProvider);
  return service.watchAllProjects();
});

final selectedTaskProjectProvider = StateProvider<int?>((ref) => null);

final showArchivedTasksProvider = StateProvider<bool>((ref) => false);

final taskListProvider = StreamProvider<List<TaskItem>>((ref) {
  final service = ref.watch(taskServiceProvider);
  final projectId = ref.watch(selectedTaskProjectProvider);
  final showArchived = ref.watch(showArchivedTasksProvider);
  return service.watchTasksForProject(projectId, includeArchived: showArchived);
});

final autocompleteProjectsProvider = FutureProvider<List<String>>((ref) async {
  final taskService = ref.watch(taskServiceProvider);
  final projectService = ref.watch(projectServiceProvider);

  final taskProjectNames = await taskService.getProjectNames();
  final timerProjectNames = await projectService.getKnownProjects();

  final seen = <String>{};
  final merged = <String>[];
  for (final name in [...taskProjectNames, ...timerProjectNames]) {
    if (seen.add(name.toLowerCase())) {
      merged.add(name);
    }
  }
  return merged;
});

/// Persists the last-viewed task project selection (or clears it for
/// Unassigned) to SharedPreferences.
Future<void> persistSelectedTaskProject(int? projectId) async {
  final prefs = await SharedPreferences.getInstance();
  if (projectId == null) {
    await prefs.remove(_lastTaskProjectIdKey);
  } else {
    await prefs.setInt(_lastTaskProjectIdKey, projectId);
  }
}

/// Reads the persisted last-viewed task project id, or null if unset.
Future<int?> loadPersistedTaskProjectId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(_lastTaskProjectIdKey);
}

/// Restores the last-viewed project from SharedPreferences into
/// [selectedTaskProjectProvider], validating it still exists in the
/// database. Falls back to Unassigned (and clears the stale value) if the
/// project was deleted, and leaves the default of Unassigned untouched if
/// nothing was ever persisted.
Future<void> restoreLastTaskProject(WidgetRef ref) async {
  final lastId = await loadPersistedTaskProjectId();
  if (lastId == null) return;

  final projects = await ref.read(taskServiceProvider).getAllProjects();
  if (projects.any((project) => project.id == lastId)) {
    ref.read(selectedTaskProjectProvider.notifier).state = lastId;
  } else {
    await persistSelectedTaskProject(null);
  }
}

/// Wires automatic persistence of [selectedTaskProjectProvider] changes.
/// Must be kept alive by watching it (e.g. from TasksScreen's build method)
/// for selection changes to be persisted.
final taskProjectPersistenceProvider = Provider<void>((ref) {
  ref.listen<int?>(selectedTaskProjectProvider, (previous, next) {
    persistSelectedTaskProject(next);
  });
});
