import 'package:injectable/injectable.dart';
import 'package:video_toolkit/features/video_metadata/data/datasources/exiftool_datasource.dart';
import 'package:video_toolkit/features/video_metadata/data/datasources/ffprobe_datasource.dart';
import 'package:video_toolkit/features/video_metadata/data/models/video_metadata.dart';
import 'package:video_toolkit/features/video_metadata/data/repositories/video_metadata_repository.dart';

@LazySingleton(as: VideoMetadataRepository)
class VideoMetadataRepositoryImpl implements VideoMetadataRepository {
  VideoMetadataRepositoryImpl(this._exiftool, this._ffprobe);

  final ExiftoolDatasource _exiftool;
  final FfprobeDatasource _ffprobe;

  @override
  Future<VideoMetadata> extractMetadata(String filePath) async {
    final results = await Future.wait([
      _ffprobe.extract(filePath),
      _exiftool.extract(filePath),
    ]);

    final ffprobeData = results[0];
    final exifData = results[1];

    if (ffprobeData == null && exifData == null) {
      return const VideoMetadata();
    }

    // ffprobe is authoritative for A/V technical data,
    // exiftool supplements with camera/GPS/creation date
    return VideoMetadata(
      duration: ffprobeData?.duration,
      width: ffprobeData?.width,
      height: ffprobeData?.height,
      videoCodec: ffprobeData?.videoCodec,
      audioCodec: ffprobeData?.audioCodec,
      bitrate: ffprobeData?.bitrate,
      frameRate: ffprobeData?.frameRate,
      creationDate: exifData?.creationDate,
      gpsLatitude: exifData?.gpsLatitude,
      gpsLongitude: exifData?.gpsLongitude,
      cameraModel: exifData?.cameraModel,
      rawExif: exifData?.rawExif ?? {},
    );
  }

  @override
  Future<bool> isExiftoolAvailable() => _exiftool.isAvailable;

  @override
  Future<bool> isFfprobeAvailable() => _ffprobe.isAvailable;
}
