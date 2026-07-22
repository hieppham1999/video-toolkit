import 'package:video_toolkit/features/video_encoding/data/models/encode_progress.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';

abstract class VideoEncodeRepository {
  Future<bool> isFfmpegAvailable();

  Stream<EncodeProgress> encode({
    required String inputPath,
    required EncodeSettings settings,
    required Duration totalDuration,
    String? outputDir,
    DateTime? creationDate,
    bool creationDateFromFileSystem = false,
  });
}
