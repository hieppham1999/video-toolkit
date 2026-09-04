import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/cli/bundled_binary_resolver.dart';
import 'package:video_toolkit/core/cli/cli_result.dart';
import 'package:video_toolkit/core/cli/cli_tool_runner.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/home/data/models/video_file.dart';
import 'package:video_toolkit/features/home/presentation/cubit/preview_cubit.dart';
import 'package:video_toolkit/features/video_encoding/data/datasources/ffmpeg_datasource.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_progress.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/output_directory_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/repositories/video_encode_repository.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_cubit.dart';
import 'package:video_toolkit/features/video_metadata/data/datasources/exiftool_datasource.dart';

void main() {
  setUpAll(() {
    GetIt.I.registerSingleton<AppLogger>(AppLogger(Logger(level: Level.off)));
  });

  tearDownAll(GetIt.I.reset);

  test(
    'uses per-file output override and snapshots unique output paths',
    () async {
      final temp = Directory.systemTemp.createTempSync('video-toolkit-encode-');
      addTearDown(() => temp.deleteSync(recursive: true));
      final globalOutput = Directory(p.join(temp.path, 'global'))..createSync();
      final overrideOutput = Directory(p.join(temp.path, 'override'))
        ..createSync();
      File(p.join(globalOutput.path, 'same.mp4')).writeAsStringSync('existing');
      final repository = _FakeVideoEncodeRepository();
      final runner = _FakeCliToolRunner();
      final preview = PreviewCubit(
        FfmpegDatasource(runner, BundledBinaryResolver()),
      );
      final cubit = VideoEncodeCubit(
        repository,
        preview,
        ExiftoolDatasource(runner),
      );
      addTearDown(cubit.close);
      addTearDown(preview.close);
      final files = [
        _videoFile(p.join(temp.path, 'one', 'first.mp4')),
        _videoFile(p.join(temp.path, 'two', 'second.mp4')),
        _videoFile(
          p.join(temp.path, 'three', 'third.mp4'),
          outputOverride: OutputDirectorySettings(
            mode: OutputDirectoryMode.custom,
            customPath: overrideOutput.path,
          ),
        ),
      ];

      await cubit.startBatchEncode(
        files: files,
        globalSettings: const EncodeSettings(
          outputNameTemplate: 'same',
          copySourceMetadata: false,
        ),
        outputDirectory: OutputDirectorySettings(
          mode: OutputDirectoryMode.custom,
          customPath: globalOutput.path,
        ),
      );

      expect(repository.outputPaths, [
        p.join(globalOutput.path, 'same (1).mp4'),
        p.join(globalOutput.path, 'same (2).mp4'),
        p.join(overrideOutput.path, 'same.mp4'),
      ]);
      expect(cubit.currentData.outputPaths, {
        files[0].path: repository.outputPaths[0],
        files[1].path: repository.outputPaths[1],
        files[2].path: repository.outputPaths[2],
      });
    },
  );
}

VideoFile _videoFile(String path, {OutputDirectorySettings? outputOverride}) =>
    VideoFile(
      path: path,
      name: p.basename(path),
      sizeInBytes: 0,
      importedAt: DateTime(2026),
      outputDirectoryOverride: outputOverride,
    );

class _FakeVideoEncodeRepository implements VideoEncodeRepository {
  final outputPaths = <String>[];

  @override
  Future<bool> isFfmpegAvailable() async => true;

  @override
  Stream<EncodeProgress> encode({
    required String inputPath,
    required String outputPath,
    required EncodeSettings settings,
    required Duration totalDuration,
    DateTime? creationDate,
  }) {
    outputPaths.add(outputPath);
    return const Stream<EncodeProgress>.empty();
  }
}

class _FakeCliToolRunner implements CliToolRunner {
  @override
  Future<bool> isAvailable(String executable) async => false;

  @override
  Future<CliResult> run(
    String executable,
    List<String> args, {
    Duration timeout = const Duration(seconds: 30),
  }) async => const CliResult(stdout: '', stderr: '', exitCode: 0);
}
