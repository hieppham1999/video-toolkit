import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
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

class MacosEncodeSettingsSheet extends StatefulWidget {
  const MacosEncodeSettingsSheet({
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
  State<MacosEncodeSettingsSheet> createState() =>
      _MacosEncodeSettingsSheetState();
}

class _MacosEncodeSettingsSheetState extends State<MacosEncodeSettingsSheet> {
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
    return showMacosAlertDialog<String?>(
      context: context,
      builder: (ctx) => MacosAlertDialog(
        appIcon: const MacosIcon(CupertinoIcons.floppy_disk, size: 48),
        title: Text(l10n.saveAs),
        message: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: MacosTextField(
            controller: controller,
            placeholder: l10n.presetNameHint,
            autofocus: true,
          ),
        ),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
          child: Text(l10n.save),
        ),
        secondaryButton: PushButton(
          controlSize: ControlSize.large,
          secondary: true,
          onPressed: () => Navigator.of(ctx).pop(null),
          child: Text(l10n.cancel),
        ),
      ),
    );
  }

  Future<String?> _promptImportedPresetName() async {
    final l10n = Languages.translate;
    final controller = TextEditingController();
    return showMacosAlertDialog<String?>(
      context: context,
      builder: (ctx) => MacosAlertDialog(
        appIcon: const MacosIcon(CupertinoIcons.arrow_down_doc, size: 48),
        title: Text(l10n.import),
        message: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.importPresetNamePrompt),
              const SizedBox(height: 8),
              MacosTextField(
                controller: controller,
                placeholder: l10n.presetNameHint,
                autofocus: true,
              ),
            ],
          ),
        ),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
          child: Text(l10n.save),
        ),
        secondaryButton: PushButton(
          controlSize: ControlSize.large,
          secondary: true,
          onPressed: () => Navigator.of(ctx).pop(''),
          child: Text(l10n.cancel),
        ),
      ),
    );
  }

  Future<bool?> _confirmRevert(String name) {
    final l10n = Languages.translate;
    return showMacosAlertDialog<bool>(
      context: context,
      builder: (ctx) => MacosAlertDialog(
        appIcon: const MacosIcon(CupertinoIcons.arrow_uturn_left, size: 48),
        title: Text(l10n.revert),
        message: Text(l10n.revertConfirm(name)),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n.revert),
        ),
        secondaryButton: PushButton(
          controlSize: ControlSize.large,
          secondary: true,
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.cancel),
        ),
      ),
    );
  }

  Future<void> _showImportError() {
    final l10n = Languages.translate;
    return showMacosAlertDialog<void>(
      context: context,
      builder: (ctx) => MacosAlertDialog(
        appIcon: const MacosIcon(CupertinoIcons.exclamationmark_triangle,
            size: 48),
        title: Text(l10n.importError),
        message: Text(l10n.importFailed),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.save),
        ),
      ),
    );
  }

  Future<void> _handleImport() async {
    try {
      await _c.importAndSaveAsPreset(_promptImportedPresetName);
    } catch (_) {
      if (mounted) await _showImportError();
    }
  }

  Future<void> _handleRevert() async {
    final name = _c.selectedPresetName();
    if (name == null) return;
    final ok = await _confirmRevert(name);
    if (ok == true) _c.revertToSelectedPreset();
  }

  Future<bool?> _confirmDelete(String name) {
    final l10n = Languages.translate;
    return showMacosAlertDialog<bool>(
      context: context,
      builder: (ctx) => MacosAlertDialog(
        appIcon: const MacosIcon(CupertinoIcons.delete, size: 48),
        title: Text(l10n.deletePreset),
        message: Text(l10n.confirmDeletePreset(name)),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n.deletePreset),
        ),
        secondaryButton: PushButton(
          controlSize: ControlSize.large,
          secondary: true,
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.cancel),
        ),
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
    final theme = MacosTheme.of(context);
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

    return Transform.translate(
      offset: _c.dragOffset,
      child: MacosSheet(
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitleBar(theme),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: _c.sidebarWidth,
                      child: _buildPresetSidebar(theme, l10n, presets),
                    ),
                    SidebarResizeHandle(
                      onDragDelta: _c.resizeSidebar,
                      lineColor: theme.brightness == Brightness.dark
                          ? const Color(0xFF3A3A3C)
                          : const Color(0xFFD1D1D6),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.encodeSettings,
                                    style: theme.typography.title2,
                                  ),
                                ),
                                PushButton(
                                  controlSize: ControlSize.regular,
                                  secondary: true,
                                  onPressed: _handleImport,
                                  child: Text(l10n.import),
                                ),
                                const SizedBox(width: 6),
                                PushButton(
                                  controlSize: ControlSize.regular,
                                  secondary: true,
                                  onPressed: _c.selectedPresetId != null
                                      ? () => _c.exportSelectedPreset()
                                      : null,
                                  child: Text(l10n.export),
                                ),
                                const SizedBox(width: 6),
                                PushButton(
                                  controlSize: ControlSize.regular,
                                  secondary: true,
                                  onPressed: _c.selectedPresetId != null
                                      ? _handleRevert
                                      : null,
                                  child: Text(l10n.revert),
                                ),
                                const SizedBox(width: 6),
                                PushButton(
                                  controlSize: ControlSize.regular,
                                  secondary: true,
                                  onPressed: () =>
                                      _c.handleSaveAs(_promptPresetName),
                                  child: Text(l10n.saveAs),
                                ),
                                const SizedBox(width: 6),
                                PushButton(
                                  controlSize: ControlSize.regular,
                                  secondary: true,
                                  onPressed: () =>
                                      _c.handleSave(_promptPresetName),
                                  child: Text(l10n.save),
                                ),
                                const SizedBox(width: 6),
                                PushButton(
                                  controlSize: ControlSize.regular,
                                  secondary: true,
                                  onPressed: canDelete
                                      ? () => _c.handleDelete(_confirmDelete)
                                      : null,
                                  child: Text(l10n.deletePreset),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                for (int i = 0; i < tabs.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 4),
                                  PushButton(
                                    controlSize: ControlSize.regular,
                                    secondary: i != _c.selectedTab,
                                    onPressed: () => _c.setTab(i),
                                    child: Text(tabs[i]),
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
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (widget.onReset != null)
                                  PushButton(
                                    controlSize: ControlSize.large,
                                    secondary: true,
                                    onPressed: widget.onReset,
                                    child: Text(l10n.resetToGlobal),
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
                                  onPressed: () =>
                                      widget.onSave(_c.buildSettings()),
                                  child: Text(l10n.save),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar(MacosThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFECECEC);
    final borderColor =
        isDark ? const Color(0xFF3A3A3C) : const Color(0xFFD1D1D6);

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          _TrafficLightButton(
            color: const Color(0xFFFF5F56),
            borderColor: const Color(0xFFE0443E),
            icon: CupertinoIcons.xmark,
            onTap: widget.onCancel,
          ),
          const SizedBox(width: 8),
          _TrafficLightButton(
            color: const Color(0xFFFFBD2E),
            borderColor: const Color(0xFFDEA123),
            icon: CupertinoIcons.minus,
            onTap: _c.resetDrag,
          ),
          const SizedBox(width: 8),
          _TrafficLightButton(
            color: const Color(0xFF27C93F),
            borderColor: const Color(0xFF1AAB29),
            icon: CupertinoIcons.fullscreen,
            onTap: _c.resetDrag,
          ),
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.move,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (d) => _c.dragBy(d.delta),
                onDoubleTap: _c.resetDrag,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSidebar(
    MacosThemeData theme,
    dynamic l10n,
    List<SettingsPreset> presets,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final subtle = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
    final bg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              l10n.presets,
              style: theme.typography.caption1.copyWith(color: subtle),
            ),
          ),
          Expanded(
            child: MacosScrollbar(
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

  Widget _buildFileTab(MacosThemeData theme, dynamic l10n) {
    final isDark = theme.brightness == Brightness.dark;
    final subtleText =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
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
                  style: theme.typography.body.copyWith(color: subtleText),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$preview.${_c.outputExtension.value}',
                  style:
                      theme.typography.body.copyWith(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.availableTags,
            style: theme.typography.caption1.copyWith(color: subtleText),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in FilenameTemplate.tags)
                AppTagChip(
                  tag: '{$tag}',
                  onTap: () => _c.appendNameTag(tag),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContainerTab(MacosThemeData theme) {
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

  String _deinterlaceLabel(Deinterlace d) {
    final l10n = Languages.translate;
    return switch (d) {
      Deinterlace.off => l10n.deinterlaceOff,
      Deinterlace.yadifFrame => l10n.deinterlaceYadifFrame,
      Deinterlace.yadifField => l10n.deinterlaceYadifField,
      Deinterlace.bwdifFrame => l10n.deinterlaceBwdifFrame,
      Deinterlace.bwdifField => l10n.deinterlaceBwdifField,
    };
  }

  Widget _buildSizingTab(MacosThemeData theme) {
    final l10n = Languages.translate;
    final isDark = theme.brightness == Brightness.dark;
    final subtleText =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
    final srcW = widget.sampleWidth;
    final srcH = widget.sampleHeight;
    final srcLabel = (srcW != null && srcH != null) ? '$srcW × $srcH' : '-';
    final aspectStr = _c.aspectNum.isNotEmpty && _c.aspectDen.isNotEmpty
        ? '${_c.aspectNum}:${_c.aspectDen}'
        : '';
    final cropOut =
        EncodeSettingsController.computeCropOutput(srcW, srcH, aspectStr);

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
                  style: theme.typography.body.copyWith(color: subtleText),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                srcLabel,
                style:
                    theme.typography.body.copyWith(fontFamily: 'monospace'),
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
                  style: theme.typography.body.copyWith(color: subtleText),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                cropOut,
                style:
                    theme.typography.body.copyWith(fontFamily: 'monospace'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(MacosThemeData theme, dynamic l10n) {
    final isDark = theme.brightness == Brightness.dark;
    final subtleText =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);

    final fontState = context.watch<FontCubit>().state;
    final fonts = fontState is NormalState<FontState>
        ? fontState.data.fonts
        : const <FontInfo>[];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppDropdown<Deinterlace>(
            label: l10n.deinterlace,
            value: _c.deinterlace,
            items: Deinterlace.values,
            itemLabel: _deinterlaceLabel,
            onChanged: _c.setDeinterlace,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(l10n.textOverlays, style: theme.typography.headline),
              const Spacer(),
              PushButton(
                controlSize: ControlSize.small,
                secondary: true,
                onPressed: _c.addOverlay,
                child: Text(l10n.addText),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _c.textOverlays.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isDark
                      ? const Color(0xFF1C1C1E)
                      : const Color(0xFFF2F2F7),
                ),
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
                        MacosIconButton(
                          icon: MacosIcon(
                            CupertinoIcons.xmark,
                            size: 12,
                            color: subtleText,
                          ),
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
                        TextOverlayType.timestamp => l10n.overlayTypeTimestamp,
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
                    if (_c.textOverlays[i].type == TextOverlayType.custom) ...[
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
                                  _c.textOverlays[i].copyWith(fontColor: v),
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
                                  _c.textOverlays[i].copyWith(borderColor: v),
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
        ],
      ),
    );
  }

  Widget _buildAudioTab(MacosThemeData theme) {
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

class _TrafficLightButton extends StatefulWidget {
  const _TrafficLightButton({
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.onTap,
  });

  final Color color;
  final Color borderColor;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_TrafficLightButton> createState() => _TrafficLightButtonState();
}

class _TrafficLightButtonState extends State<_TrafficLightButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            border: Border.all(color: widget.borderColor, width: 0.5),
          ),
          alignment: Alignment.center,
          child: _hovered
              ? Icon(widget.icon, size: 8, color: const Color(0x99000000))
              : null,
        ),
      ),
    );
  }
}
