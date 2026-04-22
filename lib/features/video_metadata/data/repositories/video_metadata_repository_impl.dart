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
    final ffprobeData = await _ffprobe.extract(filePath) ?? const VideoMetadata();

    if (ffprobeData.creationDate != null) return ffprobeData;

    final exiftoolData = await _exiftool.extract(filePath);
    if (exiftoolData?.creationDate == null) return ffprobeData;

    return ffprobeData.copyWith(
      creationDate: exiftoolData!.creationDate,
      gpsLatitude: ffprobeData.gpsLatitude ?? exiftoolData.gpsLatitude,
      gpsLongitude: ffprobeData.gpsLongitude ?? exiftoolData.gpsLongitude,
      cameraModel: ffprobeData.cameraModel ?? exiftoolData.cameraModel,
    );
  }

  @override
  Future<bool> isExiftoolAvailable() => _exiftool.isAvailable;

  @override
  Future<bool> isFfprobeAvailable() => _ffprobe.isAvailable;
}
