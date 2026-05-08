import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/core/utils/filename_template.dart';
import 'package:video_toolkit/features/fonts_loader/data/font_resolver.dart';
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
          sourceTimezoneOffset: settings.sourceTimezoneOffset,
        );
        final outputPath = p.join(dir, '$outName.${settings.outputExtension.value}');

        final resolved = await _resolveFonts(settings);
        final useTwoPass = resolved.qualityMode == QualityMode.avgBitrate &&
            resolved.twoPass;

        if (useTwoPass) {
          final logPrefix = p.join(
            Directory.systemTemp.path,
            'vt-passlog-${DateTime.now().microsecondsSinceEpoch}',
          );
          try {
            final pass1Args = resolved.buildArgs(
              inputPath,
              outputPath,
              creationDate: creationDate,
              pass: 1,
              passLogPrefix: logPrefix,
            );
            appLogger.d('2-pass: prefix=$logPrefix');
            // Pass 1 → maps into [0%, 50%]. estimatedRemaining is doubled to
            // approximate the remaining time across BOTH passes (rough — pass 2
            // is usually slower than a turbo pass 1).
            await for (final p in _ffmpeg.encode(
              inputPath: inputPath,
              args: pass1Args,
              totalDuration: totalDuration,
            )) {
              if (controller.isClosed) return;
              controller.add(p.copyWith(
                percent: (p.percent * 0.5).clamp(0.0, 0.5),
                estimatedRemaining: p.estimatedRemaining == null
                    ? null
                    : p.estimatedRemaining! * 2,
                pass: 1,
              ));
            }

            final statsFile = File('$logPrefix-0.log');
            final statsExists = await statsFile.exists();
            final statsSize = statsExists ? await statsFile.length() : 0;
            appLogger.d(
              '2-pass: after pass1 — stats file ${statsFile.path} '
              'exists=$statsExists size=$statsSize bytes',
            );
            if (!statsExists || statsSize == 0) {
              throw StateError(
                'Pass 1 finished but stats file is missing/empty at '
                '${statsFile.path}. Pass 2 cannot proceed.',
              );
            }

            final pass2Args = resolved.buildArgs(
              inputPath,
              outputPath,
              creationDate: creationDate,
              pass: 2,
              passLogPrefix: logPrefix,
            );
            appLogger.i('ffmpeg pass2 args: ${pass2Args.join(' ')}');
            // Pass 2 → maps into [50%, 100%].
            await for (final p in _ffmpeg.encode(
              inputPath: inputPath,
              args: pass2Args,
              totalDuration: totalDuration,
            )) {
              if (controller.isClosed) return;
              controller.add(p.copyWith(
                percent: (0.5 + p.percent * 0.5).clamp(0.5, 1.0),
                pass: 2,
              ));
            }
          } finally {
            await _cleanupPassLogs(logPrefix);
          }
        } else {
          final args = resolved.buildArgs(inputPath, outputPath, creationDate: creationDate);
          await controller.addStream(_ffmpeg.encode(
            inputPath: inputPath,
            args: args,
            totalDuration: totalDuration,
          ));
        }
      } catch (e, st) {
        controller.addError(e, st);
      } finally {
        await controller.close();
      }
    }();
    return controller.stream;
  }

  /// Removes the ffmpeg 2-pass stats files generated under [prefix]
  /// (`<prefix>-0.log`, `<prefix>-0.log.mbtree`, and the x265 variants).
  Future<void> _cleanupPassLogs(String prefix) async {
    const suffixes = [
      '-0.log',
      '-0.log.mbtree',
      '-0.log.cutree',
      '-0.log.temp',
    ];
    for (final s in suffixes) {
      final f = File('$prefix$s');
      if (await f.exists()) {
        try {
          await f.delete();
        } catch (_) {}
      }
    }
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
