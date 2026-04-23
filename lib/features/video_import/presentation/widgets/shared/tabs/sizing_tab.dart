import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_preset_chip.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_twin_field.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/shared/encode_settings_controller.dart';

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
        ],
      ),
    );
  }

  Widget _labelRow(String label, String value, _SizingStyles styles) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: styles.subtleBody),
        ),
        const SizedBox(width: 8),
        Text(value, style: styles.monoBody),
      ],
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
      subtleBody:
          body.copyWith(color: theme.resources.textFillColorSecondary),
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
