import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/utils/filename_template.dart';
import 'package:video_toolkit/features/fonts/data/font_resolver.dart';
import 'package:video_toolkit/features/video_encoding/data/datasources/ffmpeg_datasource.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_progress.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/repositories/video_encode_repository.dart';

@LazySingleton(as: VideoEncodeRepository)
class VideoEncodeRepositoryImpl implements VideoEncodeRepository {
  VideoEncodeRepositoryImpl(this._ffmpeg, this._fontResolver);

  final FfmpegDatasource _ffmpeg;
  final FontResolver _fontResolver;

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
    final controller = StreamController<EncodeProgress>();
    () async {
      try {
        final dir = outputDir ?? p.dirname(inputPath);
        final baseName = p.basenameWithoutExtension(inputPath);
        final outName = FilenameTemplate.apply(
          settings.outputNameTemplate,
          originalName: baseName,
          creationDate: creationDate,
        );
        final outputPath = p.join(dir, '$outName.${settings.outputExtension.value}');

        final resolved = await _resolveFonts(settings);
        final args = resolved.buildArgs(inputPath, outputPath, creationDate: creationDate);

        await controller.addStream(_ffmpeg.encode(
          inputPath: inputPath,
          args: args,
          totalDuration: totalDuration,
        ));
      } catch (e, st) {
        controller.addError(e, st);
      } finally {
        await controller.close();
      }
    }();
    return controller.stream;
  }

  /// Replaces each overlay's `fontFile` with the resolver's effective path so
  /// ffmpeg always receives a valid `fontfile=` (overlay → user default →
  /// bundled VCR fallback).
  Future<EncodeSettings> _resolveFonts(EncodeSettings settings) async {
    if (settings.textOverlays.isEmpty) return settings;
    final resolvedOverlays = <TextOverlay>[];
    for (final overlay in settings.textOverlays) {
      final path = await _fontResolver.resolve(overlay.fontFile);
      resolvedOverlays.add(overlay.copyWith(fontFile: path));
    }
    return settings.copyWith(textOverlays: resolvedOverlays);
  }
}
