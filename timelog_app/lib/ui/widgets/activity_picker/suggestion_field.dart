import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/activity_types.dart';
import '../../../core/theme.dart';
import '../../../providers/task_providers.dart';

/// Autocomplete text field that suggests names of one [SuggestionScope].
///
/// Used for the project field and the custom name field of the entry sheets
/// and for the project name of the Tasks tab, so every place that suggests
/// names behaves the same. When [scope] changes the typed text is kept and the
/// suggestions of the new scope are offered.
class SuggestionField extends ConsumerWidget {
  final AppThemeData theme;
  final SuggestionScope scope;
  final String hint;
  final String initialText;
  final ValueChanged<String> onChanged;
  final bool autofocus;
  final int? maxLength;

  const SuggestionField({
    super.key,
    required this.theme,
    required this.scope,
    required this.hint,
    required this.initialText,
    required this.onChanged,
    this.autofocus = false,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names =
        ref.watch(suggestionsProvider(scope)).valueOrNull ?? const <String>[];

    return Container(
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Autocomplete<String>(
        initialValue: TextEditingValue(text: initialText),
        optionsBuilder: (textEditingValue) {
          final query = textEditingValue.text.trim().toLowerCase();
          if (query.isEmpty) return names;
          return names.where((n) => n.toLowerCase().contains(query));
        },
        onSelected: onChanged,
        fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            maxLength: maxLength,
            onChanged: onChanged,
            style: TextStyle(
              color: theme.text,
              fontFamily: 'Sora',
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: theme.faint, fontFamily: 'Sora'),
              border: InputBorder.none,
              counterStyle: TextStyle(color: theme.faint, fontSize: 11),
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
    );
  }
}
