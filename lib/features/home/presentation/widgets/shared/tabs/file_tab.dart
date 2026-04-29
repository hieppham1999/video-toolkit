import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/core/utils/filename_template.dart';
import 'package:video_toolkit/widgets/app_checkbox.dart';
import 'package:video_toolkit/widgets/app_dropdown.dart';
import 'package:video_toolkit/widgets/app_field.dart';
import 'package:video_toolkit/widgets/app_tag_chip.dart';
import 'package:video_toolkit/features/home/presentation/widgets/shared/encode_settings_controller.dart';

class FileTab extends StatelessWidget {
  const FileTab({
    super.key,
    required this.controller,
    required this.sampleFileName,
    required this.sampleCreationDate,
  });

  final EncodeSettingsController controller;
  final String sampleFileName;
  final DateTime? sampleCreationDate;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final c = controller;
    final styles = _resolveStyles(context);
    final preview = FilenameTemplate.apply(
      c.outputNameTemplate,
      originalName: sampleFileName,
      creationDate: sampleCreationDate ?? DateTime.now(),
      sourceTimezoneOffset: c.sourceTimezoneOffset,
    );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppField(
            label: l10n.outputName,
            value: c.outputNameTemplate,
            onChanged: c.setOutputNameTemplate,
            hint: l10n.outputNameHint,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(l10n.outputNamePreview, style: styles.subtleBody),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$preview.${c.outputExtension.value}',
                  style: styles.monoBody,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.availableTags, style: styles.subtleCaption),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in FilenameTemplate.tags)
                AppTagChip(tag: '{$tag}', onTap: () => c.appendNameTag(tag)),
            ],
          ),
          const SizedBox(height: 16),
          AppCheckbox(
            value: c.copySourceMetadata,
            onChanged: c.setCopySourceMetadata,
            label: Text(l10n.copySourceMetadata),
          ),
          const SizedBox(height: 12),
          AppDropdown<String?>(
            label: l10n.sourceTimezone,
            value: c.sourceTimezoneOffset,
            items: EncodeSettingsController.timezoneOffsets,
            itemLabel: (v) => v == null ? l10n.sourceTimezoneAuto : '(GMT$v)',
            onChanged: c.setSourceTimezoneOffset,
            enabled: c.copySourceMetadata,
          ),
        ],
      ),
    );
  }
}

class _TabTextStyles {
  const _TabTextStyles({
    required this.subtleBody,
    required this.monoBody,
    required this.subtleCaption,
  });

  final TextStyle subtleBody;
  final TextStyle monoBody;
  final TextStyle subtleCaption;
}

_TabTextStyles _resolveStyles(BuildContext context) {
  if (Platform.isWindows) {
    final theme = fluent.FluentTheme.of(context);
    final subtle = theme.resources.textFillColorSecondary;
    final body = theme.typography.body ?? const TextStyle();
    final caption = theme.typography.caption ?? const TextStyle();
    return _TabTextStyles(
      subtleBody: body.copyWith(color: subtle),
      monoBody: body.copyWith(fontFamily: 'monospace'),
      subtleCaption: caption.copyWith(color: subtle),
    );
  }
  final theme = MacosTheme.of(context);
  final subtle = AppColors.textTertiary(theme.brightness);
  return _TabTextStyles(
    subtleBody: theme.typography.body.copyWith(color: subtle),
    monoBody: theme.typography.body.copyWith(fontFamily: 'monospace'),
    subtleCaption: theme.typography.caption1.copyWith(color: subtle),
  );
}
