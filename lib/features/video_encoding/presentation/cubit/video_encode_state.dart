import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_progress.dart';

part 'generated/video_encode_state.freezed.dart';

enum EncodeStatus { idle, encoding, done, error }

@freezed
abstract class VideoEncodeState with _$VideoEncodeState {
  const factory VideoEncodeState({
    @Default(EncodeStatus.idle) EncodeStatus status,
    @Default(EncodeProgress()) EncodeProgress progress,
    String? errorMessage,
    String? currentFilePath,
    String? outputPath,
    @Default(0) int currentIndex,
    @Default(0) int totalFiles,
    @Default(0) int completedCount,
    @Default([]) List<String> failedFiles,
  }) = _VideoEncodeState;
}
