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
    // Temporarily only use ffprobe — exiftool binary not bundled yet.
    final ffprobeData = await _ffprobe.extract(filePath);
    return ffprobeData ?? const VideoMetadata();
  }

  @override
  Future<bool> isExiftoolAvailable() => _exiftool.isAvailable;

  @override
  Future<bool> isFfprobeAvailable() => _ffprobe.isAvailable;
}
