import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/activity_types.dart';
import '../../../core/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'subtype_block.dart';
import 'suggestion_field.dart';

/// Preference key of the last selected main type.
const lastActivityTypeKey = 'last_activity_type';

/// Preference key prefix of the last selected subtype of each main type.
const _lastSubtypeKeyPrefix = 'last_subtype_';

/// What the user has chosen in an [ActivityPicker].
@immutable
class ActivitySelection {
  const ActivitySelection({
    required this.typeKey,
    this.subtypeKey,
    this.project = '',
    this.customName = '',
  });

  final String typeKey;
  final String? subtypeKey;
  final String project;
  final String customName;

  ActivitySelection copyWith({
    String? typeKey,
    String? subtypeKey,
    bool clearSubtype = false,
    String? project,
    String? customName,
  }) {
    return ActivitySelection(
      typeKey: typeKey ?? this.typeKey,
      subtypeKey: clearSubtype ? null : (subtypeKey ?? this.subtypeKey),
      project: project ?? this.project,
      customName: customName ?? this.customName,
    );
  }

  /// The values to store in a time entry: a project only when the type has a
  /// project field, a custom name only when it has a custom name field, and a
  /// subtype only when the registry defines it for the type. Empty text is null.
  ({String? subtype, String? project, String? customName}) toRowValues() {
    final subtype = subtypeOf(typeKey, subtypeKey) != null ? subtypeKey : null;
    final projectText = project.trim();
    final nameText = customName.trim();
    return (
      subtype: subtype,
      project: hasProjectField(typeKey) && projectText.isNotEmpty
          ? projectText
          : null,
      customName: hasCustomNameField(typeKey) && nameText.isNotEmpty
          ? nameText
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ActivitySelection &&
      other.typeKey == typeKey &&
      other.subtypeKey == subtypeKey &&
      other.project == project &&
      other.customName == customName;

  @override
  int get hashCode => Object.hash(typeKey, subtypeKey, project, customName);
}

/// Shared type picker of the entry sheets: the main type chips, the subtype
/// block of the selected type and the project or custom name field.
///
/// [initial] comes from a draft or from the entry being edited; without it the
/// last used type and subtype are restored. [onChanged] is called with the
/// current selection whenever it changes, including once after the first build.
class ActivityPicker extends StatefulWidget {
  final AppThemeData theme;
  final ActivitySelection? initial;
  final ValueChanged<ActivitySelection> onChanged;
  final bool autofocusExtraField;

  const ActivityPicker({
    super.key,
    required this.theme,
    required this.onChanged,
    this.initial,
    this.autofocusExtraField = false,
  });

  @override
  State<ActivityPicker> createState() => _ActivityPickerState();
}

class _ActivityPickerState extends State<ActivityPicker> {
  late ActivitySelection _selection;
  final Map<String, String> _rememberedSubtypes = {};
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _selection = _resolve(
      widget.initial ?? ActivitySelection(typeKey: activityTypes.first),
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onChanged(_selection);
    });
    _loadMemory();
  }

  /// Fills in the subtype: the given one when valid, otherwise the remembered
  /// or the first one; none for a type without subtypes.
  ActivitySelection _resolve(ActivitySelection selection) {
    // An explicitly given valid subtype wins over the remembered one.
    final given = subtypeOf(selection.typeKey, selection.subtypeKey) != null
        ? selection.subtypeKey
        : null;
    return ActivitySelection(
      typeKey: selection.typeKey,
      subtypeKey:
          given ??
          defaultSubtypeKey(
            selection.typeKey,
            remembered: _rememberedSubtypes[selection.typeKey],
          ),
      project: selection.project,
      customName: selection.customName,
    );
  }

  Future<void> _loadMemory() async {
    final prefs = await SharedPreferences.getInstance();
    for (final type in activityRegistry) {
      final saved = prefs.getString('$_lastSubtypeKeyPrefix${type.key}');
      if (saved != null && subtypeOf(type.key, saved) != null) {
        _rememberedSubtypes[type.key] = saved;
      }
    }
    if (!mounted || _touched) return;

    final savedType = prefs.getString(lastActivityTypeKey);
    final typeKey =
        widget.initial?.typeKey ??
        (savedType != null && activityTypeOf(savedType) != null
            ? savedType
            : _selection.typeKey);
    final next = _resolve(
      ActivitySelection(
        typeKey: typeKey,
        subtypeKey: widget.initial?.subtypeKey,
        project: _selection.project,
        customName: _selection.customName,
      ),
    );
    if (next != _selection) {
      setState(() => _selection = next);
      widget.onChanged(_selection);
    }
  }

  Future<void> _selectType(String typeKey) async {
    _touched = true;
    setState(() {
      _selection = _resolve(
        ActivitySelection(
          typeKey: typeKey,
          project: _selection.project,
          customName: _selection.customName,
        ),
      );
    });
    widget.onChanged(_selection);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastActivityTypeKey, typeKey);
  }

  Future<void> _selectSubtype(String subtypeKey) async {
    _touched = true;
    _rememberedSubtypes[_selection.typeKey] = subtypeKey;
    setState(() => _selection = _selection.copyWith(subtypeKey: subtypeKey));
    widget.onChanged(_selection);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_lastSubtypeKeyPrefix${_selection.typeKey}',
      subtypeKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.themeKey != AppTheme.paper;
    final type = activityTypeOf(_selection.typeKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.pickerTypeCaption.toUpperCase(),
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
            for (final t in activityRegistry)
              _TypeChip(
                key: ValueKey('type-chip-${t.key}'),
                theme: theme,
                label: activityTypeLabel(l10n, t.key),
                color: activityMainColor(t.key, isDark: isDark),
                isSelected: t.key == _selection.typeKey,
                dashed: t.extra == TypeExtra.customName,
                onTap: () => _selectType(t.key),
              ),
          ],
        ),
        if (type != null && type.subtypes.isNotEmpty) ...[
          const SizedBox(height: 26),
          SubtypeBlock(
            theme: theme,
            type: type,
            selectedKey: _selection.subtypeKey,
            onSelected: _selectSubtype,
          ),
        ],
        if (type != null && type.extra != TypeExtra.none) ...[
          const SizedBox(height: 16),
          SuggestionField(
            key: ValueKey('${type.extra.name}-field'),
            theme: theme,
            scope:
                suggestionScopeOf(type.key, _selection.subtypeKey) ??
                SuggestionScope.workUnpaid,
            hint: type.extra == TypeExtra.customName
                ? l10n.customNameHint
                : l10n.projectNameHint,
            initialText: type.extra == TypeExtra.customName
                ? _selection.customName
                : _selection.project,
            autofocus: widget.autofocusExtraField,
            onChanged: (text) {
              _selection = type.extra == TypeExtra.customName
                  ? _selection.copyWith(customName: text)
                  : _selection.copyWith(project: text);
              widget.onChanged(_selection);
            },
          ),
        ],
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final AppThemeData theme;
  final String label;
  final Color color;
  final bool isSelected;
  final bool dashed;
  final VoidCallback onTap;

  const _TypeChip({
    super.key,
    required this.theme,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.dashed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? color : theme.border;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.2) : theme.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dashed ? Colors.transparent : borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? color : theme.text,
          fontFamily: 'Sora',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: dashed
            ? CustomPaint(
                foregroundPainter: _DashedBorderPainter(color: borderColor),
                child: chip,
              )
            : chip,
      ),
    );
  }
}

/// Draws a dashed rounded border, used for the free-form "Other" type chip.
class _DashedBorderPainter extends CustomPainter {
  final Color color;

  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rect = Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(20)));
    const dash = 4.0;
    const gap = 3.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            math.min(distance + dash, metric.length),
          ),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
