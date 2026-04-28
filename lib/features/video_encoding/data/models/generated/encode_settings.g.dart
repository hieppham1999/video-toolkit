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

_EncodeSettings _$EncodeSettingsFromJson(Map<String, dynamic> json) =>
    _EncodeSettings(
      codec:
          $enumDecodeNullable(_$VideoEncoderEnumMap, json['codec']) ??
          VideoEncoder.h264,
      preset:
          $enumDecodeNullable(_$EncodePresetEnumMap, json['preset']) ??
          EncodePreset.veryfast,
      crf: (json['crf'] as num?)?.toInt() ?? 23,
      outputExtension:
          $enumDecodeNullable(
            _$OutputExtensionEnumMap,
            json['outputExtension'],
          ) ??
          OutputExtension.mp4,
      resolution: json['resolution'] as String?,
      audioCodec:
          $enumDecodeNullable(_$AudioCodecEnumMap, json['audioCodec']) ??
          AudioCodec.passthrough,
      audioBitrate:
          $enumDecodeNullable(_$AudioBitrateEnumMap, json['audioBitrate']) ??
          AudioBitrate.k128,
      textOverlays:
          (json['textOverlays'] as List<dynamic>?)
              ?.map((e) => TextOverlay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      outputNameTemplate: json['outputNameTemplate'] as String? ?? '',
      cropAspectRatio: json['cropAspectRatio'] as String?,
      deinterlace:
          $enumDecodeNullable(_$DeinterlaceEnumMap, json['deinterlace']) ??
          Deinterlace.off,
      qualityMode:
          $enumDecodeNullable(_$QualityModeEnumMap, json['qualityMode']) ??
          QualityMode.crf,
      avgBitrateKbps: (json['avgBitrateKbps'] as num?)?.toInt() ?? 4000,
      twoPass: json['twoPass'] as bool? ?? false,
      turboFirstPass: json['turboFirstPass'] as bool? ?? false,
      extraParams: json['extraParams'] as String? ?? '',
      copySourceMetadata: json['copySourceMetadata'] as bool? ?? true,
      webOptimized: json['webOptimized'] as bool? ?? true,
    );

Map<String, dynamic> _$EncodeSettingsToJson(_EncodeSettings instance) =>
    <String, dynamic>{
      'codec': _$VideoEncoderEnumMap[instance.codec]!,
      'preset': _$EncodePresetEnumMap[instance.preset]!,
      'crf': instance.crf,
      'outputExtension': _$OutputExtensionEnumMap[instance.outputExtension]!,
      'resolution': instance.resolution,
      'audioCodec': _$AudioCodecEnumMap[instance.audioCodec]!,
      'audioBitrate': _$AudioBitrateEnumMap[instance.audioBitrate]!,
      'textOverlays': instance.textOverlays,
      'outputNameTemplate': instance.outputNameTemplate,
      'cropAspectRatio': instance.cropAspectRatio,
      'deinterlace': _$DeinterlaceEnumMap[instance.deinterlace]!,
      'qualityMode': _$QualityModeEnumMap[instance.qualityMode]!,
      'avgBitrateKbps': instance.avgBitrateKbps,
      'twoPass': instance.twoPass,
      'turboFirstPass': instance.turboFirstPass,
      'extraParams': instance.extraParams,
      'copySourceMetadata': instance.copySourceMetadata,
      'webOptimized': instance.webOptimized,
    };

const _$VideoEncoderEnumMap = {
  VideoEncoder.h264: 'h264',
  VideoEncoder.h265: 'h265',
  VideoEncoder.vp9: 'vp9',
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

const _$OutputExtensionEnumMap = {
  OutputExtension.mp4: 'mp4',
  OutputExtension.mov: 'mov',
  OutputExtension.avi: 'avi',
  OutputExtension.mkv: 'mkv',
  OutputExtension.mts: 'mts',
};

const _$AudioCodecEnumMap = {
  AudioCodec.aac: 'aac',
  AudioCodec.mp3: 'mp3',
  AudioCodec.ac3: 'ac3',
  AudioCodec.passthrough: 'passthrough',
};

const _$AudioBitrateEnumMap = {
  AudioBitrate.k64: 'k64',
  AudioBitrate.k128: 'k128',
  AudioBitrate.k192: 'k192',
  AudioBitrate.k256: 'k256',
  AudioBitrate.k320: 'k320',
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
};
