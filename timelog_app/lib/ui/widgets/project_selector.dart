import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/database.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/task_providers.dart';

/// Horizontal scrollable chip bar showing all Task_Projects alphabetically,
/// followed by the always-present "Nepřiřazeno" (Unassigned) entry and an
/// add-project button. Reads [taskProjectsProvider], writes
/// [selectedTaskProjectProvider].
class ProjectSelector extends ConsumerWidget {
  final AppThemeData theme;

  const ProjectSelector({super.key, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(taskProjectsProvider);
    final selectedId = ref.watch(selectedTaskProjectProvider);

    return projectsAsync.when(
      data: (projects) => _buildRow(context, ref, projects, selectedId),
      loading: () => const SizedBox(height: 44),
      error: (_, _) => const SizedBox(height: 44),
    );
  }

  Widget _buildRow(
    BuildContext context,
    WidgetRef ref,
    List<TaskProject> projects,
    int? selectedId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final project in projects) ...[
            _ProjectChip(
              theme: theme,
              label: project.name,
              isSelected: selectedId == project.id,
              onTap: () =>
                  ref.read(selectedTaskProjectProvider.notifier).state = project.id,
              onDelete: () => _confirmDeleteProject(context, ref, project),
            ),
            const SizedBox(width: 8),
          ],
          _ProjectChip(
            theme: theme,
            label: l10n.commonUnassigned,
            isSelected: selectedId == null,
            onTap: () =>
                ref.read(selectedTaskProjectProvider.notifier).state = null,
          ),
          const SizedBox(width: 8),
          _AddProjectButton(
            theme: theme,
            onTap: () => _createProject(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _createProject(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => _CreateProjectDialog(theme: theme),
    );
    if (name == null) return;

    try {
      await ref.read(taskServiceProvider).createProject(name);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.projectCreateFailed)),
        );
      }
    }
  }

  Future<void> _confirmDeleteProject(
    BuildContext context,
    WidgetRef ref,
    TaskProject project,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.projectDeleteTitle(project.name),
          style: TextStyle(
            color: theme.text,
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          l10n.projectDeleteBody,
          style: TextStyle(color: theme.dim, fontFamily: 'Sora', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel, style: TextStyle(color: theme.dim, fontFamily: 'Sora')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.commonDelete,
              style: TextStyle(
                color: Colors.red[400],
                fontFamily: 'Sora',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(taskServiceProvider).deleteProject(project.id);
      if (ref.read(selectedTaskProjectProvider) == project.id) {
        ref.read(selectedTaskProjectProvider.notifier).state = null;
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.projectDeleteFailed)),
        );
      }
    }
  }
}

class _ProjectChip extends StatelessWidget {
  final AppThemeData theme;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _ProjectChip({
    required this.theme,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        padding: EdgeInsets.only(left: 14, right: onDelete != null ? 6 : 14),
        decoration: BoxDecoration(
          color: isSelected ? theme.accent.withValues(alpha: 0.2) : theme.panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? theme.accent : theme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.accent : theme.text,
                fontFamily: 'Sora',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 2),
              GestureDetector(
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.close, size: 14, color: theme.dim),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddProjectButton extends StatelessWidget {
  final AppThemeData theme;
  final VoidCallback onTap;

  const _AddProjectButton({required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.panel,
          shape: BoxShape.circle,
          border: Border.all(color: theme.border),
        ),
        child: Icon(Icons.add, size: 18, color: theme.dim),
      ),
    );
  }
}

class _CreateProjectDialog extends StatefulWidget {
  final AppThemeData theme;

  const _CreateProjectDialog({required this.theme});

  @override
  State<_CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<_CreateProjectDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid => _controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: theme.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        l10n.projectCreateTitle,
        style: TextStyle(color: theme.text, fontFamily: 'Sora', fontWeight: FontWeight.w600),
      ),
      content: Container(
        decoration: BoxDecoration(
          color: theme.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextField(
          controller: _controller,
          autofocus: true,
          maxLength: 100,
          style: TextStyle(color: theme.text, fontFamily: 'Sora'),
          decoration: InputDecoration(
            hintText: l10n.projectNameFieldHint,
            hintStyle: TextStyle(color: theme.faint, fontFamily: 'Sora'),
            border: InputBorder.none,
            counterStyle: TextStyle(color: theme.faint, fontSize: 11),
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) {
            if (_isValid) Navigator.of(context).pop(_controller.text.trim());
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel, style: TextStyle(color: theme.dim, fontFamily: 'Sora')),
        ),
        TextButton(
          onPressed: _isValid
              ? () => Navigator.of(context).pop(_controller.text.trim())
              : null,
          child: Text(
            l10n.commonCreate,
            style: TextStyle(
              color: _isValid ? theme.accent : theme.faint,
              fontFamily: 'Sora',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
