import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/injection.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/app/base/app_state.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/features/fonts_loader/data/models/font_info.dart';
import 'package:video_toolkit/features/fonts_loader/presentation/cubit/font_cubit.dart';
import 'package:video_toolkit/features/fonts_loader/presentation/cubit/font_state.dart';
import 'package:video_toolkit/features/encode_settings/presentation/pages/encode_settings_controller.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/widgets/app_checkbox.dart';
import 'package:video_toolkit/widgets/app_dropdown.dart';
import 'package:video_toolkit/widgets/app_field.dart';
import 'package:video_toolkit/widgets/color_picker_button.dart';

class FilterTab extends StatelessWidget {
  const FilterTab({super.key, required this.controller});

  final EncodeSettingsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final l10n = Languages.translate;
    final c = controller;

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
            value: c.deinterlace,
            items: Deinterlace.values,
            itemLabel: EncodeSettingsController.deinterlaceLabel,
            onChanged: c.setDeinterlace,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(l10n.textOverlays, style: theme.typography.headline),
              const Spacer(),
              PushButton(
                controlSize: ControlSize.small,
                secondary: true,
                onPressed: c.addOverlay,
                child: Text(l10n.addText),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < c.textOverlays.length; i++)
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
                          onPressed: () => c.removeOverlay(i),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppDropdown<TextOverlayType>(
                      label: l10n.overlayType,
                      value: c.textOverlays[i].type,
                      items: TextOverlayType.values,
                      itemLabel: (e) => switch (e) {
                        TextOverlayType.custom => l10n.overlayTypeCustom,
                        TextOverlayType.timestamp => l10n.overlayTypeTimestamp,
                      },
                      onChanged: (v) => c.updateOverlay(
                        i,
                        c.textOverlays[i].copyWith(
                          type: v,
                          text: v == TextOverlayType.timestamp
                              ? ''
                              : c.textOverlays[i].text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (c.textOverlays[i].type == TextOverlayType.custom) ...[
                      AppField(
                        label: l10n.textLabel,
                        value: c.textOverlays[i].text,
                        onChanged: (v) => c.updateOverlay(
                          i,
                          c.textOverlays[i].copyWith(text: v),
                        ),
                        hint: l10n.textHintTimestamp,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (c.textOverlays[i].type ==
                        TextOverlayType.timestamp) ...[
                      AppCheckbox(
                        value: c.textOverlays[i].showTimezone,
                        onChanged: (v) => c.updateOverlay(
                          i,
                          c.textOverlays[i].copyWith(showTimezone: v),
                        ),
                        label: Text(l10n.overlayShowTimezone),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: AppField(
                            label: l10n.fontSize,
                            value: '${c.textOverlays[i].fontSize}',
                            onChanged: (v) => c.updateOverlay(
                              i,
                              c.textOverlays[i].copyWith(
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
                                value: c.textOverlays[i].fontColor,
                                onChanged: (v) => c.updateOverlay(
                                  i,
                                  c.textOverlays[i].copyWith(fontColor: v),
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
                            value: '${c.textOverlays[i].borderWidth}',
                            onChanged: (v) => c.updateOverlay(
                              i,
                              c.textOverlays[i].copyWith(
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
                                value: c.textOverlays[i].borderColor,
                                onChanged: (v) => c.updateOverlay(
                                  i,
                                  c.textOverlays[i].copyWith(borderColor: v),
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
                      value: c.textOverlays[i].position,
                      items: TextOverlayPosition.values,
                      itemLabel: (e) => e.name,
                      onChanged: (v) => c.updateOverlay(
                        i,
                        c.textOverlays[i].copyWith(position: v),
                      ),
                    ),
                    if (c.textOverlays[i].position !=
                        TextOverlayPosition.center) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: AppField(
                              label: l10n.offsetX,
                              value: '${c.textOverlays[i].offsetX}',
                              onChanged: (v) => c.updateOverlay(
                                i,
                                c.textOverlays[i].copyWith(
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
                              value: '${c.textOverlays[i].offsetY}',
                              onChanged: (v) => c.updateOverlay(
                                i,
                                c.textOverlays[i].copyWith(
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
                      value: c.textOverlays[i].fontFile ?? '',
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
                      onChanged: (v) => c.updateOverlay(
                        i,
                        c.textOverlays[i]
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
