import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_toolkit/features/video_metadata/data/models/video_metadata.dart';

part 'generated/video_metadata_state.freezed.dart';

@freezed
abstract class VideoMetadataState with _$VideoMetadataState {
  const factory VideoMetadataState({
    @Default({}) Map<String, VideoMetadata> metadataByPath,
    @Default({}) Set<String> loadingPaths,
    @Default(true) bool isExiftoolAvailable,
    @Default(true) bool isFfprobeAvailable,
  }) = _VideoMetadataState;
}
