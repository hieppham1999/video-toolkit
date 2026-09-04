import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/fonts_loader/data/font_resolver.dart';
import 'package:video_toolkit/features/video_encoding/data/datasources/ffmpeg_datasource.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_progress.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/domain/timestamp_subtitle.dart';
import 'package:video_toolkit/features/video_encoding/data/repositories/video_encode_repository.dart';
import 'package:video_toolkit/features/video_metadata/data/datasources/ffprobe_datasource.dart';

@LazySingleton(as: VideoEncodeRepository)
class VideoEncodeRepositoryImpl implements VideoEncodeRepository {
  VideoEncodeRepositoryImpl(this._ffmpeg, this._fontResolver, this._ffprobe);

  final FfmpegDatasource _ffmpeg;
  final FontResolver _fontResolver;
  final FfprobeDatasource _ffprobe;

  @override
  Future<bool> isFfmpegAvailable() => _ffmpeg.isAvailable;

  @override
  Future<void> cancelActiveEncode() => _ffmpeg.cancelActiveEncode();

  @override
  Stream<EncodeProgress> encode({
    required String inputPath,
    required String outputPath,
    required EncodeSettings settings,
    required Duration totalDuration,
    DateTime? creationDate,
  }) {
    var cancelled = false;
    late final StreamController<EncodeProgress> controller;
    controller = StreamController<EncodeProgress>(
      onCancel: () async {
        cancelled = true;
        await _ffmpeg.cancelActiveEncode();
      },
    );
    () async {
      final temporaryOutputPath = _temporaryOutputPath(outputPath);
      try {
        String? timestampSubtitlePath;
        try {
          final timestampSubtitleEnabled =
              settings.embedTimestampSubtitle &&
              settings.supportsTimestampSubtitle;
          final effectiveCreationDate =
              timestampSubtitleEnabled && creationDate == null
              ? DateTime.now()
              : creationDate;
          if (timestampSubtitleEnabled) {
            timestampSubtitlePath = await writeTimestampSubtitle(
              duration: totalDuration,
              creationDate: effectiveCreationDate,
              sourceTimezoneOffset: settings.sourceTimezoneOffset,
            );
            if (timestampSubtitlePath == null) {
              appLogger.w(
                'Timestamp subtitle skipped because the video duration is not positive',
              );
            }
          }

          final resolved = await _resolveFonts(settings);
          final videoEncoder = await _ffmpeg.resolveVideoEncoder(
            resolved.codec,
            resolved.encoderMode,
          );
          final targetVideoBitrateKbps =
              resolved.qualityMode == QualityMode.targetSize
              ? resolved.targetVideoBitrateKbps(totalDuration)
              : null;
          final useTwoPass =
              resolved.qualityMode != QualityMode.crf &&
              resolved.twoPass &&
              videoEncoder == resolved.codec.value;

          if (useTwoPass) {
            final logPrefix = p.join(
              Directory.systemTemp.path,
              'vt-passlog-${DateTime.now().microsecondsSinceEpoch}',
            );
            try {
              final pass1Args = resolved.buildArgs(
                inputPath,
                temporaryOutputPath,
                creationDate: effectiveCreationDate,
                pass: 1,
                passLogPrefix: logPrefix,
                timestampSubtitlePath: timestampSubtitlePath,
                resolvedVideoEncoder: videoEncoder,
                resolvedVideoBitrateKbps: targetVideoBitrateKbps,
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
                controller.add(
                  p.copyWith(
                    percent: (p.percent * 0.5).clamp(0.0, 0.5),
                    estimatedRemaining: p.estimatedRemaining == null
                        ? null
                        : p.estimatedRemaining! * 2,
                    pass: 1,
                  ),
                );
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
                temporaryOutputPath,
                creationDate: effectiveCreationDate,
                pass: 2,
                passLogPrefix: logPrefix,
                timestampSubtitlePath: timestampSubtitlePath,
                resolvedVideoEncoder: videoEncoder,
                resolvedVideoBitrateKbps: targetVideoBitrateKbps,
              );
              appLogger.i('ffmpeg pass2 args: ${pass2Args.join(' ')}');
              // Pass 2 → maps into [50%, 100%].
              await for (final p in _ffmpeg.encode(
                inputPath: inputPath,
                args: pass2Args,
                totalDuration: totalDuration,
              )) {
                if (controller.isClosed) return;
                controller.add(
                  p.copyWith(
                    percent: (0.5 + p.percent * 0.5).clamp(0.5, 1.0),
                    pass: 2,
                  ),
                );
              }
            } finally {
              await _cleanupPassLogs(logPrefix);
            }
          } else {
            final args = resolved.buildArgs(
              inputPath,
              temporaryOutputPath,
              creationDate: effectiveCreationDate,
              timestampSubtitlePath: timestampSubtitlePath,
              resolvedVideoEncoder: videoEncoder,
              resolvedVideoBitrateKbps: targetVideoBitrateKbps,
            );
            await controller.addStream(
              _ffmpeg.encode(
                inputPath: inputPath,
                args: args,
                totalDuration: totalDuration,
              ),
            );
          }

          if (cancelled) return;
          await _verifyOutput(temporaryOutputPath);
          await _publishOutput(
            temporaryOutputPath: temporaryOutputPath,
            outputPath: outputPath,
          );
        } finally {
          if (timestampSubtitlePath != null) {
            final subtitleFile = File(timestampSubtitlePath);
            try {
              if (await subtitleFile.exists()) await subtitleFile.delete();
            } catch (e) {
              appLogger.w('Failed to clean up timestamp subtitle: $e');
            }
          }
        }
      } catch (e, st) {
        if (!cancelled && !controller.isClosed) {
          controller.addError(e, st);
        }
      } finally {
        await _deleteIfExists(temporaryOutputPath);
        await controller.close();
      }
    }();
    return controller.stream;
  }

  String _temporaryOutputPath(String outputPath) {
    final extension = p.extension(outputPath);
    final stem = p.basenameWithoutExtension(outputPath);
    final token = DateTime.now().microsecondsSinceEpoch;
    return p.join(p.dirname(outputPath), '.$stem.$token.part$extension');
  }

  Future<void> _publishOutput({
    required String temporaryOutputPath,
    required String outputPath,
  }) async {
    final temporary = File(temporaryOutputPath);
    if (!await temporary.exists() || await temporary.length() == 0) {
      throw StateError(
        'FFmpeg completed without producing a valid output file.',
      );
    }
    if (await FileSystemEntity.type(outputPath, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw StateError('The planned output path became occupied: $outputPath');
    }
    await temporary.rename(outputPath);
  }

  Future<void> _verifyOutput(String path) async {
    final metadata = await _ffprobe.extract(path);
    if (metadata == null ||
        metadata.width == null ||
        metadata.height == null ||
        metadata.width! <= 0 ||
        metadata.height! <= 0) {
      throw StateError('The encoded output could not be verified by ffprobe.');
    }
  }

  Future<void> _deleteIfExists(String path) async {
    final file = File(path);
    try {
      if (await file.exists()) await file.delete();
    } catch (e) {
      appLogger.w('Failed to clean up temporary encode output $path: $e');
    }
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
