import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/encode_settings.freezed.dart';

@freezed
abstract class EncodeSettings with _$EncodeSettings {
  const factory EncodeSettings({
    @Default(false) bool burnTimestamp,
  }) = _EncodeSettings;
}
