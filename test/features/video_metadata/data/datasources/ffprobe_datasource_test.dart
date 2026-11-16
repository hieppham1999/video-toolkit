import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:video_toolkit/core/cli/cli_result.dart';
import 'package:video_toolkit/core/cli/cli_tool_runner.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_metadata/data/datasources/ffprobe_datasource.dart';
import 'package:video_toolkit/features/video_metadata/data/datasources/exiftool_datasource.dart';
import 'package:video_toolkit/features/video_metadata/data/models/video_metadata.dart';
import 'package:video_toolkit/features/video_metadata/data/repositories/video_metadata_repository_impl.dart';

void main() {
  setUpAll(() {
    GetIt.I.registerSingleton<AppLogger>(AppLogger(Logger(level: Level.off)));
  });
  tearDownAll(GetIt.I.reset);

  test(
    'extracts every subtitle track in source order with optional tags',
    () async {
      final runner = _Runner([
        {'index': 0, 'codec_type': 'video', 'width': 640, 'height': 360},
        {'index': 1, 'codec_type': 'audio'},
        {
          'index': 2,
          'codec_type': 'subtitle',
          'codec_name': 'subrip',
          'tags': {'title': 'English', 'language': 'eng'},
          'disposition': {'default': 1, 'forced': 0},
        },
        {
          'index': 3,
          'codec_type': 'subtitle',
          'codec_name': 'mov_text',
          'tags': {'handler_name': 'Vietnamese', 'language': 'vie'},
          'disposition': {'default': 0, 'forced': 1},
        },
        {'index': 4, 'codec_type': 'subtitle'},
      ]);
      final metadata = await VideoMetadataRepositoryImpl(
        ExiftoolDatasource(runner),
        FfprobeDatasource(runner),
      ).extractMetadata('input.mkv');
      expect(metadata.width, 640);
      expect(metadata.subtitleTracks, const [
        SubtitleTrack(
          index: 2,
          codec: 'subrip',
          title: 'English',
          language: 'eng',
          isDefault: true,
        ),
        SubtitleTrack(
          index: 3,
          codec: 'mov_text',
          title: 'Vietnamese',
          language: 'vie',
          isForced: true,
        ),
        SubtitleTrack(index: 4),
      ]);
    },
  );

  test(
    'successful probe distinguishes no tracks from unavailable metadata',
    () async {
      final metadata = await FfprobeDatasource(
        _Runner([]),
      ).extract('input.mp4');
      expect(metadata!.subtitleTracks, isEmpty);
      expect(const VideoMetadata().subtitleTracks, isNull);
    },
  );

  test('failed probe keeps subtitle information unavailable', () async {
    final runner = _Runner([], exitCode: 1);
    final metadata = await VideoMetadataRepositoryImpl(
      ExiftoolDatasource(runner),
      FfprobeDatasource(runner),
    ).extractMetadata('missing.mp4');
    expect(metadata.subtitleTracks, isNull);
  });
}

class _Runner implements CliToolRunner {
  _Runner(this.streams, {this.exitCode = 0});
  final List<Map<String, Object>> streams;
  final int exitCode;

  @override
  Future<bool> isAvailable(String executable) async => true;

  @override
  Future<CliResult> run(
    String executable,
    List<String> args, {
    Duration timeout = const Duration(seconds: 30),
  }) async => CliResult(
    stdout: executable == 'exiftool'
        ? '[{}]'
        : jsonEncode({'streams': streams}),
    stderr: '',
    exitCode: exitCode,
  );
}
