// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../encode_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TextOverlay _$TextOverlayFromJson(Map<String, dynamic> json) => _TextOverlay(
  text: json['text'] as String,
  type:
      $enumDecodeNullable(_$TextOverlayTypeEnumMap, json['type']) ??
      TextOverlayType.custom,
  fontSize: (json['fontSize'] as num?)?.toInt() ?? 24,
  fontColor: json['fontColor'] as String? ?? 'white',
  position:
      $enumDecodeNullable(_$TextOverlayPositionEnumMap, json['position']) ??
      TextOverlayPosition.bottomRight,
  offsetX: (json['offsetX'] as num?)?.toInt() ?? 16,
  offsetY: (json['offsetY'] as num?)?.toInt() ?? 16,
  fontFile: json['fontFile'] as String?,
  showBackground: json['showBackground'] as bool? ?? true,
  backgroundColor: json['backgroundColor'] as String? ?? 'black@0.5',
  borderWidth: (json['borderWidth'] as num?)?.toInt() ?? 0,
  borderColor: json['borderColor'] as String? ?? 'black',
  showTimezone: json['showTimezone'] as bool? ?? false,
);

Map<String, dynamic> _$TextOverlayToJson(_TextOverlay instance) =>
    <String, dynamic>{
      'text': instance.text,
      'type': _$TextOverlayTypeEnumMap[instance.type]!,
      'fontSize': instance.fontSize,
      'fontColor': instance.fontColor,
      'position': _$TextOverlayPositionEnumMap[instance.position]!,
      'offsetX': instance.offsetX,
      'offsetY': instance.offsetY,
      'fontFile': instance.fontFile,
      'showBackground': instance.showBackground,
      'backgroundColor': instance.backgroundColor,
      'borderWidth': instance.borderWidth,
      'borderColor': instance.borderColor,
      'showTimezone': instance.showTimezone,
    };

const _$TextOverlayTypeEnumMap = {
  TextOverlayType.custom: 'custom',
  TextOverlayType.timestamp: 'timestamp',
};

const _$TextOverlayPositionEnumMap = {
  TextOverlayPosition.topLeft: 'topLeft',
  TextOverlayPosition.topRight: 'topRight',
  TextOverlayPosition.bottomLeft: 'bottomLeft',
  TextOverlayPosition.bottomRight: 'bottomRight',
  TextOverlayPosition.center: 'center',
};

_EncodeSettings _$EncodeSettingsFromJson(
  Map<String, dynamic> json,
) => _EncodeSettings(
  codec:
      $enumDecodeNullable(_$VideoEncoderEnumMap, json['codec']) ??
      VideoEncoder.h264,
  encoderMode:
      $enumDecodeNullable(_$EncoderModeEnumMap, json['encoderMode']) ??
      EncoderMode.software,
  preset:
      $enumDecodeNullable(_$EncodePresetEnumMap, json['preset']) ??
      EncodePreset.veryfast,
  videoProfile:
      $enumDecodeNullable(_$VideoProfileEnumMap, json['videoProfile']) ??
      VideoProfile.auto,
  videoLevel:
      $enumDecodeNullable(_$VideoLevelEnumMap, json['videoLevel']) ??
      VideoLevel.auto,
  pixelFormat:
      $enumDecodeNullable(_$PixelFormatEnumMap, json['pixelFormat']) ??
      PixelFormat.auto,
  frameRate: (json['frameRate'] as num?)?.toDouble(),
  toneMapMode:
      $enumDecodeNullable(_$ToneMapModeEnumMap, json['toneMapMode']) ??
      ToneMapMode.off,
  crf: (json['crf'] as num?)?.toInt() ?? 23,
  outputExtension:
      $enumDecodeNullable(_$OutputExtensionEnumMap, json['outputExtension']) ??
      OutputExtension.mp4,
  resolution: json['resolution'] as String?,
  audioCodec:
      $enumDecodeNullable(_$AudioCodecEnumMap, json['audioCodec']) ??
      AudioCodec.passthrough,
  audioBitrate:
      $enumDecodeNullable(_$AudioBitrateEnumMap, json['audioBitrate']) ??
      AudioBitrate.k128,
  audioChannels:
      $enumDecodeNullable(_$AudioChannelModeEnumMap, json['audioChannels']) ??
      AudioChannelMode.source,
  audioSampleRate:
      $enumDecodeNullable(_$AudioSampleRateEnumMap, json['audioSampleRate']) ??
      AudioSampleRate.source,
  normalizeAudio: json['normalizeAudio'] as bool? ?? false,
  audioGainDb: (json['audioGainDb'] as num?)?.toDouble() ?? 0,
  preserveAllAudioTracks: json['preserveAllAudioTracks'] as bool? ?? true,
  textOverlays:
      (json['textOverlays'] as List<dynamic>?)
          ?.map((e) => TextOverlay.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  embedTimestampSubtitle: json['embedTimestampSubtitle'] as bool? ?? false,
  preserveSourceSubtitles: json['preserveSourceSubtitles'] as bool? ?? false,
  outputNameTemplate: json['outputNameTemplate'] as String? ?? '',
  cropAspectRatio: json['cropAspectRatio'] as String?,
  deinterlace:
      $enumDecodeNullable(_$DeinterlaceEnumMap, json['deinterlace']) ??
      Deinterlace.off,
  qualityMode:
      $enumDecodeNullable(_$QualityModeEnumMap, json['qualityMode']) ??
      QualityMode.crf,
  avgBitrateKbps: (json['avgBitrateKbps'] as num?)?.toInt() ?? 4000,
  targetSizeMb: (json['targetSizeMb'] as num?)?.toInt() ?? 100,
  twoPass: json['twoPass'] as bool? ?? false,
  turboFirstPass: json['turboFirstPass'] as bool? ?? false,
  extraParams: json['extraParams'] as String? ?? '',
  copySourceMetadata: json['copySourceMetadata'] as bool? ?? true,
  sourceTimezoneOffset: json['sourceTimezoneOffset'] as String?,
  webOptimized: json['webOptimized'] as bool? ?? true,
  rotation:
      $enumDecodeNullable(_$RotationEnumMap, json['rotation']) ?? Rotation.none,
  useDisplayRotation: json['useDisplayRotation'] as bool? ?? false,
  flipHorizontal: json['flipHorizontal'] as bool? ?? false,
  flipVertical: json['flipVertical'] as bool? ?? false,
);

Map<String, dynamic> _$EncodeSettingsToJson(_EncodeSettings instance) =>
    <String, dynamic>{
      'codec': _$VideoEncoderEnumMap[instance.codec]!,
      'encoderMode': _$EncoderModeEnumMap[instance.encoderMode]!,
      'preset': _$EncodePresetEnumMap[instance.preset]!,
      'videoProfile': _$VideoProfileEnumMap[instance.videoProfile]!,
      'videoLevel': _$VideoLevelEnumMap[instance.videoLevel]!,
      'pixelFormat': _$PixelFormatEnumMap[instance.pixelFormat]!,
      'frameRate': instance.frameRate,
      'toneMapMode': _$ToneMapModeEnumMap[instance.toneMapMode]!,
      'crf': instance.crf,
      'outputExtension': _$OutputExtensionEnumMap[instance.outputExtension]!,
      'resolution': instance.resolution,
      'audioCodec': _$AudioCodecEnumMap[instance.audioCodec]!,
      'audioBitrate': _$AudioBitrateEnumMap[instance.audioBitrate]!,
      'audioChannels': _$AudioChannelModeEnumMap[instance.audioChannels]!,
      'audioSampleRate': _$AudioSampleRateEnumMap[instance.audioSampleRate]!,
      'normalizeAudio': instance.normalizeAudio,
      'audioGainDb': instance.audioGainDb,
      'preserveAllAudioTracks': instance.preserveAllAudioTracks,
      'textOverlays': instance.textOverlays,
      'embedTimestampSubtitle': instance.embedTimestampSubtitle,
      'preserveSourceSubtitles': instance.preserveSourceSubtitles,
      'outputNameTemplate': instance.outputNameTemplate,
      'cropAspectRatio': instance.cropAspectRatio,
      'deinterlace': _$DeinterlaceEnumMap[instance.deinterlace]!,
      'qualityMode': _$QualityModeEnumMap[instance.qualityMode]!,
      'avgBitrateKbps': instance.avgBitrateKbps,
      'targetSizeMb': instance.targetSizeMb,
      'twoPass': instance.twoPass,
      'turboFirstPass': instance.turboFirstPass,
      'extraParams': instance.extraParams,
      'copySourceMetadata': instance.copySourceMetadata,
      'sourceTimezoneOffset': instance.sourceTimezoneOffset,
      'webOptimized': instance.webOptimized,
      'rotation': _$RotationEnumMap[instance.rotation]!,
      'useDisplayRotation': instance.useDisplayRotation,
      'flipHorizontal': instance.flipHorizontal,
      'flipVertical': instance.flipVertical,
    };

const _$VideoEncoderEnumMap = {
  VideoEncoder.h264: 'h264',
  VideoEncoder.h265: 'h265',
  VideoEncoder.vp9: 'vp9',
  VideoEncoder.av1: 'av1',
  VideoEncoder.prores: 'prores',
};

const _$EncoderModeEnumMap = {
  EncoderMode.software: 'software',
  EncoderMode.auto: 'auto',
  EncoderMode.hardware: 'hardware',
};

const _$EncodePresetEnumMap = {
  EncodePreset.veryfast: 'veryfast',
  EncodePreset.faster: 'faster',
  EncodePreset.fast: 'fast',
  EncodePreset.medium: 'medium',
  EncodePreset.slow: 'slow',
  EncodePreset.slower: 'slower',
  EncodePreset.veryslow: 'veryslow',
};

const _$VideoProfileEnumMap = {
  VideoProfile.auto: 'auto',
  VideoProfile.baseline: 'baseline',
  VideoProfile.main: 'main',
  VideoProfile.high: 'high',
  VideoProfile.main10: 'main10',
};

const _$VideoLevelEnumMap = {
  VideoLevel.auto: 'auto',
  VideoLevel.l3_1: 'l3_1',
  VideoLevel.l4_0: 'l4_0',
  VideoLevel.l4_1: 'l4_1',
  VideoLevel.l5_0: 'l5_0',
  VideoLevel.l5_1: 'l5_1',
};

const _$PixelFormatEnumMap = {
  PixelFormat.auto: 'auto',
  PixelFormat.yuv420p: 'yuv420p',
  PixelFormat.yuv420p10le: 'yuv420p10le',
  PixelFormat.yuv422p10le: 'yuv422p10le',
};

const _$ToneMapModeEnumMap = {
  ToneMapMode.off: 'off',
  ToneMapMode.hable: 'hable',
  ToneMapMode.reinhard: 'reinhard',
  ToneMapMode.mobius: 'mobius',
};

const _$OutputExtensionEnumMap = {
  OutputExtension.mp4: 'mp4',
  OutputExtension.mov: 'mov',
  OutputExtension.avi: 'avi',
  OutputExtension.mkv: 'mkv',
  OutputExtension.mts: 'mts',
  OutputExtension.webm: 'webm',
};

const _$AudioCodecEnumMap = {
  AudioCodec.none: 'none',
  AudioCodec.aac: 'aac',
  AudioCodec.mp3: 'mp3',
  AudioCodec.ac3: 'ac3',
  AudioCodec.opus: 'opus',
  AudioCodec.passthrough: 'passthrough',
};

const _$AudioBitrateEnumMap = {
  AudioBitrate.k64: 'k64',
  AudioBitrate.k128: 'k128',
  AudioBitrate.k192: 'k192',
  AudioBitrate.k256: 'k256',
  AudioBitrate.k320: 'k320',
};

const _$AudioChannelModeEnumMap = {
  AudioChannelMode.source: 'source',
  AudioChannelMode.mono: 'mono',
  AudioChannelMode.stereo: 'stereo',
  AudioChannelMode.surround51: 'surround51',
};

const _$AudioSampleRateEnumMap = {
  AudioSampleRate.source: 'source',
  AudioSampleRate.hz44100: 'hz44100',
  AudioSampleRate.hz48000: 'hz48000',
  AudioSampleRate.hz96000: 'hz96000',
};

const _$DeinterlaceEnumMap = {
  Deinterlace.off: 'off',
  Deinterlace.yadifFrame: 'yadifFrame',
  Deinterlace.yadifField: 'yadifField',
  Deinterlace.bwdifFrame: 'bwdifFrame',
  Deinterlace.bwdifField: 'bwdifField',
};

const _$QualityModeEnumMap = {
  QualityMode.crf: 'crf',
  QualityMode.avgBitrate: 'avgBitrate',
  QualityMode.targetSize: 'targetSize',
};

const _$RotationEnumMap = {
  Rotation.none: 'none',
  Rotation.cw90: 'cw90',
  Rotation.deg180: 'deg180',
  Rotation.ccw90: 'ccw90',
};
