import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';

/// Cross-platform tappable chip showing a preset value. Highlights when
/// [active] to indicate the current selection.
class AppPresetChip extends StatelessWidget {
  const AppPresetChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return _FluentPresetChip(label: label, active: active, onTap: onTap);
    }
    return _MacosPresetChip(label: label, active: active, onTap: onTap);
  }
}

class _MacosPresetChip extends StatelessWidget {
  const _MacosPresetChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final b = theme.brightness;
    final Color bg;
    final Color fg;
    if (active) {
      bg = theme.primaryColor;
      fg = const Color(0xFFFFFFFF);
    } else {
      bg = AppColors.surfaceElevated(b);
      fg = AppColors.textPrimary(b);
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          color: bg,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.typography.caption1.copyWith(
            color: fg,
            height: 1.0,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _FluentPresetChip extends StatelessWidget {
  const _FluentPresetChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    final Color bg = active ? theme.accentColor : theme.cardColor;
    final Color fg = active
        ? const Color(0xFFFFFFFF)
        : theme.resources.textFillColorPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          color: bg,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.typography.caption?.copyWith(
            color: fg,
            height: 1.0,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
