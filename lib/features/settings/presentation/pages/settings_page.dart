import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:video_toolkit/app/injection.dart';
import 'package:video_toolkit/features/fonts/data/models/font_info.dart';
import 'package:video_toolkit/features/fonts/presentation/cubit/font_cubit.dart';
import 'package:video_toolkit/features/fonts/presentation/cubit/font_state.dart';
import 'package:video_toolkit/features/settings/presentation/cubit/app_setting_cubit.dart';
import 'package:video_toolkit/features/settings/presentation/cubit/app_setting_state.dart';
import 'package:video_toolkit/presentation/base/bloc_state_builder.dart';

import 'macos/macos_settings_renderer.dart';
import 'settings_view_data.dart';
import 'windows/windows_settings_renderer.dart';

/// Shown as a sheet (macOS) or dialog (Windows). All logic lives here; the
/// platform renderers are pure UI per the CLAUDE.md convention.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingCubit = getIt<AppSettingCubit>();
    return CubitStateBuilder<AppSettingState>(
      cubit: settingCubit,
      builder: (context, state) {
        return CubitStateBuilder<FontState>(
          cubit: getIt<FontCubit>(),
          builder: (context, fontState) {
            final data = SettingsViewData(
              accent: state.accent,
              language: state.language,
              themeMode: state.themeMode,
              defaultFontPath: state.defaultFontPath,
              fonts: _filteredFonts(fontState.fonts),
              onAccentChanged: settingCubit.setAccent,
              onLanguageChanged: settingCubit.setLanguage,
              onThemeModeChanged: settingCubit.setThemeMode,
              onDefaultFontChanged: settingCubit.setDefaultFont,
              onClose: () => Navigator.of(context).pop(),
            );
            return Platform.isWindows
                ? WindowsSettingsRenderer(data: data)
                : MacosSettingsRenderer(data: data);
          },
        );
      },
    );
  }

  /// Only surface bundled fonts (shipped under `assets/fonts/`) as picker
  /// options — system fonts vary per machine and aren't guaranteed to exist
  /// when the setting is re-applied elsewhere.
  List<FontInfo> _filteredFonts(List<FontInfo> fonts) =>
      fonts.where((f) => f.isBundled).toList();
}
