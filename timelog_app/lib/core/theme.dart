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
    background: Color(0xFF0D1117),
    text: Color(0xFFE6EDF3),
    accent: Color(0xFF58A6FF),
    ink: Color(0xFF0D1117),
    panel: Color(0x0BFFFFFF),
    border: Color(0x1AFFFFFF),
    track: Color(0x14FFFFFF),
    dim: Color(0x8CE6EDF3),
    faint: Color(0x66E6EDF3),
    glow: Color(0x8058A6FF),
    glowSoft: Color(0x9958A6FF),
  );

  static const paper = AppThemeData(
    name: 'Paper',
    themeKey: AppTheme.paper,
    background: Color(0xFFF5F0EB),
    text: Color(0xFF2C2420),
    accent: Color(0xFF9B4523),
    ink: Color(0xFFF5F0EB),
    panel: Color(0x0B000000),
    border: Color(0x14000000),
    track: Color(0x12000000),
    dim: Color(0x8C2C2420),
    faint: Color(0x662C2420),
    glow: Color(0x809B4523),
    glowSoft: Color(0x999B4523),
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
