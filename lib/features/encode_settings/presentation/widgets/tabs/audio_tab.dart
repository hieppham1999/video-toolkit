import 'package:flutter/widgets.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/widgets/app_checkbox.dart';
import 'package:video_toolkit/widgets/app_dropdown.dart';
import 'package:video_toolkit/widgets/app_field.dart';
import 'package:video_toolkit/features/encode_settings/presentation/pages/encode_settings_controller.dart';

class AudioTab extends StatelessWidget {
  const AudioTab({super.key, required this.controller});

  final EncodeSettingsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final c = controller;
    final textStyle = DefaultTextStyle.of(context).style;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppDropdown<AudioCodec>(
            label: l10n.audioCodec,
            value: c.audioCodec,
            items: AudioCodec.values,
            itemLabel: (e) => switch (e) {
              AudioCodec.none => l10n.noAudio,
              AudioCodec.passthrough => l10n.passthrough,
              _ => e.value,
            },
            onChanged: c.setAudioCodec,
          ),
          const SizedBox(height: 12),
          AppDropdown<AudioBitrate>(
            label: l10n.bitrate,
            value: c.audioBitrate,
            items: AudioBitrate.values,
            itemLabel: (e) => e.value,
            onChanged: c.setAudioBitrate,
            enabled:
                c.audioCodec != AudioCodec.passthrough &&
                c.audioCodec != AudioCodec.none,
          ),
          const SizedBox(height: 12),
          AppDropdown<AudioChannelMode>(
            label: l10n.audioChannels,
            value: c.audioChannels,
            items: AudioChannelMode.values,
            itemLabel: (mode) => switch (mode) {
              AudioChannelMode.source => l10n.keepSourceValue,
              AudioChannelMode.mono => l10n.mono,
              AudioChannelMode.stereo => l10n.stereo,
              AudioChannelMode.surround51 => l10n.surround51,
            },
            onChanged: c.setAudioChannels,
            enabled: c.audioCodec != AudioCodec.none,
          ),
          const SizedBox(height: 12),
          AppDropdown<AudioSampleRate>(
            label: l10n.sampleRate,
            value: c.audioSampleRate,
            items: AudioSampleRate.values,
            itemLabel: (rate) =>
                rate.value == null ? l10n.keepSourceValue : '${rate.value} Hz',
            onChanged: c.setAudioSampleRate,
            enabled: c.audioCodec != AudioCodec.none,
          ),
          const SizedBox(height: 12),
          AppField(
            label: l10n.audioGainDb,
            value: c.audioGainDb,
            hint: '0',
            onChanged: c.setAudioGainDb,
            enabled: c.audioCodec != AudioCodec.none,
          ),
          const SizedBox(height: 12),
          AppCheckbox(
            value: c.normalizeAudio,
            onChanged: c.setNormalizeAudio,
            enabled: c.audioCodec != AudioCodec.none,
            label: Text(l10n.normalizeAudio, style: textStyle),
          ),
          const SizedBox(height: 12),
          AppCheckbox(
            value: c.preserveAllAudioTracks,
            onChanged: c.setPreserveAllAudioTracks,
            enabled: c.audioCodec != AudioCodec.none,
            label: Text(l10n.preserveAllAudioTracks, style: textStyle),
          ),
        ],
      ),
    );
  }
}
