// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../settings_preset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SettingsPreset _$SettingsPresetFromJson(Map<String, dynamic> json) =>
    _SettingsPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      settings: EncodeSettings.fromJson(
        json['settings'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$SettingsPresetToJson(_SettingsPreset instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isBuiltIn': instance.isBuiltIn,
      'settings': instance.settings,
    };
