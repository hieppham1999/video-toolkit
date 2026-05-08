import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/painting.dart';
import 'package:macos_ui/macos_ui.dart' as macos;

/// Selectable accent color palette. Stored as an enum (not a raw `Color`) so
/// it serialises cleanly to JSON and maps to per-platform accent types
/// (Fluent's `AccentColor` with shades, macOS' plain `Color`).
enum AppAccent {
  blue,
  purple,
  pink,
  red,
  orange,
  yellow,
  green,
  teal,
  graphite,
}

extension AppAccentX on AppAccent {
  /// Primary (normal) color used by macOS `primaryColor` and as the base for
  /// Windows' `AccentColor` shade ramp.
  Color get color {
    switch (this) {
      case AppAccent.blue:
        return const Color(0xFF0A84FF);
      case AppAccent.purple:
        return const Color(0xFFBF5AF2);
      case AppAccent.pink:
        return const Color(0xFFFF2D55);
      case AppAccent.red:
        return const Color(0xFFFF453A);
      case AppAccent.orange:
        return const Color(0xFFFF9F0A);
      case AppAccent.yellow:
        return const Color(0xFFFFD60A);
      case AppAccent.green:
        return const Color(0xFF30D158);
      case AppAccent.teal:
        return const Color(0xFF64D2FF);
      case AppAccent.graphite:
        return const Color(0xFF8E8E93);
    }
  }

  /// macOS accent enum consumed by `MacosThemeData.accentColor`. `PushButton`
  /// reads this (not `primaryColor`) to pick its gradient. `AppAccent.teal`
  /// maps to `AccentColor.blue` because macos_ui has no teal option.
  macos.AccentColor get macosAccent {
    switch (this) {
      case AppAccent.blue:
      case AppAccent.teal:
        return macos.AccentColor.blue;
      case AppAccent.purple:
        return macos.AccentColor.purple;
      case AppAccent.pink:
        return macos.AccentColor.pink;
      case AppAccent.red:
        return macos.AccentColor.red;
      case AppAccent.orange:
        return macos.AccentColor.orange;
      case AppAccent.yellow:
        return macos.AccentColor.yellow;
      case AppAccent.green:
        return macos.AccentColor.green;
      case AppAccent.graphite:
        return macos.AccentColor.graphite;
    }
  }

  /// Fluent accent (multi-shade) derived from [color]. Uses `swatch` helper
  /// so dark/light shades are generated automatically.
  fluent.AccentColor get fluentAccent => fluent.AccentColor.swatch({
        'darkest': _shade(color, -0.40),
        'darker': _shade(color, -0.25),
        'dark': _shade(color, -0.12),
        'normal': color,
        'light': _shade(color, 0.15),
        'lighter': _shade(color, 0.28),
        'lightest': _shade(color, 0.42),
      });

  /// ARB key for the localised label of this accent option.
  String get labelKey {
    switch (this) {
      case AppAccent.blue:
        return 'accentBlue';
      case AppAccent.purple:
        return 'accentPurple';
      case AppAccent.pink:
        return 'accentPink';
      case AppAccent.red:
        return 'accentRed';
      case AppAccent.orange:
        return 'accentOrange';
      case AppAccent.yellow:
        return 'accentYellow';
      case AppAccent.green:
        return 'accentGreen';
      case AppAccent.teal:
        return 'accentTeal';
      case AppAccent.graphite:
        return 'accentGraphite';
    }
  }
}

Color _shade(Color base, double amount) {
  // amount in [-1, 1]. Negative = darker toward black, positive = lighter
  // toward white. Linear RGB blend — good enough for accent shades.
  final target = amount < 0 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  final t = amount.abs().clamp(0.0, 1.0);
  return Color.lerp(base, target, t) ?? base;
}
