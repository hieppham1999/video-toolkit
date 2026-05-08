import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';

part 'generated/settings_preset.freezed.dart';
part 'generated/settings_preset.g.dart';

@freezed
abstract class SettingsPreset with _$SettingsPreset {
  const factory SettingsPreset({
    required String id,
    required String name,
    @Default(false) bool isBuiltIn,
    required EncodeSettings settings,
  }) = _SettingsPreset;

  factory SettingsPreset.fromJson(Map<String, dynamic> json) => _$SettingsPresetFromJson(json);
}
