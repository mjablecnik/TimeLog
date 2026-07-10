import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';

const _themeKey = 'selected_theme';

class ThemeNotifier extends StateNotifier<AppThemeData> {
  ThemeNotifier() : super(AppThemeData.ember) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeKey);
    if (saved != null) {
      final key = AppTheme.values.where((e) => e.name == saved).firstOrNull;
      if (key != null) state = AppThemeData.fromKey(key);
    }
  }

  Future<void> select(AppThemeData themeData) async {
    state = themeData;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeData.themeKey.name);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeData>(
  (_) => ThemeNotifier(),
);
