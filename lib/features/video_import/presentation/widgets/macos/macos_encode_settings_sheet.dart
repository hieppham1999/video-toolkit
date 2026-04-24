import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/injection.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/features/fonts/data/models/font_info.dart';
import 'package:video_toolkit/features/fonts/presentation/cubit/font_cubit.dart';
import 'package:video_toolkit/features/fonts/presentation/cubit/font_state.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/settings_preset.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/preset_cubit.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/preset_state.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_button.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_dialog_title_bar.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_dropdown.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_field.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/shared/app_preset_tile.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/shared/encode_settings_controller.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/shared/sidebar_resize_handle.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/shared/tabs/audio_tab.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/shared/tabs/container_tab.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/shared/tabs/file_tab.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/shared/tabs/sizing_tab.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/shared/tabs/video_codec_tab.dart';
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
      presetCubit: getIt<PresetCubit>(),
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
    return BlocBuilder<PresetCubit, CubitState<PresetState>>(
      bloc: getIt<PresetCubit>(),
      builder: (context, _) => BlocBuilder<FontCubit, CubitState<FontState>>(
        bloc: getIt<FontCubit>(),
        builder: (context, _) => ListenableBuilder(
          listenable: _c,
          builder: (context, _) => _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = MacosTheme.of(context);
    final l10n = Languages.translate;

    final tabs = [
      l10n.tabFile,
      l10n.tabContainer,
      l10n.tabVideoCodec,
      l10n.tabSizing,
      l10n.tabFilter,
      l10n.tabAudio,
    ];
    final presetState = getIt<PresetCubit>().state;
    final presets = presetState is NormalState<PresetState>
        ? presetState.data.presets
        : const <SettingsPreset>[];
    final canDelete = _c.currentUserPreset() != null;

    return AppDialogTitleBar(
      title: Text(l10n.encodeSettings),
      draggable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
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
                      lineColor: AppColors.divider(theme.brightness),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Spacer(),
                                AppButton(
                                  secondary: true,
                                  onPressed: _handleImport,
                                  child: Text(l10n.import),
                                ),
                                const SizedBox(width: 6),
                                AppButton(
                                  secondary: true,
                                  onPressed: _c.selectedPresetId != null
                                      ? () => _c.exportSelectedPreset()
                                      : null,
                                  child: Text(l10n.export),
                                ),
                                const SizedBox(width: 6),
                                AppButton(
                                  secondary: true,
                                  onPressed: _c.selectedPresetId != null
                                      ? _handleRevert
                                      : null,
                                  child: Text(l10n.revert),
                                ),
                                const SizedBox(width: 6),
                                AppButton(
                                  secondary: true,
                                  onPressed: () =>
                                      _c.handleSaveAs(_promptPresetName),
                                  child: Text(l10n.saveAs),
                                ),
                                const SizedBox(width: 6),
                                AppButton(
                                  secondary: true,
                                  onPressed: () =>
                                      _c.handleSave(_promptPresetName),
                                  child: Text(l10n.save),
                                ),
                                const SizedBox(width: 6),
                                AppButton(
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
                                0 => FileTab(
                                    controller: _c,
                                    sampleFileName: widget.sampleFileName,
                                    sampleCreationDate:
                                        widget.sampleCreationDate,
                                  ),
                                1 => ContainerTab(controller: _c),
                                2 => VideoCodecTab(controller: _c),
                                3 => SizingTab(
                                    controller: _c,
                                    sampleWidth: widget.sampleWidth,
                                    sampleHeight: widget.sampleHeight,
                                  ),
                                4 => _buildFilterTab(theme, l10n),
                                5 => AudioTab(controller: _c),
                                _ => const SizedBox.shrink(),
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (widget.onReset != null)
                                  AppButton(
                                    size: AppButtonSize.large,
                                    secondary: true,
                                    onPressed: widget.onReset,
                                    child: Text(l10n.resetToGlobal),
                                  ),
                                const Spacer(),
                                AppButton(
                                  size: AppButtonSize.large,
                                  secondary: true,
                                  onPressed: widget.onCancel,
                                  child: Text(l10n.cancel),
                                ),
                                const SizedBox(width: 8),
                                AppButton(
                                  size: AppButtonSize.large,
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
      );
  }

  Widget _buildPresetSidebar(
    MacosThemeData theme,
    dynamic l10n,
    List<SettingsPreset> presets,
  ) {
    final b = theme.brightness;
    final subtle = AppColors.textTertiary(b);
    final bg = AppColors.surface(b);

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

  Widget _buildFilterTab(MacosThemeData theme, dynamic l10n) {
    final b = theme.brightness;
    final subtleText = AppColors.textTertiary(b);

    final fontState = getIt<FontCubit>().state;
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
            itemLabel: EncodeSettingsController.deinterlaceLabel,
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
                  color: AppColors.surface(b),
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
                    if (_c.textOverlays[i].position !=
                        TextOverlayPosition.center) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: AppField(
                              label: l10n.offsetX,
                              value: '${_c.textOverlays[i].offsetX}',
                              onChanged: (v) => _c.updateOverlay(
                                i,
                                _c.textOverlays[i].copyWith(
                                  offsetX: int.tryParse(v) ?? 0,
                                ),
                              ),
                              hint: l10n.offsetHint,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppField(
                              label: l10n.offsetY,
                              value: '${_c.textOverlays[i].offsetY}',
                              onChanged: (v) => _c.updateOverlay(
                                i,
                                _c.textOverlays[i].copyWith(
                                  offsetY: int.tryParse(v) ?? 0,
                                ),
                              ),
                              hint: l10n.offsetHint,
                            ),
                          ),
                        ],
                      ),
                    ],
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

}

