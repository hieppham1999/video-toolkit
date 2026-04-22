import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

/// Centralised semantic color tokens. All widgets should read UI colors from
/// here rather than hardcoding `Color(0xFF...)` inline so that dark/light
/// adaptation (and future theming) stays consistent.
///
/// Status colors are brightness-independent because they must stay recognisable
/// in both modes; neutral tokens switch per [Brightness].
class AppColors {
  AppColors._();

  // ── Text ────────────────────────────────────────────────
  static Color textPrimary(Brightness b) =>
      b == Brightness.dark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);

  static Color textSecondary(Brightness b) =>
      b == Brightness.dark ? const Color(0xFFAEAEB2) : const Color(0xFF6E6E73);

  static Color textTertiary(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);

  // ── Surfaces & borders ──────────────────────────────────
  /// Page / canvas neutral surface.
  static Color surface(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);

  /// Cards, chips, slightly raised surfaces.
  static Color surfaceElevated(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

  /// Alternative elevated for light-mode light-grey (ECECEC) backgrounds.
  static Color surfaceSubtle(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF2C2C2E) : const Color(0xFFECECEC);

  static Color divider(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF38383A) : const Color(0xFFD1D1D6);

  static Color hoverOverlay(Brightness b) =>
      b == Brightness.dark ? const Color(0x22FFFFFF) : const Color(0x11000000);

  /// Selected-row highlight in video table (uses accent-tinted blue today).
  static Color tableRowHighlight(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF0A3A6B) : const Color(0xFFD0E4F7);

  // ── Status ───────────────────────────────────────────────
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);

  // ── macOS traffic-light close/minimize/maximize ──────────
  static const Color trafficRedLight = Color(0xFFFF5F56);
  static const Color trafficRedDark = Color(0xFFE0443E);
  static const Color trafficYellowLight = Color(0xFFFFBD2E);
  static const Color trafficYellowDark = Color(0xFFDEA123);
  static const Color trafficGreenLight = Color(0xFF27C93F);
  static const Color trafficGreenDark = Color(0xFF1AAB29);

  // ── Misc overlays ────────────────────────────────────────
  /// Faint icon/border alpha used on color-picker swatches.
  static const Color swatchBorder = Color(0x33000000);

  /// Heavy icon alpha for overlays over video thumbnails.
  static const Color overlayIconShadow = Color(0x99000000);
}

/// Helper to pull [Brightness] from whichever platform theme is in scope
/// without per-callsite `Platform.isWindows` branches.
Brightness brightnessOf(BuildContext context) {
  if (Platform.isWindows) return fluent.FluentTheme.of(context).brightness;
  return MacosTheme.of(context).brightness;
}
