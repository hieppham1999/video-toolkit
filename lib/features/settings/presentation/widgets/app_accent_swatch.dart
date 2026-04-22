import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/core/theme/app_accent.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';

/// Circular accent swatch with an active ring. Uses platform theme colours
/// for the ring/inactive border so it blends on both macOS and Windows.
class AppAccentSwatch extends StatelessWidget {
  const AppAccentSwatch({
    super.key,
    required this.accent,
    required this.active,
    required this.onTap,
    this.size = 28,
  });

  final AppAccent accent;
  final bool active;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final brightness = brightnessOf(context);
    final ringColor = Platform.isWindows
        ? fluent.FluentTheme.of(context).accentColor
        : MacosTheme.of(context).primaryColor;
    final inactiveBorder = AppColors.divider(brightness);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size + 8,
        height: size + 8,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? ringColor : inactiveBorder,
            width: active ? 2 : 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: accent.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
