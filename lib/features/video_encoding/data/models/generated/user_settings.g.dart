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
      accentColor:
          $enumDecodeNullable(_$AppAccentEnumMap, json['accentColor']) ??
          AppAccent.blue,
      language:
          $enumDecodeNullable(_$AppLanguageEnumMap, json['language']) ??
          AppLanguage.system,
      themeMode:
          $enumDecodeNullable(_$AppThemeModeEnumMap, json['themeMode']) ??
          AppThemeMode.system,
    );

Map<String, dynamic> _$UserSettingsToJson(_UserSettings instance) =>
    <String, dynamic>{
      'selectedPresetId': instance.selectedPresetId,
      'encodeSettings': instance.encodeSettings,
      'defaultFontPath': instance.defaultFontPath,
      'accentColor': _$AppAccentEnumMap[instance.accentColor]!,
      'language': _$AppLanguageEnumMap[instance.language]!,
      'themeMode': _$AppThemeModeEnumMap[instance.themeMode]!,
    };

const _$AppAccentEnumMap = {
  AppAccent.blue: 'blue',
  AppAccent.purple: 'purple',
  AppAccent.pink: 'pink',
  AppAccent.red: 'red',
  AppAccent.orange: 'orange',
  AppAccent.yellow: 'yellow',
  AppAccent.green: 'green',
  AppAccent.teal: 'teal',
  AppAccent.graphite: 'graphite',
};

const _$AppLanguageEnumMap = {
  AppLanguage.system: 'system',
  AppLanguage.en: 'en',
  AppLanguage.vi: 'vi',
};

const _$AppThemeModeEnumMap = {
  AppThemeMode.system: 'system',
  AppThemeMode.light: 'light',
  AppThemeMode.dark: 'dark',
};
