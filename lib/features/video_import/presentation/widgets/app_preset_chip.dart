import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    final Color bg;
    final Color fg;
    if (active) {
      bg = theme.primaryColor;
      fg = const Color(0xFFFFFFFF);
    } else {
      bg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
      fg = isDark ? const Color(0xFFE5E5EA) : const Color(0xFF1C1C1E);
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: bg,
        ),
        child: Text(
          label,
          style: theme.typography.caption1.copyWith(color: fg),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: bg,
        ),
        child: Text(
          label,
          style: theme.typography.caption?.copyWith(color: fg),
        ),
      ),
    );
  }
}
