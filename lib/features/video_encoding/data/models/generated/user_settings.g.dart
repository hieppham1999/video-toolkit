// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) =>
    _UserSettings(
      selectedPresetId: json['selectedPresetId'] as String?,
      encodeSettings: EncodeSettings.fromJson(
        json['encodeSettings'] as Map<String, dynamic>,
      ),
      defaultFontPath: json['defaultFontPath'] as String?,
    );

Map<String, dynamic> _$UserSettingsToJson(_UserSettings instance) =>
    <String, dynamic>{
      'selectedPresetId': instance.selectedPresetId,
      'encodeSettings': instance.encodeSettings,
      'defaultFontPath': instance.defaultFontPath,
    };
