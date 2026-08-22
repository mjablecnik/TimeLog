import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/database.dart';
import '../../l10n/generated/app_localizations.dart';

/// Values entered in a [TaskEditDialog] on save. The caller is responsible
/// for persisting them via TaskService (create or update).
class TaskEditResult {
  final String title;
  final String? description;
  final String? deadline; // ISO 8601 "YYYY-MM-DD"

  const TaskEditResult({required this.title, this.description, this.deadline});
}

/// Modal bottom sheet for creating or editing a Task (Requirement 3). Pass
/// [task] to pre-fill for editing; omit it to create a new Task. Returns a
/// [TaskEditResult] on save, or null if cancelled.
class TaskEditDialog extends StatefulWidget {
  final AppThemeData theme;
  final TaskItem? task;

  const TaskEditDialog({super.key, required this.theme, this.task});

  static Future<TaskEditResult?> show(
    BuildContext context, {
    required AppThemeData theme,
    TaskItem? task,
  }) {
    return showModalBottomSheet<TaskEditResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskEditDialog(theme: theme, task: task),
    );
  }

  @override
  State<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<TaskEditDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _deadline;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    final deadline = task?.deadline;
    _deadline = deadline != null ? DateTime.parse(deadline) : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canSave => _titleController.text.trim().isNotEmpty;

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline != null && !_deadline!.isBefore(today) ? _deadline! : today,
      firstDate: today,
      lastDate: DateTime(today.year + 10),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _clearDeadline() => setState(() => _deadline = null);

  String _formatPickedDeadline(DateTime date) => '${date.day}. ${date.month}. ${date.year}';

  String _toIsoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void _save() {
    if (!_canSave) return;
    final description = _descriptionController.text.trim();
    Navigator.of(context).pop(
      TaskEditResult(
        title: _titleController.text.trim(),
        description: description.isEmpty ? null : description,
        deadline: _deadline == null ? null : _toIsoDate(_deadline!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: theme.border)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    Text(
                      _isEditing ? l10n.taskEditTitle : l10n.taskNewTitle,
                      style: TextStyle(
                        color: theme.text,
                        fontFamily: 'Sora',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.panel,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: TextField(
                        controller: _titleController,
                        maxLength: 200,
                        autofocus: !_isEditing,
                        style: TextStyle(color: theme.text, fontFamily: 'Sora'),
                        decoration: InputDecoration(
                          hintText: l10n.taskTitleHint,
                          hintStyle: TextStyle(color: theme.faint, fontFamily: 'Sora'),
                          border: InputBorder.none,
                          counterStyle: TextStyle(color: theme.faint, fontSize: 11),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.panel,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: TextField(
                        controller: _descriptionController,
                        maxLength: 1000,
                        maxLines: 4,
                        style: TextStyle(color: theme.text, fontFamily: 'Sora', fontSize: 15),
                        decoration: InputDecoration(
                          hintText: l10n.taskDescriptionHint,
                          hintStyle: TextStyle(color: theme.faint, fontFamily: 'Sora'),
                          border: InputBorder.none,
                          counterStyle: TextStyle(color: theme.faint, fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickDeadline,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.panel,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.border),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Icon(Icons.event, size: 18, color: theme.dim),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _deadline == null
                                    ? l10n.taskDeadlineHint
                                    : _formatPickedDeadline(_deadline!),
                                style: TextStyle(
                                  color: _deadline == null ? theme.faint : theme.text,
                                  fontFamily: _deadline == null ? 'Sora' : 'JetBrainsMono',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (_deadline != null)
                              GestureDetector(
                                onTap: _clearDeadline,
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(Icons.close, size: 16, color: theme.dim),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(foregroundColor: theme.dim),
                          child: Text(
                            l10n.commonCancel,
                            style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _canSave ? _save : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.accent,
                            foregroundColor: theme.ink,
                            disabledBackgroundColor: theme.accent.withValues(alpha: 0.3),
                            disabledForegroundColor: theme.ink.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.commonSave,
                            style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
