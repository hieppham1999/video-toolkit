import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/features/video_encoding/data/models/settings_preset.dart';

/// A row in the preset sidebar. Highlights when [active], shows a lock
/// icon for built-in presets, and uses platform-native styling for hover
/// + selected backgrounds.
class AppPresetTile extends StatefulWidget {
  const AppPresetTile({
    super.key,
    required this.preset,
    required this.active,
    required this.onTap,
  });

  final SettingsPreset preset;
  final bool active;
  final VoidCallback onTap;

  @override
  State<AppPresetTile> createState() => _AppPresetTileState();
}

class _AppPresetTileState extends State<AppPresetTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isWindows = Platform.isWindows;
    final Color? bg;
    final TextStyle? textStyle;
    final Widget? lockIcon;
    final BorderRadius radius;

    if (isWindows) {
      final theme = fluent.FluentTheme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      final subtle = theme.resources.textFillColorSecondary;
      if (widget.active) {
        bg = theme.accentColor.withValues(alpha: isDark ? 0.35 : 0.2);
      } else if (_hovered) {
        bg = theme.resources.subtleFillColorSecondary;
      } else {
        bg = null;
      }
      textStyle = theme.typography.body?.copyWith(
        fontWeight: widget.active ? FontWeight.w600 : FontWeight.normal,
      );
      lockIcon = widget.preset.isBuiltIn
          ? fluent.Icon(fluent.FluentIcons.lock, size: 11, color: subtle)
          : null;
      radius = BorderRadius.circular(4);
    } else {
      final theme = MacosTheme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      final subtle =
          isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
      final accent = theme.primaryColor;
      if (widget.active) {
        bg = accent.withValues(alpha: isDark ? 0.35 : 0.22);
      } else if (_hovered) {
        bg = isDark ? const Color(0x22FFFFFF) : const Color(0x11000000);
      } else {
        bg = null;
      }
      textStyle = theme.typography.body.copyWith(
        fontWeight: widget.active ? FontWeight.w600 : FontWeight.normal,
      );
      lockIcon = widget.preset.isBuiltIn
          ? MacosIcon(CupertinoIcons.lock_fill, size: 11, color: subtle)
          : null;
      radius = BorderRadius.circular(6);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(color: bg, borderRadius: radius),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.preset.name,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ),
              if (lockIcon != null) lockIcon,
            ],
          ),
        ),
      ),
    );
  }
}
