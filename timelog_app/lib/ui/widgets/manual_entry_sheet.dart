import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/activity_types.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/database_provider.dart';
import '../../providers/task_providers.dart';
import '../../providers/history_provider.dart' show logicalDay;
import 'activity_picker/activity_picker.dart';

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
  // New manual entries start with the first type; the subtype is restored by
  // the picker from the last one used for that type.
  final _initialSelection = ActivitySelection(typeKey: activityTypes.first);
  late ActivitySelection _selection = _initialSelection;
  late DateTime _startTime;
  late DateTime _endTime;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _initDefaultTimes();
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

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime(bool isStart) async {
    final l10n = AppLocalizations.of(context)!;
    final timeOrderError = l10n.errorEndBeforeStart;
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
        _error = timeOrderError;
      } else if (_error == timeOrderError) {
        _error = null;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _customNameMissing =>
      hasCustomNameField(_selection.typeKey) && _selection.customName.trim().isEmpty;

  bool get _canSubmit =>
      _controller.text.trim().isNotEmpty && !_saving && !_customNameMissing;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_controller.text.trim().isEmpty) {
      setState(() => _error = l10n.errorDescriptionEmpty);
      return;
    }
    if (!_endTime.isAfter(_startTime)) {
      setState(() => _error = l10n.errorEndBeforeStart);
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
          _error = l10n.errorDatabaseUnavailable;
          _saving = false;
        });
        return;
      }

      final values = _selection.toRowValues();

      await dbService.insertTimeEntry(
        TimeEntriesCompanion(
          startTime: Value(_startTime.toIso8601String()),
          endTime: Value(_endTime.toIso8601String()),
          description: Value(_controller.text.trim()),
          activityType: Value(_selection.typeKey),
          project: Value(values.project),
          subtype: Value(values.subtype),
          customName: Value(values.customName),
        ),
      );

      final scope = suggestionScopeOf(_selection.typeKey, values.subtype);
      final name = values.project ?? values.customName;
      if (scope != null && name != null) {
        await ref.read(projectServiceProvider).saveName(scope, name);
        ref.invalidate(suggestionsProvider);
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
                      l10n.manualEntryTitle,
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
                            label: l10n.timeFieldStart,
                            time: _formatTime(_startTime),
                            onTap: () => _pickTime(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TimeField(
                            theme: theme,
                            label: l10n.timeFieldEnd,
                            time: _formatTime(_endTime),
                            onTap: () => _pickTime(false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ActivityPicker(
                      theme: theme,
                      initial: _initialSelection,
                      onChanged: (selection) => setState(() => _selection = selection),
                    ),
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
                          hintText: l10n.descriptionHint,
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
                                l10n.commonSubmit,
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
