import 'package:flutter/material.dart' show ThemeMode;

/// User-facing theme choice. `system` defers to the OS appearance; the others
/// force a specific brightness on both `MacosApp` and `FluentApp`.
enum AppThemeMode { system, light, dark }

extension AppThemeModeX on AppThemeMode {
  /// Mapped to Flutter's [ThemeMode] for `MacosApp.themeMode` /
  /// `FluentApp.themeMode`.
  ThemeMode get flutterThemeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  String get labelKey {
    switch (this) {
      case AppThemeMode.system:
        return 'themeSystem';
      case AppThemeMode.light:
        return 'themeLight';
      case AppThemeMode.dark:
        return 'themeDark';
    }
  }
}
