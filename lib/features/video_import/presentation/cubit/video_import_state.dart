import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/video_file.dart';

part 'generated/video_import_state.freezed.dart';

@freezed
abstract class VideoImportState with _$VideoImportState {
  const factory VideoImportState({
    @Default([]) List<VideoFile> files,
    @Default(false) bool isDragging,
  }) = _VideoImportState;
}
