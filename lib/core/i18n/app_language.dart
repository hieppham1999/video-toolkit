import 'dart:ui';

/// User-facing language choice. `system` defers to the OS locale; the others
/// force a specific [Locale] on both `MacosApp` and `FluentApp`.
enum AppLanguage { system, en, vi }

extension AppLanguageX on AppLanguage {
  /// `null` means "follow system" (pass directly as `MacosApp/FluentApp.locale`).
  Locale? get locale {
    switch (this) {
      case AppLanguage.system:
        return null;
      case AppLanguage.en:
        return const Locale('en');
      case AppLanguage.vi:
        return const Locale('vi');
    }
  }

  String get labelKey {
    switch (this) {
      case AppLanguage.system:
        return 'languageSystem';
      case AppLanguage.en:
        return 'languageEnglish';
      case AppLanguage.vi:
        return 'languageVietnamese';
    }
  }
}
