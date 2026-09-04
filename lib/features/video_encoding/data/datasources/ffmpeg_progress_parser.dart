import 'package:video_toolkit/features/video_encoding/data/models/encode_progress.dart';

/// Parses one machine-readable snapshot emitted by `ffmpeg -progress`.
class FfmpegProgressParser {
  const FfmpegProgressParser._();

  static EncodeProgress? parse(
    Map<String, String> values, {
    required Duration totalDuration,
    required Duration elapsed,
  }) {
    final currentTime = _parseOutputTime(values);
    if (currentTime == null) return null;

    final totalUs = totalDuration.inMicroseconds;
    final percent = totalUs > 0
        ? (currentTime.inMicroseconds / totalUs).clamp(0.0, 1.0)
        : 0.0;
    final fps = double.tryParse(values['fps'] ?? '') ?? 0;
    final speedText = values['speed']?.replaceFirst(RegExp(r'x$'), '') ?? '';
    final speed = double.tryParse(speedText) ?? 0;

    Duration? estimatedRemaining;
    if (percent > 0.01) {
      final totalEstimatedUs = (elapsed.inMicroseconds / percent).round();
      estimatedRemaining = Duration(
        microseconds: totalEstimatedUs - elapsed.inMicroseconds,
      );
    }

    return EncodeProgress(
      percent: percent,
      elapsed: elapsed,
      estimatedRemaining: estimatedRemaining,
      fps: fps,
      speed: speed,
    );
  }

  static Duration? _parseOutputTime(Map<String, String> values) {
    // Despite its historical name, FFmpeg's out_time_ms is expressed in
    // microseconds. Newer versions also expose the clearer out_time_us key.
    final microseconds = int.tryParse(
      values['out_time_us'] ?? values['out_time_ms'] ?? '',
    );
    if (microseconds != null) return Duration(microseconds: microseconds);

    final text = values['out_time'];
    if (text == null) return null;
    final match = RegExp(r'^(\d+):(\d+):(\d+)(?:\.(\d+))?$').firstMatch(text);
    if (match == null) return null;
    final fraction = (match.group(4) ?? '').padRight(6, '0');
    return Duration(
      hours: int.parse(match.group(1)!),
      minutes: int.parse(match.group(2)!),
      seconds: int.parse(match.group(3)!),
      microseconds: int.parse(fraction.substring(0, 6)),
    );
  }
}
