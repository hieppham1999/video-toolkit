import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:video_toolkit/app/injection.dart';
import 'package:video_toolkit/core/i18n/app_language.dart';
import 'package:video_toolkit/core/theme/app_accent.dart';
import 'package:video_toolkit/core/theme/app_theme_mode.dart';
import 'package:video_toolkit/features/fonts_loader/data/models/font_info.dart';
import 'package:video_toolkit/features/fonts_loader/presentation/cubit/font_cubit.dart';
import 'package:video_toolkit/features/fonts_loader/presentation/cubit/font_state.dart';
import 'package:video_toolkit/features/app_settings/presentation/cubit/app_setting_cubit.dart';
import 'package:video_toolkit/features/video_encoding/data/models/output_directory_settings.dart';
import 'package:video_toolkit/app/base/bloc_state_builder.dart';

import 'macos/macos_settings_renderer.dart';
import 'settings_view_data.dart';
import 'windows/windows_settings_renderer.dart';

/// Shown as a sheet (macOS) or dialog (Windows). Edits are held as a local
/// draft so changes don't leak out (or persist) until the user clicks Save.
/// Closing via the title bar's close button discards the draft.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _settingCubit = getIt<AppSettingCubit>();

  late AppAccent _accent;
  late AppLanguage _language;
  late AppThemeMode _themeMode;
  String? _defaultFontPath;
  late OutputDirectorySettings _outputDirectory;

  @override
  void initState() {
    super.initState();
    final s = _settingCubit.currentData;
    _accent = s.accent;
    _language = s.language;
    _themeMode = s.themeMode;
    _defaultFontPath = s.defaultFontPath;
    _outputDirectory = s.outputDirectory;
  }

  void _save() {
    final s = _settingCubit.currentData;
    if (_accent != s.accent) _settingCubit.setAccent(_accent);
    if (_language != s.language) _settingCubit.setLanguage(_language);
    if (_themeMode != s.themeMode) _settingCubit.setThemeMode(_themeMode);
    if (_defaultFontPath != s.defaultFontPath) {
      _settingCubit.setDefaultFont(_defaultFontPath);
    }
    if (_outputDirectory != s.outputDirectory) {
      _settingCubit.setOutputDirectory(_outputDirectory);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CubitStateBuilder<FontState>(
      cubit: getIt<FontCubit>(),
      builder: (context, fontState) {
        final data = SettingsViewData(
          accent: _accent,
          language: _language,
          themeMode: _themeMode,
          defaultFontPath: _defaultFontPath,
          fonts: _filteredFonts(fontState.fonts),
          outputDirectory: _outputDirectory,
          onAccentChanged: (v) => setState(() => _accent = v),
          onLanguageChanged: (v) => setState(() => _language = v),
          onThemeModeChanged: (v) => setState(() => _themeMode = v),
          onDefaultFontChanged: (v) => setState(() => _defaultFontPath = v),
          onOutputDirectoryChanged: (v) =>
              setState(() => _outputDirectory = v),
          onClose: _save,
        );
        return Platform.isWindows
            ? WindowsSettingsRenderer(data: data)
            : MacosSettingsRenderer(data: data);
      },
    );
  }

  /// Only surface bundled fonts (shipped under `assets/fonts/`) as picker
  /// options — system fonts vary per machine and aren't guaranteed to exist
  /// when the setting is re-applied elsewhere.
  List<FontInfo> _filteredFonts(List<FontInfo> fonts) =>
      fonts.where((f) => f.isBundled).toList();
}
