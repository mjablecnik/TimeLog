import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/activity_types.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/task_providers.dart';
import 'activity_picker/suggestion_field.dart';

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
              dotColor: suggestionScopeColor(
                suggestionScopeFromName(project.scope),
                isDark: theme.themeKey != AppTheme.paper,
              ),
              semanticsLabel: l10n.taskProjectChipSemantics(
                project.name,
                suggestionScopeLabel(l10n, suggestionScopeFromName(project.scope)),
              ),
              onTap: () =>
                  ref.read(selectedTaskProjectProvider.notifier).state = project.id,
              onLongPress: () => _showProjectMenu(context, ref, project),
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
    final result = await showDialog<({String name, SuggestionScope scope})>(
      context: context,
      builder: (ctx) => _ProjectDialog(theme: theme),
    );
    if (result == null) return;

    try {
      await ref
          .read(taskServiceProvider)
          .createProject(result.name, scope: result.scope);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastTaskProjectScopeKey, result.scope.name);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.projectCreateFailed)),
        );
      }
    }
  }

  /// Long press on a project chip: edit its category or delete it.
  Future<void> _showProjectMenu(
    BuildContext context,
    WidgetRef ref,
    TaskProject project,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: theme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  project.name,
                  style: TextStyle(
                    color: theme.dim,
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            ListTile(
              key: const ValueKey('project-menu-edit'),
              title: Text(
                l10n.taskProjectEditCategory,
                style: TextStyle(
                  color: theme.text,
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => Navigator.of(ctx).pop('edit'),
            ),
            ListTile(
              key: const ValueKey('project-menu-delete'),
              title: Text(
                l10n.commonDelete,
                style: TextStyle(
                  color: Colors.red[400],
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => Navigator.of(ctx).pop('delete'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    if (action == 'delete') {
      await _confirmDeleteProject(context, ref, project);
    } else if (action == 'edit') {
      await _editCategory(context, ref, project);
    }
  }

  Future<void> _editCategory(
    BuildContext context,
    WidgetRef ref,
    TaskProject project,
  ) async {
    final result = await showDialog<({String name, SuggestionScope scope})>(
      context: context,
      builder: (ctx) => _ProjectDialog(theme: theme, existing: project),
    );
    if (result == null) return;
    await ref
        .read(taskServiceProvider)
        .updateProjectScope(project.id, result.scope);
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
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final Color? dotColor;
  final String? semanticsLabel;

  const _ProjectChip({
    required this.theme,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
    this.onDelete,
    this.dotColor,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final chip = GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress ?? onDelete,
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
            if (dotColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
            ],
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
    if (semanticsLabel == null) return chip;
    // The dot says nothing to a screen reader, so the label names the category.
    return Semantics(label: semanticsLabel, button: true, child: ExcludeSemantics(child: chip));
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

/// Preference key of the category last chosen when creating a project.
const _lastTaskProjectScopeKey = 'last_task_project_scope';

/// Creates a project (name and category) or, with [existing], changes the
/// category of a project; the name of an existing project cannot be edited.
class _ProjectDialog extends StatefulWidget {
  final AppThemeData theme;
  final TaskProject? existing;

  const _ProjectDialog({required this.theme, this.existing});

  @override
  State<_ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<_ProjectDialog> {
  String _name = '';
  late SuggestionScope _scope;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _scope = suggestionScopeFromName(widget.existing?.scope);
    if (!_isEdit) _loadLastScope();
  }

  Future<void> _loadLastScope() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_lastTaskProjectScopeKey);
    if (saved != null && mounted) {
      setState(() => _scope = suggestionScopeFromName(saved));
    }
  }

  bool get _isValid => _isEdit || _name.trim().isNotEmpty;

  void _confirm() {
    if (!_isValid) return;
    Navigator.of(context).pop((
      name: _isEdit ? widget.existing!.name : _name.trim(),
      scope: _scope,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.themeKey != AppTheme.paper;
    return AlertDialog(
      backgroundColor: theme.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        _isEdit ? l10n.taskProjectEditCategory : l10n.projectCreateTitle,
        style: TextStyle(color: theme.text, fontFamily: 'Sora', fontWeight: FontWeight.w600),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEdit) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.panel,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.border),
                ),
                child: Text(
                  widget.existing!.name,
                  style: TextStyle(color: theme.text, fontFamily: 'Sora'),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              l10n.taskProjectCategoryCaption.toUpperCase(),
              style: TextStyle(
                color: theme.faint,
                fontFamily: 'Sora',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.9,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final scope in SuggestionScope.values)
                  _ScopeChip(
                    key: ValueKey('scope-chip-${scope.name}'),
                    theme: theme,
                    label: suggestionScopeLabel(l10n, scope),
                    color: suggestionScopeColor(scope, isDark: isDark),
                    isSelected: scope == _scope,
                    onTap: () => setState(() => _scope = scope),
                  ),
              ],
            ),
            if (!_isEdit) ...[
              const SizedBox(height: 16),
              SuggestionField(
                theme: theme,
                scope: _scope,
                hint: l10n.projectNameFieldHint,
                initialText: '',
                autofocus: true,
                maxLength: 100,
                onChanged: (text) => setState(() => _name = text),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel, style: TextStyle(color: theme.dim, fontFamily: 'Sora')),
        ),
        TextButton(
          onPressed: _isValid ? _confirm : null,
          child: Text(
            _isEdit ? l10n.commonSave : l10n.commonCreate,
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

class _ScopeChip extends StatelessWidget {
  final AppThemeData theme;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScopeChip({
    super.key,
    required this.theme,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : theme.panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? color : theme.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : theme.text,
              fontFamily: 'Sora',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
