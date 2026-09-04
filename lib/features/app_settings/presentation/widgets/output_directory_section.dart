import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/features/video_encoding/data/models/output_directory_settings.dart';
import 'package:video_toolkit/features/video_encoding/domain/output_path_resolver.dart';
import 'package:video_toolkit/widgets/app_button.dart';
import 'package:video_toolkit/widgets/app_checkbox.dart';
import 'package:video_toolkit/widgets/app_radio.dart';

/// Cross-platform settings section for choosing where encoded videos are
/// written. Shows the two modes (same-as-source / custom) with their
/// sub-options and a live path preview.
class AppOutputDirectorySection extends StatelessWidget {
  const AppOutputDirectorySection({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.sampleInputPath = '/path/to/video.mp4',
    this.sampleOutputFileName = 'video.mp4',
    this.showValidationErrors = false,
  });

  final OutputDirectorySettings value;
  final ValueChanged<OutputDirectorySettings> onChanged;
  final bool enabled;
  final String sampleInputPath;
  final String sampleOutputFileName;
  final bool showValidationErrors;

  String _previewDir() {
    return OutputPathResolver.resolveDir(
      inputPath: sampleInputPath,
      settings: value,
    );
  }

  Future<void> _pickFolder() async {
    if (!enabled) return;
    final dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null) return;
    onChanged(value.copyWith(customPath: dir));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final isWindows = Platform.isWindows;
    final previewDir = _previewDir();
    final previewPath = previewDir.isEmpty
        ? '–'
        : p.join(previewDir, sampleOutputFileName);

    final bodyStyle = isWindows
        ? fluent.FluentTheme.of(context).typography.body ?? const TextStyle()
        : MacosTheme.of(context).typography.body;

    final captionStyle = isWindows
        ? fluent.FluentTheme.of(context).typography.caption?.copyWith(
            color: AppColors.textSecondary(
              fluent.FluentTheme.of(context).brightness,
            ),
          )
        : MacosTheme.of(context).typography.caption1.copyWith(
            color: AppColors.textSecondary(MacosTheme.of(context).brightness),
          );

    final errorStyle = (captionStyle ?? const TextStyle()).copyWith(
      color: AppColors.error,
    );
    final validationMessage = switch (value.mode) {
      OutputDirectoryMode.custom
          when value.customPath == null || value.customPath!.trim().isEmpty =>
        l10n.outputDirCustomRequired,
      OutputDirectoryMode.sameAsSource
          when value.subfolderEnabled &&
              value.subfolderName
                  .replaceAll(RegExp(r'[\\/]+'), '_')
                  .trim()
                  .isEmpty =>
        l10n.outputDirSubfolderRequired,
      _ => null,
    };

    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppRadio<OutputDirectoryMode>(
              value: OutputDirectoryMode.sameAsSource,
              groupValue: value.mode,
              onChanged: (m) => onChanged(value.copyWith(mode: m)),
              label: Text(l10n.outputDirSameAsSource, style: bodyStyle),
            ),
            if (value.mode == OutputDirectoryMode.sameAsSource)
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppCheckbox(
                      value: value.subfolderEnabled,
                      onChanged: (v) =>
                          onChanged(value.copyWith(subfolderEnabled: v)),
                      label: Text(l10n.outputDirSubfolder, style: bodyStyle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InlineTextField(
                        value: value.subfolderName,
                        enabled: value.subfolderEnabled,
                        hint: l10n.outputDirSubfolderHint,
                        onChanged: (v) =>
                            onChanged(value.copyWith(subfolderName: v)),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            AppRadio<OutputDirectoryMode>(
              value: OutputDirectoryMode.custom,
              groupValue: value.mode,
              onChanged: (m) => onChanged(value.copyWith(mode: m)),
              label: Text(l10n.outputDirCustom, style: bodyStyle),
            ),
            if (value.mode == OutputDirectoryMode.custom)
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value.customPath?.isNotEmpty == true
                            ? value.customPath!
                            : l10n.outputDirCustomNotSet,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: captionStyle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      secondary: true,
                      onPressed: _pickFolder,
                      child: Text(l10n.outputDirChooseFolder, style: bodyStyle),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Text(l10n.outputDirPreview, style: captionStyle),
            const SizedBox(height: 4),
            Text(
              previewPath,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: captionStyle,
            ),
            if (showValidationErrors && validationMessage != null) ...[
              const SizedBox(height: 8),
              Text(validationMessage, style: errorStyle),
            ],
          ],
        ),
      ),
    );
  }
}

class _InlineTextField extends StatefulWidget {
  const _InlineTextField({
    required this.value,
    required this.onChanged,
    required this.enabled,
    this.hint,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? hint;

  @override
  State<_InlineTextField> createState() => _InlineTextFieldState();
}

class _InlineTextFieldState extends State<_InlineTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _InlineTextField old) {
    super.didUpdateWidget(old);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget field;
    if (Platform.isWindows) {
      final theme = fluent.FluentTheme.of(context);
      final placeholderStyle = (theme.typography.body ?? const TextStyle())
          .copyWith(color: AppColors.textSecondary(theme.brightness));
      field = fluent.TextBox(
        controller: _controller,
        placeholder: widget.hint,
        placeholderStyle: placeholderStyle,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
      );
    } else {
      final theme = MacosTheme.of(context);
      final placeholderStyle = theme.typography.body.copyWith(
        color: AppColors.textSecondary(theme.brightness),
      );
      field = MacosTextField(
        controller: _controller,
        placeholder: widget.hint,
        placeholderStyle: placeholderStyle,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
      );
    }
    return Opacity(opacity: widget.enabled ? 1 : 0.5, child: field);
  }
}
