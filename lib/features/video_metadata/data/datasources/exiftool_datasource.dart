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
      // Keys:CreationDate is the only QuickTime tag that preserves the source
      // timezone offset literally — read it first so we can round-trip the
      // exact offset on encode.
      '-Keys:CreationDate',
      '-CreateDate',
      '-MediaCreateDate',
      '-DateTimeOriginal',
      '-TrackCreateDate',
      // Filesystem date fallbacks for containers without embedded creation
      // dates (e.g. AVCHD .MTS from Sony cameras). FileCreateDate typically
      // matches the recording start; FileModifyDate matches recording end.
      '-FileCreateDate',
      '-FileModifyDate',
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

      final rawDate = data['CreateDate'] ??
          data['MediaCreateDate'] ??
          data['TrackCreateDate'] ??
          data['DateTimeOriginal'] ??
          data['FileCreateDate'] ??
          data['FileModifyDate'];

      // Prefer Keys:CreationDate for offset detection — Apple devices store
      // the source TZ literally there, while QuickTime atoms strip it.
      final offsetSource = data['CreationDate'] as String? ?? rawDate;

      final metadata = VideoMetadata(
        creationDate: _parseDate(rawDate),
        timezoneOffset: _extractTimezoneOffset(offsetSource),
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

  static final _tzOffsetRegex = RegExp(r'(Z|[+-]\d{2}:?\d{2})$');

  // Dart intl's DateFormat does not reliably emit the ZZZZZ offset token, so
  // we build "+HH:MM" / "-HH:MM" ourselves from a Duration.
  String _formatOffset(Duration offset) {
    final sign = offset.isNegative ? '-' : '+';
    final abs = offset.abs();
    final h = abs.inHours.toString().padLeft(2, '0');
    final m = (abs.inMinutes % 60).toString().padLeft(2, '0');
    return '$sign$h:$m';
  }

  String? _extractTimezoneOffset(dynamic value) {
    if (value is! String) return null;
    final match = _tzOffsetRegex.firstMatch(value.trim());
    if (match == null) return null;
    final raw = match.group(1)!;
    if (raw == 'Z') return '+00:00';
    // Normalize "+0700" → "+07:00"
    if (raw.length == 5 && !raw.contains(':')) {
      return '${raw.substring(0, 3)}:${raw.substring(3)}';
    }
    return raw;
  }

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

    final dateFormatterNoTz = DateFormat("yyyy:MM:dd HH:mm:ss");

    // CreateDate fields use the source's original offset when known; otherwise
    // fall back to the encode machine's local offset (DateFormat.parse for an
    // offset-less source returns a UTC DateTime whose timeZoneOffset is 0, so
    // we cannot trust creationDate.timeZoneOffset).
    final localOffset = _formatOffset(now.timeZoneOffset);
    final sourceOffset = metadata?.timezoneOffset ?? localOffset;
    final nowStr = '${dateFormatterNoTz.format(now)}$localOffset';
    String? creationDateStr;
    if (metadata?.creationDate != null) {
      creationDateStr = '${dateFormatterNoTz.format(metadata!.creationDate!)}$sourceOffset';
    }
    // Keys:CreationDate stores in ISO 8601 (the format Apple writes natively).
    // Using "T" separator + offset gives exiftool the unambiguous form so the
    // offset is preserved verbatim instead of being normalized to +00:00.
    String? keysCreationDateStr;
    if (metadata?.creationDate != null) {
      final iso = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(metadata!.creationDate!);
      keysCreationDateStr = '$iso$sourceOffset';
    }

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
      // Keys:CreationDate (com.apple.quicktime.creationdate) is the one MP4
      // atom that preserves the timezone offset literally — Photos.app and
      // Finder read this for "Content created" display.
      if (keysCreationDateStr != null) '-Keys:CreationDate=$keysCreationDateStr',
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
