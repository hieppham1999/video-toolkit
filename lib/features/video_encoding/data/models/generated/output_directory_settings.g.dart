// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../output_directory_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OutputDirectorySettings _$OutputDirectorySettingsFromJson(
  Map<String, dynamic> json,
) => _OutputDirectorySettings(
  mode:
      $enumDecodeNullable(_$OutputDirectoryModeEnumMap, json['mode']) ??
      OutputDirectoryMode.sameAsSource,
  subfolderEnabled: json['subfolderEnabled'] as bool? ?? false,
  subfolderName: json['subfolderName'] as String? ?? '',
  customPath: json['customPath'] as String?,
);

Map<String, dynamic> _$OutputDirectorySettingsToJson(
  _OutputDirectorySettings instance,
) => <String, dynamic>{
  'mode': _$OutputDirectoryModeEnumMap[instance.mode]!,
  'subfolderEnabled': instance.subfolderEnabled,
  'subfolderName': instance.subfolderName,
  'customPath': instance.customPath,
};

const _$OutputDirectoryModeEnumMap = {
  OutputDirectoryMode.sameAsSource: 'sameAsSource',
  OutputDirectoryMode.custom: 'custom',
};
