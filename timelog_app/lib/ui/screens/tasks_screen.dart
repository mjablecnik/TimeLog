import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/database.dart';
import '../../providers/task_providers.dart';
import '../../providers/theme_provider.dart';
import '../../services/task_service.dart';
import '../widgets/project_selector.dart';
import '../widgets/task_card.dart';
import '../widgets/task_edit_dialog.dart';

/// Main screen for the Tasks tab: project selector, manually-ordered task
/// list (drag-and-drop reorder), add-task FAB, and an archive toggle menu
/// (Requirements 3, 4, 5, 6, 9, 10).
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await restoreLastTaskProject(ref);
      await ref.read(taskServiceProvider).archiveExpiredTasks();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(taskServiceProvider).archiveExpiredTasks();
    }
  }

  Future<void> _addTask(BuildContext context, AppThemeData theme, int? projectId) async {
    final result = await TaskEditDialog.show(context, theme: theme);
    if (result == null) return;

    try {
      await ref.read(taskServiceProvider).createTask(
            title: result.title,
            description: result.description,
            deadline: result.deadline,
            projectId: projectId,
          );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vytvoření úkolu se nezdařilo.')),
        );
      }
    }
  }

  Future<void> _reorder(int taskId, int newPosition, int? projectId) async {
    try {
      await ref.read(taskServiceProvider).reorder(taskId, newPosition, projectId);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Přesunutí úkolu se nezdařilo.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the last-viewed-project persistence listener alive.
    ref.watch(taskProjectPersistenceProvider);

    final theme = ref.watch(themeProvider);
    final tasksAsync = ref.watch(taskListProvider);
    final selectedProjectId = ref.watch(selectedTaskProjectProvider);
    final showArchived = ref.watch(showArchivedTasksProvider);

    return Scaffold(
      backgroundColor: theme.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.accent,
        foregroundColor: theme.ink,
        onPressed: () => _addTask(context, theme, selectedProjectId),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'Úkoly',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.text,
                    fontFamily: 'Sora',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Positioned(
                  right: 4,
                  child: PopupMenuButton<void>(
                    icon: Icon(Icons.more_vert, color: theme.text),
                    color: theme.panel,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (context) => [
                      PopupMenuItem<void>(
                        onTap: () => ref.read(showArchivedTasksProvider.notifier).state =
                            !showArchived,
                        child: Row(
                          children: [
                            Icon(
                              showArchived ? Icons.check_box : Icons.check_box_outline_blank,
                              size: 18,
                              color: theme.dim,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Zobrazit archivované úkoly',
                              style: TextStyle(color: theme.text, fontFamily: 'Sora', fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ProjectSelector(theme: theme),
            const SizedBox(height: 4),
            Expanded(
              child: tasksAsync.when(
                data: (tasks) => _TaskListBody(
                  theme: theme,
                  tasks: tasks,
                  showArchived: showArchived,
                  selectedProjectId: selectedProjectId,
                  onReorder: _reorder,
                ),
                loading: () => Center(
                  child: CircularProgressIndicator(color: theme.accent),
                ),
                error: (error, _) => Center(
                  child: Text(
                    'Načtení úkolů se nezdařilo.',
                    style: TextStyle(color: theme.dim, fontFamily: 'Sora'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskListBody extends StatelessWidget {
  final AppThemeData theme;
  final List<TaskItem> tasks;
  final bool showArchived;
  final int? selectedProjectId;
  final Future<void> Function(int taskId, int newPosition, int? projectId) onReorder;

  const _TaskListBody({
    required this.theme,
    required this.tasks,
    required this.showArchived,
    required this.selectedProjectId,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final activeTasks = tasks.where((t) => !t.isArchived).toList();
    final archivedTasks = TaskService.sortArchivedTasks(
        tasks.where((t) => t.isArchived).toList());

    final showArchivedSection = showArchived && archivedTasks.isNotEmpty;

    if (activeTasks.isEmpty && !showArchivedSection) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.checklist_outlined, size: 52, color: theme.faint),
              const SizedBox(height: 16),
              Text(
                'Zatím žádné úkoly',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.dim, fontFamily: 'Sora', fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Klepnutím na + vytvořte první úkol',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.faint, fontFamily: 'Sora', fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final itemCount = activeTasks.length + (showArchivedSection ? 1 + archivedTasks.length : 0);

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 96, top: 4),
      buildDefaultDragHandles: false,
      itemCount: itemCount,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex >= activeTasks.length) return;
        onReorder(activeTasks[oldIndex].id, newIndex, selectedProjectId);
      },
      itemBuilder: (context, index) {
        if (index < activeTasks.length) {
          final task = activeTasks[index];
          return ReorderableDragStartListener(
            key: ValueKey('task-${task.id}'),
            index: index,
            child: TaskCard(task: task, theme: theme),
          );
        }

        if (index == activeTasks.length) {
          return Padding(
            key: const ValueKey('archived-header'),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Archivováno',
              style: TextStyle(
                color: theme.faint,
                fontFamily: 'Sora',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        final archivedTask = archivedTasks[index - activeTasks.length - 1];
        return TaskCard(
          key: ValueKey('task-${archivedTask.id}'),
          task: archivedTask,
          theme: theme,
        );
      },
    );
  }
}
