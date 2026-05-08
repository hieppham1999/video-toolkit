import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';

/// Cross-platform icon-only button that inherits its color from the current
/// theme. Use for toolbar-style actions inside dialogs (copy, clear, close…)
/// where `AppToolbarButton` is overkill.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.macosIcon,
    required this.fluentIcon,
    required this.onPressed,
    this.size = 14,
    this.tooltip,
  });

  final IconData macosIcon;
  final IconData fluentIcon;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      final theme = fluent.FluentTheme.of(context);
      final enabled = onPressed != null;
      final color = enabled
          ? theme.accentColor
          : theme.resources.textFillColorDisabled;
      final btn = fluent.IconButton(
        icon: fluent.Icon(fluentIcon, size: size, color: color),
        onPressed: onPressed,
      );
      return tooltip == null ? btn : fluent.Tooltip(message: tooltip!, child: btn);
    }
    final theme = MacosTheme.of(context);
    final enabled = onPressed != null;
    final color = enabled
        ? theme.primaryColor
        : AppColors.textPrimary(theme.brightness).withValues(alpha: 0.4);
    return MacosIconButton(
      icon: MacosIcon(macosIcon, size: size, color: color),
      onPressed: onPressed,
    );
  }
}
