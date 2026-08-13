import 'package:flutter_test/flutter_test.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';

void main() {
  test('defaults timestamp subtitle to disabled for old settings JSON', () {
    final settings = EncodeSettings.fromJson(const {
      'codec': 'h264',
      'outputExtension': 'mp4',
    });

    expect(settings.embedTimestampSubtitle, isFalse);
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
}
