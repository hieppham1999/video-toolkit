import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';

part 'generated/user_settings.freezed.dart';
part 'generated/user_settings.g.dart';

/// Persisted user state across app restarts: last-used encode settings
/// and which preset was selected.
@freezed
abstract class UserSettings with _$UserSettings {
  const factory UserSettings({
    String? selectedPresetId,
    required EncodeSettings encodeSettings,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}
