import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/utils/filename_template.dart';
import 'package:video_toolkit/features/video_encoding/data/datasources/ffmpeg_datasource.dart';
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
    required EncodeSettings settings,
    required Duration totalDuration,
    String? outputDir,
    DateTime? creationDate,
  }) {
    final dir = outputDir ?? p.dirname(inputPath);
    final baseName = p.basenameWithoutExtension(inputPath);
    final outName = FilenameTemplate.apply(
      settings.outputNameTemplate,
      originalName: baseName,
      creationDate: creationDate,
    );
    final outputPath = p.join(dir, '$outName.${settings.outputExtension.value}');
    final args = settings.buildArgs(inputPath, outputPath, creationDate: creationDate);

    return _ffmpeg.encode(
      inputPath: inputPath,
      args: args,
      totalDuration: totalDuration,
    );
  }
}
