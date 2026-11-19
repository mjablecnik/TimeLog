import 'package:flutter/material.dart';

import '../../../core/activity_types.dart';
import '../../../core/theme.dart';
import '../../../l10n/generated/app_localizations.dart';

/// The framed block that holds the subtype chips of the selected main type.
///
/// It is drawn in the colour of the main type and has its own heading and hint,
/// so the choice cannot be overlooked next to the main type chips above it.
class SubtypeBlock extends StatelessWidget {
  final AppThemeData theme;
  final ActivityType type;
  final String? selectedKey;
  final ValueChanged<String> onSelected;

  const SubtypeBlock({
    super.key,
    required this.theme,
    required this.type,
    required this.selectedKey,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.themeKey != AppTheme.paper;
    final mainColor = activityMainColor(type.key, isDark: isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: mainColor.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mainColor.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  '↳ ${l10n.pickerSubtypeHeading(activityTypeLabel(l10n, type.key))}',
                  style: TextStyle(
                    color: mainColor,
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.pickerSubtypeHint,
                style: TextStyle(
                  color: theme.dim,
                  fontFamily: 'Sora',
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final subtype in type.subtypes)
                _SubtypeChip(
                  key: ValueKey('subtype-chip-${subtype.key}'),
                  theme: theme,
                  label: subtypeLabel(l10n, type.key, subtype.key),
                  color: isDark ? subtype.dark : subtype.light,
                  isSelected: subtype.key == selectedKey,
                  onTap: () => onSelected(subtype.key),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubtypeChip extends StatelessWidget {
  final AppThemeData theme;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubtypeChip({
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
