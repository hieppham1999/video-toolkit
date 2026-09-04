import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_failure.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_progress.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/output_directory_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/repositories/video_encode_repository.dart';
import 'package:video_toolkit/features/video_encoding/domain/output_path_resolver.dart';
import 'package:video_toolkit/features/home/data/models/video_file.dart';
import 'package:video_toolkit/features/home/presentation/cubit/preview_cubit.dart';
import 'package:video_toolkit/features/video_metadata/data/datasources/exiftool_datasource.dart';
import 'package:video_toolkit/app/base/base_cubit.dart';

import 'video_encode_state.dart';

@lazySingleton
class VideoEncodeCubit extends BaseCubit<VideoEncodeState> {
  VideoEncodeCubit(this._repository, this._previewCubit, this._exiftool)
    : super.normal(const VideoEncodeState());

  final VideoEncodeRepository _repository;
  final PreviewCubit _previewCubit;
  final ExiftoolDatasource _exiftool;
  StreamSubscription<void>? _encodeSub;
  bool _cancelled = false;
  int _lastLoggedBucket = -1;

  List<VideoFile> _queue = [];
  late EncodeSettings _globalSettings;
  OutputDirectorySettings _outputDirectory = const OutputDirectorySettings();
  Map<String, String> _outputPaths = const {};

  /// Start encoding all [files] sequentially.
  /// Each file uses its own [overrideSettings] if set, otherwise [globalSettings].
  Future<void> startBatchEncode({
    required List<VideoFile> files,
    required EncodeSettings globalSettings,
    OutputDirectorySettings outputDirectory = const OutputDirectorySettings(),
  }) async {
    if (files.isEmpty) return;
    await _encodeSub?.cancel();

    _queue = List.of(files);
    _globalSettings = globalSettings;
    _outputDirectory = outputDirectory;
    _outputPaths = _planOutputPaths(files);
    _cancelled = false;

    emitNormal(
      currentData.copyWith(
        status: EncodeStatus.encoding,
        totalFiles: files.length,
        currentIndex: 0,
        completedCount: 0,
        failures: [],
        errorMessage: null,
        outputPaths: _outputPaths,
      ),
    );

    _previewCubit.startLiveMode();

    await _encodeNext();
  }

  Future<void> _encodeNext() async {
    final index = currentData.currentIndex;
    if (_cancelled || index >= _queue.length) {
      _finish();
      return;
    }

    _lastLoggedBucket = -1;
    final file = _queue[index];
    final settings = _effectiveSettingsFor(file);
    final outputPath = _outputPaths[file.path]!;
    final dir = p.dirname(outputPath);

    try {
      await Directory(dir).create(recursive: true);
    } catch (e) {
      appLogger.w('Failed to create output dir $dir: $e');
    }

    emitNormal(
      currentData.copyWith(
        currentFilePath: file.path,
        outputPath: outputPath,
        progress: const EncodeProgress(),
      ),
    );

    final completer = Completer<bool>();
    String? errorDetail;

    _encodeSub = _repository
        .encode(
          inputPath: file.path,
          outputPath: outputPath,
          settings: settings,
          totalDuration: file.metadata?.duration ?? Duration.zero,
          creationDate: file.metadata?.creationDate,
        )
        .listen(
          (progress) {
            final bucket = (progress.percent / 10).floor();
            if (bucket > _lastLoggedBucket) {
              _lastLoggedBucket = bucket;
              appLogger.i(
                'Encode ${p.basename(file.path)}: ${progress.percent.toStringAsFixed(0)}% '
                'fps=${progress.fps.toStringAsFixed(1)} '
                'speed=${progress.speed.toStringAsFixed(2)}x '
                'eta=${progress.estimatedRemaining ?? "-"}',
              );
            }
            emitNormal(currentData.copyWith(progress: progress));
            _previewCubit.updateLiveContext(
              file: file,
              settings: settings,
              percent: progress.percent,
            );
          },
          onError: (Object e) {
            errorDetail = e.toString();
            appLogger.e('Encode error for ${file.name}: $e');
            completer.complete(false);
          },
          onDone: () {
            if (!completer.isCompleted) completer.complete(true);
          },
        );

    final success = await completer.future;

    if (_cancelled) return;

    if (success && settings.copySourceMetadata) {
      // User-chosen source timezone overrides whatever was extracted from the
      // source file. Falls back to extracted value (or machine local TZ at
      // exiftool-write time) when no override is set.
      final effectiveMetadata = settings.sourceTimezoneOffset != null
          ? file.metadata?.copyWith(
              timezoneOffset: settings.sourceTimezoneOffset,
            )
          : file.metadata;
      await _exiftool.copyMetadata(
        sourcePath: file.path,
        targetPath: outputPath,
        metadata: effectiveMetadata,
      );
    }

    emitNormal(
      currentData.copyWith(
        currentIndex: index + 1,
        completedCount: success
            ? currentData.completedCount + 1
            : currentData.completedCount,
        failures: success
            ? currentData.failures
            : [
                ...currentData.failures,
                EncodeFailure(
                  filePath: file.path,
                  message: errorDetail ?? 'Unknown error',
                ),
              ],
      ),
    );

    await _encodeNext();
  }

  void _finish() {
    _previewCubit.stopLiveMode();
    final failed = currentData.failures;
    emitNormal(
      currentData.copyWith(
        status: _cancelled
            ? EncodeStatus.idle
            : failed.isEmpty
            ? EncodeStatus.done
            : EncodeStatus.error,
        errorMessage: failed.isNotEmpty
            ? '${failed.length} file(s) failed: ${failed.map((f) => p.basename(f.filePath)).join(', ')}'
            : null,
        currentFilePath: null,
      ),
    );
  }

  void stop() {
    _cancelled = true;
    _encodeSub?.cancel();
    _finish();
  }

  void reset() {
    _encodeSub?.cancel();
    _cancelled = false;
    _queue = [];
    _outputPaths = const {};
    emitNormal(const VideoEncodeState());
  }

  EncodeSettings _effectiveSettingsFor(VideoFile file) {
    final rawSettings = file.overrideSettings ?? _globalSettings;
    // When user keeps TZ on "Auto", fall back to the source's auto-detected
    // offset so filename / overlay timestamps reflect the recording's local
    // wall-clock instead of the encode machine's TZ.
    return rawSettings.sourceTimezoneOffset == null
        ? rawSettings.copyWith(
            sourceTimezoneOffset: file.metadata?.timezoneOffset,
          )
        : rawSettings;
  }

  Map<String, String> _planOutputPaths(List<VideoFile> files) {
    final reservedPaths = <String>{};
    final result = <String, String>{};
    for (final file in files) {
      final desiredPath = OutputPathResolver.resolvePath(
        inputPath: file.path,
        encodeSettings: _effectiveSettingsFor(file),
        directorySettings: file.outputDirectoryOverride ?? _outputDirectory,
        creationDate: file.metadata?.creationDate,
        creationDateFromFileSystem:
            file.metadata?.creationDateFromFileSystem ?? false,
        detectedTimezoneOffset: file.metadata?.timezoneOffset,
      );
      result[file.path] = OutputPathResolver.reserveAvailablePath(
        desiredPath,
        reservedPaths: reservedPaths,
      );
    }
    return result;
  }

  @override
  Future<void> close() {
    _encodeSub?.cancel();
    return super.close();
  }
}
