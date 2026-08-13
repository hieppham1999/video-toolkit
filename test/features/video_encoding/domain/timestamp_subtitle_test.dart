import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:video_toolkit/features/video_encoding/domain/timestamp_subtitle.dart';

void main() {
  test('writes one timestamp cue per second with source timezone', () async {
    final path = await writeTimestampSubtitle(
      duration: const Duration(milliseconds: 2500),
      creationDate: DateTime.utc(2025, 1, 2, 3, 4, 5),
      sourceTimezoneOffset: '+07:00',
    );

    expect(path, isNotNull);
    final file = File(path!);
    addTearDown(() async {
      if (await file.exists()) await file.delete();
    });

    final content = await file.readAsString();
    expect(
      content,
      contains('1\n00:00:00,000 --> 00:00:01,000\n10:04:05\nJan.02 2025'),
    );
    expect(
      content,
      contains('2\n00:00:01,000 --> 00:00:02,000\n10:04:06\nJan.02 2025'),
    );
    expect(
      content,
      contains('3\n00:00:02,000 --> 00:00:02,500\n10:04:07\nJan.02 2025'),
    );
  });

  test('does not create a subtitle for an unknown duration', () async {
    final path = await writeTimestampSubtitle(duration: Duration.zero);

    expect(path, isNull);
  });
}
