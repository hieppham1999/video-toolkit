import 'package:fluent_ui/fluent_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/widgets/app_button.dart';
import 'package:video_toolkit/widgets/app_dialog_title_bar.dart';

import '../../widgets/app_settings_sidebar.dart';
import '../../widgets/settings_tabs.dart';
import '../settings_view_data.dart';

class WindowsSettingsRenderer extends StatefulWidget {
  const WindowsSettingsRenderer({super.key, required this.data});

  final SettingsViewData data;

  @override
  State<WindowsSettingsRenderer> createState() =>
      _WindowsSettingsRendererState();
}

class _WindowsSettingsRendererState extends State<WindowsSettingsRenderer> {
  AppSettingsTab _selectedTab = AppSettingsTab.general;

  Widget _tabBody() {
    switch (_selectedTab) {
      case AppSettingsTab.general:
        return GeneralTab(data: widget.data);
      case AppSettingsTab.appearance:
        return AppearanceTab(data: widget.data);
      case AppSettingsTab.fileHandling:
        return FileHandlingTab(data: widget.data);
      case AppSettingsTab.about:
        return const AboutTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = Languages.translate;
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 720),
      title: AppDialogTitleBar(title: Text(l10n.settings)),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - 220,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSettingsSidebar(
                selected: _selectedTab,
                onSelect: (t) => setState(() => _selectedTab = t),
              ),
              Container(
                width: 1,
                color: theme.resources.dividerStrokeColorDefault,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
                  child: _tabBody(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        AppButton(onPressed: widget.data.onClose, child: Text(l10n.save)),
      ],
    );
  }
}
