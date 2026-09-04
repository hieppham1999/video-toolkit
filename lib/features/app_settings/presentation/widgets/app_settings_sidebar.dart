import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';

enum AppSettingsTab { general, appearance, about }

class AppSettingsSidebar extends StatelessWidget {
  const AppSettingsSidebar({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final AppSettingsTab selected;
  final ValueChanged<AppSettingsTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Platform.isWindows
        ? _FluentSidebar(selected: selected, onSelect: onSelect)
        : _MacosSidebar(selected: selected, onSelect: onSelect);
  }
}

class _SidebarItem {
  const _SidebarItem(this.tab, this.macIcon, this.fluentIcon, this.label);
  final AppSettingsTab tab;
  final IconData macIcon;
  final IconData fluentIcon;
  final String label;
}

List<_SidebarItem> _items() {
  final l10n = Languages.translate;
  return [
    _SidebarItem(
      AppSettingsTab.general,
      CupertinoIcons.gear,
      fluent.FluentIcons.settings,
      l10n.settingsTabGeneral,
    ),
    _SidebarItem(
      AppSettingsTab.appearance,
      CupertinoIcons.paintbrush,
      fluent.FluentIcons.color,
      l10n.appearance,
    ),
    _SidebarItem(
      AppSettingsTab.about,
      CupertinoIcons.info_circle,
      fluent.FluentIcons.info,
      l10n.settingsTabAbout,
    ),
  ];
}

class _MacosSidebar extends StatelessWidget {
  const _MacosSidebar({required this.selected, required this.onSelect});
  final AppSettingsTab selected;
  final ValueChanged<AppSettingsTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return SizedBox(
      width: 160,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in _items())
              _MacosRow(
                item: item,
                active: item.tab == selected,
                onTap: () => onSelect(item.tab),
                theme: theme,
              ),
          ],
        ),
      ),
    );
  }
}

class _MacosRow extends StatelessWidget {
  const _MacosRow({
    required this.item,
    required this.active,
    required this.onTap,
    required this.theme,
  });

  final _SidebarItem item;
  final bool active;
  final VoidCallback onTap;
  final MacosThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final bg = active
        ? (isDark ? const Color(0x33FFFFFF) : const Color(0x14000000))
        : null;
    final fg = active
        ? AppColors.textPrimary(theme.brightness)
        : AppColors.textSecondary(theme.brightness);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            children: [
              MacosIcon(item.macIcon, size: 16, color: fg),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  style: theme.typography.body.copyWith(color: fg),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FluentSidebar extends StatelessWidget {
  const _FluentSidebar({required this.selected, required this.onSelect});
  final AppSettingsTab selected;
  final ValueChanged<AppSettingsTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in _items())
              _FluentRow(
                item: item,
                active: item.tab == selected,
                onTap: () => onSelect(item.tab),
              ),
          ],
        ),
      ),
    );
  }
}

class _FluentRow extends StatelessWidget {
  const _FluentRow({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _SidebarItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    final activeBg = theme.resources.subtleFillColorSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: fluent.HoverButton(
        onPressed: onTap,
        builder: (context, states) {
          final bg = active
              ? activeBg
              : (states.isHovered
                    ? theme.resources.subtleFillColorTertiary
                    : null);
          return Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                fluent.Icon(item.fluentIcon, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.label,
                    style: theme.typography.body,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
