import 'package:flutter/material.dart';

enum AppTheme { ember, midnight, paper }

class AppThemeData {
  final String name;
  final AppTheme themeKey;
  final Color background;
  final Color text;
  final Color accent;
  final Color ink;
  final Color panel;
  final Color border;
  final Color track;
  final Color dim;
  final Color faint;
  final Color glow;
  final Color glowSoft;

  const AppThemeData({
    required this.name,
    required this.themeKey,
    required this.background,
    required this.text,
    required this.accent,
    required this.ink,
    required this.panel,
    required this.border,
    required this.track,
    required this.dim,
    required this.faint,
    required this.glow,
    required this.glowSoft,
  });

  static const ember = AppThemeData(
    name: 'Ember',
    themeKey: AppTheme.ember,
    background: Color(0xFF1A1310),
    text: Color(0xFFEEE6DC),
    accent: Color(0xFFE88A66),
    ink: Color(0xFF1A120E),
    panel: Color(0x0BFFFFFF),
    border: Color(0x14FFFFFF),
    track: Color(0x12FFFFFF),
    dim: Color(0x8CEEE6DC),
    faint: Color(0x66EEE6DC),
    glow: Color(0x80E88A66),
    glowSoft: Color(0x99E88A66),
  );

  static const midnight = AppThemeData(
    name: 'Midnight',
    themeKey: AppTheme.midnight,
    background: Color(0xFF0F1319),
    text: Color(0xFFE6EAF2),
    accent: Color(0xFF78B4C4),
    ink: Color(0xFF08131A),
    panel: Color(0x0BFFFFFF),
    border: Color(0x1AFFFFFF),
    track: Color(0x14FFFFFF),
    dim: Color(0x8CE6EAF2),
    faint: Color(0x66E6EAF2),
    glow: Color(0x8078B4C4),
    glowSoft: Color(0x9978B4C4),
  );

  static const paper = AppThemeData(
    name: 'Paper',
    themeKey: AppTheme.paper,
    background: Color(0xFFF3EEE6),
    text: Color(0xFF2B2420),
    accent: Color(0xFFC25E3C),
    ink: Color(0xFFFBF7F1),
    panel: Color(0x0B000000),
    border: Color(0x14000000),
    track: Color(0x12000000),
    dim: Color(0x8C2B2420),
    faint: Color(0x662B2420),
    glow: Color(0x80C25E3C),
    glowSoft: Color(0x99C25E3C),
  );

  static const List<AppThemeData> all = [ember, midnight, paper];

  static AppThemeData fromKey(AppTheme key) {
    switch (key) {
      case AppTheme.ember:
        return ember;
      case AppTheme.midnight:
        return midnight;
      case AppTheme.paper:
        return paper;
    }
  }

  ThemeData toMaterialTheme() {
    return ThemeData(
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.dark(
        surface: background,
        primary: accent,
        onSurface: text,
        onPrimary: ink,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: text, fontFamily: 'Sora'),
        bodyMedium: TextStyle(color: text, fontFamily: 'Sora'),
        bodySmall: TextStyle(color: dim, fontFamily: 'Sora'),
        labelLarge: TextStyle(color: text, fontFamily: 'Sora'),
      ),
      fontFamily: 'Sora',
      dividerColor: border,
    );
  }
}
