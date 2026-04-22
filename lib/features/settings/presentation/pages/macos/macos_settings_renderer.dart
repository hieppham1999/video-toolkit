import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/i18n/app_language.dart';
import 'package:video_toolkit/core/theme/app_accent.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/features/settings/presentation/widgets/app_accent_swatch.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_button.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_dialog_title_bar.dart';

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
      child: SizedBox(
        width: 350,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section(
                context,
                title: l10n.appearance,
                child: _AccentRow(data: data),
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
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  size: AppButtonSize.large,
                  onPressed: data.onClose,
                  child: Text(l10n.save),
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
