import 'package:video_toolkit/features/video_metadata/data/models/video_metadata.dart';

abstract class VideoMetadataRepository {
  Future<VideoMetadata> extractMetadata(String filePath);

  Future<bool> isExiftoolAvailable();

  Future<bool> isFfprobeAvailable();
}
