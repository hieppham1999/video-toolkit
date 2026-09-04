import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/output_directory_settings.dart';
import 'package:video_toolkit/features/video_encoding/domain/output_path_resolver.dart';
import 'package:video_toolkit/widgets/app_button.dart';
import 'package:video_toolkit/widgets/app_checkbox.dart';
import 'package:video_toolkit/widgets/app_dialog_title_bar.dart';

import 'output_directory_section.dart';

Future<void> showAppOutputDirectoryDialog({
  required BuildContext context,
  required OutputDirectorySettings globalSettings,
  required bool isPerFile,
  required String sampleInputPath,
  required EncodeSettings sampleEncodeSettings,
  required ValueChanged<OutputDirectorySettings?> onSave,
  OutputDirectorySettings? initialOverride,
  DateTime? sampleCreationDate,
  bool sampleCreationDateFromFileSystem = false,
  String? sampleTimezoneOffset,
}) {
  final dialog = AppOutputDirectoryDialog(
    globalSettings: globalSettings,
    isPerFile: isPerFile,
    sampleInputPath: sampleInputPath,
    sampleEncodeSettings: sampleEncodeSettings,
    initialOverride: initialOverride,
    sampleCreationDate: sampleCreationDate,
    sampleCreationDateFromFileSystem: sampleCreationDateFromFileSystem,
    sampleTimezoneOffset: sampleTimezoneOffset,
    onSave: onSave,
  );
  if (Platform.isWindows) {
    return fluent.showDialog<void>(context: context, builder: (_) => dialog);
  }
  return showMacosSheet<void>(context: context, builder: (_) => dialog);
}

/// Shared global/per-file output directory editor. A null value returned from
/// the per-file variant means the file inherits the global setting.
class AppOutputDirectoryDialog extends StatefulWidget {
  const AppOutputDirectoryDialog({
    super.key,
    required this.globalSettings,
    required this.isPerFile,
    required this.sampleInputPath,
    required this.sampleEncodeSettings,
    required this.onSave,
    this.initialOverride,
    this.sampleCreationDate,
    this.sampleCreationDateFromFileSystem = false,
    this.sampleTimezoneOffset,
  });

  final OutputDirectorySettings globalSettings;
  final bool isPerFile;
  final String sampleInputPath;
  final EncodeSettings sampleEncodeSettings;
  final ValueChanged<OutputDirectorySettings?> onSave;
  final OutputDirectorySettings? initialOverride;
  final DateTime? sampleCreationDate;
  final bool sampleCreationDateFromFileSystem;
  final String? sampleTimezoneOffset;

  @override
  State<AppOutputDirectoryDialog> createState() =>
      _AppOutputDirectoryDialogState();
}

class _AppOutputDirectoryDialogState extends State<AppOutputDirectoryDialog> {
  late bool _useGlobal;
  late OutputDirectorySettings _draft;

  @override
  void initState() {
    super.initState();
    _useGlobal = widget.isPerFile && widget.initialOverride == null;
    _draft = widget.initialOverride ?? widget.globalSettings;
  }

  OutputDirectorySettings get _previewSettings =>
      _useGlobal ? widget.globalSettings : _draft;

  String get _sampleOutputFileName => p.basename(
    OutputPathResolver.resolvePath(
      inputPath: widget.sampleInputPath,
      encodeSettings: widget.sampleEncodeSettings,
      directorySettings: _previewSettings,
      creationDate: widget.sampleCreationDate,
      creationDateFromFileSystem: widget.sampleCreationDateFromFileSystem,
      detectedTimezoneOffset: widget.sampleTimezoneOffset,
    ),
  );

  String? get _validationMessage {
    if (_useGlobal) return null;
    final l10n = Languages.translate;
    if (_draft.isValid) return null;
    if (_draft.mode == OutputDirectoryMode.custom) {
      return l10n.outputDirCustomRequired;
    }
    return l10n.outputDirSubfolderRequired;
  }

  void _save() {
    if (_validationMessage != null) return;
    widget.onSave(_useGlobal ? null : _draft);
    Navigator.of(context).pop();
  }

  void _cancel() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Platform.isWindows
        ? _buildWindowsDialog(context)
        : _buildMacosDialog(context);
  }

  Widget _buildEditor(BuildContext context) {
    final l10n = Languages.translate;
    final bodyStyle = Platform.isWindows
        ? fluent.FluentTheme.of(context).typography.body ?? const TextStyle()
        : MacosTheme.of(context).typography.body;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isPerFile) ...[
          AppCheckbox(
            value: _useGlobal,
            onChanged: (value) => setState(() => _useGlobal = value),
            label: Text(l10n.useGlobalOutputDirectory, style: bodyStyle),
          ),
          const SizedBox(height: 16),
        ],
        AppOutputDirectorySection(
          value: _previewSettings,
          enabled: !_useGlobal,
          sampleInputPath: widget.sampleInputPath,
          sampleOutputFileName: _sampleOutputFileName,
          showValidationErrors: true,
          onChanged: (value) => setState(() => _draft = value),
        ),
      ],
    );
  }

  Widget _buildWindowsDialog(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    final l10n = Languages.translate;
    return fluent.ContentDialog(
      constraints: const BoxConstraints(maxWidth: 620),
      title: AppDialogTitleBar(
        title: Text(l10n.outputDirectory, style: theme.typography.subtitle),
      ),
      content: SingleChildScrollView(child: _buildEditor(context)),
      actions: [
        AppButton(
          secondary: true,
          onPressed: _cancel,
          child: Text(l10n.cancel, style: theme.typography.body),
        ),
        AppButton(
          onPressed: _validationMessage == null ? _save : null,
          child: Text(l10n.save, style: theme.typography.body),
        ),
      ],
    );
  }

  Widget _buildMacosDialog(BuildContext context) {
    final theme = MacosTheme.of(context);
    final l10n = Languages.translate;
    return AppDialogTitleBar(
      title: Text(l10n.outputDirectory, style: theme.typography.title3),
      shrinkWrap: true,
      draggable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 120, vertical: 80),
      child: SizedBox(
        width: 560,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEditor(context),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    secondary: true,
                    onPressed: _cancel,
                    child: Text(l10n.cancel, style: theme.typography.body),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    onPressed: _validationMessage == null ? _save : null,
                    child: Text(l10n.save, style: theme.typography.body),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
