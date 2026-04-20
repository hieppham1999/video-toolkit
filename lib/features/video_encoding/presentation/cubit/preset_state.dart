import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_toolkit/features/video_encoding/data/models/settings_preset.dart';

part 'generated/preset_state.freezed.dart';

@freezed
abstract class PresetState with _$PresetState {
  const factory PresetState({
    @Default([]) List<SettingsPreset> presets,
    String? selectedId,
    @Default(false) bool isLoading,
  }) = _PresetState;
}
