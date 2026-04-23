import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/injection.dart';
import 'package:video_toolkit/core/i18n/app_language.dart';
import 'package:video_toolkit/core/theme/app_accent.dart';
import 'package:video_toolkit/core/theme/app_theme_mode.dart';
import 'package:video_toolkit/features/settings/presentation/cubit/app_setting_cubit.dart';
import 'package:video_toolkit/features/settings/presentation/cubit/app_setting_state.dart';
import 'package:video_toolkit/generated/l10n/app_localizations.dart';
import 'package:video_toolkit/presentation/base/bloc_state_builder.dart';

import '../core/navigation/app_navigator.dart';
import '../core/navigation/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return CubitStateBuilder<AppSettingState>(
      cubit: getIt<AppSettingCubit>(),
      builder: (context, settings) {
        return Platform.isWindows
            ? _WindowsApp(
                accent: settings.accent,
                locale: settings.language.locale,
                themeMode: settings.themeMode,
              )
            : _MacosApp(
                accent: settings.accent,
                locale: settings.language.locale,
                themeMode: settings.themeMode,
              );
      },
    );
  }
}

class _WindowsApp extends StatelessWidget {
  const _WindowsApp({
    required this.accent,
    required this.locale,
    required this.themeMode,
  });

  final AppAccent accent;
  final Locale? locale;
  final AppThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final fluentAccent = accent.fluentAccent;
    return fluent.FluentApp(
      title: 'Video Toolkit',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigatorKey.key,
      onGenerateRoute: AppRouter.onGenerateRoute,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      themeMode: themeMode.flutterThemeMode,
      theme: fluent.FluentThemeData(
        accentColor: fluentAccent,
        brightness: Brightness.light,
      ),
      darkTheme: fluent.FluentThemeData(
        accentColor: fluentAccent,
        brightness: Brightness.dark,
      ),
    );
  }
}

MacosThemeData _macosTheme(MacosThemeData base, AppAccent accent) {
  // `PushButton` reads `MacosThemeData.accentColor` (AccentColor enum) — not
  // `primaryColor` — to pick its gradient. Set both so widgets that use
  // either source stay in sync.
  return base.copyWith(
    primaryColor: accent.color,
    accentColor: accent.macosAccent,
  );
}

class _MacosApp extends StatelessWidget {
  const _MacosApp({
    required this.accent,
    required this.locale,
    required this.themeMode,
  });

  final AppAccent accent;
  final Locale? locale;
  final AppThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: 'Video Toolkit',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigatorKey.key,
      onGenerateRoute: AppRouter.onGenerateRoute,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      themeMode: themeMode.flutterThemeMode,
      theme: _macosTheme(MacosThemeData.light(), accent),
      darkTheme: _macosTheme(MacosThemeData.dark(), accent),
    );
  }
}
