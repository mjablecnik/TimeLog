import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/generated/app_localizations.dart';

/// SharedPreferences key used to persist the user's explicit language
/// choice ('en' or 'cs'). Absent means "follow system locale" — see
/// [localeProvider] in `providers/locale_provider.dart`.
const String kLanguagePrefKey = 'app_language';

/// Parses a persisted language code into a [Locale], or `null` if [code] is
/// missing/unrecognized (meaning "follow system locale").
Locale? localeFromCode(String? code) {
  switch (code) {
    case 'en':
      return const Locale('en');
    case 'cs':
      return const Locale('cs');
    default:
      return null;
  }
}

/// Loads an [AppLocalizations] instance for background/non-widget-tree code
/// (notification builders, scheduling services) that has no `BuildContext`.
/// Reads the persisted language choice directly from SharedPreferences and
/// falls back to English when none was explicitly chosen.
Future<AppLocalizations> loadAppLocalizations() async {
  final prefs = await SharedPreferences.getInstance();
  final locale = localeFromCode(prefs.getString(kLanguagePrefKey)) ?? const Locale('en');
  return lookupAppLocalizations(locale);
}
