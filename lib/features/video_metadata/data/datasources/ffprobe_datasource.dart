import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:video_toolkit/core/cli/cli_tool_runner.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_metadata/data/models/video_metadata.dart';

@lazySingleton
class FfprobeDatasource {
  FfprobeDatasource(this._runner);

  final CliToolRunner _runner;

  static const _executable = 'ffprobe';

  Future<bool> get isAvailable => _runner.isAvailable(_executable);

  Future<VideoMetadata?> extract(String filePath) async {
    if (!await isAvailable) return null;

    final result = await _runner.run(_executable, [
      '-v', 'quiet',
      '-print_format', 'json',
      '-show_format',
      '-show_streams',
      filePath,
    ], timeout: const Duration(seconds: 15));

    if (!result.isSuccess) {
      appLogger.w('ffprobe failed for $filePath: ${result.stderr}');
      return null;
    }

    try {
      final data = jsonDecode(result.stdout) as Map<String, dynamic>;
      final streams = data['streams'] as List? ?? [];
      final format = data['format'] as Map<String, dynamic>? ?? {};

      final videoStream = streams.cast<Map<String, dynamic>>().where(
        (s) => s['codec_type'] == 'video',
      ).firstOrNull;

      final audioStream = streams.cast<Map<String, dynamic>>().where(
        (s) => s['codec_type'] == 'audio',
      ).firstOrNull;

      return VideoMetadata(
        duration: _parseDuration(format['duration']),
        width: videoStream?['width'] as int?,
        height: videoStream?['height'] as int?,
        videoCodec: videoStream?['codec_name'] as String?,
        audioCodec: audioStream?['codec_name'] as String?,
        bitrate: int.tryParse(format['bit_rate']?.toString() ?? ''),
        frameRate: _parseFrameRate(videoStream?['r_frame_rate']),
      );
    } catch (e) {
      appLogger.e('ffprobe parse error: $e');
      return null;
    }
  }

  Duration? _parseDuration(dynamic value) {
    if (value == null) return null;
    final seconds = double.tryParse(value.toString());
    if (seconds == null) return null;
    return Duration(milliseconds: (seconds * 1000).round());
  }

  double? _parseFrameRate(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    // ffprobe returns frame rate as fraction e.g. "30000/1001"
    final parts = str.split('/');
    if (parts.length == 2) {
      final num = double.tryParse(parts[0]);
      final den = double.tryParse(parts[1]);
      if (num != null && den != null && den != 0) {
        return num / den;
      }
    }
    return double.tryParse(str);
  }
}
