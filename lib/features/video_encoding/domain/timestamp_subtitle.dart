import 'dart:io';

import 'package:path/path.dart' as p;

/// Shared timestamp formatting used by the burn-in overlay and subtitle track.
Duration? parseTimestampOffset(String? offset) {
  if (offset == null) return null;
  final match = RegExp(r'^([+-])(\d{2}):(\d{2})$').firstMatch(offset);
  if (match == null) return null;
  final sign = match.group(1) == '-' ? -1 : 1;
  final hours = int.parse(match.group(2)!);
  final minutes = int.parse(match.group(3)!);
  return Duration(hours: sign * hours, minutes: sign * minutes);
}

/// Converts an absolute recording date into the wall-clock date displayed to
/// the user. An explicit source offset takes precedence over the local zone.
DateTime timestampWallClock(
  DateTime creationDate, {
  String? sourceTimezoneOffset,
}) {
  final offset = parseTimestampOffset(sourceTimezoneOffset);
  return offset == null
      ? creationDate.toLocal()
      : creationDate.toUtc().add(offset);
}

String formatLocalTimestampOffset(Duration offset) {
  final sign = offset.isNegative ? '-' : '+';
  final abs = offset.abs();
  final hours = abs.inHours.toString().padLeft(2, '0');
  final minutes = (abs.inMinutes % 60).toString().padLeft(2, '0');
  return '$sign$hours:$minutes';
}

String formatTimestampTime(DateTime value) {
  final hours = value.hour.toString().padLeft(2, '0');
  final minutes = value.minute.toString().padLeft(2, '0');
  final seconds = value.second.toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

String formatTimestampDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[value.month - 1]}.${value.day.toString().padLeft(2, '0')} ${value.year}';
}

String formatTimestampSubtitleText(DateTime value) =>
    '${formatTimestampTime(value)}\n${formatTimestampDate(value)}';

String _formatSrtTime(Duration value) {
  final milliseconds = value.inMilliseconds.clamp(0, 359999999).toInt();
  final hours = milliseconds ~/ Duration.millisecondsPerHour;
  final minutes =
      (milliseconds % Duration.millisecondsPerHour) ~/
      Duration.millisecondsPerMinute;
  final seconds =
      (milliseconds % Duration.millisecondsPerMinute) ~/
      Duration.millisecondsPerSecond;
  final millis = milliseconds % Duration.millisecondsPerSecond;
  return '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')},'
      '${millis.toString().padLeft(3, '0')}';
}

/// Writes a temporary SRT track containing one timestamp cue per second.
///
/// Returns the path to the temporary file, or null when [duration] is not
/// positive. The caller owns cleanup of the returned file.
Future<String?> writeTimestampSubtitle({
  required Duration duration,
  DateTime? creationDate,
  String? sourceTimezoneOffset,
}) async {
  if (duration <= Duration.zero) return null;

  final baseDate = timestampWallClock(
    creationDate ?? DateTime.now(),
    sourceTimezoneOffset: sourceTimezoneOffset,
  );
  final filePath = p.join(
    Directory.systemTemp.path,
    'video-toolkit-timestamp-${DateTime.now().microsecondsSinceEpoch}.srt',
  );
  final file = File(filePath);
  final durationMs = duration.inMilliseconds;
  final cueCount = (durationMs + 999) ~/ 1000;
  final output = StringBuffer();

  for (var index = 0; index < cueCount; index++) {
    final start = Duration(milliseconds: index * 1000);
    final endMs = ((index + 1) * 1000).clamp(0, durationMs).toInt();
    final end = Duration(milliseconds: endMs);
    if (end <= start) continue;

    final cueDate = baseDate.add(start);
    output
      ..writeln(index + 1)
      ..writeln('${_formatSrtTime(start)} --> ${_formatSrtTime(end)}')
      ..writeln(formatTimestampSubtitleText(cueDate))
      ..writeln();
  }

  try {
    await file.writeAsString(output.toString(), flush: true);
    return filePath;
  } catch (_) {
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
    rethrow;
  }
}
