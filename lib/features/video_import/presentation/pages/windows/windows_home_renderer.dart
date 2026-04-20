import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/utils/date_formatter.dart';
import 'package:video_toolkit/core/utils/file_size_formatter.dart';
import 'package:video_toolkit/core/utils/filename_template.dart';
import 'package:video_toolkit/core/utils/video_utils.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_state.dart';
import 'package:video_toolkit/features/video_import/data/models/video_file.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_column_resize_handle.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_metadata_row.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_overall_progress_bar.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_resizable_divider.dart';
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
      header: PageHeader(
        title: const Text('Video Toolkit'),
        commandBar: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Button(
              onPressed: data.onPickFiles,
              child: Row(
                children: [
                  const Icon(FluentIcons.add, size: 14),
                  const SizedBox(width: 6),
                  Text(l10n.addVideo),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Button(
              onPressed: () => _openEncodeSettings(context),
              child: Row(
                children: [
                  const Icon(FluentIcons.settings, size: 14),
                  const SizedBox(width: 6),
                  Text(l10n.encodeSettings),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: data.onStart,
              child: Row(
                children: [
                  const Icon(FluentIcons.play, size: 14),
                  const SizedBox(width: 6),
                  Text(l10n.start),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Button(
              onPressed: data.onStop,
              child: Row(
                children: [
                  const Icon(FluentIcons.stop, size: 14),
                  const SizedBox(width: 6),
                  Text(l10n.stop),
                ],
              ),
            ),
            if (data.hasFiles) ...[
              const SizedBox(width: 16),
              Button(
                onPressed: () => _confirmClearAll(context),
                child: Row(
                  children: [
                    const Icon(FluentIcons.delete, size: 14),
                    const SizedBox(width: 6),
                    Text(l10n.clearAll),
                  ],
                ),
              ),
            ],
          ],
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
                  child: _VideoTableSection(
                    files: data.files,
                    globalSettings: data.encodeSettings,
                    selectedFilePath: data.selectedFile?.path,
                    encodeState: data.encodeState,
                    onSelect: data.onSelectVideo,
                    onRemove: data.onRemoveFile,
                    onUpdateFileSettings: data.onUpdateFileSettings,
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
    final primaryText = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final secondaryText = isDark ? const Color(0xFFAEAEB2) : const Color(0xFF6E6E73);
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

// ─── Video Table Section ────────────────────────────────────────

class _VideoTableSection extends StatefulWidget {
  const _VideoTableSection({
    required this.files,
    required this.globalSettings,
    required this.selectedFilePath,
    required this.encodeState,
    required this.onSelect,
    required this.onRemove,
    required this.onUpdateFileSettings,
  });

  final List<VideoFile> files;
  final EncodeSettings globalSettings;
  final String? selectedFilePath;
  final VideoEncodeState encodeState;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onRemove;
  final void Function(String path, EncodeSettings? settings) onUpdateFileSettings;

  @override
  State<_VideoTableSection> createState() => _VideoTableSectionState();
}

class _VideoTableSectionState extends State<_VideoTableSection> {
  static const _minColWidth = 60.0;
  static const _gapWidth = 8.0;
  static const _actionWidth = 72.0; // settings + delete buttons
  static const _headerHeight = 32.0;
  static const _proportions = [0.22, 0.33, 0.15, 0.3];

  final List<double> _dragOffsets = [0, 0, 0, 0];

  List<double> _computeWidths(double viewportWidth) {
    final available = viewportWidth - _actionWidth - 32 - (_gapWidth * 3);
    return List.generate(4, (i) {
      return (available * _proportions[i] + _dragOffsets[i]).clamp(_minColWidth, double.infinity);
    });
  }

  void _onResizeColumn(int index, double dx) {
    setState(() {
      _dragOffsets[index] += dx;
      _dragOffsets[index + 1] -= dx;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = Languages.translate;
    final isDark = theme.brightness == Brightness.dark;
    final selectedBg = isDark ? const Color(0xFF0A3A6B) : const Color(0xFFD0E4F7);
    final altRowBg = theme.cardColor.withValues(alpha: 0.4);
    final dividerColor = theme.resources.controlStrokeColorDefault;
    final isEncoding = widget.encodeState.status == EncodeStatus.encoding;

    if (widget.files.isEmpty) {
      return Center(
        child: Text(
          l10n.noVideos,
          style: theme.typography.body?.copyWith(
            color: theme.resources.textFillColorSecondary,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final colWidths = _computeWidths(constraints.maxWidth);
        final contentWidth = colWidths.fold(0.0, (s, w) => s + w) + (_gapWidth * 3) + _actionWidth + 32;
        final effectiveWidth = contentWidth.clamp(constraints.maxWidth, double.infinity);
        final headerLabels = [l10n.columnName, l10n.columnPath, l10n.columnSize, l10n.columnOutput];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: effectiveWidth,
            height: constraints.maxHeight,
            child: Column(
              children: [
                Container(
                  height: _headerHeight,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    border: Border(bottom: BorderSide(color: dividerColor)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      for (int i = 0; i < 4; i++) ...[
                        SizedBox(
                          width: colWidths[i],
                          child: Align(
                            alignment: i == 2 ? Alignment.centerRight : Alignment.centerLeft,
                            child: Text(
                              headerLabels[i],
                              style: (theme.typography.caption ?? const TextStyle()).copyWith(
                                color: theme.resources.textFillColorSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (i < 3)
                          AppColumnResizeHandle(
                            dividerColor: dividerColor,
                            onDrag: (dx) => _onResizeColumn(i, dx),
                          ),
                      ],
                      const SizedBox(width: _actionWidth),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.files.length,
                    itemBuilder: (context, index) {
                      final file = widget.files[index];
                      final isSelected = file.path == widget.selectedFilePath;
                      final isCurrentFile = isEncoding && widget.encodeState.currentFilePath == file.path;
                      final isDone = isEncoding && widget.encodeState.currentIndex > index;

                      Color? bgColor;
                      if (isSelected) {
                        bgColor = selectedBg;
                      } else if (index.isEven) {
                        bgColor = altRowBg;
                      }

                      final effectiveSettings = file.overrideSettings ?? widget.globalSettings;
                      final baseName = p.basenameWithoutExtension(file.path);
                      final outName = FilenameTemplate.apply(
                        effectiveSettings.outputNameTemplate,
                        originalName: baseName,
                        creationDate: file.metadata?.creationDate,
                      );
                      final outputDisplay = '$outName.${effectiveSettings.outputExtension.value}';

                      return GestureDetector(
                        onTap: () => widget.onSelect(file.path),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: bgColor,
                            border: Border(bottom: BorderSide(color: dividerColor, width: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: colWidths[0],
                                    child: Row(
                                      children: [
                                        Icon(
                                          isDone ? FluentIcons.check_mark : FluentIcons.video,
                                          size: 16,
                                          color: isDone ? const Color(0xFF34C759) : theme.accentColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(file.name, style: theme.typography.body, overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: _gapWidth),
                                  SizedBox(
                                    width: colWidths[1],
                                    child: Text(
                                      p.dirname(file.path),
                                      style: theme.typography.caption?.copyWith(color: theme.resources.textFillColorSecondary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: _gapWidth),
                                  SizedBox(
                                    width: colWidths[2],
                                    child: Text(FileSizeFormatter.format(file.sizeInBytes), style: theme.typography.caption, textAlign: TextAlign.end),
                                  ),
                                  const SizedBox(width: _gapWidth),
                                  SizedBox(
                                    width: colWidths[3],
                                    child: Text(outputDisplay, style: theme.typography.caption, overflow: TextOverflow.ellipsis),
                                  ),
                                  SizedBox(
                                    width: _actionWidth,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            FluentIcons.settings,
                                            size: 12,
                                            color: file.overrideSettings != null
                                                ? theme.accentColor
                                                : theme.resources.textFillColorSecondary,
                                          ),
                                          onPressed: () => _openFileSettings(
                                            context,
                                            file,
                                            widget.globalSettings,
                                            widget.onUpdateFileSettings,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(FluentIcons.chrome_close, size: 12),
                                          onPressed: () => widget.onRemove(file.path),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (isCurrentFile)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: ProgressBar(value: widget.encodeState.progress.percent * 100),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
}

