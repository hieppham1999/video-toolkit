import 'package:flutter/widgets.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_dropdown.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_field.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/shared/encode_settings_controller.dart';

class ContainerTab extends StatelessWidget {
  const ContainerTab({super.key, required this.controller});

  final EncodeSettingsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final c = controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDropdown<OutputExtension>(
          label: l10n.fileExtension,
          value: c.outputExtension,
          items: OutputExtension.values,
          itemLabel: (e) => e.value,
          onChanged: c.setOutputExtension,
        ),
        const SizedBox(height: 12),
        AppDropdown<VideoEncoder>(
          label: l10n.videoCodec,
          value: c.codec,
          items: VideoEncoder.values,
          itemLabel: (e) => e.value,
          onChanged: c.setCodec,
        ),
        const SizedBox(height: 12),
        AppDropdown<EncodePreset>(
          label: l10n.encodePreset,
          value: c.preset,
          items: EncodePreset.values,
          itemLabel: (e) => e.value,
          onChanged: c.setPreset,
        ),
        const SizedBox(height: 12),
        AppField(
          label: l10n.crf,
          value: '${c.crf}',
          onChanged: (v) => c.setCrf(int.tryParse(v) ?? c.crf),
        ),
      ],
    );
  }
}
