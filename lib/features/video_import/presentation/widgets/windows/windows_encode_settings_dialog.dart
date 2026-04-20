import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/utils/filename_template.dart';
import 'package:video_toolkit/features/fonts/data/models/font_info.dart';
import 'package:video_toolkit/features/fonts/presentation/cubit/font_cubit.dart';
import 'package:video_toolkit/features/fonts/presentation/cubit/font_state.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/settings_preset.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/preset_cubit.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/preset_state.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_dropdown.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_field.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_preset_chip.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_tag_chip.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_twin_field.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/shared/app_preset_tile.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/shared/encode_settings_controller.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/shared/sidebar_resize_handle.dart';
import 'package:video_toolkit/presentation/base/app_state.dart';
import 'package:video_toolkit/presentation/widgets/color_picker_button.dart';

class WindowsEncodeSettingsDialog extends StatefulWidget {
  const WindowsEncodeSettingsDialog({
    super.key,
    required this.settings,
    required this.onSave,
    required this.onCancel,
    this.onReset,
    this.sampleFileName = 'video',
    this.sampleCreationDate,
    this.sampleWidth,
    this.sampleHeight,
  });

  final EncodeSettings settings;
  final ValueChanged<EncodeSettings> onSave;
  final VoidCallback onCancel;
  final VoidCallback? onReset;
  final String sampleFileName;
  final DateTime? sampleCreationDate;
  final int? sampleWidth;
  final int? sampleHeight;

  @override
  State<WindowsEncodeSettingsDialog> createState() =>
      _WindowsEncodeSettingsDialogState();
}

class _WindowsEncodeSettingsDialogState
    extends State<WindowsEncodeSettingsDialog> {
  late final EncodeSettingsController _c;

  @override
  void initState() {
    super.initState();
    _c = EncodeSettingsController(
      initialSettings: widget.settings,
      presetCubit: context.read<PresetCubit>(),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<String?> _promptPresetName() async {
    final l10n = Languages.translate;
    final controller = TextEditingController();
    return showDialog<String?>(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Text(l10n.saveAs),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextBox(
            controller: controller,
            placeholder: l10n.presetNameHint,
            autofocus: true,
          ),
        ),
        actions: [
          Button(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(String name) {
    final l10n = Languages.translate;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Text(l10n.deletePreset),
        content: Text(l10n.confirmDeletePreset(name)),
        actions: [
          Button(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deletePreset),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = Languages.translate;

    final tabs = [
      l10n.tabFile,
      l10n.tabContainer,
      l10n.tabSizing,
      l10n.tabFilter,
      l10n.tabAudio,
    ];
    final presetState = context.watch<PresetCubit>().state;
    final presets = presetState is NormalState<PresetState>
        ? presetState.data.presets
        : const <SettingsPreset>[];
    final canDelete = _c.currentUserPreset() != null;

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 820, maxHeight: 620),
      title: Row(
        children: [
          Expanded(child: Text(l10n.encodeSettings)),
          Button(
            onPressed: () => _c.handleSaveAs(_promptPresetName),
            child: Text(l10n.saveAs),
          ),
          const SizedBox(width: 6),
          Button(
            onPressed: () => _c.handleSave(_promptPresetName),
            child: Text(l10n.save),
          ),
          const SizedBox(width: 6),
          Button(
            onPressed: canDelete
                ? () => _c.handleDelete(_confirmDelete)
                : null,
            child: Text(l10n.deletePreset),
          ),
        ],
      ),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _c.sidebarWidth,
            child: _buildPresetSidebar(theme, l10n, presets),
          ),
          SidebarResizeHandle(
            onDragDelta: _c.resizeSidebar,
            lineColor: theme.resources.cardStrokeColorDefault,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (int i = 0; i < tabs.length; i++) ...[
                        if (i > 0) const SizedBox(width: 4),
                        Button(
                          onPressed: () => _c.setTab(i),
                          child: Text(
                            tabs[i],
                            style: i == _c.selectedTab
                                ? theme.typography.body
                                    ?.copyWith(fontWeight: FontWeight.w600)
                                : theme.typography.body,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: switch (_c.selectedTab) {
                      0 => _buildFileTab(theme, l10n),
                      1 => _buildContainerTab(theme),
                      2 => _buildSizingTab(theme),
                      3 => _buildFilterTab(theme, l10n),
                      4 => _buildAudioTab(theme),
                      _ => const SizedBox.shrink(),
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (widget.onReset != null)
          Button(onPressed: widget.onReset, child: Text(l10n.resetToGlobal)),
        Button(onPressed: widget.onCancel, child: Text(l10n.cancel)),
        FilledButton(
          onPressed: () => widget.onSave(_c.buildSettings()),
          child: Text(l10n.save),
        ),
      ],
    );
  }

  Widget _buildPresetSidebar(
    FluentThemeData theme,
    dynamic l10n,
    List<SettingsPreset> presets,
  ) {
    final subtle = theme.resources.textFillColorSecondary;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.resources.cardStrokeColorDefault),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              l10n.presets,
              style: theme.typography.caption?.copyWith(color: subtle),
            ),
          ),
          Expanded(
            child: Scrollbar(
              controller: _c.presetScrollController,
              child: ListView.builder(
                controller: _c.presetScrollController,
                padding: EdgeInsets.zero,
                itemCount: presets.length,
                itemBuilder: (ctx, i) {
                  final p = presets[i];
                  return AppPresetTile(
                    preset: p,
                    active: p.id == _c.selectedPresetId,
                    onTap: () => _c.selectPreset(p),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileTab(FluentThemeData theme, dynamic l10n) {
    final preview = FilenameTemplate.apply(
      _c.outputNameTemplate,
      originalName: widget.sampleFileName,
      creationDate: widget.sampleCreationDate ?? DateTime.now(),
    );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppField(
            label: l10n.outputName,
            value: _c.outputNameTemplate,
            onChanged: _c.setOutputNameTemplate,
            hint: l10n.outputNameHint,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  l10n.outputNamePreview,
                  style: theme.typography.body?.copyWith(
                    color: theme.resources.textFillColorSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$preview.${_c.outputExtension.value}',
                  style:
                      theme.typography.body?.copyWith(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.availableTags,
            style: theme.typography.caption?.copyWith(
              color: theme.resources.textFillColorSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in FilenameTemplate.tags)
                AppTagChip(tag: '{$tag}', onTap: () => _c.appendNameTag(tag)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContainerTab(FluentThemeData theme) {
    final l10n = Languages.translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDropdown<OutputExtension>(
          label: l10n.fileExtension,
          value: _c.outputExtension,
          items: OutputExtension.values,
          itemLabel: (e) => e.value,
          onChanged: _c.setOutputExtension,
        ),
        const SizedBox(height: 12),
        AppDropdown<VideoEncoder>(
          label: l10n.videoCodec,
          value: _c.codec,
          items: VideoEncoder.values,
          itemLabel: (e) => e.value,
          onChanged: _c.setCodec,
        ),
        const SizedBox(height: 12),
        AppDropdown<EncodePreset>(
          label: l10n.encodePreset,
          value: _c.preset,
          items: EncodePreset.values,
          itemLabel: (e) => e.value,
          onChanged: _c.setPreset,
        ),
        const SizedBox(height: 12),
        AppField(
          label: l10n.crf,
          value: '${_c.crf}',
          onChanged: (v) => _c.setCrf(int.tryParse(v) ?? _c.crf),
        ),
      ],
    );
  }

  Widget _buildSizingTab(FluentThemeData theme) {
    final l10n = Languages.translate;
    final srcW = widget.sampleWidth;
    final srcH = widget.sampleHeight;
    final srcLabel = (srcW != null && srcH != null) ? '$srcW × $srcH' : '-';
    final aspectStr = _c.aspectNum.isNotEmpty && _c.aspectDen.isNotEmpty
        ? '${_c.aspectNum}:${_c.aspectDen}'
        : '';
    final outLabel =
        EncodeSettingsController.computeCropOutput(srcW, srcH, aspectStr);
    final subtleColor = theme.resources.textFillColorSecondary;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTwinField(
            label: l10n.resolution,
            separator: '×',
            leftValue: _c.resWidth,
            rightValue: _c.resHeight,
            leftHint: 'W',
            rightHint: 'H',
            onLeftChanged: _c.setResWidth,
            onRightChanged: _c.setResHeight,
          ),
          const SizedBox(height: 12),
          AppTwinField(
            label: l10n.aspectRatio,
            separator: ':',
            leftValue: _c.aspectNum,
            rightValue: _c.aspectDen,
            leftHint: 'N',
            rightHint: 'D',
            onLeftChanged: _c.setAspectNum,
            onRightChanged: _c.setAspectDen,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 108),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final preset in EncodeSettingsController.aspectPresets)
                  AppPresetChip(
                    label: preset,
                    active: aspectStr == preset,
                    onTap: () => _c.applyAspectPreset(preset),
                  ),
                AppPresetChip(
                  label: l10n.original,
                  active: aspectStr.isEmpty,
                  onTap: _c.clearAspect,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  l10n.sourceSize,
                  style: theme.typography.body?.copyWith(color: subtleColor),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                srcLabel,
                style:
                    theme.typography.body?.copyWith(fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  l10n.afterCrop,
                  style: theme.typography.body?.copyWith(color: subtleColor),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                outLabel,
                style:
                    theme.typography.body?.copyWith(fontFamily: 'monospace'),
              ),
            ],
          ),
        ],
      ),
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
              Text(l10n.textOverlays, style: theme.typography.bodyStrong),
              const Spacer(),
              Button(
                onPressed: _c.addOverlay,
                child: Text(l10n.addText),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _c.textOverlays.length; i++)
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
                          Text(
                            l10n.textOverlayLabel(i + 1),
                            style: theme.typography.body,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(FluentIcons.chrome_close,
                                size: 12),
                            onPressed: () => _c.removeOverlay(i),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AppDropdown<TextOverlayType>(
                        label: l10n.overlayType,
                        value: _c.textOverlays[i].type,
                        items: TextOverlayType.values,
                        itemLabel: (e) => switch (e) {
                          TextOverlayType.custom => l10n.overlayTypeCustom,
                          TextOverlayType.timestamp =>
                            l10n.overlayTypeTimestamp,
                        },
                        onChanged: (v) => _c.updateOverlay(
                          i,
                          _c.textOverlays[i].copyWith(
                            type: v,
                            text: v == TextOverlayType.timestamp
                                ? ''
                                : _c.textOverlays[i].text,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_c.textOverlays[i].type ==
                          TextOverlayType.custom) ...[
                        AppField(
                          label: l10n.textLabel,
                          value: _c.textOverlays[i].text,
                          onChanged: (v) => _c.updateOverlay(
                            i,
                            _c.textOverlays[i].copyWith(text: v),
                          ),
                          hint: l10n.textHintTimestamp,
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: AppField(
                              label: l10n.fontSize,
                              value: '${_c.textOverlays[i].fontSize}',
                              onChanged: (v) => _c.updateOverlay(
                                i,
                                _c.textOverlays[i].copyWith(
                                  fontSize: int.tryParse(v) ?? 24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    l10n.color,
                                    style: theme.typography.body,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ColorPickerButton(
                                  value: _c.textOverlays[i].fontColor,
                                  onChanged: (v) => _c.updateOverlay(
                                    i,
                                    _c.textOverlays[i]
                                        .copyWith(fontColor: v),
                                  ),
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
                            child: AppField(
                              label: l10n.border,
                              value: '${_c.textOverlays[i].borderWidth}',
                              onChanged: (v) => _c.updateOverlay(
                                i,
                                _c.textOverlays[i].copyWith(
                                  borderWidth: int.tryParse(v) ?? 0,
                                ),
                              ),
                              hint: l10n.noBorderHint,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    l10n.borderColor,
                                    style: theme.typography.body,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ColorPickerButton(
                                  value: _c.textOverlays[i].borderColor,
                                  onChanged: (v) => _c.updateOverlay(
                                    i,
                                    _c.textOverlays[i]
                                        .copyWith(borderColor: v),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AppDropdown<TextOverlayPosition>(
                        label: l10n.position,
                        value: _c.textOverlays[i].position,
                        items: TextOverlayPosition.values,
                        itemLabel: (e) => e.name,
                        onChanged: (v) => _c.updateOverlay(
                          i,
                          _c.textOverlays[i].copyWith(position: v),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppDropdown<String>(
                        label: l10n.font,
                        value: _c.textOverlays[i].fontFile ?? '',
                        items: ['', ...fonts.map((f) => f.path)],
                        itemLabel: (v) {
                          if (v.isEmpty) return l10n.fontDefault;
                          final match =
                              fonts.where((e) => e.path == v).firstOrNull;
                          if (match == null) return v;
                          return match.isBundled
                              ? '${match.name} (${l10n.fontBundled})'
                              : match.name;
                        },
                        onChanged: (v) => _c.updateOverlay(
                          i,
                          _c.textOverlays[i]
                              .copyWith(fontFile: v.isEmpty ? null : v),
                        ),
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
    final l10n = Languages.translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDropdown<AudioCodec>(
          label: l10n.audioCodec,
          value: _c.audioCodec,
          items: AudioCodec.values,
          itemLabel: (e) => e.value,
          onChanged: _c.setAudioCodec,
        ),
        const SizedBox(height: 12),
        AppDropdown<AudioBitrate>(
          label: l10n.bitrate,
          value: _c.audioBitrate,
          items: AudioBitrate.values,
          itemLabel: (e) => e.value,
          onChanged: _c.setAudioBitrate,
        ),
      ],
    );
  }
}

