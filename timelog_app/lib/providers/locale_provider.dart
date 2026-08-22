import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_locale.dart';

/// The app's current explicit language choice, or `null` to follow the
/// system locale (resolved by [MaterialApp.localeResolutionCallback]).
/// Persisted to SharedPreferences under [kLanguagePrefKey] as `'en'`/`'cs'`;
/// absent when the user hasn't made an explicit choice.
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final locale = localeFromCode(prefs.getString(kLanguagePrefKey));
    if (locale != null) state = locale;
  }

  Future<void> select(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kLanguagePrefKey, locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (_) => LocaleNotifier(),
);
