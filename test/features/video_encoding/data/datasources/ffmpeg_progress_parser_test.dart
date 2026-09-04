import 'package:flutter_test/flutter_test.dart';
import 'package:video_toolkit/features/video_encoding/data/datasources/ffmpeg_progress_parser.dart';

void main() {
  test('parses a machine-readable FFmpeg progress snapshot', () {
    final progress = FfmpegProgressParser.parse(
      const {
        'out_time_us': '2500000',
        'fps': '59.94',
        'speed': '2.5x',
        'progress': 'continue',
      },
      totalDuration: const Duration(seconds: 10),
      elapsed: const Duration(seconds: 1),
    );

    expect(progress, isNotNull);
    expect(progress!.percent, 0.25);
    expect(progress.fps, 59.94);
    expect(progress.speed, 2.5);
    expect(progress.estimatedRemaining, const Duration(seconds: 3));
  });

  test('falls back to out_time and tolerates N/A speed', () {
    final progress = FfmpegProgressParser.parse(
      const {'out_time': '01:02:03.500000', 'speed': 'N/A'},
      totalDuration: const Duration(hours: 2),
      elapsed: const Duration(minutes: 1),
    );

    expect(progress, isNotNull);
    expect(progress!.percent, closeTo(3723.5 / 7200, 0.000001));
    expect(progress.speed, 0);
  });
}
