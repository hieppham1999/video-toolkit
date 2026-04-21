import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
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
import 'package:video_toolkit/features/video_import/presentation/widgets/macos/macos_encode_settings_sheet.dart';

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
            inToolbarBuilder: (_) => _toolbarBtn(
              theme: theme,
              iconColor: iconColor,
              icon: CupertinoIcons.add_circled,
              label: l10n.addVideo,
              onTap: data.onPickFiles,
            ),
          ),
          const ToolBarDivider(),
          CustomToolbarItem(
            tooltipMessage: l10n.encodeSettings,
            inToolbarBuilder: (_) => _toolbarBtn(
              theme: theme,
              iconColor: iconColor,
              icon: CupertinoIcons.slider_horizontal_3,
              label: l10n.encodeSettings,
              subLabel: _presetSubLabel(),
              onTap: () => _openEncodeSettings(context),
            ),
          ),
          CustomToolbarItem(
            tooltipMessage: l10n.start,
            inToolbarBuilder: (_) => _toolbarBtn(
              theme: theme,
              iconColor: iconColor,
              icon: CupertinoIcons.play_fill,
              label: l10n.start,
              onTap: data.onStart,
            ),
          ),
          CustomToolbarItem(
            tooltipMessage: l10n.stop,
            inToolbarBuilder: (_) => _toolbarBtn(
              theme: theme,
              iconColor: iconColor,
              icon: CupertinoIcons.stop_fill,
              label: l10n.stop,
              onTap: data.onStop,
            ),
          ),
          if (data.hasFiles) ...[
            const ToolBarDivider(),
            CustomToolbarItem(
              tooltipMessage: l10n.clearAll,
              inToolbarBuilder: (_) => _toolbarBtn(
                theme: theme,
                iconColor: iconColor,
                icon: CupertinoIcons.trash,
                label: l10n.clearAll,
                onTap: () => _confirmClearAll(context),
              ),
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

  /// Fixed total height for every toolbar button so that macos_ui's internal
  /// Row (center-aligned) renders all icons at the same Y coordinate whether
  /// or not a sublabel is present.
  static const double _btnHeight = 68;

  Widget _toolbarBtn({
    required MacosThemeData theme,
    required Color iconColor,
    required IconData icon,
    required String label,
    String? subLabel,
    VoidCallback? onTap,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final subtleColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
    final enabled = onTap != null;
    final effectiveIconColor =
        enabled ? iconColor : iconColor.withValues(alpha: 0.4);
    final effectiveLabelColor =
        enabled ? iconColor : iconColor.withValues(alpha: 0.5);

    return SizedBox(
      height: _btnHeight,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MacosIcon(icon, color: effectiveIconColor, size: 30),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.typography.caption1.copyWith(color: effectiveLabelColor),
              ),
              if (subLabel != null)
                Text(
                  subLabel,
                  style: theme.typography.caption2.copyWith(color: subtleColor),
                ),
            ],
          ),
        ),
      ),
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
  // Proportions for: Name, Path, Size, Output
  static const _proportions = [0.22, 0.33, 0.15, 0.3];

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
        final headerLabels = [l10n.columnName, l10n.columnPath, l10n.columnSize, l10n.columnOutput];

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
                            alignment: i == 2 ? Alignment.centerRight : Alignment.centerLeft,
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
                          AppColumnResizeHandle(
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
                                    child: Text(p.dirname(file.path), style: theme.typography.caption1.copyWith(color: subtleText), overflow: TextOverflow.ellipsis),
                                  ),
                                  const SizedBox(width: _gapWidth),
                                  SizedBox(
                                    width: colWidths[2],
                                    child: Text(FileSizeFormatter.format(file.sizeInBytes), style: theme.typography.caption1, textAlign: TextAlign.end),
                                  ),
                                  const SizedBox(width: _gapWidth),
                                  SizedBox(
                                    width: colWidths[3],
                                    child: Text(outputDisplay, style: theme.typography.caption1, overflow: TextOverflow.ellipsis),
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
      builder: (_) => MacosEncodeSettingsSheet(
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

