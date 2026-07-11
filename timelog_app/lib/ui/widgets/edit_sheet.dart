import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/activity_types.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import '../../providers/database_provider.dart';

class EditSheet extends ConsumerStatefulWidget {
  final AppThemeData theme;
  final TimeEntry entry;

  const EditSheet({
    super.key,
    required this.theme,
    required this.entry,
  });

  @override
  ConsumerState<EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends ConsumerState<EditSheet> {
  late final TextEditingController _controller;
  late final TextEditingController _projectController;
  late String _selectedType;
  String? _error;
  bool _saving = false;
  List<String> _knownProjects = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.entry.description);
    _projectController = TextEditingController(text: widget.entry.project ?? '');
    _selectedType = widget.entry.activityType;
    _loadKnownProjects();
  }

  Future<void> _loadKnownProjects() async {
    final projects = await ref.read(projectServiceProvider).getKnownProjects();
    if (mounted) setState(() => _knownProjects = projects);
  }

  @override
  void dispose() {
    _controller.dispose();
    _projectController.dispose();
    super.dispose();
  }

  bool get _canSave => _controller.text.trim().isNotEmpty && !_saving;

  Future<void> _save() async {
    if (_controller.text.trim().isEmpty) {
      setState(() => _error = 'Description cannot be empty.');
      return;
    }
    if (!_canSave) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final dbService = ref.read(databaseServiceProvider).valueOrNull;
      if (dbService == null) {
        setState(() {
          _error = 'Database unavailable. Please try again.';
          _saving = false;
        });
        return;
      }

      final project = isWorkActivityType(_selectedType)
          ? _projectController.text.trim()
          : '';

      await dbService.updateDescription(
        widget.entry.id,
        _controller.text.trim(),
        activityType: _selectedType,
        project: Value(project.isEmpty ? null : project),
      );

      if (project.isNotEmpty) {
        await ref.read(projectServiceProvider).saveProject(project);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() {
        _error = 'Failed to save. Please try again.';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: theme.border)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Edit description',
                  style: TextStyle(
                    color: theme.text,
                    fontFamily: 'Sora',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: activityTypes.map((type) {
                    final isSelected = type == _selectedType;
                    final color = activityTypeColor(
                      type,
                      isDark: theme.themeKey != AppTheme.paper,
                    );
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.2)
                              : theme.panel,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? color : theme.border,
                          ),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            color: isSelected ? color : theme.text,
                            fontFamily: 'Sora',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (isWorkActivityType(_selectedType)) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.panel,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Autocomplete<String>(
                      textEditingController: _projectController,
                      optionsBuilder: (textEditingValue) {
                        final query = textEditingValue.text.trim().toLowerCase();
                        if (query.isEmpty) return _knownProjects;
                        return _knownProjects.where(
                          (p) => p.toLowerCase().contains(query),
                        );
                      },
                      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          style: TextStyle(color: theme.text, fontFamily: 'Sora', fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Project name...',
                            hintStyle: TextStyle(color: theme.faint, fontFamily: 'Sora'),
                            border: InputBorder.none,
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            color: theme.panel,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    title: Text(
                                      option,
                                      style: TextStyle(color: theme.text, fontFamily: 'Sora'),
                                    ),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: theme.panel,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.border),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: TextField(
                    controller: _controller,
                    maxLines: 4,
                    maxLength: 500,
                    autofocus: true,
                    style: TextStyle(
                        color: theme.text, fontFamily: 'Sora', fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Describe what you worked on...',
                      hintStyle:
                          TextStyle(color: theme.faint, fontFamily: 'Sora'),
                      border: InputBorder.none,
                      counterStyle:
                          TextStyle(color: theme.faint, fontSize: 11),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Colors.red[400],
                      fontFamily: 'Sora',
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _canSave ? _save : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accent,
                      foregroundColor: theme.ink,
                      disabledBackgroundColor:
                          theme.accent.withValues(alpha: 0.3),
                      disabledForegroundColor:
                          theme.ink.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _saving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: theme.ink,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Save',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: theme.ink,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
