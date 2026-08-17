import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/features/home/domain/queue_completion_action.dart';
import 'package:video_toolkit/features/video_encoding/data/datasources/encode_failure_log_writer.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_failure.dart';

void main() {
  late Directory temporaryDirectory;
  late EncodeFailureLogWriter writer;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'video_toolkit_failure_log_test_',
    );
    writer = EncodeFailureLogWriter();
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('writes every failure to the single fixed log file', () async {
    final path = await writer.updateInDirectory(
      directory: temporaryDirectory,
      startedAt: DateTime(2026, 8, 17, 10),
      finishedAt: DateTime(2026, 8, 17, 11),
      totalFiles: 3,
      completedCount: 1,
      failures: const [
        EncodeFailure(filePath: r'C:\videos\a.mp4', message: 'first error'),
        EncodeFailure(filePath: r'C:\videos\b.mp4', message: 'second error'),
      ],
      action: QueueCompletionAction.shutdown,
    );

    expect(path, p.join(temporaryDirectory.path, 'last_encode_errors.log'));
    final report = await File(path!).readAsString();
    expect(report, contains(r'C:\videos\a.mp4'));
    expect(report, contains('first error'));
    expect(report, contains(r'C:\videos\b.mp4'));
    expect(report, contains('second error'));
    expect(report, contains('Post-queue action: shutdown'));
    expect(
      temporaryDirectory.listSync().whereType<File>().where(
        (file) => file.path.endsWith('.log'),
      ),
      hasLength(1),
    );
  });

  test('a newer failed queue replaces the previous report', () async {
    final oldLog = File(
      p.join(temporaryDirectory.path, EncodeFailureLogWriter.fileName),
    );
    await oldLog.writeAsString('old failure');

    await writer.updateInDirectory(
      directory: temporaryDirectory,
      startedAt: DateTime(2026, 8, 17, 12),
      finishedAt: DateTime(2026, 8, 17, 13),
      totalFiles: 1,
      completedCount: 0,
      failures: const [
        EncodeFailure(filePath: '/videos/new.mp4', message: 'new failure'),
      ],
      action: QueueCompletionAction.restart,
    );

    final report = await oldLog.readAsString();
    expect(report, isNot(contains('old failure')));
    expect(report, contains('new failure'));
  });

  test('a successful queue removes the previous error log', () async {
    final oldLog = File(
      p.join(temporaryDirectory.path, EncodeFailureLogWriter.fileName),
    );
    await oldLog.writeAsString('old failure');

    final result = await writer.updateInDirectory(
      directory: temporaryDirectory,
      startedAt: DateTime(2026, 8, 17, 12),
      finishedAt: DateTime(2026, 8, 17, 13),
      totalFiles: 1,
      completedCount: 1,
      failures: const [],
      action: QueueCompletionAction.none,
    );

    expect(result, isNull);
    expect(await oldLog.exists(), isFalse);
  });

  test(
    'surfaces an I/O failure instead of silently losing the report',
    () async {
      final blockingFile = File(
        p.join(temporaryDirectory.path, 'not_a_directory'),
      );
      await blockingFile.writeAsString('blocked');

      await expectLater(
        writer.updateInDirectory(
          directory: Directory(blockingFile.path),
          startedAt: DateTime(2026, 8, 17, 12),
          finishedAt: DateTime(2026, 8, 17, 13),
          totalFiles: 1,
          completedCount: 0,
          failures: const [
            EncodeFailure(filePath: '/videos/a.mp4', message: 'encode failed'),
          ],
          action: QueueCompletionAction.shutdown,
        ),
        throwsA(isA<FileSystemException>()),
      );
    },
  );
}
