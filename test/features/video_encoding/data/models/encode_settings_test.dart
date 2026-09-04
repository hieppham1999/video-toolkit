import 'package:flutter_test/flutter_test.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';

void main() {
  test(
    'does not overwrite final outputs but allows the two-pass null sink',
    () {
      const settings = EncodeSettings();

      final normal = settings.buildArgs('input.mp4', 'output.mp4');
      final passOne = settings.buildArgs('input.mp4', 'output.mp4', pass: 1);

      expect(normal, contains('-n'));
      expect(normal, isNot(contains('-y')));
      expect(passOne, contains('-y'));
      expect(passOne, isNot(contains('-n')));
    },
  );

  test('defaults timestamp subtitle to disabled for old settings JSON', () {
    final settings = EncodeSettings.fromJson(const {
      'codec': 'h264',
      'outputExtension': 'mp4',
    });

    expect(settings.embedTimestampSubtitle, isFalse);
    expect(settings.encoderMode, EncoderMode.software);
    expect(settings.targetSizeMb, 100);
    expect(settings.preserveAllAudioTracks, isTrue);
    expect(settings.preserveSourceSubtitles, isFalse);
  });

  test('derives target-size bitrate and forwards the resolved value', () {
    const settings = EncodeSettings(
      qualityMode: QualityMode.targetSize,
      targetSizeMb: 100,
      audioCodec: AudioCodec.aac,
      audioBitrate: AudioBitrate.k128,
    );

    final bitrate = settings.targetVideoBitrateKbps(
      const Duration(minutes: 10),
    );
    final args = settings.buildArgs(
      'input.mp4',
      'output.mp4',
      resolvedVideoBitrateKbps: bitrate,
    );

    expect(bitrate, 1178);
    expect(args, containsAllInOrder(['-b:v', '1178k']));
    expect(args, isNot(contains('-crf')));
  });

  test('builds codec-specific AV1, VP9, and ProRes arguments', () {
    final av1 = const EncodeSettings(
      codec: VideoEncoder.av1,
      preset: EncodePreset.fast,
      outputExtension: OutputExtension.webm,
      audioCodec: AudioCodec.opus,
    ).buildArgs('input.mp4', 'output.webm');
    final vp9 = const EncodeSettings(
      codec: VideoEncoder.vp9,
    ).buildArgs('input.mp4', 'output.mkv');
    final prores = const EncodeSettings(
      codec: VideoEncoder.prores,
    ).buildArgs('input.mp4', 'output.mov');

    expect(av1, containsAllInOrder(['-c:v', 'libsvtav1', '-preset', '8']));
    expect(av1, containsAllInOrder(['-c:a', 'libopus']));
    expect(vp9, containsAllInOrder(['-deadline', 'good', '-cpu-used', '8']));
    expect(
      prores,
      containsAllInOrder(['-c:v', 'prores_ks', '-profile:v', '3']),
    );
    expect(prores, isNot(contains('-crf')));
    expect(prores, isNot(contains('-b:v')));
  });

  test('hardware encoder uses bitrate and omits software-only parameters', () {
    const settings = EncodeSettings(
      codec: VideoEncoder.h264,
      encoderMode: EncoderMode.hardware,
      extraParams: 'keyint=60',
    );

    final args = settings.buildArgs(
      'input.mp4',
      'output.mp4',
      resolvedVideoEncoder: 'h264_videotoolbox',
    );

    expect(args, containsAllInOrder(['-c:v', 'h264_videotoolbox']));
    expect(args, containsAllInOrder(['-b:v', '4000k']));
    expect(args, isNot(contains('-crf')));
    expect(args, isNot(contains('-preset')));
    expect(args, isNot(contains('-x264-params')));
  });

  test('builds MP4 subtitle arguments with timestamp track title', () {
    const settings = EncodeSettings(
      outputExtension: OutputExtension.mp4,
      embedTimestampSubtitle: true,
    );

    final args = settings.buildArgs(
      'input.mp4',
      'output.mp4',
      timestampSubtitlePath: 'timestamp.srt',
    );

    expect(
      args,
      containsAllInOrder([
        '-i',
        'input.mp4',
        '-i',
        'timestamp.srt',
        '-map',
        '0:v:0',
        '-map',
        '0:a?',
        '-map',
        '1:0',
        '-c:s',
        'mov_text',
        '-metadata:s:s:0',
        'title=timestamp',
      ]),
    );
  });

  test('uses subrip for MKV and omits subtitle in pass one', () {
    const settings = EncodeSettings(
      outputExtension: OutputExtension.mkv,
      embedTimestampSubtitle: true,
    );

    final passOne = settings.buildArgs(
      'input.mkv',
      'output.mkv',
      pass: 1,
      timestampSubtitlePath: 'timestamp.srt',
    );
    final passTwo = settings.buildArgs(
      'input.mkv',
      'output.mkv',
      pass: 2,
      timestampSubtitlePath: 'timestamp.srt',
    );

    expect(
      passOne,
      containsAllInOrder(['-i', 'timestamp.srt', '-map', '0:v:0']),
    );
    expect(passOne, isNot(contains('1:0')));
    expect(passOne, isNot(contains('-c:s')));
    expect(passTwo, containsAllInOrder(['-map', '1:0', '-c:s', 'subrip']));
  });

  test('does not add subtitle input for unsupported containers', () {
    const settings = EncodeSettings(
      outputExtension: OutputExtension.avi,
      embedTimestampSubtitle: true,
    );

    final args = settings.buildArgs(
      'input.avi',
      'output.avi',
      timestampSubtitlePath: 'timestamp.srt',
    );

    expect(args, isNot(contains('timestamp.srt')));
    expect(settings.supportsTimestampSubtitle, isFalse);
  });

  test('maps all audio, source subtitles, metadata, and chapters', () {
    const settings = EncodeSettings(
      outputExtension: OutputExtension.mkv,
      preserveSourceSubtitles: true,
      copySourceMetadata: true,
    );

    final args = settings.buildArgs('input.mkv', 'output.mkv');

    expect(
      args,
      containsAllInOrder(['-map', '0:v:0', '-map', '0:a?', '-map', '0:s?']),
    );
    expect(args, containsAllInOrder(['-c:s', 'copy']));
    expect(args, containsAllInOrder(['-map_metadata', '0']));
    expect(args, containsAllInOrder(['-map_chapters', '0']));
  });

  test('can limit audio mapping to the first source track', () {
    const settings = EncodeSettings(preserveAllAudioTracks: false);

    final args = settings.buildArgs('input.mp4', 'output.mp4');

    expect(args, containsAllInOrder(['-map', '0:a:0?']));
    expect(args, isNot(contains('0:a?')));
  });
}
