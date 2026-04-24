import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:video_toolkit/core/cli/bundled_binary_resolver.dart';
import 'package:video_toolkit/core/cli/cli_exception.dart';
import 'package:video_toolkit/core/cli/cli_result.dart';
import 'package:video_toolkit/core/cli/cli_tool_runner.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';

@LazySingleton(as: CliToolRunner)
class CliToolRunnerImpl implements CliToolRunner {
  CliToolRunnerImpl(this._bundledResolver);

  final BundledBinaryResolver _bundledResolver;
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

    appLogger.d('CLI: $resolvedPath ${args.join(' ')}');

    try {
      final result = await Process.run(resolvedPath, args).timeout(timeout);
      final cliResult = CliResult(
        stdout: result.stdout as String,
        stderr: result.stderr as String,
        exitCode: result.exitCode,
      );

      if (!cliResult.isSuccess) {
        appLogger.w(
          'CLI: $executable exited with ${cliResult.exitCode}\n'
          'args: ${args.join(' ')}\n'
          'stderr: ${cliResult.stderr.trim()}\n'
          'stdout: ${cliResult.stdout.trim()}',
        );
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

    // 1. Check bundled binary first
    final bundledPath = await _bundledResolver.resolve(executable);
    if (bundledPath != null) {
      _pathCache[executable] = bundledPath;
      return bundledPath;
    }

    // 2. Fall back to system PATH
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
