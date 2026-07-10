import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../providers/theme_provider.dart';

class ThemeDots extends ConsumerWidget {
  const ThemeDots({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(themeProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: AppThemeData.all.map((t) {
        final isActive = t.themeKey == active.themeKey;
        return GestureDetector(
          onTap: () => ref.read(themeProvider.notifier).select(t),
          child: Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.accent,
              border: isActive
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
