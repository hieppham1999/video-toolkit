import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Tooltip;
import 'package:macos_ui/macos_ui.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/core/utils/file_reveal.dart';
import 'package:video_toolkit/core/utils/file_size_formatter.dart';
import 'package:video_toolkit/features/app_settings/presentation/widgets/app_output_directory_dialog.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/output_directory_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/settings_preset.dart';
import 'package:video_toolkit/features/video_encoding/domain/encode_settings_differ.dart';
import 'package:video_toolkit/features/video_encoding/domain/output_path_resolver.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_state.dart';
import 'package:video_toolkit/features/home/data/models/video_file.dart';
import 'package:video_toolkit/widgets/app_column_resize_handle.dart';
import 'package:video_toolkit/widgets/app_context_menu.dart';
import 'package:video_toolkit/widgets/app_progress_bar.dart';

/// Cross-platform table listing imported videos. Layout, resize, selection,
/// alt-row striping and per-row progress are platform-agnostic; only the
/// theming primitives (colors, icons, action buttons, text styles) branch on
/// platform at the leaves.
class AppVideoTableSection extends StatefulWidget {
  const AppVideoTableSection({
    super.key,
    required this.files,
    required this.globalSettings,
    required this.outputDirectory,
    required this.selectedFilePath,
    required this.encodeState,
    required this.presets,
    required this.globalSelectedPresetId,
    required this.onSelect,
    required this.onRemove,
    required this.onRemoveAll,
    required this.onOpenFileSettings,
    required this.onUpdateFileOutputDirectory,
    required this.onMoveFile,
  });

  final List<VideoFile> files;
  final EncodeSettings globalSettings;
  final OutputDirectorySettings outputDirectory;
  final String? selectedFilePath;
  final VideoEncodeState encodeState;
  final List<SettingsPreset> presets;
  final String? globalSelectedPresetId;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onRemove;
  final VoidCallback onRemoveAll;
  final ValueChanged<VideoFile> onOpenFileSettings;
  final void Function(String path, OutputDirectorySettings? settings)
  onUpdateFileOutputDirectory;
  final void Function(String path, int delta) onMoveFile;

  @override
  State<AppVideoTableSection> createState() => _AppVideoTableSectionState();
}

class _AppVideoTableSectionState extends State<AppVideoTableSection> {
  static const _minColWidth = 40.0;
  static const _gapWidth = 8.0;
  static const _actionWidth = 104.0;
  static const _statusWidth = 140.0;
  static const _sizeColWidth = 80.0;
  static const _outputSizeColWidth = 80.0;
  static const _ratioColWidth = 52.0;
  static const _headerHeight = 32.0;
  // Column indices in display order:
  // 0: Name (prop), 1: Path (prop), 2: Size (fixed), 3: Setting (prop),
  // 4: Output (prop), 5: OutputSize (fixed), 6: Ratio (fixed),
  // 7: Status (fixed).
  static const _proportions = [0.18, 0.32, 0.18, 0.32];
  static const _propIndices = [0, 1, 3, 4];

  static const _greenColor = AppColors.success;
  static const _redColor = AppColors.error;

  final List<double> _dragOffsets = [0, 0, 0, 0, 0, 0, 0, 0];
  final Map<String, int?> _outputSizeCache = {};
  List<double> _lastColWidths = const [];

  double _fixedWidth(int idx, double base) =>
      (base + _dragOffsets[idx]).clamp(_minColWidth, double.infinity);

  /// Returns widths in display order (indices 0..7). Status columns are 0 when
  /// hidden.
  List<double> _computeWidths(double viewportWidth, bool showStatus) {
    final size = _fixedWidth(2, _sizeColWidth);
    final outSize = showStatus ? _fixedWidth(5, _outputSizeColWidth) : 0.0;
    final ratio = showStatus ? _fixedWidth(6, _ratioColWidth) : 0.0;
    final status = showStatus ? _fixedWidth(7, _statusWidth) : 0.0;
    // Visible-column gaps: 4 always (between 0-1, 1-2, 2-3, 3-4) +
    // 3 when status block shown (4-5, 5-6, 6-7).
    final gapCount = showStatus ? 7 : 4;
    final available =
        viewportWidth -
        _actionWidth -
        size -
        outSize -
        ratio -
        status -
        32 -
        (_gapWidth * gapCount);
    final props = List<double>.generate(_propIndices.length, (j) {
      return (available * _proportions[j] + _dragOffsets[_propIndices[j]])
          .clamp(_minColWidth, double.infinity);
    });
    _lastColWidths = [
      props[0], // Name
      props[1], // Path
      size,
      props[2], // Setting
      props[3], // Output
      outSize,
      ratio,
      status,
    ];
    return _lastColWidths;
  }

  void _onResizeColumn(int leftIdx, double dx) {
    if (_lastColWidths.length <= leftIdx + 1) return;
    final leftW = _lastColWidths[leftIdx];
    final rightW = _lastColWidths[leftIdx + 1];
    double effective = dx;
    if (effective < 0 && leftW + effective < _minColWidth) {
      effective = _minColWidth - leftW;
    }
    if (effective > 0 && rightW - effective < _minColWidth) {
      effective = rightW - _minColWidth;
    }
    if (effective == 0) return;
    // If a fixed column is involved, `available` changes and every
    // proportional column would redistribute. Compensate each proportional
    // column's offset so only L and R actually change width.
    const fixedCols = {2, 5, 6, 7};
    double f = 0;
    if (fixedCols.contains(leftIdx)) f += effective;
    if (fixedCols.contains(leftIdx + 1)) f -= effective;
    setState(() {
      _dragOffsets[leftIdx] += effective;
      _dragOffsets[leftIdx + 1] -= effective;
      if (f != 0) {
        for (var j = 0; j < _propIndices.length; j++) {
          _dragOffsets[_propIndices[j]] += _proportions[j] * f;
        }
      }
    });
  }

  int? _readOutputSize(String path) {
    if (_outputSizeCache.containsKey(path)) return _outputSizeCache[path];
    try {
      final size = File(path).lengthSync();
      _outputSizeCache[path] = size;
      return size;
    } catch (_) {
      _outputSizeCache[path] = null;
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette(context);
    final l10n = Languages.translate;
    final isEncoding = widget.encodeState.status == EncodeStatus.encoding;
    final showStatus = widget.encodeState.status != EncodeStatus.idle;

    if (widget.files.isEmpty) {
      return Center(child: Text(l10n.noVideos, style: palette.emptyStyle));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final colWidths = _computeWidths(constraints.maxWidth, showStatus);
        final gapCount = showStatus ? 7 : 4;
        final contentWidth =
            colWidths.fold(0.0, (s, w) => s + w) +
            (_gapWidth * gapCount) +
            _actionWidth +
            32;
        final effectiveWidth = contentWidth.clamp(
          constraints.maxWidth,
          double.infinity,
        );

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: effectiveWidth,
            height: constraints.maxHeight,
            child: Column(
              children: [
                _buildHeader(palette, colWidths, showStatus),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.files.length,
                    itemBuilder: (context, index) => _buildRow(
                      palette,
                      colWidths,
                      index,
                      isEncoding,
                      showStatus,
                    ),
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
    bool showStatus,
  ) {
    final l10n = Languages.translate;
    Widget headerCell(String label, double width, {bool alignEnd = false}) {
      return SizedBox(
        width: width,
        child: Align(
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            label,
            style: palette.headerStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return Container(
      height: _headerHeight,
      decoration: BoxDecoration(
        color: palette.headerBg,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          headerCell(l10n.columnName, colWidths[0]),
          AppColumnResizeHandle(
            dividerColor: palette.divider,
            onDrag: (dx) => _onResizeColumn(0, dx),
          ),
          headerCell(l10n.columnPath, colWidths[1]),
          AppColumnResizeHandle(
            dividerColor: palette.divider,
            onDrag: (dx) => _onResizeColumn(1, dx),
          ),
          headerCell(l10n.columnSize, colWidths[2], alignEnd: true),
          AppColumnResizeHandle(
            dividerColor: palette.divider,
            onDrag: (dx) => _onResizeColumn(2, dx),
          ),
          headerCell(l10n.columnSetting, colWidths[3]),
          AppColumnResizeHandle(
            dividerColor: palette.divider,
            onDrag: (dx) => _onResizeColumn(3, dx),
          ),
          headerCell(l10n.columnOutput, colWidths[4]),
          if (showStatus) ...[
            AppColumnResizeHandle(
              dividerColor: palette.divider,
              onDrag: (dx) => _onResizeColumn(4, dx),
            ),
            headerCell(l10n.columnOutputSize, colWidths[5], alignEnd: true),
            AppColumnResizeHandle(
              dividerColor: palette.divider,
              onDrag: (dx) => _onResizeColumn(5, dx),
            ),
            headerCell(l10n.columnSizeRatio, colWidths[6], alignEnd: true),
            AppColumnResizeHandle(
              dividerColor: palette.divider,
              onDrag: (dx) => _onResizeColumn(6, dx),
            ),
            headerCell(l10n.columnStatus, colWidths[7]),
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
    final rowStatus = showStatus ? _rowStatusFor(file) : null;

    final Color? bgColor = isSelected ? palette.selectedBg : null;

    final effectiveSettings = file.overrideSettings ?? widget.globalSettings;
    final effectiveOutputDirectory =
        file.outputDirectoryOverride ?? widget.outputDirectory;
    final desiredOutputPath = OutputPathResolver.resolvePath(
      inputPath: file.path,
      encodeSettings: effectiveSettings,
      directorySettings: effectiveOutputDirectory,
      creationDate: file.metadata?.creationDate,
      creationDateFromFileSystem:
          file.metadata?.creationDateFromFileSystem ?? false,
      detectedTimezoneOffset: file.metadata?.timezoneOffset,
    );
    final outputPath =
        widget.encodeState.outputPaths[file.path] ?? desiredOutputPath;
    final outputDir = p.dirname(outputPath);
    final hasOverride = file.overrideSettings != null;

    final isCompleted = rowStatus == _RowStatus.completed;
    final outputSize = isCompleted ? _readOutputSize(outputPath) : null;
    final outputSizeLabel = outputSize != null
        ? FileSizeFormatter.format(outputSize)
        : '–';
    final ratioLabel = (outputSize != null && file.sizeInBytes > 0)
        ? '${((outputSize / file.sizeInBytes) * 100).toStringAsFixed(0)}%'
        : '–';

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
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onSelect(file.path),
      onSecondaryTapDown: (details) => _showRowMenu(
        context,
        details.globalPosition,
        file,
        outputPath: outputPath,
        isCompleted: isCompleted,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            bottom: BorderSide(color: palette.divider, width: 0.5),
          ),
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
                outputDir,
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
              child: _settingCell(
                palette,
                file,
                effectiveSettings,
                captionStyle,
              ),
            ),
            const SizedBox(width: _gapWidth),
            fluent.Expanded(
              child: SizedBox(
                width: colWidths[4],
                child: Text(
                  outputPath,
                  style: subtleCaptionStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (showStatus) ...[
              const SizedBox(width: _gapWidth),
              SizedBox(
                width: colWidths[5],
                child: Text(
                  outputSizeLabel,
                  style: captionStyle,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: _gapWidth),
              SizedBox(
                width: colWidths[6],
                child: Text(
                  ratioLabel,
                  style: captionStyle,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: _gapWidth),
              SizedBox(
                width: colWidths[7],
                child: _statusCell(palette, rowStatus!, captionStyle),
              ),
            ],
            SizedBox(
              width: _actionWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isEncoding) _settingsButton(palette, hasOverride, file),
                  if (!isEncoding)
                    _outputButton(palette, file, effectiveSettings),
                  _removeButton(palette, file),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRowMenu(
    BuildContext context,
    Offset position,
    VideoFile file, {
    required String outputPath,
    required bool isCompleted,
  }) {
    if (widget.selectedFilePath != file.path) {
      widget.onSelect(file.path);
    }
    final l10n = Languages.translate;
    final showRevealOutput = isCompleted && File(outputPath).existsSync();
    final index = widget.files.indexWhere((item) => item.path == file.path);
    final canReorder = widget.encodeState.status != EncodeStatus.encoding;
    showAppContextMenu(
      context: context,
      globalPosition: position,
      items: [
        AppContextMenuItem(
          label: l10n.revealInputInFolder,
          onTap: () => revealInOsFileManager(file.path),
        ),
        if (showRevealOutput)
          AppContextMenuItem(
            label: l10n.revealOutputInFolder,
            onTap: () => revealInOsFileManager(outputPath),
          ),
        if (canReorder && index > 0)
          AppContextMenuItem(
            label: l10n.moveUp,
            onTap: () => widget.onMoveFile(file.path, -1),
          ),
        if (canReorder && index >= 0 && index < widget.files.length - 1)
          AppContextMenuItem(
            label: l10n.moveDown,
            onTap: () => widget.onMoveFile(file.path, 1),
          ),
        AppContextMenuItem(
          label: l10n.remove,
          isDestructive: true,
          onTap: () => widget.onRemove(file.path),
        ),
        AppContextMenuItem(
          label: l10n.removeAll,
          isDestructive: true,
          onTap: widget.onRemoveAll,
        ),
      ],
    );
  }

  _RowStatus _rowStatusFor(VideoFile file) {
    final s = widget.encodeState;
    if (s.failedPaths.contains(file.path)) return _RowStatus.failed;
    if (s.skippedPaths.contains(file.path)) return _RowStatus.skipped;
    if (s.currentFilePath == file.path && s.status == EncodeStatus.encoding) {
      return _RowStatus.processing;
    }
    if (s.completedPaths.contains(file.path)) return _RowStatus.completed;
    return _RowStatus.pending;
  }

  Color? _rowTextColor(_RowStatus? status) {
    switch (status) {
      case _RowStatus.processing:
      case _RowStatus.completed:
        return _greenColor;
      case _RowStatus.failed:
        return _redColor;
      case _RowStatus.skipped:
        return null;
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
      case _RowStatus.skipped:
        return Text(
          l10n.statusSkipped,
          style: captionStyle,
          overflow: TextOverflow.ellipsis,
        );
      case _RowStatus.processing:
        final progress = widget.encodeState.progress;
        final percentLabel = '${(progress.percent * 100).toStringAsFixed(0)}%';
        final etaLabel = _formatEta(progress.estimatedRemaining);
        final passLabel = progress.pass == null ? null : 'P${progress.pass}/2';
        final parts = [
          if (passLabel != null) passLabel,
          percentLabel,
          if (etaLabel != null) etaLabel,
        ];
        return Row(
          children: [
            Expanded(child: AppProgressBar(percent: progress.percent)),
            const SizedBox(width: 6),
            Text(parts.join('  ·  '), style: captionStyle),
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
    final Widget button = Platform.isWindows
        ? fluent.IconButton(
            key: ValueKey('video-settings-${file.path}'),
            icon: fluent.Icon(
              fluent.FluentIcons.settings,
              size: 12,
              color: color,
            ),
            onPressed: () => widget.onOpenFileSettings(file),
          )
        : MacosIconButton(
            key: ValueKey('video-settings-${file.path}'),
            icon: MacosIcon(
              CupertinoIcons.slider_horizontal_3,
              size: 12,
              color: color,
            ),
            onPressed: () => widget.onOpenFileSettings(file),
          );
    if (!hasOverride) return button;
    return Tooltip(
      message: Languages.translate.perFileSettingsOverrideTooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: button,
    );
  }

  Widget _outputButton(
    _Palette palette,
    VideoFile file,
    EncodeSettings effectiveSettings,
  ) {
    final hasOverride = file.outputDirectoryOverride != null;
    final color = hasOverride ? palette.accent : palette.subtleText;
    final Widget button = Platform.isWindows
        ? fluent.IconButton(
            key: ValueKey('video-output-${file.path}'),
            icon: fluent.Icon(
              fluent.FluentIcons.folder_open,
              size: 12,
              color: color,
            ),
            onPressed: () => _openFileOutputDirectory(file, effectiveSettings),
          )
        : MacosIconButton(
            key: ValueKey('video-output-${file.path}'),
            icon: MacosIcon(CupertinoIcons.folder, size: 12, color: color),
            onPressed: () => _openFileOutputDirectory(file, effectiveSettings),
          );
    return Tooltip(
      message: hasOverride
          ? Languages.translate.perFileOutputOverrideTooltip
          : Languages.translate.setOutputDirectory,
      waitDuration: const Duration(milliseconds: 400),
      child: button,
    );
  }

  void _openFileOutputDirectory(
    VideoFile file,
    EncodeSettings effectiveSettings,
  ) {
    showAppOutputDirectoryDialog(
      context: context,
      globalSettings: widget.outputDirectory,
      initialOverride: file.outputDirectoryOverride,
      isPerFile: true,
      sampleInputPath: file.path,
      sampleEncodeSettings: effectiveSettings,
      sampleCreationDate: file.metadata?.creationDate,
      sampleCreationDateFromFileSystem:
          file.metadata?.creationDateFromFileSystem ?? false,
      sampleTimezoneOffset: file.metadata?.timezoneOffset,
      onSave: (settings) =>
          widget.onUpdateFileOutputDirectory(file.path, settings),
    );
  }

  Widget _removeButton(_Palette palette, VideoFile file) {
    if (Platform.isWindows) {
      return fluent.IconButton(
        key: ValueKey('video-remove-${file.path}'),
        icon: const fluent.Icon(fluent.FluentIcons.chrome_close, size: 12),
        onPressed: () => widget.onRemove(file.path),
      );
    }
    return MacosIconButton(
      key: ValueKey('video-remove-${file.path}'),
      icon: MacosIcon(
        CupertinoIcons.xmark,
        size: 12,
        color: palette.subtleText,
      ),
      onPressed: () => widget.onRemove(file.path),
    );
  }

  Widget _settingCell(
    _Palette palette,
    VideoFile file,
    EncodeSettings effectiveSettings,
    TextStyle captionStyle,
  ) {
    final l10n = Languages.translate;
    final effectivePresetId =
        file.appliedPresetId ?? widget.globalSelectedPresetId;
    final basePreset = effectivePresetId == null
        ? null
        : widget.presets.where((p) => p.id == effectivePresetId).firstOrNull;

    if (basePreset == null) {
      return Text(
        '–',
        style: captionStyle.copyWith(color: palette.subtleText),
        overflow: TextOverflow.ellipsis,
      );
    }

    final diffs = EncodeSettingsDiffer.diff(
      basePreset.settings,
      effectiveSettings,
    );
    final isModified = diffs.isNotEmpty;
    final label = isModified ? '${basePreset.name} *' : basePreset.name;
    final color = isModified ? palette.accent : null;
    final text = Text(
      label,
      style: color == null ? captionStyle : captionStyle.copyWith(color: color),
      overflow: TextOverflow.ellipsis,
    );
    if (!isModified) return text;

    final lines = [
      '${l10n.presetModifiedTooltipTitle} ${basePreset.name}',
      ...diffs.map((d) => '${d.label}: ${d.before} → ${d.after}'),
    ];
    return Tooltip(
      message: lines.join('\n'),
      waitDuration: const Duration(milliseconds: 400),
      child: text,
    );
  }

  _Palette _palette(BuildContext context) {
    if (Platform.isWindows) {
      final theme = fluent.FluentTheme.of(context);
      return _Palette(
        accent: theme.accentColor,
        subtleText: theme.resources.textFillColorSecondary,
        divider: theme.resources.controlStrokeColorDefault,
        headerBg: theme.cardColor,
        selectedBg: theme.accentColor.withValues(alpha: 0.18),
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
    final subtleText = AppColors.textTertiary(b);
    final divider = AppColors.divider(b);
    return _Palette(
      accent: theme.primaryColor,
      subtleText: subtleText,
      divider: divider,
      headerBg: AppColors.surface(b),
      selectedBg: theme.primaryColor.withValues(alpha: 0.18),
      bodyStyle: theme.typography.body,
      captionStyle: theme.typography.caption1,
      subtleCaptionStyle: theme.typography.caption1.copyWith(color: subtleText),
      headerStyle: theme.typography.caption1.copyWith(
        color: subtleText,
        fontWeight: FontWeight.w600,
      ),
      emptyStyle: theme.typography.subheadline.copyWith(color: subtleText),
    );
  }
}

enum _RowStatus { pending, processing, completed, failed, skipped }

class _Palette {
  const _Palette({
    required this.accent,
    required this.subtleText,
    required this.divider,
    required this.headerBg,
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
  final Color selectedBg;
  final TextStyle bodyStyle;
  final TextStyle captionStyle;
  final TextStyle subtleCaptionStyle;
  final TextStyle headerStyle;
  final TextStyle emptyStyle;
}
