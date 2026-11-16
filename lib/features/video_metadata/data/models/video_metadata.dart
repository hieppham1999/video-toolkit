import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/video_metadata.freezed.dart';

@freezed
abstract class SubtitleTrack with _$SubtitleTrack {
  const factory SubtitleTrack({
    required int index,
    String? codec,
    String? title,
    String? language,
    @Default(false) bool isDefault,
    @Default(false) bool isForced,
  }) = _SubtitleTrack;
}

@freezed
abstract class VideoMetadata with _$VideoMetadata {
  const factory VideoMetadata({
    Duration? duration,
    int? width,
    int? height,
    String? videoCodec,
    String? audioCodec,
    int? bitrate,
    double? frameRate,
    DateTime? creationDate,
    @Default(false) bool creationDateFromFileSystem,
    String? timezoneOffset,
    double? gpsLatitude,
    double? gpsLongitude,
    String? cameraModel,

    /// Null until ffprobe successfully reads the streams; empty means none.
    List<SubtitleTrack>? subtitleTracks,
    @Default({}) Map<String, String> rawExif,
  }) = _VideoMetadata;
}
