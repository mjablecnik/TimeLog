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
import 'activity_picker/activity_picker.dart';

const _lastSubmittedDescriptionKey = 'last_submitted_description';
const _lastSubmittedActivityTypeKey = 'last_submitted_activity_type';
const _lastSubmittedProjectKey = 'last_submitted_project';
const _lastSubmittedSubtypeKey = 'last_submitted_subtype';
const _lastSubmittedCustomNameKey = 'last_submitted_custom_name';

class DescriptionSheet extends ConsumerStatefulWidget {
  final AppThemeData theme;
  final DateTime sessionStart;
  final DateTime endedAt;
  final String? initialDescription;
  final String? initialActivityType;
  final String? initialProject;
  final String? initialSubtype;
  final String? initialCustomName;
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
    this.initialSubtype,
    this.initialCustomName,
    this.triggeredByStop = false,
    this.isPrefillMode = false,
  });

  @override
  ConsumerState<DescriptionSheet> createState() => _DescriptionSheetState();
}

class _DescriptionSheetState extends ConsumerState<DescriptionSheet> {
  final _controller = TextEditingController();
  String? _error;
  bool _saving = false;

  /// Selection the picker starts from; null lets the picker restore the last
  /// used type. Replaced when the last submitted entry is loaded or the form
  /// is cleared.
  ActivitySelection? _initialSelection;
  late ActivitySelection _selection;

  /// Bumped to rebuild the picker with a new initial selection.
  int _pickerGeneration = 0;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialDescription ?? '';
    final initialType = widget.initialActivityType;
    if (initialType != null) {
      _initialSelection = ActivitySelection(
        typeKey: initialType,
        subtypeKey: widget.initialSubtype,
        project: widget.initialProject ?? '',
        customName: widget.initialCustomName ?? '',
      );
    }
    _selection = _initialSelection ?? ActivitySelection(typeKey: activityTypes.first);
    if (!widget.isPrefillMode && widget.initialDescription == null) {
      _loadLastSubmitted();
    }
  }

  Future<void> _loadLastSubmitted() async {
    final prefs = await SharedPreferences.getInstance();
    final description = prefs.getString(_lastSubmittedDescriptionKey);
    final activityType = prefs.getString(_lastSubmittedActivityTypeKey);
    final project = prefs.getString(_lastSubmittedProjectKey);
    final subtype = prefs.getString(_lastSubmittedSubtypeKey);
    final customName = prefs.getString(_lastSubmittedCustomNameKey);
    if (!mounted) return;
    setState(() {
      if (description != null) _controller.text = description;
      if (activityType != null && activityTypeOf(activityType) != null) {
        _initialSelection = ActivitySelection(
          typeKey: activityType,
          subtypeKey: subtype,
          project: project ?? '',
          customName: customName ?? '',
        );
        _selection = _initialSelection!;
        _pickerGeneration++;
      }
    });
  }

  void _resetForm() {
    setState(() {
      _controller.clear();
      _initialSelection = ActivitySelection(typeKey: activityTypes.first);
      _selection = _initialSelection!;
      _pickerGeneration++;
    });
  }

  Future<void> _saveLastSubmitted(
    String description,
    ActivitySelection selection,
  ) async {
    final values = selection.toRowValues();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSubmittedDescriptionKey, description);
    await prefs.setString(_lastSubmittedActivityTypeKey, selection.typeKey);
    await prefs.setString(_lastSubmittedProjectKey, values.project ?? '');
    await prefs.setString(_lastSubmittedSubtypeKey, values.subtype ?? '');
    await prefs.setString(_lastSubmittedCustomNameKey, values.customName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// `Ostatní` needs a name to be submitted (Skip still saves without one).
  bool get _customNameMissing =>
      hasCustomNameField(_selection.typeKey) && _selection.customName.trim().isEmpty;

  bool get _canSubmit =>
      _controller.text.trim().isNotEmpty && !_saving && !_customNameMissing;

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
    final values = _selection.toRowValues();
    notifier.savePrefill(
      _controller.text.trim(),
      _selection.typeKey,
      project: values.project,
      subtype: values.subtype,
      customName: values.customName,
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

      final values = _selection.toRowValues();

      await dbService.insertTimeEntry(
        TimeEntriesCompanion(
          startTime: Value(widget.sessionStart.toIso8601String()),
          endTime: Value(widget.endedAt.toIso8601String()),
          description: Value(description),
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

      await _saveLastSubmitted(description, _selection);

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
                  ActivityPicker(
                    key: ValueKey(_pickerGeneration),
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
                      onPressed: _saving ? null : _skip,
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
