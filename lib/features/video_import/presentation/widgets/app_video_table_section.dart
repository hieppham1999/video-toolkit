import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/core/utils/file_size_formatter.dart';
import 'package:video_toolkit/core/utils/filename_template.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_state.dart';
import 'package:video_toolkit/features/video_import/data/models/video_file.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_column_resize_handle.dart';

/// Cross-platform table listing imported videos. Layout, resize, selection,
/// alt-row striping and per-row progress are platform-agnostic; only the
/// theming primitives (colors, icons, action buttons, text styles) branch on
/// platform at the leaves.
class AppVideoTableSection extends StatefulWidget {
  const AppVideoTableSection({
    super.key,
    required this.files,
    required this.globalSettings,
    required this.selectedFilePath,
    required this.encodeState,
    required this.onSelect,
    required this.onRemove,
    required this.onOpenFileSettings,
  });

  final List<VideoFile> files;
  final EncodeSettings globalSettings;
  final String? selectedFilePath;
  final VideoEncodeState encodeState;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onRemove;
  final ValueChanged<VideoFile> onOpenFileSettings;

  @override
  State<AppVideoTableSection> createState() => _AppVideoTableSectionState();
}

class _AppVideoTableSectionState extends State<AppVideoTableSection> {
  static const _minColWidth = 60.0;
  static const _gapWidth = 8.0;
  static const _actionWidth = 72.0;
  static const _statusWidth = 140.0;
  static const _headerHeight = 32.0;
  static const _proportions = [0.22, 0.33, 0.15, 0.3];

  static const _greenColor = AppColors.success;
  static const _redColor = AppColors.error;

  final List<double> _dragOffsets = [0, 0, 0, 0];

  List<double> _computeWidths(double viewportWidth, bool showStatus) {
    final statusSpace = showStatus ? (_statusWidth + _gapWidth) : 0.0;
    final available =
        viewportWidth - _actionWidth - statusSpace - 32 - (_gapWidth * 3);
    return List.generate(4, (i) {
      return (available * _proportions[i] + _dragOffsets[i])
          .clamp(_minColWidth, double.infinity);
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
    final palette = _palette(context);
    final l10n = Languages.translate;
    final isEncoding = widget.encodeState.status == EncodeStatus.encoding;
    final showStatus = widget.encodeState.status != EncodeStatus.idle;

    if (widget.files.isEmpty) {
      return Center(
        child: Text(l10n.noVideos, style: palette.emptyStyle),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final colWidths = _computeWidths(constraints.maxWidth, showStatus);
        final contentWidth = colWidths.fold(0.0, (s, w) => s + w) +
            (_gapWidth * 3) +
            (showStatus ? (_statusWidth + _gapWidth) : 0) +
            _actionWidth +
            32;
        final effectiveWidth =
            contentWidth.clamp(constraints.maxWidth, double.infinity);
        final headerLabels = [
          l10n.columnName,
          l10n.columnPath,
          l10n.columnSize,
          l10n.columnOutput,
        ];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: effectiveWidth,
            height: constraints.maxHeight,
            child: Column(
              children: [
                _buildHeader(palette, colWidths, headerLabels, showStatus),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.files.length,
                    itemBuilder: (context, index) =>
                        _buildRow(palette, colWidths, index, isEncoding,
                            showStatus),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    _Palette palette,
    List<double> colWidths,
    List<String> headerLabels,
    bool showStatus,
  ) {
    return Container(
      height: _headerHeight,
      decoration: BoxDecoration(
        color: palette.headerBg,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (int i = 0; i < 4; i++) ...[
            SizedBox(
              width: colWidths[i],
              child: Align(
                alignment:
                    i == 2 ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                  headerLabels[i],
                  style: palette.headerStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (i < 3)
              AppColumnResizeHandle(
                dividerColor: palette.divider,
                onDrag: (dx) => _onResizeColumn(i, dx),
              ),
          ],
          if (showStatus) ...[
            const SizedBox(width: _gapWidth),
            SizedBox(
              width: _statusWidth,
              child: Text(
                Languages.translate.columnStatus,
                style: palette.headerStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const SizedBox(width: _actionWidth),
        ],
      ),
    );
  }

  Widget _buildRow(
    _Palette palette,
    List<double> colWidths,
    int index,
    bool isEncoding,
    bool showStatus,
  ) {
    final file = widget.files[index];
    final isSelected = file.path == widget.selectedFilePath;
    final rowStatus = showStatus ? _rowStatusFor(index, file) : null;

    Color? bgColor;
    if (isSelected) {
      bgColor = palette.selectedBg;
    } else if (index.isEven) {
      bgColor = palette.altRowBg;
    }

    final effectiveSettings = file.overrideSettings ?? widget.globalSettings;
    final baseName = p.basenameWithoutExtension(file.path);
    final outName = FilenameTemplate.apply(
      effectiveSettings.outputNameTemplate,
      originalName: baseName,
      creationDate: file.metadata?.creationDate,
    );
    final outputDisplay =
        '$outName.${effectiveSettings.outputExtension.value}';
    final hasOverride = file.overrideSettings != null;

    final rowColor = _rowTextColor(rowStatus);
    final bodyStyle = rowColor == null
        ? palette.bodyStyle
        : palette.bodyStyle.copyWith(color: rowColor);
    final captionStyle = rowColor == null
        ? palette.captionStyle
        : palette.captionStyle.copyWith(color: rowColor);
    final subtleCaptionStyle = rowColor == null
        ? palette.subtleCaptionStyle
        : palette.subtleCaptionStyle.copyWith(color: rowColor);

    return GestureDetector(
      onTap: () => widget.onSelect(file.path),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          border:
              Border(bottom: BorderSide(color: palette.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: colWidths[0],
              child: Row(
                children: [
                  _rowLeadingIcon(palette, rowStatus),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      file.name,
                      style: bodyStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: _gapWidth),
            SizedBox(
              width: colWidths[1],
              child: Text(
                p.dirname(file.path),
                style: subtleCaptionStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: _gapWidth),
            SizedBox(
              width: colWidths[2],
              child: Text(
                FileSizeFormatter.format(file.sizeInBytes),
                style: captionStyle,
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(width: _gapWidth),
            SizedBox(
              width: colWidths[3],
              child: Text(
                outputDisplay,
                style: captionStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showStatus) ...[
              const SizedBox(width: _gapWidth),
              SizedBox(
                width: _statusWidth,
                child: _statusCell(palette, rowStatus!, captionStyle),
              ),
            ],
            SizedBox(
              width: _actionWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!showStatus) _settingsButton(palette, hasOverride, file),
                  _removeButton(palette, file),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _RowStatus _rowStatusFor(int index, VideoFile file) {
    final s = widget.encodeState;
    if (s.failedFiles.contains(file.path)) return _RowStatus.failed;
    if (s.currentFilePath == file.path &&
        s.status == EncodeStatus.encoding) {
      return _RowStatus.processing;
    }
    if (index < s.currentIndex) return _RowStatus.completed;
    return _RowStatus.pending;
  }

  Color? _rowTextColor(_RowStatus? status) {
    switch (status) {
      case _RowStatus.processing:
      case _RowStatus.completed:
        return _greenColor;
      case _RowStatus.failed:
        return _redColor;
      case _RowStatus.pending:
      case null:
        return null;
    }
  }

  Widget _statusCell(
    _Palette palette,
    _RowStatus status,
    TextStyle captionStyle,
  ) {
    final l10n = Languages.translate;
    switch (status) {
      case _RowStatus.pending:
        return Text(
          l10n.statusPending,
          style: palette.captionStyle,
          overflow: TextOverflow.ellipsis,
        );
      case _RowStatus.completed:
        return Text(
          l10n.statusCompleted,
          style: captionStyle,
          overflow: TextOverflow.ellipsis,
        );
      case _RowStatus.failed:
        return Text(
          l10n.statusFailed,
          style: captionStyle,
          overflow: TextOverflow.ellipsis,
        );
      case _RowStatus.processing:
        final progress = widget.encodeState.progress;
        final percentLabel =
            '${(progress.percent * 100).toStringAsFixed(0)}%';
        final etaLabel = _formatEta(progress.estimatedRemaining);
        return Row(
          children: [
            Expanded(child: _progressBar(progress.percent)),
            const SizedBox(width: 6),
            Text(
              etaLabel == null
                  ? percentLabel
                  : '$percentLabel  ·  $etaLabel',
              style: captionStyle,
            ),
          ],
        );
    }
  }

  String? _formatEta(Duration? remaining) {
    if (remaining == null || remaining.inSeconds <= 0) return null;
    final total = remaining.inSeconds;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    if (h > 0) return '$h:$mm:$ss';
    return '$mm:$ss';
  }

  // ─── Platform leaves ────────────────────────────────────────────

  Widget _rowLeadingIcon(_Palette palette, _RowStatus? status) {
    final isDone = status == _RowStatus.completed;
    final isFailed = status == _RowStatus.failed;
    final color = isFailed
        ? _redColor
        : (isDone ? _greenColor : palette.accent);
    if (Platform.isWindows) {
      final iconData = isFailed
          ? fluent.FluentIcons.error_badge
          : (isDone ? fluent.FluentIcons.check_mark : fluent.FluentIcons.video);
      return fluent.Icon(iconData, size: 16, color: color);
    }
    final iconData = isFailed
        ? CupertinoIcons.xmark_circle_fill
        : (isDone ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.film);
    return MacosIcon(iconData, size: 16, color: color);
  }

  Widget _settingsButton(_Palette palette, bool hasOverride, VideoFile file) {
    final color = hasOverride ? palette.accent : palette.subtleText;
    if (Platform.isWindows) {
      return fluent.IconButton(
        icon: fluent.Icon(fluent.FluentIcons.settings, size: 12, color: color),
        onPressed: () => widget.onOpenFileSettings(file),
      );
    }
    return MacosIconButton(
      icon: MacosIcon(CupertinoIcons.slider_horizontal_3, size: 12, color: color),
      onPressed: () => widget.onOpenFileSettings(file),
    );
  }

  Widget _removeButton(_Palette palette, VideoFile file) {
    if (Platform.isWindows) {
      return fluent.IconButton(
        icon: const fluent.Icon(fluent.FluentIcons.chrome_close, size: 12),
        onPressed: () => widget.onRemove(file.path),
      );
    }
    return MacosIconButton(
      icon: MacosIcon(CupertinoIcons.xmark, size: 12, color: palette.subtleText),
      onPressed: () => widget.onRemove(file.path),
    );
  }

  Widget _progressBar(double percent) {
    if (Platform.isWindows) {
      return fluent.ProgressBar(value: percent * 100);
    }
    return ProgressBar(value: percent * 100);
  }

  _Palette _palette(BuildContext context) {
    if (Platform.isWindows) {
      final theme = fluent.FluentTheme.of(context);
      return _Palette(
        accent: theme.accentColor,
        subtleText: theme.resources.textFillColorSecondary,
        divider: theme.resources.controlStrokeColorDefault,
        headerBg: theme.cardColor,
        altRowBg: theme.cardColor.withValues(alpha: 0.4),
        selectedBg: AppColors.tableRowHighlight(theme.brightness),
        bodyStyle: theme.typography.body ?? const TextStyle(),
        captionStyle: theme.typography.caption ?? const TextStyle(),
        subtleCaptionStyle: (theme.typography.caption ?? const TextStyle())
            .copyWith(color: theme.resources.textFillColorSecondary),
        headerStyle: (theme.typography.caption ?? const TextStyle()).copyWith(
          color: theme.resources.textFillColorSecondary,
          fontWeight: FontWeight.w600,
        ),
        emptyStyle: (theme.typography.body ?? const TextStyle()).copyWith(
          color: theme.resources.textFillColorSecondary,
        ),
      );
    }
    final theme = MacosTheme.of(context);
    final b = theme.brightness;
    final isDark = b == Brightness.dark;
    final subtleText = AppColors.textTertiary(b);
    final divider = AppColors.divider(b);
    return _Palette(
      accent: theme.primaryColor,
      subtleText: subtleText,
      divider: divider,
      headerBg: AppColors.surface(b),
      altRowBg: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF9F9F9),
      selectedBg: AppColors.tableRowHighlight(b),
      bodyStyle: theme.typography.body,
      captionStyle: theme.typography.caption1,
      subtleCaptionStyle:
          theme.typography.caption1.copyWith(color: subtleText),
      headerStyle: theme.typography.caption1.copyWith(
        color: subtleText,
        fontWeight: FontWeight.w600,
      ),
      emptyStyle: theme.typography.subheadline.copyWith(color: subtleText),
    );
  }
}

enum _RowStatus { pending, processing, completed, failed }

class _Palette {
  const _Palette({
    required this.accent,
    required this.subtleText,
    required this.divider,
    required this.headerBg,
    required this.altRowBg,
    required this.selectedBg,
    required this.bodyStyle,
    required this.captionStyle,
    required this.subtleCaptionStyle,
    required this.headerStyle,
    required this.emptyStyle,
  });

  final Color accent;
  final Color subtleText;
  final Color divider;
  final Color headerBg;
  final Color altRowBg;
  final Color selectedBg;
  final TextStyle bodyStyle;
  final TextStyle captionStyle;
  final TextStyle subtleCaptionStyle;
  final TextStyle headerStyle;
  final TextStyle emptyStyle;
}
