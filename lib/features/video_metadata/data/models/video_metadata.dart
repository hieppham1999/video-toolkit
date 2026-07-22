import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/video_metadata.freezed.dart';

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
    @Default({}) Map<String, String> rawExif,
  }) = _VideoMetadata;
}
