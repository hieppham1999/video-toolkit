import 'package:fluent_ui/fluent_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/i18n/app_language.dart';
import 'package:video_toolkit/core/theme/app_accent.dart';
import 'package:video_toolkit/core/theme/app_theme_mode.dart';
import 'package:video_toolkit/widgets/app_accent_swatch.dart';
import 'package:video_toolkit/widgets/app_button.dart';
import 'package:video_toolkit/widgets/app_dialog_title_bar.dart';

import '../../widgets/output_directory_section.dart';
import '../settings_view_data.dart';

class WindowsSettingsRenderer extends StatelessWidget {
  const WindowsSettingsRenderer({super.key, required this.data});

  final SettingsViewData data;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = Languages.translate;
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 560),
      title: AppDialogTitleBar(title: Text(l10n.settings)),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - 220,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _section(
                theme,
                l10n.appearance,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AccentRow(data: data),
                    const SizedBox(height: 12),
                    _ThemeModeCombo(data: data),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _section(
                theme,
                l10n.outputDirectory,
                AppOutputDirectorySection(
                  value: data.outputDirectory,
                  onChanged: data.onOutputDirectoryChanged,
                ),
              ),
              const SizedBox(height: 16),
              _section(theme, l10n.language, _LanguageCombo(data: data)),
              const SizedBox(height: 16),
              _section(theme, l10n.defaultFont, _DefaultFontCombo(data: data)),
            ],
          ),
        ),
      ),
      actions: [
        AppButton(onPressed: data.onClose, child: Text(l10n.save)),
      ],
    );
  }

  Widget _section(FluentThemeData theme, String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.typography.bodyStrong,
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _AccentRow extends StatelessWidget {
  const _AccentRow({required this.data});
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

class _LanguageCombo extends StatelessWidget {
  const _LanguageCombo({required this.data});
  final SettingsViewData data;

  @override
  Widget build(BuildContext context) {
    return ComboBox<AppLanguage>(
      value: data.language,
      onChanged: (v) {
        if (v != null) data.onLanguageChanged(v);
      },
      items: [
        for (final l in AppLanguage.values)
          ComboBoxItem(value: l, child: Text(_label(l))),
      ],
    );
  }

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
}

class _ThemeModeCombo extends StatelessWidget {
  const _ThemeModeCombo({required this.data});
  final SettingsViewData data;

  @override
  Widget build(BuildContext context) {
    return ComboBox<AppThemeMode>(
      value: data.themeMode,
      onChanged: (v) {
        if (v != null) data.onThemeModeChanged(v);
      },
      items: [
        for (final mode in AppThemeMode.values)
          ComboBoxItem(value: mode, child: Text(_label(mode))),
      ],
    );
  }

  String _label(AppThemeMode mode) {
    final t = Languages.translate;
    switch (mode) {
      case AppThemeMode.system:
        return t.themeSystem;
      case AppThemeMode.light:
        return t.themeLight;
      case AppThemeMode.dark:
        return t.themeDark;
    }
  }
}

class _DefaultFontCombo extends StatelessWidget {
  const _DefaultFontCombo({required this.data});
  final SettingsViewData data;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    return ComboBox<String>(
      value: data.defaultFontPath ?? '',
      onChanged: (v) =>
          data.onDefaultFontChanged((v == null || v.isEmpty) ? null : v),
      items: [
        ComboBoxItem(value: '', child: Text(l10n.fontDefault)),
        for (final f in data.fonts)
          ComboBoxItem(value: f.path, child: Text(f.name)),
      ],
    );
  }
}
