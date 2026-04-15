import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/utils/file_size_formatter.dart';
import 'package:video_toolkit/core/utils/video_utils.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_import/data/models/video_file.dart';

import '../home_view_data.dart';

/// Pure UI — receives [HomeViewData], renders macOS widgets, zero logic.
class MacosHomeRenderer extends StatelessWidget {
  const MacosHomeRenderer({super.key, required this.data});

  final HomeViewData data;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? const Color(0xFFE5E5EA) : const Color(0xFF3A3A3C);
    final l10n = Languages.translate;
    const iconSize = 30.0;

    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('Video Toolkit'),
        titleWidth: 150,
        actions: [
          ToolBarIconButton(
            label: l10n.addVideo,
            icon: MacosIcon(CupertinoIcons.add_circled, color: iconColor, size: iconSize),
            onPressed: data.onPickFiles,
            showLabel: true,
          ),
          const ToolBarDivider(),
          ToolBarIconButton(
            label: l10n.encodeSettings,
            icon: MacosIcon(CupertinoIcons.slider_horizontal_3, color: iconColor, size: iconSize),
            onPressed: () => _openEncodeSettings(context),
            showLabel: true,
          ),
          ToolBarIconButton(
            label: l10n.start,
            icon: MacosIcon(CupertinoIcons.play_fill, color: iconColor, size: iconSize),
            onPressed: data.onStart,
            showLabel: true,
          ),
          ToolBarIconButton(
            label: l10n.stop,
            icon: MacosIcon(CupertinoIcons.stop_fill, color: iconColor, size: iconSize),
            onPressed: data.onStop,
            showLabel: true,
          ),
          if (data.hasFiles) ...[
            const ToolBarDivider(),
            ToolBarIconButton(
              label: l10n.clearAll,
              icon: MacosIcon(CupertinoIcons.trash, color: iconColor),
              onPressed: () => _confirmClearAll(context),
              showLabel: true,
            ),
          ],
        ],
      ),
      children: [
        ContentArea(
          builder: (context, _) {
            return DropTarget(
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
            );
          },
        ),
      ],
    );
  }

  void _openEncodeSettings(BuildContext context) {
    showMacosSheet<void>(
      context: context,
      builder: (_) => _EncodeSettingsSheet(
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
    showMacosAlertDialog<void>(
      context: context,
      builder: (_) => MacosAlertDialog(
        appIcon: const MacosIcon(CupertinoIcons.film, size: 56),
        title: Text(l10n.clearAll),
        message: Text(l10n.clearAllConfirmMessage),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () {
            data.onClearAll();
            Navigator.of(context).pop();
          },
          child: Text(l10n.delete),
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

// ─── Resizable Divider ──────────────────────────────────────────

class _ResizableDivider extends StatelessWidget {
  const _ResizableDivider({required this.onDrag});

  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    final isDark = MacosTheme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? const Color(0xFF38383A) : const Color(0xFFD1D1D6);

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
    final theme = MacosTheme.of(context);
    final accent = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;
    final subtleText = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
    final faintText = isDark ? const Color(0xFF636366) : const Color(0xFF8E8E93);
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
    final labelStyle = theme.typography.caption1.copyWith(color: subtleText);
    final valueStyle = theme.typography.body;

    return Padding(
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
                  style: theme.typography.title3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  selectedFile!.path,
                  style: theme.typography.caption1.copyWith(color: subtleText),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 16),
                if (metadata == null)
                  Text(l10n.metadataNotAvailable, style: labelStyle)
                else ...[
                  _MetadataRow(
                    label: l10n.resolution,
                    value: metadata.width != null && metadata.height != null
                        ? '${metadata.width}x${metadata.height}'
                        : '-',
                    labelStyle: labelStyle,
                    valueStyle: valueStyle,
                  ),
                  const SizedBox(height: 6),
                  _MetadataRow(
                    label: l10n.codec,
                    value: metadata.videoCodec ?? '-',
                    labelStyle: labelStyle,
                    valueStyle: valueStyle,
                  ),
                  const SizedBox(height: 6),
                  _MetadataRow(
                    label: l10n.aspectRatio,
                    value: computeAspectRatio(metadata.width, metadata.height) ?? '-',
                    labelStyle: labelStyle,
                    valueStyle: valueStyle,
                  ),
                  const SizedBox(height: 6),
                  _MetadataRow(
                    label: l10n.frameRate,
                    value: metadata.frameRate != null
                        ? '${metadata.frameRate!.toStringAsFixed(2)} fps'
                        : '-',
                    labelStyle: labelStyle,
                    valueStyle: valueStyle,
                  ),
                ],
              ],
            ),
          ),
          // Right: placeholder for future preview/thumbnail
          Expanded(
            child: Center(
              child: MacosIcon(
                CupertinoIcons.film,
                size: 64,
                color: subtleText,
              ),
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
  final TextStyle labelStyle;
  final TextStyle valueStyle;

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
  // Column width fractions for: Name, Path, Size, Imported
  // Icon (40px) and Action (40px) columns are fixed.
  static const _minColWidth = 60.0;
  List<double>? _colWidths;

  List<double> _initWidths(double available) {
    // Initial proportions: Name 25%, Path 35%, Size 15%, Imported 25%
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
      // Only apply if both columns stay above minimum
      if (newLeft >= _minColWidth && newRight >= _minColWidth) {
        w[index] = newLeft;
        w[index + 1] = newRight;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtleText = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
    final divider = isDark ? const Color(0xFF38383A) : const Color(0xFFD1D1D6);
    final headerBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final altRowBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF9F9F9);
    final selectedBg = isDark ? const Color(0xFF0A3A6B) : const Color(0xFFD0E4F7);
    final l10n = Languages.translate;

    if (widget.files.isEmpty) {
      return Center(
        child: Text(
          l10n.noVideos,
          style: theme.typography.subheadline.copyWith(color: subtleText),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const fixedWidth = 40.0 + 40.0; // icon + action
        final available = constraints.maxWidth - fixedWidth - 32; // 32 = horizontal padding
        _colWidths ??= _initWidths(available);
        final w = _colWidths!;
        final headerLabels = [l10n.columnName, l10n.columnPath, l10n.columnSize, l10n.columnImported];

        return Column(
          children: [
            // ── Header with resize handles ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: headerBg,
                border: Border(bottom: BorderSide(color: divider)),
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
                            style: theme.typography.caption1.copyWith(
                              color: subtleText,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (i < 3)
                        _ColumnResizeHandle(
                          dividerColor: divider,
                          onDrag: (dx) => _onResizeColumn(i, dx, available),
                        ),
                    ],
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
            // ── Rows ──
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
                    altRowBg: altRowBg,
                    selectedBg: selectedBg,
                    dividerColor: divider,
                    subtleTextColor: subtleText,
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
    required this.altRowBg,
    required this.selectedBg,
    required this.dividerColor,
    required this.subtleTextColor,
    required this.onTap,
    required this.onRemove,
  });

  final VideoFile file;
  final List<double> colWidths;
  final bool isEven;
  final bool isSelected;
  final Color altRowBg;
  final Color selectedBg;
  final Color dividerColor;
  final Color subtleTextColor;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);

    Color? bgColor;
    if (isSelected) {
      bgColor = selectedBg;
    } else if (isEven) {
      bgColor = altRowBg;
    }

    // Column gap to match the 8px resize handle in header
    const colGap = SizedBox(width: 8);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(bottom: BorderSide(color: dividerColor, width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: MacosIcon(CupertinoIcons.film, size: 16, color: theme.primaryColor),
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
                style: theme.typography.caption1.copyWith(color: subtleTextColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            colGap,
            SizedBox(
              width: colWidths[2],
              child: Text(
                FileSizeFormatter.format(file.sizeInBytes),
                style: theme.typography.caption1,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            colGap,
            SizedBox(
              width: colWidths[3],
              child: Text(
                _formatDate(file.importedAt),
                style: theme.typography.caption1.copyWith(color: subtleTextColor),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 40,
              child: MacosIconButton(
                icon: MacosIcon(CupertinoIcons.xmark, size: 12, color: subtleTextColor),
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

// ─── Encode Settings Sheet ──────────────────────────────────────

class _EncodeSettingsSheet extends StatefulWidget {
  const _EncodeSettingsSheet({
    required this.settings,
    required this.onSave,
    required this.onCancel,
  });

  final EncodeSettings settings;
  final ValueChanged<EncodeSettings> onSave;
  final VoidCallback onCancel;

  @override
  State<_EncodeSettingsSheet> createState() => _EncodeSettingsSheetState();
}

class _EncodeSettingsSheetState extends State<_EncodeSettingsSheet> {
  late bool _burnTimestamp;

  @override
  void initState() {
    super.initState();
    _burnTimestamp = widget.settings.burnTimestamp;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final l10n = Languages.translate;

    return MacosSheet(
      insetPadding: const EdgeInsets.symmetric(horizontal: 140, vertical: 60),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.encodeSettings, style: theme.typography.title2),
            const SizedBox(height: 24),
            Row(
              children: [
                MacosCheckbox(
                  value: _burnTimestamp,
                  onChanged: (v) => setState(() => _burnTimestamp = v),
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
                        style: theme.typography.caption1.copyWith(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF8E8E93)
                              : const Color(0xFF6E6E73),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PushButton(
                  controlSize: ControlSize.large,
                  secondary: true,
                  onPressed: widget.onCancel,
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                PushButton(
                  controlSize: ControlSize.large,
                  onPressed: () => widget.onSave(
                    EncodeSettings(burnTimestamp: _burnTimestamp),
                  ),
                  child: Text(l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
