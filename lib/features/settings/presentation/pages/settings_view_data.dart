import 'package:flutter/foundation.dart';
import 'package:video_toolkit/core/i18n/app_language.dart';
import 'package:video_toolkit/core/theme/app_accent.dart';
import 'package:video_toolkit/features/fonts/data/models/font_info.dart';

class SettingsViewData {
  const SettingsViewData({
    required this.accent,
    required this.language,
    required this.defaultFontPath,
    required this.fonts,
    required this.onAccentChanged,
    required this.onLanguageChanged,
    required this.onDefaultFontChanged,
    required this.onClose,
  });

  final AppAccent accent;
  final AppLanguage language;
  final String? defaultFontPath;
  final List<FontInfo> fonts;
  final ValueChanged<AppAccent> onAccentChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final ValueChanged<String?> onDefaultFontChanged;
  final VoidCallback onClose;
}
