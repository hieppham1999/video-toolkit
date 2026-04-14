import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:video_toolkit/core/cli/cli_tool_runner.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_metadata/data/models/video_metadata.dart';

@lazySingleton
class ExiftoolDatasource {
  ExiftoolDatasource(this._runner);

  final CliToolRunner _runner;

  static const _executable = 'exiftool';

  Future<bool> get isAvailable => _runner.isAvailable(_executable);

  Future<VideoMetadata?> extract(String filePath) async {
    if (!await isAvailable) return null;

    final result = await _runner.run(_executable, ['-json', '-n', filePath]);
    if (!result.isSuccess) {
      appLogger.w('exiftool failed for $filePath: ${result.stderr}');
      return null;
    }

    try {
      final list = jsonDecode(result.stdout) as List;
      if (list.isEmpty) return null;
      final data = list.first as Map<String, dynamic>;

      return VideoMetadata(
        creationDate: _parseDate(data['CreateDate'] ?? data['DateTimeOriginal']),
        gpsLatitude: _parseDouble(data['GPSLatitude']),
        gpsLongitude: _parseDouble(data['GPSLongitude']),
        cameraModel: data['Model'] as String?,
        rawExif: data.map((k, v) => MapEntry(k, v.toString())),
      );
    } catch (e) {
      appLogger.e('exiftool parse error: $e');
      return null;
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      // exiftool format: "2024:01:15 10:30:00"
      final normalized = value.replaceFirst(RegExp(r'^(\d{4}):(\d{2}):'), r'$1-$2-');
      return DateTime.tryParse(normalized);
    }
    return null;
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
