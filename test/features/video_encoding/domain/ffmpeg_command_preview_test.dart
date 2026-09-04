import 'package:flutter_test/flutter_test.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/domain/ffmpeg_command_preview.dart';

void main() {
  test(
    'quotes paths and resolves target-size bitrate when duration is known',
    () {
      const settings = EncodeSettings(
        qualityMode: QualityMode.targetSize,
        targetSizeMb: 100,
        audioCodec: AudioCodec.aac,
        audioBitrate: AudioBitrate.k128,
      );

      final command = buildFfmpegCommandPreview(
        settings: settings,
        inputPath: '/videos/My Clip.mp4',
        outputPath: '/output/My Clip_encoded.mp4',
        duration: const Duration(minutes: 10),
      );

      expect(command, startsWith('ffmpeg '));
      expect(command, contains('1178k'));
      expect(command, contains('My Clip.mp4'));
    },
  );

  test('shows a calculated bitrate placeholder when duration is unknown', () {
    const settings = EncodeSettings(qualityMode: QualityMode.targetSize);

    final command = buildFfmpegCommandPreview(
      settings: settings,
      inputPath: 'input.mp4',
      outputPath: 'output.mp4',
    );

    expect(command, contains('<calculated>k'));
  });
}
