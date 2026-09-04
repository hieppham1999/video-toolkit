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
    expect(settings.videoProfile, VideoProfile.auto);
    expect(settings.videoLevel, VideoLevel.auto);
    expect(settings.pixelFormat, PixelFormat.auto);
    expect(settings.frameRate, isNull);
    expect(settings.toneMapMode, ToneMapMode.off);
    expect(settings.audioChannels, AudioChannelMode.source);
    expect(settings.audioSampleRate, AudioSampleRate.source);
    expect(settings.normalizeAudio, isFalse);
    expect(settings.audioGainDb, 0);
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

  test(
    'builds frame rate, profile, level, pixel format, and tone map args',
    () {
      const settings = EncodeSettings(
        codec: VideoEncoder.h265,
        videoProfile: VideoProfile.main10,
        videoLevel: VideoLevel.l5_1,
        pixelFormat: PixelFormat.yuv420p10le,
        frameRate: 29.97,
        toneMapMode: ToneMapMode.hable,
      );

      final args = settings.buildArgs('input.mov', 'output.mp4');
      final filter = args[args.indexOf('-vf') + 1];

      expect(args, containsAllInOrder(['-profile:v', 'main10']));
      expect(args, containsAllInOrder(['-level:v', '5.1']));
      expect(args, containsAllInOrder(['-r', '29.97']));
      expect(args, containsAllInOrder(['-pix_fmt', 'yuv420p10le']));
      expect(filter, contains('tonemap=tonemap=hable'));
      expect(filter, endsWith('format=yuv420p'));
    },
  );

  test(
    'builds audio processing args and replaces incompatible passthrough',
    () {
      const settings = EncodeSettings(
        audioCodec: AudioCodec.passthrough,
        audioChannels: AudioChannelMode.stereo,
        audioSampleRate: AudioSampleRate.hz48000,
        normalizeAudio: true,
        audioGainDb: 2.5,
      );

      final args = settings.buildArgs('input.mov', 'output.mp4');

      expect(args, containsAllInOrder(['-c:a', 'aac', '-b:a', '128k']));
      expect(args, containsAllInOrder(['-ac', '2', '-ar', '48000']));
      expect(
        args,
        containsAllInOrder([
          '-af',
          'loudnorm=I=-16:LRA=11:TP=-1.5,volume=2.5dB',
        ]),
      );
    },
  );

  test('can remove audio from the output', () {
    const settings = EncodeSettings(audioCodec: AudioCodec.none);

    final args = settings.buildArgs('input.mov', 'output.mp4');

    expect(args, contains('-an'));
    expect(args, isNot(contains('-c:a')));
  });

  test('estimates output size only for bitrate-driven modes', () {
    const duration = Duration(minutes: 10);
    const average = EncodeSettings(
      qualityMode: QualityMode.avgBitrate,
      avgBitrateKbps: 4000,
      audioCodec: AudioCodec.aac,
      audioBitrate: AudioBitrate.k128,
    );

    expect(average.estimatedOutputSizeMb(duration), closeTo(315.9, 0.1));
    expect(
      const EncodeSettings(
        qualityMode: QualityMode.targetSize,
        targetSizeMb: 250,
      ).estimatedOutputSizeMb(duration),
      250,
    );
    expect(const EncodeSettings().estimatedOutputSizeMb(duration), isNull);
  });
}
