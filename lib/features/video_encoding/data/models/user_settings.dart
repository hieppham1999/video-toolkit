import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_toolkit/core/i18n/app_language.dart';
import 'package:video_toolkit/core/theme/app_accent.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';

part 'generated/user_settings.freezed.dart';
part 'generated/user_settings.g.dart';

/// Persisted user state across app restarts: last-used encode settings,
/// selected preset, default font, and app-level preferences (accent, locale).
@freezed
abstract class UserSettings with _$UserSettings {
  const factory UserSettings({
    String? selectedPresetId,
    required EncodeSettings encodeSettings,
    /// User-chosen default font path. Used when an overlay has no explicit
    /// `fontFile`. When null or the file no longer exists, the bundled VCR
    /// font is used as the final fallback. Configured from the app settings
    /// page.
    String? defaultFontPath,
    @Default(AppAccent.blue) AppAccent accentColor,
    @Default(AppLanguage.system) AppLanguage language,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}
