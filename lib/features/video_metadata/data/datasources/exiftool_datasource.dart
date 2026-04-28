import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
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

    // -fast2: skip MakerNotes + QuickTime trailer scan (big speedup on large videos, dates still intact).
    // -json: structured output.
    // -c "%+.6f": format GPS as signed decimal (parseable as double).
    // Request only the tags we use instead of dumping everything (faster + smaller output).
    // Do NOT pass -n: it converts QuickTime dates to raw epoch numbers, breaking date parsing.
    final args = [
      '-fast2',
      '-json',
      '-c', '%+.6f',
      '-CreateDate',
      '-MediaCreateDate',
      '-DateTimeOriginal',
      '-TrackCreateDate',
      '-GPSLatitude',
      '-GPSLongitude',
      '-Model',
      filePath,
    ];
    appLogger.i('exiftool command: $_executable ${args.join(' ')}');
    final result = await _runner.run(_executable, args);
    if (!result.isSuccess) {
      appLogger.w('exiftool failed for $filePath: ${result.stderr}');
      return null;
    }

    appLogger.d('exiftool raw output for $filePath:\n${result.stdout}');

    try {
      final list = jsonDecode(result.stdout) as List;
      if (list.isEmpty) return null;
      final data = list.first as Map<String, dynamic>;

      final metadata = VideoMetadata(
        creationDate: _parseDate(
          data['CreateDate'] ?? data['MediaCreateDate'] ?? data['TrackCreateDate'] ?? data['DateTimeOriginal'],
        ),
        gpsLatitude: _parseDouble(data['GPSLatitude']),
        gpsLongitude: _parseDouble(data['GPSLongitude']),
        cameraModel: data['Model'] as String?,
        rawExif: data.map((k, v) => MapEntry(k, v.toString())),
      );

      appLogger.i(
        'exiftool parsed: creationDate=${metadata.creationDate}, '
        'gps=(${metadata.gpsLatitude}, ${metadata.gpsLongitude}), '
        'camera=${metadata.cameraModel}, '
        'rawKeys=${metadata.rawExif.length}',
      );

      return metadata;
    } catch (e) {
      appLogger.e('exiftool parse error: $e');
      return null;
    }
  }

  // exiftool QuickTime dates look like "2025:11:06 07:35:25", sometimes with
  // a trailing timezone offset ("+07:00") or "Z". Try each known pattern in order.
  static final _dateFormats = [
    DateFormat("yyyy:MM:dd HH:mm:ssZZZZZ"),
    DateFormat("yyyy:MM:dd HH:mm:ss'Z'"),
    DateFormat("yyyy:MM:dd HH:mm:ss"),
  ];

  DateTime? _parseDate(dynamic value) {
    appLogger.d('exiftool parse date input: $value (type=${value.runtimeType})');
    if (value == null || value is! String) return null;

    for (final fmt in _dateFormats) {
      try {
        return fmt.parse(value);
      } catch (_) {
        // try next format
      }
    }
    appLogger.w('exiftool _parseDate: no DateFormat matched "$value"');
    return null;
  }

  Future<bool> copyMetadata({
    required String sourcePath,
    required String targetPath,
    VideoMetadata? metadata,
  }) async {
    if (!await isAvailable) {
      appLogger.w('exiftool not available, skip copyMetadata');
      return false;
    }

    final now = DateTime.now();

    final dateFormatter = DateFormat("yyyy:MM:dd HH:mm:ssZZZZZ");

    final nowStr = dateFormatter.format(now);
    final creationDateStr = metadata?.creationDate != null ? dateFormatter.format(metadata!.creationDate!) : null;

    final args = [
      '-TagsFromFile',
      sourcePath,
      '-all:all',
      '-MediaModifyDate=$nowStr',
      '-TrackModifyDate=$nowStr',
      '-ModifyDate=$nowStr',
      if (creationDateStr != null) '-MediaCreateDate=$creationDateStr',
      if (creationDateStr != null) '-TrackCreateDate=$creationDateStr',
      if (creationDateStr != null) '-QuickTime:CreateDate=$creationDateStr',
      if (metadata?.cameraModel != null) '-Model=${metadata!.cameraModel}',
      '-overwrite_original',
      targetPath,
    ];

    appLogger.i('exiftool copyMetadata: $_executable ${args.join(' ')}');
    try {
      final result = await _runner.run(
        _executable,
        args,
        timeout: const Duration(minutes: 2),
      );
      if (!result.isSuccess) {
        appLogger.w('exiftool copyMetadata failed: ${result.stderr}');
        return false;
      }
      appLogger.i('exiftool copyMetadata success for $targetPath');
      return true;
    } catch (e) {
      appLogger.e('exiftool copyMetadata error: $e');
      return false;
    }
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
