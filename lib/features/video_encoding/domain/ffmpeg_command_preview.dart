import 'dart:io';

import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';

/// Builds a copyable FFmpeg command without starting an encode.
String buildFfmpegCommandPreview({
  required EncodeSettings settings,
  required String inputPath,
  required String outputPath,
  Duration? duration,
  DateTime? creationDate,
}) {
  final hasDuration = duration != null && duration > Duration.zero;
  final targetBitrate =
      settings.qualityMode == QualityMode.targetSize && hasDuration
      ? settings.targetVideoBitrateKbps(duration)
      : null;
  final args = settings.buildArgs(
    inputPath,
    outputPath,
    creationDate: creationDate,
    timestampSubtitlePath: settings.embedTimestampSubtitle
        ? 'timestamp.srt'
        : null,
    resolvedVideoBitrateKbps: targetBitrate,
  );
  if (settings.qualityMode == QualityMode.targetSize && !hasDuration) {
    final bitrateFlag = args.indexOf('-b:v');
    if (bitrateFlag >= 0 && bitrateFlag + 1 < args.length) {
      args[bitrateFlag + 1] = '<calculated>k';
    }
  }
  return ['ffmpeg', ...args].map(_quoteArgument).join(' ');
}

String _quoteArgument(String value) {
  if (RegExp(r'^[A-Za-z0-9_./:=+,-]+$').hasMatch(value)) return value;
  if (Platform.isWindows) {
    return '"${value.replaceAll('"', r'\"')}"';
  }
  return "'${value.replaceAll("'", "'\"'\"'")}'";
}
