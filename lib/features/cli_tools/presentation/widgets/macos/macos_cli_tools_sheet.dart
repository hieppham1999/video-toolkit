import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/injection.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/cli/bundled_binary_resolver.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/features/cli_tools/domain/cli_tool.dart';
import 'package:video_toolkit/features/cli_tools/presentation/widgets/shared/cli_tool_command_bar.dart';
import 'package:video_toolkit/features/cli_tools/presentation/widgets/shared/cli_tools_controller.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_button.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_dialog_title_bar.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_dropdown.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_icon_button.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_preset_chip.dart';

class MacosCliToolsSheet extends StatefulWidget {
  const MacosCliToolsSheet({
    super.key,
    required this.inputPath,
    required this.onClose,
  });

  final String inputPath;
  final VoidCallback onClose;

  @override
  State<MacosCliToolsSheet> createState() => _MacosCliToolsSheetState();
}

class _MacosCliToolsSheetState extends State<MacosCliToolsSheet> {
  late final CliToolsController _c;

  @override
  void initState() {
    super.initState();
    _c = CliToolsController(
      inputPath: widget.inputPath,
      resolver: getIt<BundledBinaryResolver>(),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = MacosTheme.of(context);
    final l10n = Languages.translate;
    final b = theme.brightness;
    final subtle = AppColors.textTertiary(b);

    return AppDialogTitleBar(
      title: Text(l10n.cliTools),
      draggable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDropdown<CliTool>(
              label: l10n.cliToolSelectTool,
              value: _c.tool,
              items: CliTool.values,
              itemLabel: (t) => t.binaryName,
              onChanged: _c.setTool,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.cliToolPresets,
              style: theme.typography.caption1.copyWith(color: subtle),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _c.presets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final preset = _c.presets[i];
                  return AppPresetChip(
                    label: preset.label,
                    active: _c.selectedPreset?.label == preset.label,
                    onTap: () => _c.applyPreset(preset),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  l10n.cliToolCommand,
                  style: theme.typography.caption1.copyWith(color: subtle),
                ),
                const Spacer(),
                AppIconButton(
                  macosIcon: CupertinoIcons.doc_on_clipboard,
                  fluentIcon: CupertinoIcons.doc_on_clipboard,
                  tooltip: l10n.cliToolCopy,
                  onPressed: () => Clipboard.setData(
                    ClipboardData(text: _c.previewCommandLine),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            CliToolCommandBar(
              toolName: _c.tool.binaryName,
              inputPath: _c.inputPath,
              argsController: _c.argsController,
              enabled: !_c.isRunning,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _OutputPanel(controller: _c),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                AppButton(
                  size: AppButtonSize.large,
                  secondary: true,
                  onPressed: widget.onClose,
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                if (_c.isRunning)
                  AppButton(
                    size: AppButtonSize.large,
                    onPressed: _c.stop,
                    child: Text(l10n.cliToolStop),
                  )
                else
                  AppButton(
                    size: AppButtonSize.large,
                    onPressed: _c.execute,
                    child: Text(l10n.cliToolExecute),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OutputPanel extends StatelessWidget {
  const _OutputPanel({required this.controller});

  final CliToolsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final b = theme.brightness;
    final l10n = Languages.translate;
    final subtle = AppColors.textTertiary(b);
    final fg = AppColors.textPrimary(b);
    final mono = TextStyle(fontFamily: 'monospace', fontSize: 12, color: fg);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(b),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.divider(b)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Row(
              children: [
                Text(
                  l10n.cliToolOutput,
                  style: theme.typography.caption1.copyWith(color: subtle),
                ),
                if (controller.isRunning) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: ProgressCircle(radius: 6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.cliToolRunning,
                    style: theme.typography.caption1.copyWith(color: subtle),
                  ),
                ] else if (controller.exitCode != null) ...[
                  const SizedBox(width: 8),
                  _ExitCodeBadge(code: controller.exitCode!),
                ],
                const Spacer(),
                _FormatSegmented(controller: controller),
                const SizedBox(width: 8),
                AppIconButton(
                  macosIcon: CupertinoIcons.doc_on_clipboard,
                  fluentIcon: CupertinoIcons.doc_on_clipboard,
                  tooltip: l10n.cliToolCopy,
                  onPressed: controller.output.isEmpty
                      ? null
                      : () => Clipboard.setData(
                            ClipboardData(text: controller.formattedOutputText),
                          ),
                ),
                AppIconButton(
                  macosIcon: CupertinoIcons.clear,
                  fluentIcon: CupertinoIcons.clear,
                  tooltip: l10n.cliToolClear,
                  onPressed: controller.output.isEmpty
                      ? null
                      : controller.clearOutput,
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.divider(b)),
          Expanded(
            child: controller.output.isEmpty
                ? Center(
                    child: Text(
                      l10n.cliToolNoOutput,
                      style: theme.typography.caption1.copyWith(color: subtle),
                    ),
                  )
                : MacosScrollbar(
                    controller: controller.outputScrollController,
                    child: SingleChildScrollView(
                      controller: controller.outputScrollController,
                      padding: const EdgeInsets.all(12),
                      child: SelectableText(
                        controller.formattedOutputText,
                        style: mono,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

}

class _FormatSegmented extends StatelessWidget {
  const _FormatSegmented({required this.controller});

  final CliToolsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final b = theme.brightness;
    final l10n = Languages.translate;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle(b),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill(l10n.cliToolFormatRaw, CliOutputFormat.raw, theme),
          _pill(l10n.cliToolFormatJson, CliOutputFormat.json, theme),
        ],
      ),
    );
  }

  Widget _pill(String label, CliOutputFormat value, MacosThemeData theme) {
    final active = controller.outputFormat == value;
    final bg = active ? theme.primaryColor : const Color(0x00000000);
    final fg = active
        ? const Color(0xFFFFFFFF)
        : AppColors.textPrimary(theme.brightness);
    return GestureDetector(
      onTap: () => controller.setOutputFormat(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: theme.typography.caption1.copyWith(color: fg),
        ),
      ),
    );
  }
}

class _ExitCodeBadge extends StatelessWidget {
  const _ExitCodeBadge({required this.code});

  final int code;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final ok = code == 0;
    final bg = ok ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        Languages.translate.cliToolExitCode(code),
        style: theme.typography.caption1
            .copyWith(color: const Color(0xFFFFFFFF)),
      ),
    );
  }
}
