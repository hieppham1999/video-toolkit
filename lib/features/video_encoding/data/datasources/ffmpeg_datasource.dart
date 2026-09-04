import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:video_toolkit/core/cli/bundled_binary_resolver.dart';
import 'package:video_toolkit/core/cli/cli_exception.dart';
import 'package:video_toolkit/core/cli/cli_tool_runner.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_progress.dart';

import 'ffmpeg_progress_parser.dart';

@lazySingleton
class FfmpegDatasource {
  FfmpegDatasource(this._runner, this._bundledResolver);

  final CliToolRunner _runner;
  final BundledBinaryResolver _bundledResolver;

  static const _executable = 'ffmpeg';
  Process? _activeProcess;
  bool _activeCancellationRequested = false;

  Future<bool> get isAvailable => _runner.isAvailable(_executable);

  /// Stops the active FFmpeg process, preferring FFmpeg's own graceful quit
  /// command so it can flush and close its output before process termination.
  Future<void> cancelActiveEncode() async {
    final process = _activeProcess;
    if (process == null) return;
    _activeCancellationRequested = true;

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

    final commandArgs = ['-progress', 'pipe:1', '-nostats', ...args];
    appLogger.d('FfmpegDatasource: $ffmpegPath ${commandArgs.join(' ')}');

    final stopwatch = Stopwatch()..start();

    final process = await Process.start(ffmpegPath, commandArgs);
    _activeProcess = process;
    _activeCancellationRequested = false;

    try {
      final stderrTail = <String>[];
      const maxTailLines = 40;
      final stderrDrain = process.stderr
          .transform(const SystemEncoding().decoder)
          .transform(const LineSplitter())
          .forEach((line) {
            if (line.trim().isEmpty) return;
            stderrTail.add(line);
            if (stderrTail.length > maxTailLines) stderrTail.removeAt(0);
          });

      final snapshot = <String, String>{};
      await for (final line
          in process.stdout
              .transform(const SystemEncoding().decoder)
              .transform(const LineSplitter())) {
        final separator = line.indexOf('=');
        if (separator <= 0) continue;
        final key = line.substring(0, separator);
        snapshot[key] = line.substring(separator + 1);
        if (key == 'progress') {
          final progress = FfmpegProgressParser.parse(
            snapshot,
            totalDuration: totalDuration,
            elapsed: stopwatch.elapsed,
          );
          if (progress != null) yield progress;
          snapshot.clear();
        }
      }

      await stderrDrain;
      final exitCode = await process.exitCode;
      stopwatch.stop();

      if (_activeCancellationRequested) {
        throw StateError('FFmpeg encode was cancelled.');
      }

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
        _activeCancellationRequested = false;
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
