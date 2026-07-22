import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:video_toolkit/core/cli/cli_result.dart';
import 'package:video_toolkit/core/cli/cli_tool_runner.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/core/utils/filename_template.dart';
import 'package:video_toolkit/features/video_metadata/data/datasources/exiftool_datasource.dart';
import 'package:video_toolkit/features/video_metadata/data/datasources/ffprobe_datasource.dart';
import 'package:video_toolkit/features/video_metadata/data/repositories/video_metadata_repository_impl.dart';

void main() {
  setUpAll(() {
    GetIt.I.registerSingleton<AppLogger>(AppLogger(Logger(level: Level.off)));
  });

  tearDownAll(GetIt.I.reset);

  test('keeps ffprobe creation date when exiftool has no date', () async {
    final runner = _FakeCliToolRunner({
      'ffprobe': const CliResult(
        stdout: '''
          {
            "streams": [
              {
                "codec_type": "video",
                "tags": {"creation_time": "2026-07-22T08:09:10Z"}
              }
            ],
            "format": {}
          }
        ''',
        stderr: '',
        exitCode: 0,
      ),
      'exiftool': const CliResult(
        stdout: '[{"SourceFile":"video.mp4"}]',
        stderr: '',
        exitCode: 0,
      ),
    });
    final repository = VideoMetadataRepositoryImpl(
      ExiftoolDatasource(runner),
      FfprobeDatasource(runner),
    );

    final metadata = await repository.extractMetadata('video.mp4');

    expect(metadata.creationDate, DateTime.utc(2026, 7, 22, 8, 9, 10));
  });

  test(
    'falls back to exiftool FileCreateDate for an invalid embedded date',
    () async {
      final runner = _FakeCliToolRunner({
        'ffprobe': const CliResult(
          stdout: '{"streams": [], "format": {}}',
          stderr: '',
          exitCode: 0,
        ),
        'exiftool': const CliResult(
          stdout: '''
          [{
            "SourceFile": "video.mp4",
            "CreateDate": "0000:00:00 00:00:00",
            "FileCreateDate": "2026:07:22 08:09:10+00:00"
          }]
        ''',
          stderr: '',
          exitCode: 0,
        ),
      });
      final repository = VideoMetadataRepositoryImpl(
        ExiftoolDatasource(runner),
        FfprobeDatasource(runner),
      );

      final metadata = await repository.extractMetadata('video.mp4');

      expect(metadata.creationDate, DateTime.utc(2026, 7, 22, 8, 9, 10));
      expect(metadata.timezoneOffset, '+00:00');
      expect(
        FilenameTemplate.apply(
          '{year}{month}{day}_{hour}{minute}{second}_VID',
          originalName: 'video',
          creationDate: metadata.creationDate,
          creationDateFromFileSystem: metadata.creationDateFromFileSystem,
          sourceTimezoneOffset: metadata.timezoneOffset,
        ),
        '20260722_080910_VID_FILEDATE',
      );
    },
  );

  test('uses exiftool FileCreateDate even when ffprobe throws', () async {
    final runner = _FakeCliToolRunner({
      'ffprobe': StateError('ffprobe failed'),
      'exiftool': const CliResult(
        stdout: '''
          [{
            "SourceFile": "video.mp4",
            "FileCreateDate": "2026:07:11 08:31:24+07:00"
          }]
        ''',
        stderr: '',
        exitCode: 0,
      ),
    });
    final repository = VideoMetadataRepositoryImpl(
      ExiftoolDatasource(runner),
      FfprobeDatasource(runner),
    );

    final metadata = await repository.extractMetadata('video.mp4');

    expect(metadata.creationDate, DateTime.utc(2026, 7, 11, 1, 31, 24));
    expect(metadata.timezoneOffset, '+07:00');
    expect(
      FilenameTemplate.apply(
        '{year}{month}{day}_{hour}{minute}{second}_VID',
        originalName: 'video',
        creationDate: metadata.creationDate,
        creationDateFromFileSystem: metadata.creationDateFromFileSystem,
        sourceTimezoneOffset: metadata.timezoneOffset,
      ),
      '20260711_083124_VID_FILEDATE',
    );
  });

  test(
    'uses native Windows file creation time when both extractors throw',
    () async {
      final file = File(
        '${Directory.systemTemp.path}${Platform.pathSeparator}'
        'video-toolkit-${DateTime.now().microsecondsSinceEpoch}.mp4',
      );
      await file.create();
      final expected = (await file.stat()).changed;
      addTearDown(() async {
        if (await file.exists()) await file.delete();
      });
      final runner = _FakeCliToolRunner({
        'ffprobe': StateError('ffprobe failed'),
        'exiftool': StateError('exiftool failed'),
      });
      final repository = VideoMetadataRepositoryImpl(
        ExiftoolDatasource(runner),
        FfprobeDatasource(runner),
      );

      final metadata = await repository.extractMetadata(file.path);

      expect(
        metadata.creationDate?.millisecondsSinceEpoch,
        expected.millisecondsSinceEpoch,
      );
    },
    skip: !Platform.isWindows,
  );
}

class _FakeCliToolRunner implements CliToolRunner {
  _FakeCliToolRunner(this.results);

  final Map<String, Object> results;

  @override
  Future<bool> isAvailable(String executable) async => true;

  @override
  Future<CliResult> run(
    String executable,
    List<String> args, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final result = results[executable]!;
    if (result is Exception) throw result;
    return result as CliResult;
  }
}
