import 'package:injectable/injectable.dart';
import 'package:video_toolkit/core/i18n/app_language.dart';
import 'package:video_toolkit/core/theme/app_accent.dart';
import 'package:video_toolkit/core/theme/app_theme_mode.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_encoding/data/datasources/user_settings_datasource.dart';
import 'package:video_toolkit/features/video_encoding/data/models/output_directory_settings.dart';
import 'package:video_toolkit/app/base/base_cubit.dart';

import 'app_setting_state.dart';

/// Holds app-level preferences (accent, language, default font) reactively
/// for the widget tree. Persists via [UserSettingsDatasource] so the choice
/// survives restarts.
@lazySingleton
class AppSettingCubit extends BaseCubit<AppSettingState> {
  AppSettingCubit(this._datasource) : super.normal(const AppSettingState()) {
    _load();
  }

  final UserSettingsDatasource _datasource;

  Future<void> _load() async {
    try {
      final settings = await _datasource.load();
      if (settings == null) return;
      emitNormal(
        currentData.copyWith(
          accent: settings.accentColor,
          language: settings.language,
          themeMode: settings.themeMode,
          defaultFontPath: settings.defaultFontPath,
          outputDirectory: settings.outputDirectory,
        ),
      );
    } catch (e) {
      appLogger.w('AppSettingCubit: load failed: $e');
    }
  }

  Future<void> setAccent(AppAccent accent) async {
    emitNormal(currentData.copyWith(accent: accent));
    await _datasource.saveAccentColor(accent);
  }

  Future<void> setLanguage(AppLanguage language) async {
    emitNormal(currentData.copyWith(language: language));
    await _datasource.saveLanguage(language);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    emitNormal(currentData.copyWith(themeMode: mode));
    await _datasource.saveThemeMode(mode);
  }

  Future<void> setDefaultFont(String? path) async {
    emitNormal(currentData.copyWith(defaultFontPath: path));
    await _datasource.saveDefaultFontPath(path);
  }

  Future<void> setOutputDirectory(OutputDirectorySettings settings) async {
    emitNormal(currentData.copyWith(outputDirectory: settings));
    await _datasource.saveOutputDirectory(settings);
  }
}
