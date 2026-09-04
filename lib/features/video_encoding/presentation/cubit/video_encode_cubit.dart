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
  Completer<bool>? _activeCompleter;
  bool _cancelled = false;
  bool _skipRequested = false;
  int _lastLoggedBucket = -1;

  List<VideoFile> _queue = [];
  late EncodeSettings _globalSettings;
  OutputDirectorySettings _outputDirectory = const OutputDirectorySettings();
  Map<String, String> _outputPaths = const {};
  Map<String, double> _workUnits = const {};
  double _completedWorkUnits = 0;
  double _totalWorkUnits = 0;
  final Stopwatch _batchStopwatch = Stopwatch();

  /// Start encoding all [files] sequentially.
  /// Each file uses its own [overrideSettings] if set, otherwise [globalSettings].
  Future<void> startBatchEncode({
    required List<VideoFile> files,
    required EncodeSettings globalSettings,
    OutputDirectorySettings outputDirectory = const OutputDirectorySettings(),
  }) async {
    if (files.isEmpty) return;
    await _encodeSub?.cancel();
    await _repository.cancelActiveEncode();

    _queue = List.of(files);
    _globalSettings = globalSettings;
    _outputDirectory = outputDirectory;
    _outputPaths = _planOutputPaths(files);
    _workUnits = _planWorkUnits(files);
    _completedWorkUnits = 0;
    _totalWorkUnits = _workUnits.values.fold(0, (sum, value) => sum + value);
    _batchStopwatch
      ..reset()
      ..start();
    _cancelled = false;

    emitNormal(
      currentData.copyWith(
        status: EncodeStatus.encoding,
        totalFiles: files.length,
        currentIndex: 0,
        completedCount: 0,
        overallProgress: 0,
        estimatedBatchRemaining: null,
        failures: [],
        completedPaths: [],
        skippedPaths: [],
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
    if (_cancelled) return;
    if (_skipRequested) {
      _completedWorkUnits += _workUnits[file.path] ?? 0;
      await _advanceSkipped(file, index);
      return;
    }

    emitNormal(
      currentData.copyWith(
        currentFilePath: file.path,
        outputPath: outputPath,
        progress: const EncodeProgress(),
      ),
    );

    final completer = Completer<bool>();
    _activeCompleter = completer;
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
            final bucket = (progress.percent * 10).floor();
            if (bucket > _lastLoggedBucket) {
              _lastLoggedBucket = bucket;
              appLogger.i(
                'Encode ${p.basename(file.path)}: ${(progress.percent * 100).toStringAsFixed(0)}% '
                'fps=${progress.fps.toStringAsFixed(1)} '
                'speed=${progress.speed.toStringAsFixed(2)}x '
                'eta=${progress.estimatedRemaining ?? "-"}',
              );
            }
            final overallProgress = _overallProgress(
              currentFile: file,
              currentFileProgress: progress.percent,
            );
            emitNormal(
              currentData.copyWith(
                progress: progress,
                overallProgress: overallProgress,
                estimatedBatchRemaining: _estimateBatchRemaining(
                  overallProgress,
                ),
              ),
            );
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
    if (identical(_activeCompleter, completer)) {
      _activeCompleter = null;
    }

    if (_cancelled) return;

    _completedWorkUnits += _workUnits[file.path] ?? 0;

    if (_skipRequested) {
      await _advanceSkipped(file, index);
      return;
    }

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
        overallProgress: _totalWorkUnits > 0
            ? (_completedWorkUnits / _totalWorkUnits).clamp(0, 1)
            : 1,
        completedCount: success
            ? currentData.completedCount + 1
            : currentData.completedCount,
        completedPaths: success
            ? [...currentData.completedPaths, file.path]
            : currentData.completedPaths,
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
    _batchStopwatch.stop();
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
        overallProgress: _cancelled ? currentData.overallProgress : 1,
        estimatedBatchRemaining: null,
      ),
    );
  }

  Future<void> stop() async {
    if (currentData.status != EncodeStatus.encoding) return;
    _cancelled = true;
    final completer = _activeCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(false);
    }
    await _repository.cancelActiveEncode();
    await _encodeSub?.cancel();
    _finish();
  }

  Future<void> skipCurrent() async {
    if (currentData.status != EncodeStatus.encoding) return;
    _skipRequested = true;
    final subscription = _encodeSub;
    final completer = _activeCompleter;
    await _repository.cancelActiveEncode();
    await subscription?.cancel();
    if (completer != null && !completer.isCompleted) {
      completer.complete(false);
    }
  }

  Future<void> _advanceSkipped(VideoFile file, int index) async {
    _skipRequested = false;
    emitNormal(
      currentData.copyWith(
        currentIndex: index + 1,
        skippedPaths: [...currentData.skippedPaths, file.path],
        overallProgress: _completedOverallProgress,
      ),
    );
    await _encodeNext();
  }

  void reset() {
    _encodeSub?.cancel();
    _cancelled = false;
    _skipRequested = false;
    _queue = [];
    _outputPaths = const {};
    _workUnits = const {};
    _completedWorkUnits = 0;
    _totalWorkUnits = 0;
    _batchStopwatch.reset();
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

  Map<String, double> _planWorkUnits(List<VideoFile> files) {
    final knownDurations = files
        .map((file) => file.metadata?.duration?.inMilliseconds ?? 0)
        .where((duration) => duration > 0)
        .toList();
    final fallbackDuration = knownDurations.isEmpty
        ? const Duration(minutes: 1).inMilliseconds
        : knownDurations.reduce((a, b) => a + b) / knownDurations.length;
    return {
      for (final file in files)
        file.path:
            ((file.metadata?.duration?.inMilliseconds ?? 0) > 0
                ? file.metadata!.duration!.inMilliseconds
                : fallbackDuration) *
            (_usesTwoPass(_effectiveSettingsFor(file)) ? 2 : 1),
    };
  }

  bool _usesTwoPass(EncodeSettings settings) =>
      settings.qualityMode == QualityMode.avgBitrate && settings.twoPass;

  double _overallProgress({
    required VideoFile currentFile,
    required double currentFileProgress,
  }) {
    if (_totalWorkUnits <= 0) return 0;
    final currentWork = _workUnits[currentFile.path] ?? 0;
    return ((_completedWorkUnits + currentWork * currentFileProgress) /
            _totalWorkUnits)
        .clamp(0, 1);
  }

  double get _completedOverallProgress => _totalWorkUnits > 0
      ? (_completedWorkUnits / _totalWorkUnits).clamp(0, 1)
      : 1;

  Duration? _estimateBatchRemaining(double progress) {
    if (progress <= 0.01 || !_batchStopwatch.isRunning) return null;
    final elapsedUs = _batchStopwatch.elapsedMicroseconds;
    final remainingUs = (elapsedUs / progress - elapsedUs).round();
    if (remainingUs <= 0) return null;
    return Duration(microseconds: remainingUs);
  }

  @override
  Future<void> close() async {
    _cancelled = true;
    final completer = _activeCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(false);
    }
    await _repository.cancelActiveEncode();
    await _encodeSub?.cancel();
    await super.close();
  }
}
