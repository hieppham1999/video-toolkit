import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/utils/file_size_formatter.dart';
import 'package:video_toolkit/core/utils/video_utils.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_import/data/models/video_file.dart';

import '../home_view_data.dart';

/// Pure UI — receives [HomeViewData], renders Fluent widgets, zero logic.
class WindowsHomeRenderer extends StatelessWidget {
  const WindowsHomeRenderer({super.key, required this.data});

  final HomeViewData data;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;

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
      content: DropTarget(
        onDragDone: (details) {
          data.onFilesDropped(details.files.map((f) => f.path).toList());
        },
        onDragEntered: (_) => data.onDragStateChanged(true),
        onDragExited: (_) => data.onDragStateChanged(false),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalHeight = constraints.maxHeight;
            final previewH = totalHeight * data.previewFraction;
            final tableH = (totalHeight - previewH - 6).clamp(0.0, double.infinity);

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
                SizedBox(
                  height: tableH,
                  child: _VideoTableSection(
                    files: data.files,
                    selectedFilePath: data.selectedFile?.path,
                    onSelect: data.onSelectVideo,
                    onRemove: data.onRemoveFile,
                  ),
                ),
              ],
            );
          },
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
    final labelStyle = theme.typography.caption?.copyWith(
      color: theme.resources.textFillColorSecondary,
    );
    final valueStyle = theme.typography.body;

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
                  style: theme.typography.subtitle,
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
    required this.selectedFilePath,
    required this.onSelect,
    required this.onRemove,
  });

  final List<VideoFile> files;
  final String? selectedFilePath;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onRemove;

  @override
  State<_VideoTableSection> createState() => _VideoTableSectionState();
}

class _VideoTableSectionState extends State<_VideoTableSection> {
  static const _minColWidth = 60.0;
  List<double>? _colWidths;

  List<double> _initWidths(double available) {
    return [
      available * 0.25,
      available * 0.35,
      available * 0.15,
      available * 0.25,
    ];
  }

  void _onResizeColumn(int index, double dx, double available) {
    setState(() {
      _colWidths ??= _initWidths(available);
      final w = _colWidths!;
      final newLeft = (w[index] + dx).clamp(_minColWidth, available);
      final newRight = (w[index + 1] - dx).clamp(_minColWidth, available);
      if (newLeft >= _minColWidth && newRight >= _minColWidth) {
        w[index] = newLeft;
        w[index + 1] = newRight;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = Languages.translate;
    final isDark = theme.brightness == Brightness.dark;
    final selectedBg = isDark ? const Color(0xFF0A3A6B) : const Color(0xFFD0E4F7);

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
        const fixedWidth = 40.0 + 40.0;
        final available = constraints.maxWidth - fixedWidth - 32;
        _colWidths ??= _initWidths(available);
        final w = _colWidths!;
        final headerLabels = [l10n.columnName, l10n.columnPath, l10n.columnSize, l10n.columnImported];

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(
                  bottom: BorderSide(color: theme.resources.controlStrokeColorDefault),
                ),
              ),
              child: SizedBox(
                height: 32,
                child: Row(
                  children: [
                    const SizedBox(width: 40),
                    for (int i = 0; i < 4; i++) ...[
                      SizedBox(
                        width: w[i],
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
                          dividerColor: theme.resources.controlStrokeColorDefault,
                          onDrag: (dx) => _onResizeColumn(i, dx, available),
                        ),
                    ],
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.files.length,
                itemBuilder: (context, index) {
                  final file = widget.files[index];
                  final isSelected = file.path == widget.selectedFilePath;
                  return _VideoTableRow(
                    file: file,
                    colWidths: w,
                    isEven: index.isEven,
                    isSelected: isSelected,
                    selectedBg: selectedBg,
                    onTap: () => widget.onSelect(file.path),
                    onRemove: () => widget.onRemove(file.path),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
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
          width: 8,
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

class _VideoTableRow extends StatelessWidget {
  const _VideoTableRow({
    required this.file,
    required this.colWidths,
    required this.isEven,
    required this.isSelected,
    required this.selectedBg,
    required this.onTap,
    required this.onRemove,
  });

  final VideoFile file;
  final List<double> colWidths;
  final bool isEven;
  final bool isSelected;
  final Color selectedBg;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    Color? bgColor;
    if (isSelected) {
      bgColor = selectedBg;
    } else if (isEven) {
      bgColor = theme.cardColor.withValues(alpha: 0.4);
    }

    const colGap = SizedBox(width: 8);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            bottom: BorderSide(color: theme.resources.controlStrokeColorDefault, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Icon(FluentIcons.video, size: 16, color: theme.accentColor),
            ),
            SizedBox(
              width: colWidths[0],
              child: Text(file.name, style: theme.typography.body, overflow: TextOverflow.ellipsis),
            ),
            colGap,
            SizedBox(
              width: colWidths[1],
              child: Text(
                file.path,
                style: theme.typography.caption?.copyWith(
                  color: theme.resources.textFillColorSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            colGap,
            SizedBox(
              width: colWidths[2],
              child: Text(
                FileSizeFormatter.format(file.sizeInBytes),
                style: theme.typography.caption,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            colGap,
            SizedBox(
              width: colWidths[3],
              child: Text(
                _formatDate(file.importedAt),
                style: theme.typography.caption?.copyWith(
                  color: theme.resources.textFillColorSecondary,
                ),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 40,
              child: IconButton(
                icon: const Icon(FluentIcons.chrome_close, size: 12),
                onPressed: onRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} $h:$m';
  }
}

// ─── Encode Settings Dialog ─────────────────────────────────────

class _EncodeSettingsDialog extends StatefulWidget {
  const _EncodeSettingsDialog({
    required this.settings,
    required this.onSave,
    required this.onCancel,
  });

  final EncodeSettings settings;
  final ValueChanged<EncodeSettings> onSave;
  final VoidCallback onCancel;

  @override
  State<_EncodeSettingsDialog> createState() => _EncodeSettingsDialogState();
}

class _EncodeSettingsDialogState extends State<_EncodeSettingsDialog> {
  late bool _burnTimestamp;

  @override
  void initState() {
    super.initState();
    _burnTimestamp = widget.settings.burnTimestamp;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = Languages.translate;

    return ContentDialog(
      title: Text(l10n.encodeSettings),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                checked: _burnTimestamp,
                onChanged: (v) => setState(() => _burnTimestamp = v ?? false),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.burnTimestamp, style: theme.typography.body),
                    const SizedBox(height: 2),
                    Text(
                      l10n.burnTimestampDescription,
                      style: theme.typography.caption?.copyWith(
                        color: theme.resources.textFillColorSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Button(
          onPressed: widget.onCancel,
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => widget.onSave(
            EncodeSettings(burnTimestamp: _burnTimestamp),
          ),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
