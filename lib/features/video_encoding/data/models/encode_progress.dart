import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/encode_progress.freezed.dart';

@freezed
abstract class EncodeProgress with _$EncodeProgress {
  const factory EncodeProgress({
    @Default(0) double percent,
    @Default(Duration.zero) Duration elapsed,
    Duration? estimatedRemaining,
    @Default(0) double fps,
    @Default(0) double speed,
  }) = _EncodeProgress;
}
