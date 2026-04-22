import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';

/// Cross-platform monospace tag chip (e.g. `{year}`) tappable to insert
/// into a template field.
class AppTagChip extends StatelessWidget {
  const AppTagChip({super.key, required this.tag, required this.onTap});

  final String tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return _FluentTagChip(tag: tag, onTap: onTap);
    }
    return _MacosTagChip(tag: tag, onTap: onTap);
  }
}

class _MacosTagChip extends StatelessWidget {
  const _MacosTagChip({required this.tag, required this.onTap});

  final String tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppColors.surfaceElevated(theme.brightness),
        ),
        child: Text(
          tag,
          style: theme.typography.caption1.copyWith(fontFamily: 'monospace'),
        ),
      ),
    );
  }
}

class _FluentTagChip extends StatelessWidget {
  const _FluentTagChip({required this.tag, required this.onTap});

  final String tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: theme.cardColor,
        ),
        child: Text(
          tag,
          style: theme.typography.caption?.copyWith(fontFamily: 'monospace'),
        ),
      ),
    );
  }
}
