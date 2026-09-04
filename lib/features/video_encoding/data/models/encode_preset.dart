import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/settings_preset.dart';

/// Built-in (non-editable) encode presets shipped with the app.
const List<SettingsPreset> kBuiltInPresets = [
  SettingsPreset(
    id: 'builtin.h264_fast',
    name: 'H.264 (Fast)',
    isBuiltIn: true,
    settings: EncodeSettings(
      codec: VideoEncoder.h264,
      preset: EncodePreset.veryfast,
      crf: 23,
      outputExtension: OutputExtension.mp4,
    ),
  ),
  SettingsPreset(
    id: 'builtin.h264_quality',
    name: 'H.264 (Quality)',
    isBuiltIn: true,
    settings: EncodeSettings(
      codec: VideoEncoder.h264,
      preset: EncodePreset.slow,
      crf: 18,
      outputExtension: OutputExtension.mp4,
    ),
  ),
  SettingsPreset(
    id: 'builtin.h265',
    name: 'H.265 / HEVC',
    isBuiltIn: true,
    settings: EncodeSettings(
      codec: VideoEncoder.h265,
      preset: EncodePreset.medium,
      crf: 28,
      outputExtension: OutputExtension.mp4,
    ),
  ),
  SettingsPreset(
    id: 'builtin.vp9',
    name: 'VP9 WebM',
    isBuiltIn: true,
    settings: EncodeSettings(
      codec: VideoEncoder.vp9,
      preset: EncodePreset.medium,
      crf: 30,
      outputExtension: OutputExtension.mkv,
    ),
  ),
  SettingsPreset(
    id: 'builtin.av1',
    name: 'AV1 (Efficient)',
    isBuiltIn: true,
    settings: EncodeSettings(
      codec: VideoEncoder.av1,
      preset: EncodePreset.fast,
      crf: 30,
      outputExtension: OutputExtension.webm,
      audioCodec: AudioCodec.opus,
    ),
  ),
  SettingsPreset(
    id: 'builtin.prores',
    name: 'ProRes 422 HQ',
    isBuiltIn: true,
    settings: EncodeSettings(
      codec: VideoEncoder.prores,
      outputExtension: OutputExtension.mov,
      audioCodec: AudioCodec.aac,
    ),
  ),
];
