import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:video_toolkit/features/home/domain/queue_completion_action.dart';

enum SystemPlatform { windows, macos }

class SystemPowerCommand {
  const SystemPowerCommand(this.executable, this.arguments);

  final String executable;
  final List<String> arguments;
}

class SystemCommandResult {
  const SystemCommandResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final int exitCode;
  final String stdout;
  final String stderr;
}

abstract interface class SystemCommandRunner {
  Future<SystemCommandResult> run(String executable, List<String> arguments);
}

@LazySingleton(as: SystemCommandRunner)
class DartSystemCommandRunner implements SystemCommandRunner {
  @override
  Future<SystemCommandResult> run(
    String executable,
    List<String> arguments,
  ) async {
    final result = await Process.run(executable, arguments);
    return SystemCommandResult(
      exitCode: result.exitCode,
      stdout: result.stdout.toString(),
      stderr: result.stderr.toString(),
    );
  }
}

abstract interface class SystemPowerService {
  Future<void> execute(QueueCompletionAction action);
}

class SystemPowerException implements Exception {
  const SystemPowerException(this.message);

  final String message;

  @override
  String toString() => message;
}

@LazySingleton(as: SystemPowerService)
class SystemPowerServiceImpl implements SystemPowerService {
  const SystemPowerServiceImpl(this._runner);

  final SystemCommandRunner _runner;

  @override
  Future<void> execute(QueueCompletionAction action) async {
    if (action == QueueCompletionAction.none) return;

    final platform = Platform.isWindows
        ? SystemPlatform.windows
        : Platform.isMacOS
        ? SystemPlatform.macos
        : null;
    if (platform == null) {
      throw const SystemPowerException('Unsupported operating system.');
    }

    final command = commandFor(action, platform);
    final result = await _runner.run(command.executable, command.arguments);
    if (result.exitCode == 0) return;

    final detail = result.stderr.trim().isNotEmpty
        ? result.stderr.trim()
        : result.stdout.trim();
    throw SystemPowerException(
      'Power command failed with exit code ${result.exitCode}'
      '${detail.isEmpty ? '.' : ': $detail'}',
    );
  }

  static SystemPowerCommand commandFor(
    QueueCompletionAction action,
    SystemPlatform platform,
  ) {
    if (action == QueueCompletionAction.none) {
      throw const SystemPowerException(
        'No system command exists for the no-action option.',
      );
    }

    switch (platform) {
      case SystemPlatform.windows:
        return switch (action) {
          QueueCompletionAction.shutdown => const SystemPowerCommand(
            'shutdown.exe',
            ['/s', '/t', '0'],
          ),
          QueueCompletionAction.restart => const SystemPowerCommand(
            'shutdown.exe',
            ['/r', '/t', '0'],
          ),
          QueueCompletionAction.sleep =>
            const SystemPowerCommand('powershell.exe', [
              '-NoProfile',
              '-NonInteractive',
              '-Command',
              r'Add-Type -AssemblyName System.Windows.Forms; if (-not [System.Windows.Forms.Application]::SetSuspendState([System.Windows.Forms.PowerState]::Suspend, $false, $false)) { exit 1 }',
            ]),
          QueueCompletionAction.none => throw const SystemPowerException(
            'No system command exists for the no-action option.',
          ),
        };
      case SystemPlatform.macos:
        final verb = switch (action) {
          QueueCompletionAction.shutdown => 'shut down',
          QueueCompletionAction.restart => 'restart',
          QueueCompletionAction.sleep => 'sleep',
          QueueCompletionAction.none => throw const SystemPowerException(
            'No system command exists for the no-action option.',
          ),
        };
        return SystemPowerCommand('/usr/bin/osascript', [
          '-e',
          'tell application "System Events" to $verb',
        ]);
    }
  }
}
