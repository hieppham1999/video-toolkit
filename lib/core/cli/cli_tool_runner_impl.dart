import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:video_toolkit/core/cli/cli_exception.dart';
import 'package:video_toolkit/core/cli/cli_result.dart';
import 'package:video_toolkit/core/cli/cli_tool_runner.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';

@LazySingleton(as: CliToolRunner)
class CliToolRunnerImpl implements CliToolRunner {
  final Map<String, String?> _pathCache = {};

  @override
  Future<CliResult> run(
    String executable,
    List<String> args, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final resolvedPath = await _resolvePath(executable);
    if (resolvedPath == null) {
      throw ToolNotFoundException(executable);
    }

    appLogger.d('CLI: $executable ${args.join(' ')}');

    try {
      final result = await Process.run(resolvedPath, args).timeout(timeout);
      final cliResult = CliResult(
        stdout: result.stdout as String,
        stderr: result.stderr as String,
        exitCode: result.exitCode,
      );

      if (!cliResult.isSuccess) {
        appLogger.w('CLI: $executable exited with ${cliResult.exitCode}');
      }

      return cliResult;
    } on TimeoutException {
      throw ToolTimeoutException(executable, timeout);
    }
  }

  @override
  Future<bool> isAvailable(String executable) async {
    final path = await _resolvePath(executable);
    return path != null;
  }

  Future<String?> _resolvePath(String executable) async {
    if (_pathCache.containsKey(executable)) {
      return _pathCache[executable];
    }

    final whichCmd = Platform.isWindows ? 'where' : 'which';
    try {
      final result = await Process.run(whichCmd, [executable]);
      if (result.exitCode == 0) {
        final path = (result.stdout as String).trim().split('\n').first;
        _pathCache[executable] = path;
        return path;
      }
    } catch (_) {}

    _pathCache[executable] = null;
    return null;
  }
}
