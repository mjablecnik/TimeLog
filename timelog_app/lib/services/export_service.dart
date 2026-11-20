import 'dart:io';
import 'dart:ui' show Rect;

import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database.dart';
import '../data/database_export.dart';

/// Writes all app data to one JSON file and hands it to the system share sheet.
class ExportService {
  ExportService(
    this._db, {
    DateTime Function()? now,
    Future<String> Function()? appVersion,
  }) : _now = now ?? DateTime.now,
       _appVersion = appVersion ?? _platformVersion;

  final AppDatabase _db;
  final DateTime Function() _now;
  final Future<String> Function() _appVersion;

  static Future<String> _platformVersion() async =>
      (await PackageInfo.fromPlatform()).version;

  /// The export as JSON text and the file name it is saved under.
  Future<({String fileName, String json})> build() async {
    final now = _now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final json = await exportDataAsJson(
      _db,
      preferences: <String, Object?>{
        for (final key in prefs.getKeys()) key: prefs.get(key),
      },
      appVersion: await _appVersion(),
      exportedAt: now,
    );
    return (fileName: 'timelog-export-${_date(now)}.json', json: json);
  }

  /// Writes the export to the temporary directory and opens the share sheet.
  ///
  /// [origin] is where the sheet anchors on iPad; iPhone ignores it.
  Future<void> shareExport({Rect? origin}) async {
    final export = await build();
    final directory = await getTemporaryDirectory();
    final file = File(p.join(directory.path, export.fileName));
    await file.writeAsString(export.json, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(file.path)],
        sharePositionOrigin: origin,
      ),
    );
  }

  static String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
