import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/utils/file_size_formatter.dart';
import 'package:video_toolkit/core/utils/video_utils.dart';
import 'package:video_toolkit/features/fonts/data/models/font_info.dart';
import 'package:video_toolkit/features/fonts/presentation/cubit/font_cubit.dart';
import 'package:video_toolkit/features/fonts/presentation/cubit/font_state.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_state.dart';
import 'package:video_toolkit/features/video_import/data/models/video_file.dart';
import 'package:video_toolkit/presentation/base/app_state.dart';
import 'package:video_toolkit/presentation/widgets/color_picker_button.dart';

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
                _ResizableDivider(
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
                _OverallProgressBar(encodeState: data.encodeState),
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
      builder: (_) => _EncodeSettingsDialog(
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

// ─── Resizable Divider ──────────────────────────────────────────

class _ResizableDivider extends StatelessWidget {
  const _ResizableDivider({required this.onDrag});

  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final dividerColor = theme.resources.controlStrokeColorDefault;

    return GestureDetector(
      onVerticalDragUpdate: (details) => onDrag(details.delta.dy),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: Container(
          height: 6,
          color: dividerColor.withValues(alpha: 0.3),
          child: Center(
            child: Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: dividerColor,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
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
                  _MetadataRow(label: l10n.resolution, value: metadata.width != null && metadata.height != null ? '${metadata.width}x${metadata.height}' : '-', labelStyle: labelStyle, valueStyle: valueStyle),
                  const SizedBox(height: 6),
                  _MetadataRow(label: l10n.codec, value: metadata.videoCodec ?? '-', labelStyle: labelStyle, valueStyle: valueStyle),
                  const SizedBox(height: 6),
                  _MetadataRow(label: l10n.aspectRatio, value: computeAspectRatio(metadata.width, metadata.height) ?? '-', labelStyle: labelStyle, valueStyle: valueStyle),
                  const SizedBox(height: 6),
                  _MetadataRow(label: l10n.frameRate, value: metadata.frameRate != null ? '${metadata.frameRate!.toStringAsFixed(2)} fps' : '-', labelStyle: labelStyle, valueStyle: valueStyle),
                  const SizedBox(height: 6),
                  _MetadataRow(label: l10n.duration, value: _formatDuration(metadata.duration), labelStyle: labelStyle, valueStyle: valueStyle),
                  const SizedBox(height: 6),
                  _MetadataRow(label: l10n.dateTaken, value: _formatDate(metadata.creationDate), labelStyle: labelStyle, valueStyle: valueStyle),
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

  String _formatDuration(Duration? d) {
    if (d == null) return '-';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    final y = dt.year.toString().padLeft(4, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi';
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label, style: labelStyle)),
        Expanded(child: Text(value, style: valueStyle, overflow: TextOverflow.ellipsis)),
      ],
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
  static const _proportions = [0.25, 0.35, 0.15, 0.25];

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
        final headerLabels = [l10n.columnName, l10n.columnPath, l10n.columnSize, l10n.columnImported];

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
                            alignment: i >= 2 ? Alignment.centerRight : Alignment.centerLeft,
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
                          _ColumnResizeHandle(
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
                                      file.path,
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
                                    child: Text(
                                      _formatDate(file.importedAt),
                                      style: theme.typography.caption?.copyWith(color: theme.resources.textFillColorSecondary),
                                      textAlign: TextAlign.end,
                                    ),
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
      builder: (_) => _EncodeSettingsDialog(
        settings: effective,
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

  String _formatDate(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} $h:$m';
  }
}

class _ColumnResizeHandle extends StatelessWidget {
  const _ColumnResizeHandle({required this.dividerColor, required this.onDrag});

  final Color dividerColor;
  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: SizedBox(
          width: _VideoTableSectionState._gapWidth,
          height: double.infinity,
          child: Center(
            child: Container(
              width: 1,
              height: 16,
              color: dividerColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Overall Progress Bar ───────────────────────────────────────

class _OverallProgressBar extends StatelessWidget {
  const _OverallProgressBar({required this.encodeState});

  final VideoEncodeState encodeState;

  @override
  Widget build(BuildContext context) {
    final status = encodeState.status;
    if (status == EncodeStatus.idle) return const SizedBox.shrink();

    final theme = FluentTheme.of(context);
    final total = encodeState.totalFiles;
    final current = encodeState.currentIndex;
    final completed = encodeState.completedCount;
    final failed = encodeState.failedFiles;
    final overallPercent = total > 0 ? current / total : 0.0;

    String statusText;
    Color statusColor;
    switch (status) {
      case EncodeStatus.encoding:
        statusText = 'Encoding $current / $total'
            '${encodeState.progress.speed > 0 ? '  ·  ${encodeState.progress.speed.toStringAsFixed(1)}x' : ''}';
        statusColor = theme.resources.textFillColorSecondary;
      case EncodeStatus.done:
        statusText = 'Done — $completed / $total completed';
        statusColor = const Color(0xFF34C759);
      case EncodeStatus.error:
        statusText = '$completed completed, ${failed.length} failed';
        statusColor = const Color(0xFFFF3B30);
      case EncodeStatus.idle:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.resources.controlStrokeColorDefault)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  statusText,
                  style: (theme.typography.caption ?? const TextStyle()).copyWith(color: statusColor),
                ),
              ),
              Text(
                '${(overallPercent * 100).toStringAsFixed(0)}%',
                style: theme.typography.caption?.copyWith(color: theme.resources.textFillColorSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ProgressBar(value: overallPercent * 100),
        ],
      ),
    );
  }
}

// ─── Encode Settings Dialog ─────────────────────────────────────

class _EncodeSettingsDialog extends StatefulWidget {
  const _EncodeSettingsDialog({
    required this.settings,
    required this.onSave,
    required this.onCancel,
    this.onReset,
  });

  final EncodeSettings settings;
  final ValueChanged<EncodeSettings> onSave;
  final VoidCallback onCancel;
  final VoidCallback? onReset;

  @override
  State<_EncodeSettingsDialog> createState() => _EncodeSettingsDialogState();
}

class _EncodeSettingsDialogState extends State<_EncodeSettingsDialog> {
  late VideoEncoder _codec;
  late EncodePreset _preset;
  late int _crf;
  late OutputExtension _outputExtension;
  late String _resolution;
  late AudioCodec _audioCodec;
  late AudioBitrate _audioBitrate;
  late List<TextOverlay> _textOverlays;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    final s = widget.settings;
    _codec = s.codec;
    _preset = s.preset;
    _crf = s.crf;
    _outputExtension = s.outputExtension;
    _resolution = s.resolution ?? '';
    _audioCodec = s.audioCodec;
    _audioBitrate = s.audioBitrate;
    _textOverlays = List.of(s.textOverlays);
  }

  EncodeSettings _buildSettings() {
    return EncodeSettings(
      codec: _codec,
      preset: _preset,
      crf: _crf,
      outputExtension: _outputExtension,
      resolution: _resolution.isEmpty ? null : _resolution,
      audioCodec: _audioCodec,
      audioBitrate: _audioBitrate,
      textOverlays: _textOverlays,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = Languages.translate;

    final tabs = ['Container', 'Sizing', 'Filter', 'Audio'];

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 520, maxHeight: 480),
      title: Text(l10n.encodeSettings),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (int i = 0; i < tabs.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Button(
                  onPressed: () => setState(() => _selectedTab = i),
                  child: Text(
                    tabs[i],
                    style: i == _selectedTab
                        ? theme.typography.body?.copyWith(fontWeight: FontWeight.w600)
                        : theme.typography.body,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: switch (_selectedTab) {
              0 => _buildContainerTab(theme),
              1 => _buildSizingTab(theme),
              2 => _buildFilterTab(theme, l10n),
              3 => _buildAudioTab(theme),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
      ),
      actions: [
        if (widget.onReset != null)
          Button(onPressed: widget.onReset, child: const Text('Reset to Global')),
        Button(onPressed: widget.onCancel, child: Text(l10n.cancel)),
        FilledButton(onPressed: () => widget.onSave(_buildSettings()), child: Text(l10n.save)),
      ],
    );
  }

  Widget _buildContainerTab(FluentThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FluentDropdown<OutputExtension>(label: 'Extension', value: _outputExtension, items: OutputExtension.values, itemLabel: (e) => e.value, onChanged: (v) => setState(() => _outputExtension = v)),
        const SizedBox(height: 12),
        _FluentDropdown<VideoEncoder>(label: 'Video Codec', value: _codec, items: VideoEncoder.values, itemLabel: (e) => e.value, onChanged: (v) => setState(() => _codec = v)),
        const SizedBox(height: 12),
        _FluentDropdown<EncodePreset>(label: 'Preset', value: _preset, items: EncodePreset.values, itemLabel: (e) => e.value, onChanged: (v) => setState(() => _preset = v)),
        const SizedBox(height: 12),
        _FluentField(label: 'CRF', value: '$_crf', onChanged: (v) => setState(() => _crf = int.tryParse(v) ?? _crf)),
      ],
    );
  }

  Widget _buildSizingTab(FluentThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FluentField(label: 'Resolution', value: _resolution, onChanged: (v) => setState(() => _resolution = v), hint: '1920:1080 (empty = original)'),
      ],
    );
  }

  Widget _buildFilterTab(FluentThemeData theme, dynamic l10n) {
    final fontState = context.watch<FontCubit>().state;
    final fonts = fontState is NormalState<FontState>
        ? fontState.data.fonts
        : const <FontInfo>[];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Text Overlays', style: theme.typography.bodyStrong),
              const Spacer(),
              Button(
                onPressed: () => setState(() {
                  _textOverlays = [..._textOverlays, const TextOverlay(text: 'Text')];
                }),
                child: const Text('+ Add Text'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _textOverlays.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Text ${i + 1}', style: theme.typography.body),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(FluentIcons.chrome_close, size: 12),
                            onPressed: () => setState(() {
                              _textOverlays = [..._textOverlays]..removeAt(i);
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _FluentDropdown<TextOverlayType>(
                        label: l10n.overlayType,
                        value: _textOverlays[i].type,
                        items: TextOverlayType.values,
                        itemLabel: (e) => switch (e) {
                          TextOverlayType.custom => l10n.overlayTypeCustom,
                          TextOverlayType.timestamp => l10n.overlayTypeTimestamp,
                        },
                        onChanged: (v) => setState(() {
                          _textOverlays = [..._textOverlays]..[i] = _textOverlays[i].copyWith(
                            type: v,
                            text: v == TextOverlayType.timestamp ? '' : _textOverlays[i].text,
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      if (_textOverlays[i].type == TextOverlayType.custom) ...[
                        _FluentField(
                          label: 'Text',
                          value: _textOverlays[i].text,
                          onChanged: (v) => setState(() {
                            _textOverlays = [..._textOverlays]..[i] = _textOverlays[i].copyWith(text: v);
                          }),
                          hint: r"%{pts\:hms} for timestamp",
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Expanded(child: _FluentField(
                            label: 'Size',
                            value: '${_textOverlays[i].fontSize}',
                            onChanged: (v) => setState(() {
                              _textOverlays = [..._textOverlays]..[i] = _textOverlays[i].copyWith(fontSize: int.tryParse(v) ?? 24);
                            }),
                          )),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                SizedBox(width: 100, child: Text('Color', style: theme.typography.body)),
                                const SizedBox(width: 8),
                                ColorPickerButton(
                                  value: _textOverlays[i].fontColor,
                                  onChanged: (v) => setState(() {
                                    _textOverlays = [..._textOverlays]..[i] = _textOverlays[i].copyWith(fontColor: v);
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _FluentField(
                            label: 'Border',
                            value: '${_textOverlays[i].borderWidth}',
                            onChanged: (v) => setState(() {
                              _textOverlays = [..._textOverlays]..[i] = _textOverlays[i].copyWith(borderWidth: int.tryParse(v) ?? 0);
                            }),
                            hint: '0 = no border',
                          )),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                SizedBox(width: 100, child: Text('Border Color', style: theme.typography.body)),
                                const SizedBox(width: 8),
                                ColorPickerButton(
                                  value: _textOverlays[i].borderColor,
                                  onChanged: (v) => setState(() {
                                    _textOverlays = [..._textOverlays]..[i] = _textOverlays[i].copyWith(borderColor: v);
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _FluentDropdown<TextOverlayPosition>(
                        label: 'Position',
                        value: _textOverlays[i].position,
                        items: TextOverlayPosition.values,
                        itemLabel: (e) => e.name,
                        onChanged: (v) => setState(() {
                          _textOverlays = [..._textOverlays]..[i] = _textOverlays[i].copyWith(position: v);
                        }),
                      ),
                      const SizedBox(height: 8),
                      _FluentDropdown<String>(
                        label: l10n.font,
                        value: _textOverlays[i].fontFile ?? '',
                        items: ['', ...fonts.map((f) => f.path)],
                        itemLabel: (v) {
                          if (v.isEmpty) return l10n.fontDefault;
                          final match = fonts.where((e) => e.path == v).firstOrNull;
                          if (match == null) return v;
                          return match.isBundled ? '${match.name} (${l10n.fontBundled})' : match.name;
                        },
                        onChanged: (v) => setState(() {
                          _textOverlays = [..._textOverlays]..[i] = _textOverlays[i].copyWith(fontFile: v.isEmpty ? null : v);
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAudioTab(FluentThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FluentDropdown<AudioCodec>(label: 'Audio Codec', value: _audioCodec, items: AudioCodec.values, itemLabel: (e) => e.value, onChanged: (v) => setState(() => _audioCodec = v)),
        const SizedBox(height: 12),
        _FluentDropdown<AudioBitrate>(label: 'Bitrate', value: _audioBitrate, items: AudioBitrate.values, itemLabel: (e) => e.value, onChanged: (v) => setState(() => _audioBitrate = v)),
      ],
    );
  }
}

class _FluentField extends StatelessWidget {
  const _FluentField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: theme.typography.body)),
        const SizedBox(width: 8),
        Expanded(
          child: TextBox(
            controller: TextEditingController(text: value),
            placeholder: hint,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _FluentDropdown<T> extends StatelessWidget {
  const _FluentDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: theme.typography.body)),
        const SizedBox(width: 8),
        ComboBox<T>(
          value: value,
          onChanged: (v) { if (v != null) onChanged(v); },
          items: items
              .map((e) => ComboBoxItem(value: e, child: Text(itemLabel(e))))
              .toList(),
        ),
      ],
    );
  }
}
