import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:video_toolkit/core/cli/bundled_binary_resolver.dart';
import 'package:video_toolkit/core/cli/cli_exception.dart';
import 'package:video_toolkit/core/cli/cli_tool_runner.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_progress.dart';

@lazySingleton
class FfmpegDatasource {
  FfmpegDatasource(this._runner, this._bundledResolver);

  final CliToolRunner _runner;
  final BundledBinaryResolver _bundledResolver;

  static const _executable = 'ffmpeg';
  Process? _activeProcess;

  Future<bool> get isAvailable => _runner.isAvailable(_executable);

  /// Stops the active FFmpeg process, preferring FFmpeg's own graceful quit
  /// command so it can flush and close its output before process termination.
  Future<void> cancelActiveEncode() async {
    final process = _activeProcess;
    if (process == null) return;

    try {
      process.stdin.writeln('q');
      await process.stdin.flush();
    } catch (_) {
      // The process may already have closed stdin. Continue with termination.
    }

    try {
      await process.exitCode.timeout(const Duration(seconds: 2));
      return;
    } on TimeoutException {
      // Escalate below.
    }

    process.kill();
    try {
      await process.exitCode.timeout(const Duration(seconds: 2));
      return;
    } on TimeoutException {
      if (!Platform.isWindows) {
        process.kill(ProcessSignal.sigkill);
      }
    }
  }

  /// Runs an ffmpeg encode with real-time progress reporting.
  ///
  /// [totalDuration] is needed to calculate progress percentage.
  /// Returns a stream of [EncodeProgress] and completes when encoding finishes.
  Stream<EncodeProgress> encode({
    required String inputPath,
    required List<String> args,
    required Duration totalDuration,
  }) async* {
    // Resolve ffmpeg path
    final ffmpegPath =
        await _bundledResolver.resolve(_executable) ?? await _systemPath();

    if (ffmpegPath == null) {
      throw const ToolNotFoundException(_executable);
    }

    appLogger.d('FfmpegDatasource: $ffmpegPath ${args.join(' ')}');

    final stopwatch = Stopwatch()..start();

    final process = await Process.start(ffmpegPath, args);
    _activeProcess = process;

    try {
      // ffmpeg writes progress AND errors to stderr. Keep a rolling tail so we
      // can surface the actual error message when exit code != 0.
      final stderrTail = <String>[];
      const maxTailLines = 40;

      // Drain stdout in parallel to avoid blocking ffmpeg on a full pipe buffer.
      final stdoutDrain = process.stdout.drain<void>();

      await for (final chunk in process.stderr.transform(
        const SystemEncoding().decoder,
      )) {
        for (final line in chunk.split('\n')) {
          if (line.trim().isEmpty) continue;
          stderrTail.add(line);
          if (stderrTail.length > maxTailLines) {
            stderrTail.removeAt(0);
          }
        }
        final progress = _parseProgress(
          chunk,
          totalDuration,
          stopwatch.elapsed,
        );
        if (progress != null) {
          yield progress;
        }
      }

      await stdoutDrain;
      final exitCode = await process.exitCode;
      stopwatch.stop();

      if (exitCode != 0) {
        final tail = stderrTail.join('\n');
        appLogger.e('ffmpeg failed (exit $exitCode):\n$tail');
        throw ToolExecutionException(
          tool: _executable,
          exitCode: exitCode,
          stderr: tail.isEmpty ? 'exit code $exitCode' : tail,
        );
      }

      // Emit final 100%
      yield EncodeProgress(percent: 1.0, elapsed: stopwatch.elapsed);
    } finally {
      stopwatch.stop();
      if (identical(_activeProcess, process)) {
        _activeProcess = null;
      }
      // Cancelling an async generator stops the stderr listener before the
      // process necessarily exits. Never leave that process behind.
      if (!await _hasExited(process)) {
        await _terminate(process);
      }
    }
  }

  Future<bool> _hasExited(Process process) async {
    try {
      await process.exitCode.timeout(Duration.zero);
      return true;
    } on TimeoutException {
      return false;
    }
  }

  Future<void> _terminate(Process process) async {
    process.kill();
    try {
      await process.exitCode.timeout(const Duration(seconds: 2));
    } on TimeoutException {
      if (!Platform.isWindows) {
        process.kill(ProcessSignal.sigkill);
      }
    } catch (e) {
      appLogger.w('Unable to terminate FFmpeg process: $e');
    }
  }

  EncodeProgress? _parseProgress(
    String chunk,
    Duration totalDuration,
    Duration elapsed,
  ) {
    // ffmpeg progress lines look like:
    // frame=  120 fps= 60 ... time=00:00:05.00 ... speed=2.0x
    final timeMatch = RegExp(
      r'time=(\d+):(\d+):(\d+)\.(\d+)',
    ).firstMatch(chunk);
    if (timeMatch == null) return null;

    final hours = int.parse(timeMatch.group(1)!);
    final minutes = int.parse(timeMatch.group(2)!);
    final seconds = int.parse(timeMatch.group(3)!);
    final centiseconds = int.parse(timeMatch.group(4)!);

    final currentTime = Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: centiseconds * 10,
    );

    final totalMs = totalDuration.inMilliseconds;
    final percent = totalMs > 0
        ? (currentTime.inMilliseconds / totalMs).clamp(0.0, 1.0)
        : 0.0;

    // Parse fps
    final fpsMatch = RegExp(r'fps=\s*([\d.]+)').firstMatch(chunk);
    final fps = double.tryParse(fpsMatch?.group(1) ?? '') ?? 0;

    // Parse speed
    final speedMatch = RegExp(r'speed=\s*([\d.]+)x').firstMatch(chunk);
    final speed = double.tryParse(speedMatch?.group(1) ?? '') ?? 0;

    // Estimate remaining time
    Duration? estimatedRemaining;
    if (percent > 0.01) {
      final totalEstimated = Duration(
        milliseconds: (elapsed.inMilliseconds / percent).round(),
      );
      estimatedRemaining = totalEstimated - elapsed;
    }

    return EncodeProgress(
      percent: percent,
      elapsed: elapsed,
      estimatedRemaining: estimatedRemaining,
      fps: fps,
      speed: speed,
    );
  }

  /// Extracts a single frame from [inputPath] at [atSeconds], optionally
  /// applying [filterChain], and writes it as a PNG to [outputPath].
  ///
  /// Used by the preview pipeline so previews match the real encode output.
  Future<String> extractFrame({
    required String inputPath,
    required double atSeconds,
    required String? filterChain,
    required String outputPath,
  }) async {
    final ffmpegPath =
        await _bundledResolver.resolve(_executable) ?? await _systemPath();
    if (ffmpegPath == null) {
      throw const ToolNotFoundException(_executable);
    }

    final safeSeconds = atSeconds.isFinite && atSeconds >= 0 ? atSeconds : 0.0;

    final args = <String>[
      '-y',
      '-ss',
      safeSeconds.toStringAsFixed(3),
      '-i',
      inputPath,
      if (filterChain != null) ...['-vf', filterChain],
      '-frames:v',
      '1',
      '-q:v',
      '3',
      outputPath,
    ];

    final result = await Process.run(ffmpegPath, args);
    if (result.exitCode != 0) {
      final stderr = result.stderr?.toString() ?? '';
      appLogger.e(
        'ffmpeg extractFrame failed (exit ${result.exitCode}):\n'
        'args: ${args.join(' ')}\n'
        'stderr: ${stderr.trim()}',
      );
      throw ToolExecutionException(
        tool: _executable,
        exitCode: result.exitCode,
        stderr: stderr,
      );
    }
    return outputPath;
  }

  Future<String?> _systemPath() async {
    final whichCmd = Platform.isWindows ? 'where' : 'which';
    try {
      final result = await Process.run(whichCmd, [_executable]);
      if (result.exitCode == 0) {
        return (result.stdout as String).trim().split('\n').first;
      }
    } catch (_) {}
    return null;
  }
}
