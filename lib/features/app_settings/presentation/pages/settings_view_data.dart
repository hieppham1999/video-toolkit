import 'package:flutter/foundation.dart';
import 'package:video_toolkit/core/i18n/app_language.dart';
import 'package:video_toolkit/core/theme/app_accent.dart';
import 'package:video_toolkit/core/theme/app_theme_mode.dart';
import 'package:video_toolkit/features/fonts_loader/data/models/font_info.dart';
import 'package:video_toolkit/features/video_encoding/data/models/output_directory_settings.dart';

class SettingsViewData {
  const SettingsViewData({
    required this.accent,
    required this.language,
    required this.themeMode,
    required this.defaultFontPath,
    required this.fonts,
    required this.outputDirectory,
    required this.onAccentChanged,
    required this.onLanguageChanged,
    required this.onThemeModeChanged,
    required this.onDefaultFontChanged,
    required this.onOutputDirectoryChanged,
    required this.onClose,
  });

  final AppAccent accent;
  final AppLanguage language;
  final AppThemeMode themeMode;
  final String? defaultFontPath;
  final List<FontInfo> fonts;
  final OutputDirectorySettings outputDirectory;
  final ValueChanged<AppAccent> onAccentChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final ValueChanged<AppThemeMode> onThemeModeChanged;
  final ValueChanged<String?> onDefaultFontChanged;
  final ValueChanged<OutputDirectorySettings> onOutputDirectoryChanged;
  final VoidCallback onClose;
}
