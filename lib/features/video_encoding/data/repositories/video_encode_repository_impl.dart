import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/features/video_encoding/data/datasources/ffmpeg_datasource.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_preset.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_progress.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/repositories/video_encode_repository.dart';

@LazySingleton(as: VideoEncodeRepository)
class VideoEncodeRepositoryImpl implements VideoEncodeRepository {
  VideoEncodeRepositoryImpl(this._ffmpeg);

  final FfmpegDatasource _ffmpeg;

  @override
  Future<bool> isFfmpegAvailable() => _ffmpeg.isAvailable;

  @override
  Stream<EncodeProgress> encode({
    required String inputPath,
    required EncodePreset preset,
    required Duration totalDuration,
    required EncodeSettings settings,
    String? outputDir,
  }) {
    final dir = outputDir ?? p.dirname(inputPath);
    final baseName = p.basenameWithoutExtension(inputPath);
    final outputPath = p.join(dir, '${baseName}_encoded.${preset.extension}');
    final args = preset.buildArgs(
      inputPath,
      outputPath,
      burnTimestamp: settings.burnTimestamp,
    );

    return _ffmpeg.encode(
      inputPath: inputPath,
      args: args,
      totalDuration: totalDuration,
    );
  }
}
