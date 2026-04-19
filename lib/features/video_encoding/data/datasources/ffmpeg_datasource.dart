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

  Future<bool> get isAvailable => _runner.isAvailable(_executable);

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
    final ffmpegPath = await _bundledResolver.resolve(_executable) ??
        await _systemPath();

    if (ffmpegPath == null) {
      throw const ToolNotFoundException(_executable);
    }

    appLogger.i('FfmpegDatasource: encoding $inputPath');
    appLogger.d('FfmpegDatasource: $ffmpegPath ${args.join(' ')}');

    final stopwatch = Stopwatch()..start();

    final Process process;
    if (Platform.isWindows) {
      // On Windows, Process.start doesn't quote args that lack spaces, causing
      // issues with special chars (`,`, `%`) in complex -vf filter strings.
      // Use cmd.exe /c with explicit quoting: wrap -vf value in "..." and
      // escape % as %% so cmd.exe doesn't expand environment variables.
      final cmdParts = ['"$ffmpegPath"'];
      for (var i = 0; i < args.length; i++) {
        if (args[i] == '-vf' && i + 1 < args.length) {
          cmdParts.add(args[i]);
          final filterValue = args[i + 1].replaceAll('%', '%%');
          cmdParts.add('"$filterValue"');
          i++;
        } else if (args[i].contains(' ')) {
          cmdParts.add('"${args[i]}"');
        } else {
          cmdParts.add(args[i]);
        }
      }
      final cmdLine = cmdParts.join(' ');
      appLogger.d('FfmpegDatasource (Windows cmd): $cmdLine');
      process = await Process.start('cmd', ['/c', cmdLine]);
    } else {
      process = await Process.start(ffmpegPath, args);
    }

    // ffmpeg writes progress to stderr
    await for (final chunk in process.stderr.transform(const SystemEncoding().decoder)) {
      final progress = _parseProgress(chunk, totalDuration, stopwatch.elapsed);
      if (progress != null) {
        yield progress;
      }
    }

    final exitCode = await process.exitCode;
    stopwatch.stop();

    if (exitCode != 0) {
      throw ToolExecutionException(
        tool: _executable,
        exitCode: exitCode,
        stderr: 'Encoding failed with exit code $exitCode',
      );
    }

    // Emit final 100%
    yield EncodeProgress(
      percent: 1.0,
      elapsed: stopwatch.elapsed,
    );
  }

  EncodeProgress? _parseProgress(
    String chunk,
    Duration totalDuration,
    Duration elapsed,
  ) {
    // ffmpeg progress lines look like:
    // frame=  120 fps= 60 ... time=00:00:05.00 ... speed=2.0x
    final timeMatch = RegExp(r'time=(\d+):(\d+):(\d+)\.(\d+)').firstMatch(chunk);
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
