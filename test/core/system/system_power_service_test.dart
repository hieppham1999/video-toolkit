import 'package:flutter_test/flutter_test.dart';
import 'package:video_toolkit/core/system/system_power_service.dart';
import 'package:video_toolkit/features/home/domain/queue_completion_action.dart';

void main() {
  group('SystemPowerServiceImpl.commandFor', () {
    test('maps Windows shutdown and restart without force', () {
      final shutdown = SystemPowerServiceImpl.commandFor(
        QueueCompletionAction.shutdown,
        SystemPlatform.windows,
      );
      final restart = SystemPowerServiceImpl.commandFor(
        QueueCompletionAction.restart,
        SystemPlatform.windows,
      );

      expect(shutdown.executable, 'shutdown.exe');
      expect(shutdown.arguments, ['/s', '/t', '0']);
      expect(restart.arguments, ['/r', '/t', '0']);
      expect(shutdown.arguments, isNot(contains('/f')));
      expect(restart.arguments, isNot(contains('/f')));
    });

    test('maps Windows sleep to SetSuspendState', () {
      final command = SystemPowerServiceImpl.commandFor(
        QueueCompletionAction.sleep,
        SystemPlatform.windows,
      );

      expect(command.executable, 'powershell.exe');
      expect(command.arguments.join(' '), contains('SetSuspendState'));
      expect(command.arguments.join(' '), contains('::Suspend'));
    });

    test('maps macOS actions to tokenized AppleScript arguments', () {
      for (final entry in {
        QueueCompletionAction.shutdown: 'shut down',
        QueueCompletionAction.restart: 'restart',
        QueueCompletionAction.sleep: 'sleep',
      }.entries) {
        final command = SystemPowerServiceImpl.commandFor(
          entry.key,
          SystemPlatform.macos,
        );
        expect(command.executable, '/usr/bin/osascript');
        expect(command.arguments, [
          '-e',
          'tell application "System Events" to ${entry.value}',
        ]);
      }
    });
  });

  group('SystemPowerServiceImpl', () {
    test('does not invoke the runner for none', () async {
      final runner = _FakeRunner(
        const SystemCommandResult(exitCode: 0, stdout: '', stderr: ''),
      );
      final service = SystemPowerServiceImpl(runner);

      await service.execute(QueueCompletionAction.none);

      expect(runner.callCount, 0);
    });

    test('throws useful detail for a failing command', () async {
      final runner = _FakeRunner(
        const SystemCommandResult(
          exitCode: 5,
          stdout: '',
          stderr: 'Access denied',
        ),
      );
      final service = SystemPowerServiceImpl(runner);

      await expectLater(
        service.execute(QueueCompletionAction.shutdown),
        throwsA(
          isA<SystemPowerException>().having(
            (e) => e.message,
            'message',
            contains('Access denied'),
          ),
        ),
      );
    });
  });
}

class _FakeRunner implements SystemCommandRunner {
  _FakeRunner(this.result);

  final SystemCommandResult result;
  int callCount = 0;

  @override
  Future<SystemCommandResult> run(
    String executable,
    List<String> arguments,
  ) async {
    callCount++;
    return result;
  }
}
