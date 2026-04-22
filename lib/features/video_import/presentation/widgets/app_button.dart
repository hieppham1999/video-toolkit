import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

/// Cross-platform action button.
///
/// - macOS: `PushButton`. Its gradient is driven by `MacosThemeData.accentColor`
///   (an `AccentColor` enum) — so app-wide accent changes come from setting
///   that field on the theme, not from per-button `color:`.
/// - Windows: `FilledButton` (Fluent's filled accent button) for primary,
///   plain `Button` for secondary.
enum AppButtonSize { regular, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.secondary = false,
    this.size = AppButtonSize.regular,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool secondary;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return secondary
          ? fluent.Button(onPressed: onPressed, child: child)
          : fluent.FilledButton(onPressed: onPressed, child: child);
    }
    return PushButton(
      controlSize: switch (size) {
        AppButtonSize.regular => ControlSize.regular,
        AppButtonSize.large => ControlSize.large,
      },
      secondary: secondary,
      onPressed: onPressed,
      child: child,
    );
  }
}
