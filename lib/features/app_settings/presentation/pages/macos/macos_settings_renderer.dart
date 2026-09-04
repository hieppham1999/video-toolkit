import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/widgets/app_button.dart';
import 'package:video_toolkit/widgets/app_dialog_title_bar.dart';

import '../../widgets/app_settings_sidebar.dart';
import '../../widgets/settings_tabs.dart';
import '../settings_view_data.dart';

class MacosSettingsRenderer extends StatefulWidget {
  const MacosSettingsRenderer({super.key, required this.data});

  final SettingsViewData data;

  @override
  State<MacosSettingsRenderer> createState() => _MacosSettingsRendererState();
}

class _MacosSettingsRendererState extends State<MacosSettingsRenderer> {
  AppSettingsTab _selectedTab = AppSettingsTab.general;

  Widget _tabBody() {
    switch (_selectedTab) {
      case AppSettingsTab.general:
        return GeneralTab(data: widget.data);
      case AppSettingsTab.appearance:
        return AppearanceTab(data: widget.data);
      case AppSettingsTab.about:
        return const AboutTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final theme = MacosTheme.of(context);
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
          width: 620,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppSettingsSidebar(
                      selected: _selectedTab,
                      onSelect: (t) => setState(() => _selectedTab = t),
                    ),
                    Container(
                      width: 1,
                      color: AppColors.divider(theme.brightness),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: _tabBody(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: AppColors.divider(theme.brightness)),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    size: AppButtonSize.large,
                    onPressed: widget.data.onClose,
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
}
