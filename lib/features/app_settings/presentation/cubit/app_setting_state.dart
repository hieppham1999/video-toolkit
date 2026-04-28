import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_toolkit/core/i18n/app_language.dart';
import 'package:video_toolkit/core/theme/app_accent.dart';
import 'package:video_toolkit/core/theme/app_theme_mode.dart';
import 'package:video_toolkit/features/video_encoding/data/models/output_directory_settings.dart';

part 'generated/app_setting_state.freezed.dart';

@freezed
abstract class AppSettingState with _$AppSettingState {
  const factory AppSettingState({
    @Default(AppAccent.blue) AppAccent accent,
    @Default(AppLanguage.system) AppLanguage language,
    @Default(AppThemeMode.system) AppThemeMode themeMode,
    String? defaultFontPath,
    @Default(OutputDirectorySettings()) OutputDirectorySettings outputDirectory,
  }) = _AppSettingState;
}
