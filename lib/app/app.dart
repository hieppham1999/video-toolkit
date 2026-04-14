import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/generated/l10n/app_localizations.dart';

import '../core/navigation/app_navigator.dart';
import '../core/navigation/app_router.dart';
import '../features/video_import/presentation/cubit/video_import_cubit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoImportCubit(),
      child: Platform.isWindows ? const _WindowsApp() : const _MacosApp(),
    );
  }
}

class _WindowsApp extends StatelessWidget {
  const _WindowsApp();

  @override
  Widget build(BuildContext context) {
    return fluent.FluentApp(
      title: 'Video Toolkit',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigatorKey.key,
      onGenerateRoute: AppRouter.onGenerateRoute,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: fluent.FluentThemeData(
        accentColor: fluent.Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: fluent.FluentThemeData(
        accentColor: fluent.Colors.blue,
        brightness: Brightness.dark,
      ),
    );
  }
}

class _MacosApp extends StatelessWidget {
  const _MacosApp();

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: 'Video Toolkit',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigatorKey.key,
      onGenerateRoute: AppRouter.onGenerateRoute,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
    );
  }
}
