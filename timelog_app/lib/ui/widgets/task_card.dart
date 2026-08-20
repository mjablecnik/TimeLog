import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_format_utils.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import '../../providers/task_providers.dart';
import 'task_edit_dialog.dart';

/// A single Task row: completion checkbox, title, deadline, expandable
/// description, drag handle, and edit/delete (or unarchive) actions
/// (Requirements 4.2, 4.3, 5.5, 5.9, 9.5).
class TaskCard extends ConsumerStatefulWidget {
  final TaskItem task;
  final AppThemeData theme;

  const TaskCard({super.key, required this.task, required this.theme});

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  bool _expanded = false;
  String? _error;

  Future<void> _toggleComplete() async {
    setState(() => _error = null);
    try {
      await ref.read(taskServiceProvider).toggleComplete(widget.task.id);
    } catch (_) {
      if (mounted) setState(() => _error = 'Nepodařilo se aktualizovat stav úkolu.');
    }
  }

  Future<void> _unarchive() async {
    setState(() => _error = null);
    try {
      await ref.read(taskServiceProvider).unarchiveTask(widget.task.id);
    } catch (_) {
      if (mounted) setState(() => _error = 'Nepodařilo se obnovit úkol.');
    }
  }

  Future<void> _edit() async {
    final result = await TaskEditDialog.show(
      context,
      theme: widget.theme,
      task: widget.task,
    );
    if (result == null) return;

    try {
      await ref.read(taskServiceProvider).updateTask(
            widget.task.id,
            title: result.title,
            description: result.description,
            deadline: result.deadline,
          );
    } catch (_) {
      if (mounted) setState(() => _error = 'Nepodařilo se uložit úkol.');
    }
  }

  Future<void> _delete() async {
    final theme = widget.theme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Smazat úkol?',
          style: TextStyle(color: theme.text, fontFamily: 'Sora', fontWeight: FontWeight.w600),
        ),
        content: Text(
          '"${widget.task.title}" bude trvale odstraněn.',
          style: TextStyle(color: theme.dim, fontFamily: 'Sora', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Zrušit', style: TextStyle(color: theme.dim, fontFamily: 'Sora')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Smazat',
              style: TextStyle(
                  color: Colors.red[400], fontFamily: 'Sora', fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(taskServiceProvider).deleteTask(widget.task.id);
    } catch (_) {
      if (mounted) setState(() => _error = 'Nepodařilo se smazat úkol.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final theme = widget.theme;
    final isCompleted = task.isCompleted;
    final isArchived = task.isArchived;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Opacity(
        opacity: isCompleted ? 0.5 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isArchived)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isCompleted,
                      onChanged: (_) => _toggleComplete(),
                      activeColor: theme.accent,
                      checkColor: theme.ink,
                    ),
                  )
                else
                  const SizedBox(width: 24, height: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: theme.text,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            decorationColor: theme.dim,
                          ),
                        ),
                        if (task.deadline != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            formatDeadline(task.deadline!),
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 12,
                              color: theme.dim,
                            ),
                          ),
                        ],
                        if (_expanded &&
                            task.description != null &&
                            task.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            task.description!,
                            style: TextStyle(fontFamily: 'Sora', fontSize: 13, color: theme.dim),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.drag_handle, size: 18, color: theme.dim),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 6),
              Text(
                _error!,
                style: TextStyle(color: Colors.red[400], fontFamily: 'Sora', fontSize: 12),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isArchived)
                  GestureDetector(
                    onTap: _unarchive,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.unarchive_outlined, size: 18, color: theme.dim),
                    ),
                  )
                else ...[
                  GestureDetector(
                    onTap: _edit,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.edit_outlined, size: 18, color: theme.dim),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                GestureDetector(
                  onTap: _delete,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.delete_outline, size: 18, color: theme.dim),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
