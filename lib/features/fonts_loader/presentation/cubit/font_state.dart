import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_toolkit/features/fonts_loader/data/models/font_info.dart';

part 'generated/font_state.freezed.dart';

@freezed
abstract class FontState with _$FontState {
  const factory FontState({
    @Default([]) List<FontInfo> fonts,
    @Default(false) bool isLoading,
  }) = _FontState;
}
