import 'package:flutter/widgets.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/app_dropdown.dart';
import 'package:video_toolkit/features/video_import/presentation/widgets/shared/encode_settings_controller.dart';

class AudioTab extends StatelessWidget {
  const AudioTab({super.key, required this.controller});

  final EncodeSettingsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final c = controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDropdown<AudioCodec>(
          label: l10n.audioCodec,
          value: c.audioCodec,
          items: AudioCodec.values,
          itemLabel: (e) =>
              e == AudioCodec.passthrough ? 'passthrough' : e.value,
          onChanged: c.setAudioCodec,
        ),
        const SizedBox(height: 12),
        AppDropdown<AudioBitrate>(
          label: l10n.bitrate,
          value: c.audioBitrate,
          items: AudioBitrate.values,
          itemLabel: (e) => e.value,
          onChanged: c.setAudioBitrate,
          enabled: c.audioCodec != AudioCodec.passthrough,
        ),
      ],
    );
  }
}
