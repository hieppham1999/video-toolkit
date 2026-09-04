import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/features/encode_settings/presentation/pages/encode_settings_controller.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/domain/ffmpeg_command_preview.dart';
import 'package:video_toolkit/widgets/app_button.dart';

class CommandPreviewTab extends StatelessWidget {
  const CommandPreviewTab({
    super.key,
    required this.controller,
    required this.sampleInputPath,
    required this.sampleDuration,
    this.sampleCreationDate,
  });

  final EncodeSettingsController controller;
  final String sampleInputPath;
  final Duration? sampleDuration;
  final DateTime? sampleCreationDate;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final settings = controller.buildSettings();
    final outputPath = p.join(
      p.dirname(sampleInputPath),
      '${p.basenameWithoutExtension(sampleInputPath)}_encoded.'
      '${settings.outputExtension.value}',
    );
    final command = buildFfmpegCommandPreview(
      settings: settings,
      inputPath: sampleInputPath,
      outputPath: outputPath,
      duration: sampleDuration,
      creationDate: sampleCreationDate,
    );
    final estimatedSize = settings.estimatedOutputSizeMb(sampleDuration);
    final styles = _styles(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.estimatedOutputSize, style: styles.heading),
          const SizedBox(height: 6),
          Text(
            estimatedSize == null
                ? l10n.outputSizeUnavailable
                : l10n.estimatedMegabytes(
                    estimatedSize.toStringAsFixed(estimatedSize >= 100 ? 0 : 1),
                  ),
            style: styles.body,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(l10n.ffmpegCommandPreview, style: styles.heading),
              const Spacer(),
              AppButton(
                secondary: true,
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: command)),
                child: Text(l10n.copyCommand, style: styles.body),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: styles.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(command, style: styles.monospace),
          ),
          if (settings.encoderMode != EncoderMode.software) ...[
            const SizedBox(height: 10),
            Text(l10n.commandPreviewHardwareNote, style: styles.subtle),
          ],
          const SizedBox(height: 10),
          Text(l10n.outputSizeEstimateNote, style: styles.subtle),
        ],
      ),
    );
  }
}

class _CommandPreviewStyles {
  const _CommandPreviewStyles({
    required this.heading,
    required this.body,
    required this.subtle,
    required this.monospace,
    required this.surface,
  });

  final TextStyle heading;
  final TextStyle body;
  final TextStyle subtle;
  final TextStyle monospace;
  final Color surface;
}

_CommandPreviewStyles _styles(BuildContext context) {
  if (Platform.isWindows) {
    final theme = fluent.FluentTheme.of(context);
    final body = theme.typography.body ?? const TextStyle();
    return _CommandPreviewStyles(
      heading: theme.typography.bodyStrong ?? body,
      body: body,
      subtle: body.copyWith(color: theme.resources.textFillColorSecondary),
      monospace: body.copyWith(fontFamily: 'monospace'),
      surface: theme.cardColor,
    );
  }
  final theme = MacosTheme.of(context);
  return _CommandPreviewStyles(
    heading: theme.typography.headline,
    body: theme.typography.body,
    subtle: theme.typography.body.copyWith(
      color: AppColors.textTertiary(theme.brightness),
    ),
    monospace: theme.typography.body.copyWith(fontFamily: 'monospace'),
    surface: AppColors.surface(theme.brightness),
  );
}
