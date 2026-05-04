import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/app_info.dart';
import 'package:video_toolkit/core/i18n/app_language.dart';
import 'package:video_toolkit/core/theme/app_accent.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/core/theme/app_theme_mode.dart';
import 'package:video_toolkit/widgets/app_accent_swatch.dart';

import '../pages/settings_view_data.dart';
import 'output_directory_section.dart';

// ---------- Section ----------

class AppSettingsSection extends StatelessWidget {
  const AppSettingsSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      final theme = fluent.FluentTheme.of(context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.typography.bodyStrong),
          const SizedBox(height: 8),
          child,
        ],
      );
    }
    final theme = MacosTheme.of(context);
    final subtle = AppColors.textSecondary(theme.brightness);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.typography.body.copyWith(color: subtle)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

// ---------- Tabs ----------

class GeneralTab extends StatelessWidget {
  const GeneralTab({super.key, required this.data});
  final SettingsViewData data;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSettingsSection(
          title: l10n.language,
          child: AppLanguagePicker(data: data),
        ),
        const SizedBox(height: 20),
        AppSettingsSection(
          title: l10n.defaultFont,
          child: AppFontPicker(data: data),
        ),
      ],
    );
  }
}

class AppearanceTab extends StatelessWidget {
  const AppearanceTab({super.key, required this.data});
  final SettingsViewData data;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSettingsSection(
          title: l10n.theme,
          child: AppThemePicker(data: data),
        ),
        const SizedBox(height: 20),
        AppSettingsSection(
          title: l10n.accentColor,
          child: AppAccentRow(data: data),
        ),
      ],
    );
  }
}

class FileHandlingTab extends StatelessWidget {
  const FileHandlingTab({super.key, required this.data});
  final SettingsViewData data;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    return AppSettingsSection(
      title: l10n.outputDirectory,
      child: AppOutputDirectorySection(
        value: data.outputDirectory,
        onChanged: data.onOutputDirectoryChanged,
      ),
    );
  }
}

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final isWin = Platform.isWindows;
    final titleStyle = isWin
        ? fluent.FluentTheme.of(context).typography.subtitle
        : MacosTheme.of(context).typography.title2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppInfo.appName, style: titleStyle),
        const SizedBox(height: 24),
        _AboutRow(label: l10n.aboutVersion, value: AppInfo.version),
        const SizedBox(height: 12),
        _AboutRow(label: l10n.aboutAuthor, value: AppInfo.author),
      ],
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      final theme = fluent.FluentTheme.of(context);
      return Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: theme.typography.bodyStrong),
          ),
          Expanded(child: Text(value, style: theme.typography.body)),
        ],
      );
    }
    final theme = MacosTheme.of(context);
    final subtle = AppColors.textSecondary(theme.brightness);
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: theme.typography.body.copyWith(color: subtle),
          ),
        ),
        Expanded(child: Text(value, style: theme.typography.body)),
      ],
    );
  }
}

// ---------- Pickers ----------

class AppAccentRow extends StatelessWidget {
  const AppAccentRow({super.key, required this.data});
  final SettingsViewData data;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final a in AppAccent.values)
          AppAccentSwatch(
            accent: a,
            active: a == data.accent,
            onTap: () => data.onAccentChanged(a),
          ),
      ],
    );
  }
}

class AppLanguagePicker extends StatelessWidget {
  const AppLanguagePicker({super.key, required this.data});
  final SettingsViewData data;

  String _label(AppLanguage l) {
    final t = Languages.translate;
    switch (l) {
      case AppLanguage.system:
        return t.languageSystem;
      case AppLanguage.en:
        return t.languageEnglish;
      case AppLanguage.vi:
        return t.languageVietnamese;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return fluent.ComboBox<AppLanguage>(
        value: data.language,
        onChanged: (v) {
          if (v != null) data.onLanguageChanged(v);
        },
        items: [
          for (final l in AppLanguage.values)
            fluent.ComboBoxItem(value: l, child: Text(_label(l))),
        ],
      );
    }
    return MacosPopupButton<AppLanguage>(
      value: data.language,
      onChanged: (v) {
        if (v != null) data.onLanguageChanged(v);
      },
      items: [
        for (final l in AppLanguage.values)
          MacosPopupMenuItem(value: l, child: Text(_label(l))),
      ],
    );
  }
}

class AppThemePicker extends StatelessWidget {
  const AppThemePicker({super.key, required this.data});
  final SettingsViewData data;

  String _label(AppThemeMode m) {
    final t = Languages.translate;
    switch (m) {
      case AppThemeMode.system:
        return t.themeSystem;
      case AppThemeMode.light:
        return t.themeLight;
      case AppThemeMode.dark:
        return t.themeDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return fluent.ComboBox<AppThemeMode>(
        value: data.themeMode,
        onChanged: (v) {
          if (v != null) data.onThemeModeChanged(v);
        },
        items: [
          for (final m in AppThemeMode.values)
            fluent.ComboBoxItem(value: m, child: Text(_label(m))),
        ],
      );
    }
    return MacosPopupButton<AppThemeMode>(
      value: data.themeMode,
      onChanged: (v) {
        if (v != null) data.onThemeModeChanged(v);
      },
      items: [
        for (final m in AppThemeMode.values)
          MacosPopupMenuItem(value: m, child: Text(_label(m))),
      ],
    );
  }
}

class AppFontPicker extends StatelessWidget {
  const AppFontPicker({super.key, required this.data});
  final SettingsViewData data;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final value = data.defaultFontPath ?? '';
    void onChanged(String? v) =>
        data.onDefaultFontChanged((v == null || v.isEmpty) ? null : v);

    if (Platform.isWindows) {
      return fluent.ComboBox<String>(
        value: value,
        onChanged: onChanged,
        items: [
          fluent.ComboBoxItem(value: '', child: Text(l10n.fontDefault)),
          for (final f in data.fonts)
            fluent.ComboBoxItem(value: f.path, child: Text(f.name)),
        ],
      );
    }
    return MacosPopupButton<String>(
      value: value,
      onChanged: onChanged,
      items: [
        MacosPopupMenuItem(value: '', child: Text(l10n.fontDefault)),
        for (final f in data.fonts)
          MacosPopupMenuItem(value: f.path, child: Text(f.name)),
      ],
    );
  }
}
