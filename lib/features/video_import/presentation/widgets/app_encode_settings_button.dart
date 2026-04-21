import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';

/// Toolbar button for opening the encode settings dialog. Shows the currently
/// selected preset name underneath the icon, with a trailing `*` when the
/// current settings differ from the preset's saved settings.
class AppEncodeSettingsButton extends StatelessWidget {
  const AppEncodeSettingsButton({
    super.key,
    required this.onTap,
    required this.presetName,
    required this.modified,
  });

  final VoidCallback onTap;
  final String? presetName;
  final bool modified;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return _FluentBtn(
        onTap: onTap,
        presetName: presetName,
        modified: modified,
      );
    }
    return _MacosBtn(
      onTap: onTap,
      presetName: presetName,
      modified: modified,
    );
  }
}

String _subLabel(String? presetName, bool modified) {
  final name = presetName ?? Languages.translate.noPresetSelected;
  return modified ? '$name*' : name;
}

class _MacosBtn extends StatelessWidget {
  const _MacosBtn({
    required this.onTap,
    required this.presetName,
    required this.modified,
  });

  final VoidCallback onTap;
  final String? presetName;
  final bool modified;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Match the colors used for other ToolBarIconButtons in the toolbar.
    final iconColor = isDark ? const Color(0xFFE5E5EA) : const Color(0xFF3A3A3C);
    final subtleColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
    final l10n = Languages.translate;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MacosIcon(
              CupertinoIcons.slider_horizontal_3,
              color: iconColor,
              size: 30,
            ),
            const SizedBox(height: 2),
            Text(
              l10n.encodeSettings,
              style: theme.typography.caption1.copyWith(color: iconColor),
            ),
            Text(
              _subLabel(presetName, modified),
              style: theme.typography.caption2.copyWith(color: subtleColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _FluentBtn extends StatelessWidget {
  const _FluentBtn({
    required this.onTap,
    required this.presetName,
    required this.modified,
  });

  final VoidCallback onTap;
  final String? presetName;
  final bool modified;

  @override
  Widget build(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    final l10n = Languages.translate;
    final subtleColor = theme.resources.textFillColorSecondary;

    return fluent.Button(
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const fluent.Icon(fluent.FluentIcons.settings, size: 14),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.encodeSettings),
              Text(
                _subLabel(presetName, modified),
                style: theme.typography.caption?.copyWith(color: subtleColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
