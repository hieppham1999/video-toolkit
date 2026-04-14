import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_toolkit/features/video_metadata/data/models/video_metadata.dart';

part 'generated/video_file.freezed.dart';

@freezed
abstract class VideoFile with _$VideoFile {
  const factory VideoFile({
    required String path,
    required String name,
    required int sizeInBytes,
    required DateTime importedAt,
    VideoMetadata? metadata,
  }) = _VideoFile;
}
