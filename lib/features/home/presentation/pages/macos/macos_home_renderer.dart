import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/utils/bitrate_formatter.dart';
import 'package:video_toolkit/core/utils/date_formatter.dart';
import 'package:video_toolkit/core/utils/video_utils.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/home/data/models/video_file.dart';
import 'package:video_toolkit/app/injection.dart';
import 'package:video_toolkit/features/home/presentation/cubit/preview_cubit.dart';
import 'package:video_toolkit/features/home/presentation/cubit/preview_state.dart';
import 'package:video_toolkit/widgets/app_metadata_row.dart';
import 'package:video_toolkit/features/home/presentation/widgets/app_overall_progress_bar.dart';
import 'package:video_toolkit/features/home/presentation/widgets/app_preview_panel.dart';
import 'package:video_toolkit/widgets/app_resizable_divider.dart';
import 'package:video_toolkit/app/base/bloc_state_builder.dart';
import 'package:video_toolkit/widgets/app_toolbar_button.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/features/cli_tools/presentation/cli_tools_launcher.dart';
import 'package:video_toolkit/features/app_settings/presentation/pages/settings_page.dart';
import 'package:video_toolkit/features/home/presentation/widgets/app_video_table_section.dart';
import 'package:video_toolkit/features/encode_settings/presentation/pages/macos_encode_settings_sheet.dart';

import '../home_view_data.dart';

/// Pure UI — receives [HomeViewData], renders macOS widgets, zero logic.
class MacosHomeRenderer extends StatelessWidget {
  const MacosHomeRenderer({super.key, required this.data});

  final HomeViewData data;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final l10n = Languages.translate;
    return MacosScaffold(
      backgroundColor: CupertinoDynamicColor.maybeResolve(theme.canvasColor, context) ??
                theme.canvasColor,
      toolBar: ToolBar(
        title: const Text('Video Toolkit'),
        height: 78,
        titleWidth: 150,
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.maybeResolve(theme.canvasColor, context) ??
                theme.canvasColor,
        ),

        actions: [
          CustomToolbarItem(
            tooltipMessage: l10n.addVideo,
            inToolbarBuilder: (_) => AppToolbarButton(
              macosIcon: CupertinoIcons.add_circled,
              fluentIcon: CupertinoIcons.add_circled,
              label: l10n.addVideo,
              tooltip: l10n.addVideo,
              onTap: data.onPickFiles,
            ),
          ),
          const ToolBarDivider(),
          CustomToolbarItem(
            tooltipMessage: l10n.encodeSettings,
            inToolbarBuilder: (_) => AppToolbarButton(
              macosIcon: CupertinoIcons.slider_horizontal_3,
              fluentIcon: CupertinoIcons.slider_horizontal_3,
              label: l10n.encodeSettings,
              subLabel: _presetSubLabel(),
              tooltip: l10n.encodeSettings,
              onTap: () => _openEncodeSettings(context),
            ),
          ),
          CustomToolbarItem(
            tooltipMessage: l10n.start,
            inToolbarBuilder: (_) => AppToolbarButton(
              macosIcon: CupertinoIcons.play_fill,
              fluentIcon: CupertinoIcons.play_fill,
              label: l10n.start,
              tooltip: l10n.start,
              onTap: data.onStart,
            ),
          ),
          CustomToolbarItem(
            tooltipMessage: l10n.stop,
            inToolbarBuilder: (_) => AppToolbarButton(
              macosIcon: CupertinoIcons.stop_fill,
              fluentIcon: CupertinoIcons.stop_fill,
              label: l10n.stop,
              tooltip: l10n.stop,
              onTap: data.onStop,
            ),
          ),
          const ToolBarDivider(),
          CustomToolbarItem(
            tooltipMessage: l10n.cliTools,
            inToolbarBuilder: (ctx) => AppToolbarButton(
              macosIcon: CupertinoIcons.chevron_left_slash_chevron_right,
              fluentIcon: CupertinoIcons.chevron_left_slash_chevron_right,
              label: l10n.cliTools,
              tooltip: l10n.cliTools,
              onTap: data.selectedFile != null
                  ? () => showCliToolsDialog(ctx, data.selectedFile!.path)
                  : null,
            ),
          ),
          const ToolBarDivider(),
          CustomToolbarItem(
            tooltipMessage: l10n.settings,
            inToolbarBuilder: (_) => AppToolbarButton(
              macosIcon: CupertinoIcons.gear,
              fluentIcon: CupertinoIcons.gear,
              label: l10n.settings,
              tooltip: l10n.settings,
              onTap: () => _openSettings(context),
            ),
          ),
        ],
      ),
      children: [
        ContentArea(
          builder: (context, _) {
            // Paint the entire body with canvas color so unpainted gaps
            // (below table rows, around divider) don't show the Flutter
            // default black bg through.
            final canvas = CupertinoDynamicColor.maybeResolve(theme.canvasColor, context) ??
                theme.canvasColor;
            return ColoredBox(
              color: canvas,
              child: DropTarget(
                onDragDone: (details) {
                  data.onFilesDropped(details.files.map((f) => f.path).toList());
                },
                onDragEntered: (_) => data.onDragStateChanged(true),
                onDragExited: (_) => data.onDragStateChanged(false),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalHeight = constraints.maxHeight;
                    final previewH = totalHeight * data.previewFraction;

                    return Column(
                      children: [
                        SizedBox(
                          height: previewH,
                          child: _PreviewSection(
                            isDragging: data.isDragging,
                            selectedFile: data.selectedFile,
                          ),
                        ),
                        AppResizableDivider(
                          onDrag: (dy) => data.onDividerDrag(dy / totalHeight),
                        ),
                        Expanded(
                          child: AppVideoTableSection(
                            files: data.files,
                            globalSettings: data.encodeSettings,
                            outputDirectory: data.outputDirectory,
                            selectedFilePath: data.selectedFile?.path,
                            encodeState: data.encodeState,
                            onSelect: data.onSelectVideo,
                            onRemove: data.onRemoveFile,
                            onRemoveAll: () => _confirmClearAll(context),
                            onOpenFileSettings: (file) => _openFileSettings(
                              context,
                              file,
                              data.encodeSettings,
                              data.onUpdateFileSettings,
                            ),
                          ),
                        ),
                        AppOverallProgressBar(encodeState: data.encodeState),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String? _presetSubLabel() {
    final name = data.currentPresetName;
    if (name == null) return null;
    return data.isPresetModified ? '$name*' : name;
  }


  void _openSettings(BuildContext context) {
    showMacosSheet<void>(
      context: context,
      builder: (_) => const SettingsPage(),
    );
  }

  void _openEncodeSettings(BuildContext context) {
    showMacosSheet<void>(
      context: context,
      builder: (_) => MacosEncodeSettingsSheet(
        settings: data.encodeSettings,
        onSave: (settings) {
          data.onSaveEncodeSettings(settings);
          Navigator.of(context).pop();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _openFileSettings(
    BuildContext context,
    VideoFile file,
    EncodeSettings globalSettings,
    void Function(String path, EncodeSettings? settings) onUpdate,
  ) {
    final base = file.overrideSettings ?? globalSettings;
    final w = file.metadata?.width;
    final h = file.metadata?.height;
    final effective = (base.resolution == null &&
            w != null &&
            h != null &&
            w > 0 &&
            h > 0)
        ? base.copyWith(resolution: '$w:$h')
        : base;
    showMacosSheet<void>(
      context: context,
      builder: (_) => MacosEncodeSettingsSheet(
        settings: effective,
        isPerFile: true,
        sampleFileName: p.basenameWithoutExtension(file.path),
        sampleCreationDate: file.metadata?.creationDate,
        sampleTimezoneOffset: file.metadata?.timezoneOffset,
        sampleWidth: file.metadata?.width,
        sampleHeight: file.metadata?.height,
        onSave: (settings) {
          onUpdate(file.path, settings);
          Navigator.of(context).pop();
        },
        onCancel: () => Navigator.of(context).pop(),
        onReset: file.overrideSettings != null
            ? () {
                onUpdate(file.path, null);
                Navigator.of(context).pop();
              }
            : null,
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    final l10n = Languages.translate;
    showMacosAlertDialog<void>(
      context: context,
      builder: (_) => MacosAlertDialog(
        appIcon: const MacosIcon(CupertinoIcons.film, size: 56),
        title: Text(l10n.removeAll),
        message: Text(l10n.clearAllConfirmMessage),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () {
            data.onClearAll();
            Navigator.of(context).pop();
          },
          child: Text(l10n.remove),
        ),
        secondaryButton: PushButton(
          controlSize: ControlSize.large,
          secondary: true,
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ),
    );
  }
}

// ─── Preview Section ────────────────────────────────────────────

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({required this.isDragging, required this.selectedFile});

  final bool isDragging;
  final VideoFile? selectedFile;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final accent = theme.primaryColor;
    // Trust multiple sources — whichever detects dark wins. This covers the
    // case where system brightness, canvas luminance, and theme.brightness
    // may disagree (e.g., MacosApp themeMode lag, native chrome override).
    final resolvedCanvas =
        CupertinoDynamicColor.maybeResolve(theme.canvasColor, context) ??
            theme.canvasColor;
    final isDark = theme.brightness == Brightness.dark ||
        MediaQuery.platformBrightnessOf(context) == Brightness.dark ||
        resolvedCanvas.computeLuminance() < 0.5;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final subtleText = AppColors.textSecondary(brightness);
    final faintText = AppColors.textTertiary(brightness);
    final l10n = Languages.translate;
    // Drag overlay always takes priority
    if (isDragging) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.06),
          border: Border.all(color: accent, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MacosIcon(CupertinoIcons.arrow_down_doc, size: 48, color: accent),
              const SizedBox(height: 12),
              Text(
                l10n.dropFilesHere,
                style: theme.typography.title3.copyWith(color: accent),
              ),
            ],
          ),
        ),
      );
    }

    // No video selected — placeholder
    if (selectedFile == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MacosIcon(CupertinoIcons.play_rectangle, size: 48, color: subtleText),
            const SizedBox(height: 12),
            Text(
              l10n.selectVideoToPreview,
              style: theme.typography.title3.copyWith(color: subtleText),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.dragDropInstructions,
              style: theme.typography.caption1.copyWith(color: faintText),
            ),
          ],
        ),
      );
    }

    // Video selected — show metadata
    final metadata = selectedFile!.metadata;
    final primaryText = AppColors.textPrimary(brightness);
    // Build TextStyles from scratch — theme.typography can carry
    // CupertinoDynamicColor that copyWith fails to replace cleanly.
    final labelStyle = TextStyle(color: subtleText, fontSize: 11);
    final valueStyle = TextStyle(color: primaryText, fontSize: 13);
    final titleStyle = TextStyle(color: primaryText, fontSize: 15, fontWeight: FontWeight.w600);

    // Paint our own background so text contrast is guaranteed even when
    // outer macos_ui widgets paint a different color than theme.canvasColor.
    return ColoredBox(
      color: resolvedCanvas,
      child: Padding(
        padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: metadata info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedFile!.name,
                  style: titleStyle,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  selectedFile!.path,
                  style: labelStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 16),
                if (metadata == null)
                  Text(l10n.metadataNotAvailable, style: labelStyle)
                else ...[
                  AppMetadataRow(
                    label: l10n.resolution,
                    value: metadata.width != null && metadata.height != null
                        ? '${metadata.width}x${metadata.height}'
                        : '-',
                    labelStyle: labelStyle,
                    valueStyle: valueStyle,
                  ),
                  const SizedBox(height: 6),
                  AppMetadataRow(
                    label: l10n.codec,
                    value: metadata.videoCodec ?? '-',
                    labelStyle: labelStyle,
                    valueStyle: valueStyle,
                  ),
                  const SizedBox(height: 6),
                  AppMetadataRow(
                    label: l10n.bitrate,
                    value: BitrateFormatter.format(metadata.bitrate),
                    labelStyle: labelStyle,
                    valueStyle: valueStyle,
                  ),
                  const SizedBox(height: 6),
                  AppMetadataRow(
                    label: l10n.aspectRatio,
                    value: computeAspectRatio(metadata.width, metadata.height) ?? '-',
                    labelStyle: labelStyle,
                    valueStyle: valueStyle,
                  ),
                  const SizedBox(height: 6),
                  AppMetadataRow(
                    label: l10n.frameRate,
                    value: metadata.frameRate != null
                        ? '${metadata.frameRate!.toStringAsFixed(2)} fps'
                        : '-',
                    labelStyle: labelStyle,
                    valueStyle: valueStyle,
                  ),
                  const SizedBox(height: 6),
                  AppMetadataRow(
                    label: l10n.duration,
                    value: DateFormatter.formatDuration(metadata.duration),
                    labelStyle: labelStyle,
                    valueStyle: valueStyle,
                  ),
                  const SizedBox(height: 6),
                  AppMetadataRow(
                    label: l10n.dateTaken,
                    value: DateFormatter.format(metadata.creationDate),
                    labelStyle: labelStyle,
                    valueStyle: valueStyle,
                  ),
                ],
              ],
            ),
          ),
          // Right: live/static preview frame.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CubitStateBuilder<PreviewState>(
                cubit: getIt<PreviewCubit>(),
                builder: (context, state) => AppPreviewPanel(state: state),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

}

