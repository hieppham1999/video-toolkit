import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_toolkit/core/app_info.dart';
import 'package:video_toolkit/features/home/domain/queue_completion_action.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_failure.dart';

@lazySingleton
class EncodeFailureLogWriter {
  static const fileName = 'last_encode_errors.log';

  Future<String?> update({
    required DateTime startedAt,
    required DateTime finishedAt,
    required int totalFiles,
    required int completedCount,
    required List<EncodeFailure> failures,
    required QueueCompletionAction action,
  }) async {
    final directory = await getApplicationSupportDirectory();
    return updateInDirectory(
      directory: directory,
      startedAt: startedAt,
      finishedAt: finishedAt,
      totalFiles: totalFiles,
      completedCount: completedCount,
      failures: failures,
      action: action,
    );
  }

  Future<String?> updateInDirectory({
    required Directory directory,
    required DateTime startedAt,
    required DateTime finishedAt,
    required int totalFiles,
    required int completedCount,
    required List<EncodeFailure> failures,
    required QueueCompletionAction action,
  }) async {
    final target = File(p.join(directory.path, fileName));
    final temporary = File('${target.path}.tmp');

    if (failures.isEmpty) {
      if (await temporary.exists()) await temporary.delete();
      if (await target.exists()) await target.delete();
      return null;
    }

    await directory.create(recursive: true);
    try {
      await temporary.writeAsString(
        _buildReport(
          startedAt: startedAt,
          finishedAt: finishedAt,
          totalFiles: totalFiles,
          completedCount: completedCount,
          failures: failures,
          action: action,
        ),
        flush: true,
      );
      if (await target.exists()) await target.delete();
      await temporary.rename(target.path);
      return target.path;
    } catch (_) {
      if (await temporary.exists()) {
        try {
          await temporary.delete();
        } catch (_) {
          // Preserve the original write/replace error.
        }
      }
      rethrow;
    }
  }

  String _buildReport({
    required DateTime startedAt,
    required DateTime finishedAt,
    required int totalFiles,
    required int completedCount,
    required List<EncodeFailure> failures,
    required QueueCompletionAction action,
  }) {
    final buffer = StringBuffer()
      ..writeln('${AppInfo.appName} ${AppInfo.version}'.trim())
      ..writeln('Encode queue error report')
      ..writeln('Started: ${startedAt.toLocal().toIso8601String()}')
      ..writeln('Finished: ${finishedAt.toLocal().toIso8601String()}')
      ..writeln('Total files: $totalFiles')
      ..writeln('Completed: $completedCount')
      ..writeln('Failed: ${failures.length}')
      ..writeln('Post-queue action: ${action.name}')
      ..writeln();

    for (var index = 0; index < failures.length; index++) {
      final failure = failures[index];
      buffer
        ..writeln('=== Failure ${index + 1} ===')
        ..writeln('File: ${failure.filePath}')
        ..writeln(failure.message.trim())
        ..writeln();
    }
    return buffer.toString();
  }
}
