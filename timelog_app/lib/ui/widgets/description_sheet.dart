import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/activity_types.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/database_provider.dart';
import '../../providers/task_providers.dart';
import '../../providers/timer_provider.dart';

const _lastActivityTypeKey = 'last_activity_type';
const _lastEntertainmentTypeKey = 'last_entertainment_type';
const _lastSubmittedDescriptionKey = 'last_submitted_description';
const _lastSubmittedActivityTypeKey = 'last_submitted_activity_type';
const _lastSubmittedProjectKey = 'last_submitted_project';
const _lastSubmittedEntertainmentTypeKey = 'last_submitted_entertainment_type';

class DescriptionSheet extends ConsumerStatefulWidget {
  final AppThemeData theme;
  final DateTime sessionStart;
  final DateTime endedAt;
  final String? initialDescription;
  final String? initialActivityType;
  final String? initialProject;
  final String? initialEntertainmentType;
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
    this.initialEntertainmentType,
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
  String? _entertainmentType;
  List<String> _knownProjects = [];
  String _initialProject = '';

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialDescription ?? '';
    _initialProject = widget.initialProject ?? '';
    _selectedType = widget.initialActivityType ?? activityTypes.first;
    _entertainmentType = widget.initialEntertainmentType;
    if (!widget.isPrefillMode && widget.initialDescription == null) {
      _loadLastSubmitted();
    } else if (widget.initialActivityType == null) {
      _loadLastActivityType();
    }
    _loadKnownProjects();
  }

  Future<void> _loadKnownProjects() async {
    final projects = await ref.read(autocompleteProjectsProvider.future);
    if (mounted) setState(() => _knownProjects = projects);
  }

  Future<void> _loadLastActivityType() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_lastActivityTypeKey);
    if (saved != null && activityTypes.contains(saved) && mounted) {
      final savedEntertainment = prefs.getString(_lastEntertainmentTypeKey);
      setState(() {
        _selectedType = saved;
        if (isEntertainmentActivityType(saved) &&
            savedEntertainment != null &&
            entertainmentTypes.contains(savedEntertainment)) {
          _entertainmentType = savedEntertainment;
        }
      });
    }
  }

  Future<void> _loadLastSubmitted() async {
    final prefs = await SharedPreferences.getInstance();
    final description = prefs.getString(_lastSubmittedDescriptionKey);
    final activityType = prefs.getString(_lastSubmittedActivityTypeKey);
    final project = prefs.getString(_lastSubmittedProjectKey);
    final entertainmentType = prefs.getString(_lastSubmittedEntertainmentTypeKey);
    if (!mounted) return;
    setState(() {
      if (description != null) _controller.text = description;
      if (activityType != null && activityTypes.contains(activityType)) {
        _selectedType = activityType;
      }
      if (project != null) {
        _initialProject = project;
        _projectController?.text = project;
      }
      if (entertainmentType != null && entertainmentTypes.contains(entertainmentType)) {
        _entertainmentType = entertainmentType;
      }
    });
  }

  void _resetForm() {
    setState(() {
      _controller.clear();
      _selectedType = activityTypes.first;
      _initialProject = '';
      _entertainmentType = null;
    });
    _projectController?.clear();
  }

  Future<void> _selectType(String type) async {
    setState(() {
      _selectedType = type;
      if (!isEntertainmentActivityType(type)) _entertainmentType = null;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastActivityTypeKey, type);
  }

  Future<void> _selectEntertainmentType(String type) async {
    setState(() => _entertainmentType = type);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastEntertainmentTypeKey, type);
  }

  Future<void> _saveLastSubmitted(
    String description,
    String activityType,
    String project,
    String entertainmentType,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSubmittedDescriptionKey, description);
    await prefs.setString(_lastSubmittedActivityTypeKey, activityType);
    await prefs.setString(_lastSubmittedProjectKey, project);
    await prefs.setString(_lastSubmittedEntertainmentTypeKey, entertainmentType);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _entertainmentSelectionMissing =>
      isEntertainmentActivityType(_selectedType) && _entertainmentType == null;

  bool get _canSubmit =>
      _controller.text.trim().isNotEmpty && !_saving && !_entertainmentSelectionMissing;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    if (widget.isPrefillMode) {
      await _savePrefillAndResume();
    } else {
      await _saveEntry(_controller.text.trim());
    }
  }

  Future<void> _skip() async {
    if (_saving || _entertainmentSelectionMissing) return;

    final elapsed = widget.endedAt.difference(widget.sessionStart);
    if (elapsed.inSeconds < 120) {
      // Less than 2 minutes — discard without saving.
      if (widget.triggeredByStop) {
        ref.read(timerProvider.notifier).stop();
      } else {
        ref.read(timerProvider.notifier).autoRestart();
      }
      if (mounted) Navigator.of(context).pop();
      return;
    }

    await _saveEntry('');
  }

  Future<void> _savePrefillAndResume() async {
    setState(() => _saving = true);
    final notifier = ref.read(timerProvider.notifier);
    final project = hasProjectField(_selectedType)
        ? _projectController?.text.trim()
        : null;
    final entertainmentType = isEntertainmentActivityType(_selectedType)
        ? _entertainmentType
        : null;
    notifier.savePrefill(
      _controller.text.trim(),
      _selectedType,
      project: project,
      entertainmentType: entertainmentType,
    );
    notifier.resume();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _saveEntry(String description) async {
    setState(() {
      _saving = true;
      _error = null;
    });

    final l10n = AppLocalizations.of(context)!;
    try {
      final dbService = ref.read(databaseServiceProvider).valueOrNull;
      if (dbService == null) {
        setState(() {
          _error = l10n.errorDatabaseUnavailable;
          _saving = false;
        });
        return;
      }

      final project = hasProjectField(_selectedType)
          ? (_projectController?.text.trim() ?? '')
          : '';
      final entertainmentType = isEntertainmentActivityType(_selectedType)
          ? (_entertainmentType ?? '')
          : '';

      await dbService.insertTimeEntry(
        TimeEntriesCompanion(
          startTime: Value(widget.sessionStart.toIso8601String()),
          endTime: Value(widget.endedAt.toIso8601String()),
          description: Value(description),
          activityType: Value(_selectedType),
          project: Value(project.isEmpty ? null : project),
          entertainmentType: Value(entertainmentType.isEmpty ? null : entertainmentType),
        ),
      );

      if (project.isNotEmpty) {
        await ref.read(projectServiceProvider).saveProject(project);
      }

      await _saveLastSubmitted(description, _selectedType, project, entertainmentType);

      if (widget.triggeredByStop) {
        ref.read(timerProvider.notifier).stop();
      } else {
        ref.read(timerProvider.notifier).autoRestart();
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() {
        _error = l10n.errorSaveEntryFailed;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.descriptionTitle,
                          style: TextStyle(
                            color: theme.text,
                            fontFamily: 'Sora',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: _saving ? null : _resetForm,
                          icon: Icon(Icons.restart_alt, color: theme.dim),
                          tooltip: l10n.descriptionClearFormTooltip,
                        ),
                      ),
                    ],
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
                            activityTypeLabel(l10n, type),
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
                  if (hasProjectField(_selectedType)) ...[
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
                              hintText: l10n.projectNameHint,
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
                  if (isEntertainmentActivityType(_selectedType)) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entertainmentTypes.map((type) {
                        final isSelected = type == _entertainmentType;
                        final color = activityTypeColor(
                          _selectedType,
                          isDark: theme.themeKey != AppTheme.paper,
                        );
                        return GestureDetector(
                          onTap: () => _selectEntertainmentType(type),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withValues(alpha: 0.2)
                                  : theme.panel,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? color : theme.border,
                              ),
                            ),
                            child: Text(
                              entertainmentTypeLabel(l10n, type),
                              style: TextStyle(
                                color: isSelected ? color : theme.text,
                                fontFamily: 'Sora',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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
                        hintText: l10n.descriptionHint,
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
                              widget.isPrefillMode ? l10n.prefillSaveDraft : l10n.commonSubmit,
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
                      onPressed: (_saving || _entertainmentSelectionMissing) ? null : _skip,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.dim,
                      ),
                      child: Text(
                        l10n.commonSkip,
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
                        l10n.commonCancel,
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
      ),
      ),
    );
  }
}
