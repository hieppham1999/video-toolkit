import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/i18n/app_language.dart';
import 'package:video_toolkit/core/theme/app_accent.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/core/theme/app_theme_mode.dart';
import 'package:video_toolkit/widgets/app_accent_swatch.dart';
import 'package:video_toolkit/widgets/app_button.dart';
import 'package:video_toolkit/widgets/app_dialog_title_bar.dart';

import '../../widgets/output_directory_section.dart';
import '../settings_view_data.dart';

class MacosSettingsRenderer extends StatelessWidget {
  const MacosSettingsRenderer({super.key, required this.data});

  final SettingsViewData data;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    return AppDialogTitleBar(
      title: Text(l10n.settings),
      shrinkWrap: true,
      draggable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 150, vertical: 80),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - 220,
        ),
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _section(
                        context,
                        title: l10n.appearance,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _AccentRow(data: data),
                            const SizedBox(height: 12),
                            _ThemeModeDropdown(data: data),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _section(
                        context,
                        title: l10n.outputDirectory,
                        child: AppOutputDirectorySection(
                          value: data.outputDirectory,
                          onChanged: data.onOutputDirectoryChanged,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _section(
                        context,
                        title: l10n.language,
                        child: _LanguageDropdown(data: data),
                      ),
                      const SizedBox(height: 20),
                      _section(
                        context,
                        title: l10n.defaultFont,
                        child: _DefaultFontDropdown(data: data),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    size: AppButtonSize.large,
                    onPressed: data.onClose,
                    child: Text(l10n.save),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
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

class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown({required this.data});
  final SettingsViewData data;

  @override
  Widget build(BuildContext context) {
    return MacosPopupButton<AppLanguage>(
      value: data.language,
      onChanged: (v) {
        if (v != null) data.onLanguageChanged(v);
      },
      items: [
        for (final l in AppLanguage.values)
          MacosPopupMenuItem(value: l, child: Text(_languageLabel(l))),
      ],
    );
  }

  String _languageLabel(AppLanguage l) {
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

class _ThemeModeDropdown extends StatelessWidget {
  const _ThemeModeDropdown({required this.data});
  final SettingsViewData data;

  @override
  Widget build(BuildContext context) {
    return MacosPopupButton<AppThemeMode>(
      value: data.themeMode,
      onChanged: (v) {
        if (v != null) data.onThemeModeChanged(v);
      },
      items: [
        for (final mode in AppThemeMode.values)
          MacosPopupMenuItem(value: mode, child: Text(_themeLabel(mode))),
      ],
    );
  }

  String _themeLabel(AppThemeMode mode) {
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

class _DefaultFontDropdown extends StatelessWidget {
  const _DefaultFontDropdown({required this.data});
  final SettingsViewData data;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final items = <MacosPopupMenuItem<String>>[
      MacosPopupMenuItem(value: '', child: Text(l10n.fontDefault)),
      for (final f in data.fonts)
        MacosPopupMenuItem(value: f.path, child: Text(f.name)),
    ];
    return MacosPopupButton<String>(
      value: data.defaultFontPath ?? '',
      onChanged: (v) =>
          data.onDefaultFontChanged((v == null || v.isEmpty) ? null : v),
      items: items,
    );
  }
}
