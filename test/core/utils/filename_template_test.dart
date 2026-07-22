import 'package:flutter_test/flutter_test.dart';
import 'package:video_toolkit/core/utils/filename_template.dart';

void main() {
  group('FilenameTemplate.apply', () {
    test(
      'falls back to original name for a date-only template without date',
      () {
        final result = FilenameTemplate.apply(
          '{year}-{month}-{day}_{hour}-{minute}-{second}',
          originalName: 'source-video',
        );

        expect(result, 'source-video_encoded');
      },
    );

    test('does not render a partial template when date is unavailable', () {
      final result = FilenameTemplate.apply(
        '{name}_{year}{month}{day}',
        originalName: 'source-video',
      );

      expect(result, 'source-video_encoded');
    });

    test('formats a date-only template when creation date is available', () {
      final result = FilenameTemplate.apply(
        '{year}{month}{day}_{hour}{minute}{second}',
        originalName: 'source-video',
        creationDate: DateTime.utc(2026, 7, 22, 8, 9, 10),
        sourceTimezoneOffset: '+00:00',
      );

      expect(result, '20260722_080910');
    });

    test('appends FILEDATE when timestamp comes from file creation time', () {
      final result = FilenameTemplate.apply(
        '{year}{month}{day}_{hour}{minute}{second}_VID',
        originalName: 'source-video',
        creationDate: DateTime.utc(2026, 7, 11, 1, 31, 24),
        creationDateFromFileSystem: true,
        sourceTimezoneOffset: '+07:00',
      );

      expect(result, '20260711_083124_VID_FILEDATE');
    });

    test('does not append FILEDATE when template has no date tags', () {
      final result = FilenameTemplate.apply(
        '{name}',
        originalName: 'source-video',
        creationDate: DateTime.utc(2026, 7, 11, 1, 31, 24),
        creationDateFromFileSystem: true,
        sourceTimezoneOffset: '+07:00',
      );

      expect(result, 'source-video');
    });
  });
}
