import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';

/// Predefined encode configurations — each is a named [EncodeSettings].
enum PredefinedPreset {
  h264Fast(
    label: 'H.264 (Fast)',
    settings: EncodeSettings(
      codec: VideoEncoder.h264,
      preset: EncodePreset.veryfast,
      crf: 23,
      outputExtension: OutputExtension.mp4,
    ),
  ),
  h264Quality(
    label: 'H.264 (Quality)',
    settings: EncodeSettings(
      codec: VideoEncoder.h264,
      preset: EncodePreset.slow,
      crf: 18,
      outputExtension: OutputExtension.mp4,
    ),
  ),
  h265(
    label: 'H.265 / HEVC',
    settings: EncodeSettings(
      codec: VideoEncoder.h265,
      preset: EncodePreset.medium,
      crf: 28,
      outputExtension: OutputExtension.mp4,
    ),
  ),
  webm(
    label: 'VP9 WebM',
    settings: EncodeSettings(
      codec: VideoEncoder.vp9,
      preset: EncodePreset.medium,
      crf: 30,
      outputExtension: OutputExtension.mkv,
    ),
  );

  const PredefinedPreset({required this.label, required this.settings});

  final String label;
  final EncodeSettings settings;
}
