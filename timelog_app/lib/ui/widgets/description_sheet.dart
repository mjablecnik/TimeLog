import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/activity_types.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import '../../providers/database_provider.dart';
import '../../providers/timer_provider.dart';

const _lastActivityTypeKey = 'last_activity_type';

class DescriptionSheet extends ConsumerStatefulWidget {
  final AppThemeData theme;
  final DateTime sessionStart;
  final DateTime endedAt;
  final String? initialDescription;
  final String? initialActivityType;
  final String? initialProject;
  final bool triggeredByStop;
  final bool isPrefillMode;

  const DescriptionSheet({
    super.key,
    required this.theme,
    required this.sessionStart,
    required this.endedAt,
    this.initialDescription,
    this.initialActivityType,
    this.initialProject,
    this.triggeredByStop = false,
    this.isPrefillMode = false,
  });

  @override
  ConsumerState<DescriptionSheet> createState() => _DescriptionSheetState();
}

class _DescriptionSheetState extends ConsumerState<DescriptionSheet> {
  final _controller = TextEditingController();
  TextEditingController? _projectController;
  String? _error;
  bool _saving = false;
  late String _selectedType;
  List<String> _knownProjects = [];
  String _initialProject = '';

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialDescription ?? '';
    _initialProject = widget.initialProject ?? '';
    _selectedType = widget.initialActivityType ?? activityTypes.first;
    if (widget.initialActivityType == null) {
      _loadLastActivityType();
    }
    _loadKnownProjects();
  }

  Future<void> _loadKnownProjects() async {
    final projects = await ref.read(projectServiceProvider).getKnownProjects();
    if (mounted) setState(() => _knownProjects = projects);
  }

  Future<void> _loadLastActivityType() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_lastActivityTypeKey);
    if (saved != null && activityTypes.contains(saved) && mounted) {
      setState(() => _selectedType = saved);
    }
  }

  Future<void> _selectType(String type) async {
    setState(() => _selectedType = type);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastActivityTypeKey, type);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSubmit => _controller.text.trim().isNotEmpty && !_saving;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    if (widget.isPrefillMode) {
      await _savePrefillAndResume();
    } else {
      await _saveEntry(_controller.text.trim());
    }
  }

  Future<void> _skip() async {
    if (_saving) return;
    await _saveEntry('');
  }

  Future<void> _savePrefillAndResume() async {
    setState(() => _saving = true);
    final notifier = ref.read(timerProvider.notifier);
    final project = isWorkActivityType(_selectedType)
        ? _projectController?.text.trim()
        : null;
    notifier.savePrefill(_controller.text.trim(), _selectedType, project: project);
    notifier.resume();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _saveEntry(String description) async {
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
          ? (_projectController?.text.trim() ?? '')
          : '';

      await dbService.insertTimeEntry(
        TimeEntriesCompanion(
          startTime: Value(widget.sessionStart.toIso8601String()),
          endTime: Value(widget.endedAt.toIso8601String()),
          description: Value(description),
          activityType: Value(_selectedType),
          project: Value(project.isEmpty ? null : project),
        ),
      );

      if (project.isNotEmpty) {
        await ref.read(projectServiceProvider).saveProject(project);
      }

      if (widget.triggeredByStop) {
        ref.read(timerProvider.notifier).stop();
      } else {
        ref.read(timerProvider.notifier).autoRestart();
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() {
        _error = 'Failed to save entry. Please try again.';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: false,
      child: Container(
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
                    'What did you accomplish?',
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
                        onTap: () => _selectType(type),
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
                        initialValue: TextEditingValue(text: _initialProject),
                        optionsBuilder: (textEditingValue) {
                          final query = textEditingValue.text.trim().toLowerCase();
                          if (query.isEmpty) return _knownProjects;
                          return _knownProjects.where(
                            (p) => p.toLowerCase().contains(query),
                          );
                        },
                        fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                          _projectController = controller;
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: TextField(
                      controller: _controller,
                      maxLines: 4,
                      maxLength: 500,
                      autofocus: true,
                      style: TextStyle(color: theme.text, fontFamily: 'Sora', fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Describe what you worked on...',
                        hintStyle: TextStyle(color: theme.faint, fontFamily: 'Sora'),
                        border: InputBorder.none,
                        counterStyle: TextStyle(color: theme.faint, fontSize: 11),
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
                      onPressed: _canSubmit ? _submit : null,
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
                              widget.isPrefillMode ? 'Save Draft' : 'Submit',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: theme.ink,
                              ),
                            ),
                    ),
                  ),
                  if (!widget.isPrefillMode)
                    TextButton(
                      onPressed: _saving ? null : _skip,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.dim,
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: theme.dim,
                        ),
                      ),
                    ),
                  if (widget.isPrefillMode)
                    TextButton(
                      onPressed: _saving ? null : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.dim,
                      ),
                      child: Text(
                        'Zrušit',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: theme.dim,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
