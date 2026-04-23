import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_encoding/data/datasources/ffmpeg_datasource.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_import/data/models/video_file.dart';
import 'package:video_toolkit/presentation/base/base_cubit.dart';

import 'preview_state.dart';

/// Latest context the live preview loop should target.
class _LiveContext {
  _LiveContext(this.file, this.settings, this.percent);
  final VideoFile file;
  final EncodeSettings settings;
  final double percent;
}

@lazySingleton
class PreviewCubit extends BaseCubit<PreviewState> {
  PreviewCubit(this._ffmpeg) : super.normal(const PreviewState());

  final FfmpegDatasource _ffmpeg;

  static const _debounce = Duration(milliseconds: 300);
  static const _liveInterval = Duration(seconds: 2);

  Timer? _debounceTimer;
  Timer? _liveTimer;
  bool _extracting = false;
  int _jobSeq = 0;
  _LiveContext? _liveCtx;
  Directory? _tempDir;

  VideoFile? _lastStaticFile;
  EncodeSettings? _lastStaticSettings;
  int _fileCounter = 0;

  Future<Directory> _ensureTempDir() async {
    if (_tempDir != null) return _tempDir!;
    final root = await getTemporaryDirectory();
    final dir = Directory(p.join(root.path, 'video_toolkit_preview'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _tempDir = dir;
    return dir;
  }

  /// Schedule a static-frame extraction for [file] with [settings]. Debounced
  /// to avoid thrashing when the user is sliding sliders. No-op when the
  /// inputs match the last request (so unrelated rebuilds don't re-run ffmpeg).
  ///
  /// Callers should pass the effective settings for [file] — i.e.
  /// `file.overrideSettings ?? globalSettings` — so per-file overrides show
  /// up in the preview.
  void requestStaticFrame(VideoFile? file, EncodeSettings settings) {
    final unchanged = file?.path == _lastStaticFile?.path &&
        settings == _lastStaticSettings;
    _lastStaticFile = file;
    _lastStaticSettings = settings;
    if (currentData.isLive) return; // live mode owns the image
    if (unchanged) return;
    _debounceTimer?.cancel();
    if (file == null) {
      emitNormal(currentData.copyWith(
        framePath: null,
        errorMessage: null,
        isLoading: false,
      ));
      return;
    }
    _debounceTimer = Timer(_debounce, () => _runStatic(file, settings));
  }

  Future<void> _runStatic(VideoFile file, EncodeSettings settings) async {
    if (_extracting) {
      // Retry shortly after the in-flight job completes.
      _debounceTimer = Timer(_debounce, () => _runStatic(file, settings));
      return;
    }
    final jobId = ++_jobSeq;
    _extracting = true;
    emitNormal(currentData.copyWith(isLoading: true, errorMessage: null));

    final durationSec = file.metadata?.duration?.inMilliseconds != null
        ? file.metadata!.duration!.inMilliseconds / 1000.0
        : 0.0;
    final atSec = durationSec > 0 ? durationSec / 2 : 0.0;
    final filterChain =
        settings.buildVideoFilterChain(creationDate: file.metadata?.creationDate);

    try {
      final dir = await _ensureTempDir();
      // Fresh filename per extraction: Flutter's ImageCache keys by path, so
      // reusing the same path would return the stale decoded bitmap.
      final out = p.join(dir.path, 'preview_static_${++_fileCounter}.png');
      await _ffmpeg.extractFrame(
        inputPath: file.path,
        atSeconds: atSec,
        filterChain: filterChain,
        outputPath: out,
      );
      if (jobId != _jobSeq || currentData.isLive) {
        _tryDelete(out);
        return;
      }
      final previous = currentData.framePath;
      emitNormal(currentData.copyWith(
        framePath: out,
        frameRevision: currentData.frameRevision + 1,
        isLoading: false,
        errorMessage: null,
      ));
      if (previous != null && previous != out) _tryDelete(previous);
    } catch (e) {
      appLogger.w('PreviewCubit: static extract failed: $e');
      if (jobId != _jobSeq || currentData.isLive) return;
      emitNormal(currentData.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    } finally {
      _extracting = false;
    }
  }

  /// Enter live mode: periodic frames keyed to encode progress.
  void startLiveMode() {
    _debounceTimer?.cancel();
    _liveTimer?.cancel();
    emitNormal(currentData.copyWith(
      isLive: true,
      errorMessage: null,
    ));
    _liveTimer = Timer.periodic(_liveInterval, (_) => _liveTick());
  }

  /// Called by the encode cubit on each progress update.
  void updateLiveContext({
    required VideoFile file,
    required EncodeSettings settings,
    required double percent,
  }) {
    _liveCtx = _LiveContext(file, settings, percent);
    // Kick off an immediate tick if nothing rendered yet.
    if (currentData.isLive && currentData.framePath == null && !_extracting) {
      _liveTick();
    }
  }

  void stopLiveMode() {
    _liveTimer?.cancel();
    _liveTimer = null;
    _liveCtx = null;
    emitNormal(currentData.copyWith(isLive: false));
    if (_lastStaticFile != null && _lastStaticSettings != null) {
      requestStaticFrame(_lastStaticFile, _lastStaticSettings!);
    }
  }

  Future<void> _liveTick() async {
    if (!currentData.isLive) return;
    final ctx = _liveCtx;
    if (ctx == null) return;
    if (_extracting) return;

    final jobId = ++_jobSeq;
    _extracting = true;

    final durationSec = ctx.file.metadata?.duration?.inMilliseconds != null
        ? ctx.file.metadata!.duration!.inMilliseconds / 1000.0
        : 0.0;
    final pct = ctx.percent.clamp(0.0, 0.99);
    final atSec = durationSec > 0 ? durationSec * pct : 0.0;
    final filterChain = ctx.settings
        .buildVideoFilterChain(creationDate: ctx.file.metadata?.creationDate);

    try {
      final dir = await _ensureTempDir();
      final out = p.join(dir.path, 'preview_live_${++_fileCounter}.png');
      await _ffmpeg.extractFrame(
        inputPath: ctx.file.path,
        atSeconds: atSec,
        filterChain: filterChain,
        outputPath: out,
      );
      if (jobId != _jobSeq || !currentData.isLive) {
        _tryDelete(out);
        return;
      }
      final previous = currentData.framePath;
      emitNormal(currentData.copyWith(
        framePath: out,
        frameRevision: currentData.frameRevision + 1,
        errorMessage: null,
      ));
      if (previous != null && previous != out) _tryDelete(previous);
    } catch (e) {
      appLogger.w('PreviewCubit: live extract failed: $e');
    } finally {
      _extracting = false;
    }
  }

  void _tryDelete(String path) {
    try {
      final f = File(path);
      if (f.existsSync()) f.deleteSync();
    } catch (_) {
      // best-effort cleanup
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _liveTimer?.cancel();
    return super.close();
  }
}
