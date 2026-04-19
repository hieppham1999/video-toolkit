import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
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
      backgroundColor: CupertinoDynamicColor.maybeResolve(theme.canvasColor, context) ??
                theme.canvasColor,
      toolBar: ToolBar(
        title: const Text('Video Toolkit'),
        titleWidth: 150,
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.maybeResolve(theme.canvasColor, context) ??
                theme.canvasColor,
        ),
          
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
    // Trust multiple sources — whichever detects dark wins. This covers the
    // case where system brightness, canvas luminance, and theme.brightness
    // may disagree (e.g., MacosApp themeMode lag, native chrome override).
    final resolvedCanvas =
        CupertinoDynamicColor.maybeResolve(theme.canvasColor, context) ??
            theme.canvasColor;
    final isDark = theme.brightness == Brightness.dark ||
        MediaQuery.platformBrightnessOf(context) == Brightness.dark ||
        resolvedCanvas.computeLuminance() < 0.5;
    final subtleText = isDark ? const Color(0xFFAEAEB2) : const Color(0xFF6E6E73);
    final faintText = isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93);
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
    final primaryText = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
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
                  const SizedBox(height: 6),
                  _MetadataRow(
                    label: l10n.duration,
                    value: _formatDuration(metadata.duration),
                    labelStyle: labelStyle,
                    valueStyle: valueStyle,
                  ),
                  const SizedBox(height: 6),
                  _MetadataRow(
                    label: l10n.dateTaken,
                    value: _formatDate(metadata.creationDate),
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
  // Proportions for: Name, Path, Size, Imported
  static const _proportions = [0.25, 0.35, 0.15, 0.25];

  // Manual offsets from user drag (starts at 0 for each column)
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
    final theme = MacosTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtleText = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
    final divider = isDark ? const Color(0xFF38383A) : const Color(0xFFD1D1D6);
    final headerBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final altRowBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF9F9F9);
    final selectedBg = isDark ? const Color(0xFF0A3A6B) : const Color(0xFFD0E4F7);
    final l10n = Languages.translate;
    final isEncoding = widget.encodeState.status == EncodeStatus.encoding;

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
                // ── Header ──
                Container(
                  height: _headerHeight,
                  decoration: BoxDecoration(
                    color: headerBg,
                    border: Border(bottom: BorderSide(color: divider)),
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
                            onDrag: (dx) => _onResizeColumn(i, dx),
                          ),
                      ],
                      const SizedBox(width: _actionWidth),
                    ],
                  ),
                ),
                // ── Rows ──
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
                            border: Border(bottom: BorderSide(color: divider, width: 0.5)),
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
                                        MacosIcon(
                                          isDone
                                              ? CupertinoIcons.checkmark_circle_fill
                                              : CupertinoIcons.film,
                                          size: 16,
                                          color: isDone
                                              ? const Color(0xFF34C759)
                                              : theme.primaryColor,
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
                                    child: Text(file.path, style: theme.typography.caption1.copyWith(color: subtleText), overflow: TextOverflow.ellipsis),
                                  ),
                                  const SizedBox(width: _gapWidth),
                                  SizedBox(
                                    width: colWidths[2],
                                    child: Text(FileSizeFormatter.format(file.sizeInBytes), style: theme.typography.caption1, textAlign: TextAlign.end),
                                  ),
                                  const SizedBox(width: _gapWidth),
                                  SizedBox(
                                    width: colWidths[3],
                                    child: Text(_formatDate(file.importedAt), style: theme.typography.caption1.copyWith(color: subtleText), textAlign: TextAlign.end),
                                  ),
                                  SizedBox(
                                    width: _actionWidth,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        MacosIconButton(
                                          icon: MacosIcon(
                                            CupertinoIcons.slider_horizontal_3,
                                            size: 12,
                                            color: file.overrideSettings != null
                                                ? theme.primaryColor
                                                : subtleText,
                                          ),
                                          onPressed: () => _openFileSettings(
                                            context,
                                            file,
                                            widget.globalSettings,
                                            widget.onUpdateFileSettings,
                                          ),
                                        ),
                                        MacosIconButton(
                                          icon: MacosIcon(CupertinoIcons.xmark, size: 12, color: subtleText),
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
                                  child: ProgressBar(
                                    value: widget.encodeState.progress.percent * 100,
                                  ),
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
    showMacosSheet<void>(
      context: context,
      builder: (_) => _EncodeSettingsSheet(
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

    final theme = MacosTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtleText = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
    final divider = isDark ? const Color(0xFF38383A) : const Color(0xFFD1D1D6);
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);

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
        statusColor = subtleText;
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
        color: bgColor,
        border: Border(top: BorderSide(color: divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(statusText, style: theme.typography.caption1.copyWith(color: statusColor)),
              ),
              Text(
                '${(overallPercent * 100).toStringAsFixed(0)}%',
                style: theme.typography.caption1.copyWith(color: subtleText),
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

// ─── Encode Settings Sheet ──────────────────────────────────────

class _EncodeSettingsSheet extends StatefulWidget {
  const _EncodeSettingsSheet({
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
  State<_EncodeSettingsSheet> createState() => _EncodeSettingsSheetState();
}

class _EncodeSettingsSheetState extends State<_EncodeSettingsSheet> {
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
    final theme = MacosTheme.of(context);
    final l10n = Languages.translate;

    final tabs = ['Container', 'Sizing', 'Filter', 'Audio'];

    return MacosSheet(
      insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 30),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.encodeSettings, style: theme.typography.title2),
            const SizedBox(height: 16),
            // Tab bar
            Row(
              children: [
                for (int i = 0; i < tabs.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  PushButton(
                    controlSize: ControlSize.regular,
                    secondary: i != _selectedTab,
                    onPressed: () => setState(() => _selectedTab = i),
                    child: Text(tabs[i]),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            // Tab content
            Expanded(
              child: switch (_selectedTab) {
                0 => _buildContainerTab(theme),
                1 => _buildSizingTab(theme),
                2 => _buildFilterTab(theme, l10n),
                3 => _buildAudioTab(theme),
                _ => const SizedBox.shrink(),
              },
            ),
            const SizedBox(height: 16),
            // Actions
            Row(
              children: [
                if (widget.onReset != null)
                  PushButton(
                    controlSize: ControlSize.large,
                    secondary: true,
                    onPressed: widget.onReset,
                    child: const Text('Reset to Global'),
                  ),
                const Spacer(),
                PushButton(
                  controlSize: ControlSize.large,
                  secondary: true,
                  onPressed: widget.onCancel,
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                PushButton(
                  controlSize: ControlSize.large,
                  onPressed: () => widget.onSave(_buildSettings()),
                  child: Text(l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainerTab(MacosThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MacosDropdown<OutputExtension>(
          label: 'Extension',
          value: _outputExtension,
          items: OutputExtension.values,
          itemLabel: (e) => e.value,
          onChanged: (v) => setState(() => _outputExtension = v),
        ),
        const SizedBox(height: 12),
        _MacosDropdown<VideoEncoder>(
          label: 'Video Codec',
          value: _codec,
          items: VideoEncoder.values,
          itemLabel: (e) => e.value,
          onChanged: (v) => setState(() => _codec = v),
        ),
        const SizedBox(height: 12),
        _MacosDropdown<EncodePreset>(
          label: 'Preset',
          value: _preset,
          items: EncodePreset.values,
          itemLabel: (e) => e.value,
          onChanged: (v) => setState(() => _preset = v),
        ),
        const SizedBox(height: 12),
        _MacosField(
          label: 'CRF',
          value: '$_crf',
          onChanged: (v) => setState(() => _crf = int.tryParse(v) ?? _crf),
        ),
      ],
    );
  }

  Widget _buildSizingTab(MacosThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MacosField(
          label: 'Resolution',
          value: _resolution,
          onChanged: (v) => setState(() => _resolution = v),
          hint: '1920:1080 (empty = original)',
        ),
      ],
    );
  }

  Widget _buildFilterTab(MacosThemeData theme, dynamic l10n) {
    final isDark = theme.brightness == Brightness.dark;
    final subtleText = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);

    final fonts = context.watch<FontCubit>().state is NormalState<FontState>
        ? (context.watch<FontCubit>().state as NormalState<FontState>).data.fonts
        : const <FontInfo>[];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Text Overlays', style: theme.typography.headline),
              const Spacer(),
              PushButton(
                controlSize: ControlSize.small,
                secondary: true,
                onPressed: () {
                  setState(() {
                    _textOverlays = [..._textOverlays, const TextOverlay(text: 'Text')];
                  });
                },
                child: const Text('+ Add Text'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _textOverlays.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Text ${i + 1}', style: theme.typography.body),
                        const Spacer(),
                        MacosIconButton(
                          icon: MacosIcon(CupertinoIcons.xmark, size: 12, color: subtleText),
                          onPressed: () => setState(() {
                            _textOverlays = [..._textOverlays]..removeAt(i);
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _MacosDropdown<TextOverlayType>(
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
                      _MacosField(
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
                        Expanded(
                          child: _MacosField(
                            label: 'Size',
                            value: '${_textOverlays[i].fontSize}',
                            onChanged: (v) => setState(() {
                              _textOverlays = [..._textOverlays]..[i] = _textOverlays[i].copyWith(fontSize: int.tryParse(v) ?? 24);
                            }),
                          ),
                        ),
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
                        Expanded(
                          child: _MacosField(
                            label: 'Border',
                            value: '${_textOverlays[i].borderWidth}',
                            onChanged: (v) => setState(() {
                              _textOverlays = [..._textOverlays]..[i] = _textOverlays[i].copyWith(borderWidth: int.tryParse(v) ?? 0);
                            }),
                            hint: '0 = no border',
                          ),
                        ),
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
                    _MacosDropdown<TextOverlayPosition>(
                      label: 'Position',
                      value: _textOverlays[i].position,
                      items: TextOverlayPosition.values,
                      itemLabel: (e) => e.name,
                      onChanged: (v) => setState(() {
                        _textOverlays = [..._textOverlays]..[i] = _textOverlays[i].copyWith(position: v);
                      }),
                    ),
                    const SizedBox(height: 8),
                    _MacosDropdown<String>(
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
        ],
      ),
    );
  }

  Widget _buildAudioTab(MacosThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MacosDropdown<AudioCodec>(
          label: 'Audio Codec',
          value: _audioCodec,
          items: AudioCodec.values,
          itemLabel: (e) => e.value,
          onChanged: (v) => setState(() => _audioCodec = v),
        ),
        const SizedBox(height: 12),
        _MacosDropdown<AudioBitrate>(
          label: 'Bitrate',
          value: _audioBitrate,
          items: AudioBitrate.values,
          itemLabel: (e) => e.value,
          onChanged: (v) => setState(() => _audioBitrate = v),
        ),
      ],
    );
  }
}

class _MacosField extends StatelessWidget {
  const _MacosField({
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
    final theme = MacosTheme.of(context);
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: theme.typography.body)),
        const SizedBox(width: 8),
        Expanded(
          child: MacosTextField(
            controller: TextEditingController(text: value),
            placeholder: hint,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _MacosDropdown<T> extends StatelessWidget {
  const _MacosDropdown({
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
    final theme = MacosTheme.of(context);
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: theme.typography.body)),
        const SizedBox(width: 8),
        MacosPopupButton<T>(
          value: value,
          onChanged: (v) { if (v != null) onChanged(v); },
          items: items
              .map((e) => MacosPopupMenuItem(value: e, child: Text(itemLabel(e))))
              .toList(),
        ),
      ],
    );
  }
}
