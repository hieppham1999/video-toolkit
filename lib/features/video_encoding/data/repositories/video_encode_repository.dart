import 'package:video_toolkit/features/video_encoding/data/models/encode_preset.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_progress.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';

abstract class VideoEncodeRepository {
  Future<bool> isFfmpegAvailable();

  Stream<EncodeProgress> encode({
    required String inputPath,
    required EncodePreset preset,
    required Duration totalDuration,
    required EncodeSettings settings,
    String? outputDir,
  });
}
