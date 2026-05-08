import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/output_directory_settings.freezed.dart';
part 'generated/output_directory_settings.g.dart';

enum OutputDirectoryMode { sameAsSource, custom }

@freezed
abstract class OutputDirectorySettings with _$OutputDirectorySettings {
  const factory OutputDirectorySettings({
    @Default(OutputDirectoryMode.sameAsSource) OutputDirectoryMode mode,
    @Default(false) bool subfolderEnabled,
    @Default('') String subfolderName,
    String? customPath,
  }) = _OutputDirectorySettings;

  factory OutputDirectorySettings.fromJson(Map<String, dynamic> json) =>
      _$OutputDirectorySettingsFromJson(json);
}
