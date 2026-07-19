import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/activity_types.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import '../../providers/database_provider.dart';
import '../../providers/history_provider.dart' show logicalDay;

class ManualEntrySheet extends ConsumerStatefulWidget {
  final AppThemeData theme;
  final DateTime selectedDay;

  const ManualEntrySheet({
    super.key,
    required this.theme,
    required this.selectedDay,
  });

  @override
  ConsumerState<ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends ConsumerState<ManualEntrySheet> {
  final _controller = TextEditingController();
  TextEditingController? _projectController;
  String _selectedType = activityTypes.first;
  String? _entertainmentType;
  late DateTime _startTime;
  late DateTime _endTime;
  String? _error;
  bool _saving = false;
  List<String> _knownProjects = [];

  @override
  void initState() {
    super.initState();
    _initDefaultTimes();
    _loadKnownProjects();
  }

  Future<void> _initDefaultTimes() async {
    final day = widget.selectedDay;
    final now = DateTime.now();
    final today = logicalDay(now);
    final isToday =
        day.year == today.year && day.month == today.month && day.day == today.day;

    // Synchronous fallback so the `late` fields are set before the first
    // build; overwritten below if a prior entry is found for this day.
    if (isToday) {
      final dayStart = DateTime(day.year, day.month, day.day);
      _endTime = now;
      final defaultStart = now.subtract(const Duration(minutes: 30));
      _startTime = defaultStart.isBefore(dayStart) ? dayStart : defaultStart;
    } else {
      _startTime = DateTime(day.year, day.month, day.day, 12, 0);
      _endTime = DateTime(day.year, day.month, day.day, 12, 30);
    }

    List<TimeEntry> entries;
    try {
      final dbService = await ref.read(databaseServiceProvider.future);
      entries = await dbService.getEntriesForDay(day);
    } catch (_) {
      return;
    }
    if (!mounted || entries.isEmpty) return;

    final lastEndTime = entries
        .map((e) => DateTime.parse(e.endTime))
        .reduce((a, b) => a.isAfter(b) ? a : b);

    setState(() {
      _startTime = lastEndTime;
      if (isToday) {
        _endTime = now.isBefore(lastEndTime) ? lastEndTime : now;
      } else {
        final dayEnd = DateTime(day.year, day.month, day.day, 23, 59);
        final defaultEnd = lastEndTime.add(const Duration(minutes: 30));
        _endTime = defaultEnd.isAfter(dayEnd) ? dayEnd : defaultEnd;
      }
    });
  }

  Future<void> _loadKnownProjects() async {
    final projects = await ref.read(projectServiceProvider).getKnownProjects();
    if (mounted) setState(() => _knownProjects = projects);
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static const _timeOrderError = 'End time must be after start time.';

  Future<void> _pickTime(bool isStart) async {
    final current = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked == null) return;
    setState(() {
      final day = widget.selectedDay;
      final updated = DateTime(
        day.year,
        day.month,
        day.day,
        picked.hour,
        picked.minute,
      );
      if (isStart) {
        _startTime = updated;
      } else {
        _endTime = updated;
      }
      if (!_endTime.isAfter(_startTime)) {
        _error = _timeOrderError;
      } else if (_error == _timeOrderError) {
        _error = null;
      }
    });
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
    if (_controller.text.trim().isEmpty) {
      setState(() => _error = 'Description cannot be empty.');
      return;
    }
    if (!_endTime.isAfter(_startTime)) {
      setState(() => _error = _timeOrderError);
      return;
    }
    if (!_canSubmit) return;

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
      final entertainmentType = isEntertainmentActivityType(_selectedType)
          ? _entertainmentType
          : null;

      await dbService.insertTimeEntry(
        TimeEntriesCompanion(
          startTime: Value(_startTime.toIso8601String()),
          endTime: Value(_endTime.toIso8601String()),
          description: Value(_controller.text.trim()),
          activityType: Value(_selectedType),
          project: Value(project.isEmpty ? null : project),
          entertainmentType: Value(entertainmentType),
        ),
      );

      if (project.isNotEmpty) {
        await ref.read(projectServiceProvider).saveProject(project);
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

    return GestureDetector(
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
                    Text(
                      'Add entry',
                      style: TextStyle(
                        color: theme.text,
                        fontFamily: 'Sora',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _TimeField(
                            theme: theme,
                            label: 'Start',
                            time: _formatTime(_startTime),
                            onTap: () => _pickTime(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TimeField(
                            theme: theme,
                            label: 'End',
                            time: _formatTime(_endTime),
                            onTap: () => _pickTime(false),
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
                          onTap: () => setState(() {
                            _selectedType = type;
                            if (!isEntertainmentActivityType(type)) {
                              _entertainmentType = null;
                            }
                          }),
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
                            onTap: () =>
                                setState(() => _entertainmentType = type),
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
                                type,
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
                    if (isWorkActivityType(_selectedType)) ...[
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.panel,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.border),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Autocomplete<String>(
                          optionsBuilder: (textEditingValue) {
                            final query =
                                textEditingValue.text.trim().toLowerCase();
                            if (query.isEmpty) return _knownProjects;
                            return _knownProjects.where(
                              (p) => p.toLowerCase().contains(query),
                            );
                          },
                          fieldViewBuilder:
                              (context, controller, focusNode, onSubmitted) {
                            _projectController = controller;
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              style: TextStyle(
                                  color: theme.text,
                                  fontFamily: 'Sora',
                                  fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Project name...',
                                hintStyle: TextStyle(
                                    color: theme.faint, fontFamily: 'Sora'),
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
                                  constraints:
                                      const BoxConstraints(maxHeight: 200),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(
                                          option,
                                          style: TextStyle(
                                              color: theme.text,
                                              fontFamily: 'Sora'),
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
                        onPressed: _canSubmit ? _submit : null,
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
                                'Submit',
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: theme.ink,
                                ),
                              ),
                      ),
                    ),
                    TextButton(
                      onPressed:
                          _saving ? null : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.dim,
                      ),
                      child: Text(
                        'Cancel',
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
    );
  }
}

class _TimeField extends StatelessWidget {
  final AppThemeData theme;
  final String label;
  final String time;
  final VoidCallback onTap;

  const _TimeField({
    required this.theme,
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.faint,
                fontFamily: 'Sora',
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: TextStyle(
                color: theme.text,
                fontFamily: 'Sora',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
