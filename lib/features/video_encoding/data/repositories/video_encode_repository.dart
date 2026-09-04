import 'package:video_toolkit/features/video_encoding/data/models/encode_progress.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';

abstract class VideoEncodeRepository {
  Future<bool> isFfmpegAvailable();

  /// Gracefully stops the FFmpeg process currently owned by this repository.
  ///
  /// Implementations should escalate to a forced termination if FFmpeg does
  /// not exit after being asked to stop, so cancelling a Dart subscription
  /// never leaves an encoder running in the background.
  Future<void> cancelActiveEncode();

  Stream<EncodeProgress> encode({
    required String inputPath,
    required String outputPath,
    required EncodeSettings settings,
    required Duration totalDuration,
    DateTime? creationDate,
  });
}
