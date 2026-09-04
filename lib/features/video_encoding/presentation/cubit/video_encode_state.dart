import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_failure.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_progress.dart';

part 'generated/video_encode_state.freezed.dart';

enum EncodeStatus { idle, encoding, done, error }

@freezed
abstract class VideoEncodeState with _$VideoEncodeState {
  const VideoEncodeState._();

  const factory VideoEncodeState({
    @Default(EncodeStatus.idle) EncodeStatus status,
    @Default(EncodeProgress()) EncodeProgress progress,
    String? errorMessage,
    String? currentFilePath,
    String? outputPath,
    @Default(0) int currentIndex,
    @Default(0) int totalFiles,
    @Default(0) int completedCount,
    @Default([]) List<EncodeFailure> failures,

    /// Concrete output paths reserved for the current batch, keyed by input
    /// path. These remain stable for the lifetime of the batch.
    @Default({}) Map<String, String> outputPaths,
  }) = _VideoEncodeState;

  /// Paths of files that failed to encode (convenience accessor).
  List<String> get failedPaths => failures.map((f) => f.filePath).toList();
}
