import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/preview_state.freezed.dart';

@freezed
abstract class PreviewState with _$PreviewState {
  const factory PreviewState({
    String? framePath,
    @Default(0) int frameRevision,
    @Default(false) bool isLoading,
    @Default(false) bool isLive,
    String? errorMessage,
  }) = _PreviewState;
}
