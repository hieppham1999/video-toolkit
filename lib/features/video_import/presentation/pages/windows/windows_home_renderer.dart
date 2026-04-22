import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/utils/date_formatter.dart';
import 'package:video_toolkit/core/utils/video_utils.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_import/data/models/video_file.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_metadata_row.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_overall_progress_bar.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_resizable_divider.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_toolbar_button.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/features/settings/presentation/pages/settings_page.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_video_table_section.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/windows/windows_encode_settings_dialog.dart';

import '../home_view_data.dart';

/// Pure UI — receives [HomeViewData], renders Fluent widgets, zero logic.
class WindowsHomeRenderer extends StatelessWidget {
  const WindowsHomeRenderer({super.key, required this.data});

  final HomeViewData data;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final theme = FluentTheme.of(context);

    return ScaffoldPage(
      header: SizedBox(
        height: 85,
        child: PageHeader(
          title: const Text('Video Toolkit'),
          commandBar: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppToolbarButton(
                macosIcon: FluentIcons.add,
                fluentIcon: FluentIcons.add,
                label: l10n.addVideo,
                tooltip: l10n.addVideo,
                onTap: data.onPickFiles,
              ),
              _toolbarDivider(theme),
              AppToolbarButton(
                macosIcon: FluentIcons.settings,
                fluentIcon: FluentIcons.settings,
                label: l10n.encodeSettings,
                subLabel: _presetSubLabel(),
                tooltip: l10n.encodeSettings,
                onTap: () => _openEncodeSettings(context),
              ),
              AppToolbarButton(
                macosIcon: FluentIcons.play,
                fluentIcon: FluentIcons.play,
                label: l10n.start,
                tooltip: l10n.start,
                onTap: data.onStart,
              ),
              AppToolbarButton(
                macosIcon: FluentIcons.stop,
                fluentIcon: FluentIcons.stop,
                label: l10n.stop,
                tooltip: l10n.stop,
                onTap: data.onStop,
              ),
              if (data.hasFiles) ...[
                _toolbarDivider(theme),
                AppToolbarButton(
                  macosIcon: FluentIcons.delete,
                  fluentIcon: FluentIcons.delete,
                  label: l10n.clearAll,
                  tooltip: l10n.clearAll,
                  onTap: () => _confirmClearAll(context),
                ),
              ],
              _toolbarDivider(theme),
              AppToolbarButton(
                macosIcon: FluentIcons.settings,
                fluentIcon: FluentIcons.settings,
                label: l10n.settings,
                tooltip: l10n.settings,
                onTap: () => _openSettings(context),
              ),
            ],
          ),
        ),
      ),
      content: ColoredBox(
        color: theme.micaBackgroundColor,
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
                    selectedFilePath: data.selectedFile?.path,
                    encodeState: data.encodeState,
                    onSelect: data.onSelectVideo,
                    onRemove: data.onRemoveFile,
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
      ),
    );
  }

  String? _presetSubLabel() {
    final name = data.currentPresetName;
    if (name == null) return null;
    return data.isPresetModified ? '$name*' : name;
  }

  Widget _toolbarDivider(FluentThemeData theme) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: theme.resources.dividerStrokeColorDefault,
    );
  }

  void _openSettings(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const SettingsPage(),
    );
  }

  void _openEncodeSettings(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => WindowsEncodeSettingsDialog(
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
    final effective = file.overrideSettings ?? globalSettings;
    showDialog<void>(
      context: context,
      builder: (_) => WindowsEncodeSettingsDialog(
        settings: effective,
        sampleFileName: p.basenameWithoutExtension(file.path),
        sampleCreationDate: file.metadata?.creationDate,
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
    showDialog<void>(
      context: context,
      builder: (_) => ContentDialog(
        title: Text(l10n.clearAll),
        content: Text(l10n.clearAllConfirmMessage),
        actions: [
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              data.onClearAll();
              Navigator.of(context).pop();
            },
            child: Text(l10n.delete),
          ),
        ],
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
    final theme = FluentTheme.of(context);
    final accent = theme.accentColor;
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
              Icon(FluentIcons.download, size: 48, color: accent),
              const SizedBox(height: 12),
              Text(l10n.dropFilesHere, style: theme.typography.subtitle),
            ],
          ),
        ),
      );
    }

    // No video selected — placeholder
    if (selectedFile == null) {
      return Container(
        color: theme.micaBackgroundColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.video, size: 48, color: theme.resources.textFillColorSecondary),
              const SizedBox(height: 12),
              Text(l10n.selectVideoToPreview, style: theme.typography.subtitle),
              const SizedBox(height: 4),
              Text(
                l10n.dragDropInstructions,
                style: theme.typography.caption?.copyWith(
                  color: theme.resources.textFillColorSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Video selected — show metadata
    final metadata = selectedFile!.metadata;
    // Derive from the actual rendered mica background — system brightness
    // can differ from the app's effective canvas.
    final isDark = theme.micaBackgroundColor.computeLuminance() < 0.5;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final primaryText = AppColors.textPrimary(brightness);
    final secondaryText = AppColors.textSecondary(brightness);
    final labelStyle = TextStyle(color: secondaryText, fontSize: 12);
    final valueStyle = TextStyle(color: primaryText, fontSize: 14);
    final titleStyle = TextStyle(color: primaryText, fontSize: 16, fontWeight: FontWeight.w600);

    return Container(
      color: theme.micaBackgroundColor,
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
                  AppMetadataRow(label: l10n.resolution, value: metadata.width != null && metadata.height != null ? '${metadata.width}x${metadata.height}' : '-', labelStyle: labelStyle, valueStyle: valueStyle),
                  const SizedBox(height: 6),
                  AppMetadataRow(label: l10n.codec, value: metadata.videoCodec ?? '-', labelStyle: labelStyle, valueStyle: valueStyle),
                  const SizedBox(height: 6),
                  AppMetadataRow(label: l10n.aspectRatio, value: computeAspectRatio(metadata.width, metadata.height) ?? '-', labelStyle: labelStyle, valueStyle: valueStyle),
                  const SizedBox(height: 6),
                  AppMetadataRow(label: l10n.frameRate, value: metadata.frameRate != null ? '${metadata.frameRate!.toStringAsFixed(2)} fps' : '-', labelStyle: labelStyle, valueStyle: valueStyle),
                  const SizedBox(height: 6),
                  AppMetadataRow(label: l10n.duration, value: DateFormatter.formatDuration(metadata.duration), labelStyle: labelStyle, valueStyle: valueStyle),
                  const SizedBox(height: 6),
                  AppMetadataRow(label: l10n.dateTaken, value: DateFormatter.format(metadata.creationDate), labelStyle: labelStyle, valueStyle: valueStyle),
                ],
              ],
            ),
          ),
          // Right: placeholder for future preview/thumbnail
          Expanded(
            child: Center(
              child: Icon(FluentIcons.video, size: 64, color: theme.resources.textFillColorSecondary),
            ),
          ),
        ],
      ),
    );
  }

}
