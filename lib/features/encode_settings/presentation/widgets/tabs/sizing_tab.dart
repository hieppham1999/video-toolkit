import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show Tooltip;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/widgets/app_checkbox.dart';
import 'package:video_toolkit/widgets/app_dropdown.dart';
import 'package:video_toolkit/widgets/app_field.dart';
import 'package:video_toolkit/widgets/app_preset_chip.dart';
import 'package:video_toolkit/widgets/app_twin_field.dart';
import 'package:video_toolkit/features/encode_settings/presentation/pages/encode_settings_controller.dart';

class SizingTab extends StatelessWidget {
  const SizingTab({
    super.key,
    required this.controller,
    required this.sampleWidth,
    required this.sampleHeight,
  });

  final EncodeSettingsController controller;
  final int? sampleWidth;
  final int? sampleHeight;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final c = controller;
    final styles = _resolveStyles(context);
    final srcLabel = (sampleWidth != null && sampleHeight != null)
        ? '$sampleWidth × $sampleHeight'
        : '-';
    final aspectStr = c.aspectNum.isNotEmpty && c.aspectDen.isNotEmpty
        ? '${c.aspectNum}:${c.aspectDen}'
        : '';
    final cropOut = EncodeSettingsController.computeCropOutput(
      sampleWidth,
      sampleHeight,
      aspectStr,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTwinField(
            label: l10n.resolution,
            separator: '×',
            leftValue: c.resWidth,
            rightValue: c.resHeight,
            leftHint: 'W',
            rightHint: 'H',
            onLeftChanged: c.setResWidth,
            onRightChanged: c.setResHeight,
          ),
          const SizedBox(height: 4),
          _ResolutionLegendRow(onSwap: c.swapResolution),
          const SizedBox(height: 12),
          AppField(
            label: l10n.outputFrameRate,
            value: c.frameRate,
            hint: l10n.keepSourceValue,
            onChanged: c.setFrameRate,
          ),
          const SizedBox(height: 12),
          AppTwinField(
            label: l10n.aspectRatio,
            separator: ':',
            leftValue: c.aspectNum,
            rightValue: c.aspectDen,
            leftHint: 'N',
            rightHint: 'D',
            onLeftChanged: c.setAspectNum,
            onRightChanged: c.setAspectDen,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 108),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final preset in EncodeSettingsController.aspectPresets)
                  AppPresetChip(
                    label: preset,
                    active: aspectStr == preset,
                    onTap: () => c.applyAspectPreset(preset),
                  ),
                AppPresetChip(
                  label: l10n.original,
                  active: aspectStr.isEmpty,
                  onTap: c.clearAspect,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _labelRow(l10n.sourceSize, srcLabel, styles),
          const SizedBox(height: 4),
          _labelRow(l10n.afterCrop, cropOut, styles),
          const SizedBox(height: 16),
          AppDropdown<Rotation>(
            label: l10n.rotation,
            value: c.rotation,
            items: Rotation.values,
            itemLabel: EncodeSettingsController.rotationLabel,
            onChanged: c.setRotation,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 108),
            child: Row(
              children: [
                AppCheckbox(
                  value: c.useDisplayRotation,
                  onChanged: c.setUseDisplayRotation,
                  enabled: c.rotation != Rotation.none,
                  label: Text(l10n.displayRotateOnly),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: l10n.displayRotateTooltip,
                  child: _infoIcon(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 108),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                AppCheckbox(
                  value: c.flipHorizontal,
                  onChanged: c.setFlipHorizontal,
                  label: Text(l10n.flipHorizontal),
                ),
                AppCheckbox(
                  value: c.flipVertical,
                  onChanged: c.setFlipVertical,
                  label: Text(l10n.flipVertical),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoIcon(BuildContext context) {
    if (Platform.isWindows) {
      final theme = fluent.FluentTheme.of(context);
      return fluent.Icon(
        fluent.FluentIcons.info,
        size: 14,
        color: theme.resources.textFillColorSecondary,
      );
    }
    final theme = MacosTheme.of(context);
    return MacosIcon(
      CupertinoIcons.info_circle,
      size: 14,
      color: AppColors.textTertiary(theme.brightness),
    );
  }

  Widget _labelRow(String label, String value, _SizingStyles styles) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: styles.subtleBody)),
        const SizedBox(width: 8),
        Text(value, style: styles.monoBody),
      ],
    );
  }
}

/// Header row sitting between the Resolution and Aspect-Ratio fields:
/// shows "W" / "H" labels aligned with the resolution columns and a swap
/// button to flip width ↔ height in one click.
class _ResolutionLegendRow extends StatelessWidget {
  const _ResolutionLegendRow({required this.onSwap});

  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final isWindows = Platform.isWindows;
    final TextStyle labelStyle;
    if (isWindows) {
      final theme = fluent.FluentTheme.of(context);
      labelStyle = (theme.typography.caption ?? const TextStyle()).copyWith(
        color: theme.resources.textFillColorSecondary,
      );
    } else {
      final theme = MacosTheme.of(context);
      labelStyle = theme.typography.caption1.copyWith(
        color: AppColors.textTertiary(theme.brightness),
      );
    }
    return Row(
      children: [
        const SizedBox(width: 108),
        SizedBox(
          width: 90,
          child: Text('W', textAlign: TextAlign.center, style: labelStyle),
        ),
        SizedBox(
          width: 24,
          child: Center(child: _SwapButton(onTap: onSwap)),
        ),
        SizedBox(
          width: 90,
          child: Text('H', textAlign: TextAlign.center, style: labelStyle),
        ),
      ],
    );
  }
}

class _SwapButton extends StatelessWidget {
  const _SwapButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      final theme = fluent.FluentTheme.of(context);
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: fluent.Icon(
          fluent.FluentIcons.switch_widget,
          size: 14,
          color: theme.resources.textFillColorSecondary,
        ),
      );
    }
    final theme = MacosTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: MacosIcon(
        CupertinoIcons.arrow_right_arrow_left,
        size: 14,
        color: AppColors.textTertiary(theme.brightness),
      ),
    );
  }
}

class _SizingStyles {
  const _SizingStyles({required this.subtleBody, required this.monoBody});

  final TextStyle subtleBody;
  final TextStyle monoBody;
}

_SizingStyles _resolveStyles(BuildContext context) {
  if (Platform.isWindows) {
    final theme = fluent.FluentTheme.of(context);
    final body = theme.typography.body ?? const TextStyle();
    return _SizingStyles(
      subtleBody: body.copyWith(color: theme.resources.textFillColorSecondary),
      monoBody: body.copyWith(fontFamily: 'monospace'),
    );
  }
  final theme = MacosTheme.of(context);
  final subtle = AppColors.textTertiary(theme.brightness);
  return _SizingStyles(
    subtleBody: theme.typography.body.copyWith(color: subtle),
    monoBody: theme.typography.body.copyWith(fontFamily: 'monospace'),
  );
}
