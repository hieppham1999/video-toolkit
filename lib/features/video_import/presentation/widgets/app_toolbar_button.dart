import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

/// Toolbar button shared between macOS and Windows. Layout: icon on top,
/// label below, optional sub-label. No frame/border — relies on hover state
/// for affordance on Windows. Fixed total height keeps icons vertically
/// aligned regardless of whether a sub-label is present.
class AppToolbarButton extends StatelessWidget {
  const AppToolbarButton({
    super.key,
    required this.macosIcon,
    required this.fluentIcon,
    required this.label,
    required this.onTap,
    this.subLabel,
    this.tooltip,
  });

  final IconData macosIcon;
  final IconData fluentIcon;
  final String label;
  final String? subLabel;
  final VoidCallback? onTap;
  final String? tooltip;

  static const double height = 68;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return _FluentToolbarBtn(
        icon: fluentIcon,
        label: label,
        subLabel: subLabel,
        onTap: onTap,
        tooltip: tooltip,
      );
    }
    return _MacosToolbarBtn(
      icon: macosIcon,
      label: label,
      subLabel: subLabel,
      onTap: onTap,
    );
  }
}

class _MacosToolbarBtn extends StatelessWidget {
  const _MacosToolbarBtn({
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? const Color(0xFFE5E5EA) : const Color(0xFF3A3A3C);
    final subtleColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
    final enabled = onTap != null;
    final effectiveIconColor = enabled ? iconColor : iconColor.withValues(alpha: 0.4);
    final effectiveLabelColor = enabled ? iconColor : iconColor.withValues(alpha: 0.5);

    return SizedBox(
      height: AppToolbarButton.height,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              MacosIcon(icon, color: effectiveIconColor, size: 30),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.typography.caption1.copyWith(color: effectiveLabelColor),
              ),
              if (subLabel != null)
                Text(
                  subLabel!,
                  style: theme.typography.caption2.copyWith(color: subtleColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FluentToolbarBtn extends StatefulWidget {
  const _FluentToolbarBtn({
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final String label;
  final String? subLabel;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  State<_FluentToolbarBtn> createState() => _FluentToolbarBtnState();
}

class _FluentToolbarBtnState extends State<_FluentToolbarBtn> {
  bool _hovering = false;
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    final enabled = widget.onTap != null;
    final iconColor = enabled
        ? theme.resources.textFillColorPrimary
        : theme.resources.textFillColorDisabled;
    final labelColor = iconColor;
    final subtleColor = theme.resources.textFillColorSecondary;

    Color? bg;
    if (enabled) {
      if (_pressing) {
        bg = theme.resources.subtleFillColorTertiary;
      } else if (_hovering) {
        bg = theme.resources.subtleFillColorSecondary;
      }
    }

    Widget content = SizedBox(
      height: AppToolbarButton.height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            fluent.Icon(widget.icon, size: 24, color: iconColor),
            const SizedBox(height: 2),
            Text(
              widget.label,
              style: theme.typography.caption?.copyWith(color: labelColor),
            ),
            if (widget.subLabel != null)
              Text(
                widget.subLabel!,
                style: theme.typography.caption?.copyWith(color: subtleColor),
              ),
          ],
        ),
      ),
    );

    if (widget.tooltip != null) {
      content = fluent.Tooltip(message: widget.tooltip!, child: content);
    }

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() {
        _hovering = false;
        _pressing = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _pressing = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressing = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressing = false) : null,
        onTap: widget.onTap,
        child: content,
      ),
    );
  }
}
