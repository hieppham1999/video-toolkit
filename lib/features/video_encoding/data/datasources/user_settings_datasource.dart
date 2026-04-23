import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_toolkit/core/i18n/app_language.dart';
import 'package:video_toolkit/core/theme/app_accent.dart';
import 'package:video_toolkit/core/theme/app_theme_mode.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/user_settings.dart';

/// Persists [UserSettings] (current encode settings + selected preset id) to
/// `<ApplicationSupportDirectory>/user_settings.json`. In-memory cache keeps
/// the last-known object so partial setters preserve unchanged fields.
@lazySingleton
class UserSettingsDatasource {
  UserSettings? _cache;

  Future<File> _file() async {
    final support = await getApplicationSupportDirectory();
    return File(p.join(support.path, 'user_settings.json'));
  }

  Future<UserSettings?> load() async {
    if (_cache != null) return _cache;
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      final text = await file.readAsString();
      if (text.trim().isEmpty) return null;
      final json = jsonDecode(text) as Map<String, dynamic>;
      _cache = UserSettings.fromJson(json);
      return _cache;
    } catch (e) {
      appLogger.w('UserSettingsDatasource: load failed: $e');
      return null;
    }
  }

  Future<void> save(UserSettings settings) async {
    _cache = settings;
    try {
      final file = await _file();
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(settings.toJson()),
      );
    } catch (e) {
      appLogger.w('UserSettingsDatasource: save failed: $e');
    }
  }

  Future<void> saveSelectedPresetId(String? id) async {
    final current = _cache ?? await load();
    final next = current == null
        ? UserSettings(selectedPresetId: id, encodeSettings: const EncodeSettings())
        : current.copyWith(selectedPresetId: id);
    await save(next);
  }

  Future<void> saveEncodeSettings(EncodeSettings settings) async {
    final current = _cache ?? await load();
    final next = current == null
        ? UserSettings(encodeSettings: settings)
        : current.copyWith(encodeSettings: settings);
    await save(next);
  }

  Future<void> saveDefaultFontPath(String? path) async {
    final current = _cache ?? await load();
    final next = current == null
        ? UserSettings(
            encodeSettings: const EncodeSettings(),
            defaultFontPath: path,
          )
        : current.copyWith(defaultFontPath: path);
    await save(next);
  }

  Future<void> saveAccentColor(AppAccent accent) async {
    final current = _cache ?? await load();
    final next = current == null
        ? UserSettings(
            encodeSettings: const EncodeSettings(),
            accentColor: accent,
          )
        : current.copyWith(accentColor: accent);
    await save(next);
  }

  Future<void> saveLanguage(AppLanguage language) async {
    final current = _cache ?? await load();
    final next = current == null
        ? UserSettings(
            encodeSettings: const EncodeSettings(),
            language: language,
          )
        : current.copyWith(language: language);
    await save(next);
  }

  Future<void> saveThemeMode(AppThemeMode mode) async {
    final current = _cache ?? await load();
    final next = current == null
        ? UserSettings(
            encodeSettings: const EncodeSettings(),
            themeMode: mode,
          )
        : current.copyWith(themeMode: mode);
    await save(next);
  }
}
