import 'dart:async';
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
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_state.dart';
import 'package:video_toolkit/features/video_metadata/data/datasources/exiftool_datasource.dart';
import 'package:video_toolkit/features/video_metadata/data/models/video_metadata.dart';

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

  test(
    'stop cancels an in-flight encode without leaving the batch waiting',
    () async {
      final repository = _BlockingVideoEncodeRepository();
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

      final encodeFuture = cubit.startBatchEncode(
        files: [_videoFile('/tmp/long-video.mp4')],
        globalSettings: const EncodeSettings(copySourceMetadata: false),
      );
      await Future<void>.delayed(Duration.zero);

      expect(cubit.currentData.status, EncodeStatus.encoding);
      await cubit.stop();

      expect(cubit.currentData.status, EncodeStatus.idle);
      expect(repository.cancelCount, greaterThanOrEqualTo(2));
      await encodeFuture;
    },
  );

  test('weights overall progress by video duration', () async {
    final repository = _BlockingVideoEncodeRepository();
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

    final encodeFuture = cubit.startBatchEncode(
      files: [
        _videoFile('/tmp/short.mp4', duration: const Duration(seconds: 10)),
        _videoFile('/tmp/long.mp4', duration: const Duration(seconds: 30)),
      ],
      globalSettings: const EncodeSettings(copySourceMetadata: false),
    );
    await Future<void>.delayed(Duration.zero);
    repository.add(const EncodeProgress(percent: 0.5));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.currentData.overallProgress, closeTo(0.125, 0.000001));

    await cubit.stop();
    await encodeFuture;
  });
}

VideoFile _videoFile(
  String path, {
  OutputDirectorySettings? outputOverride,
  Duration? duration,
}) => VideoFile(
  path: path,
  name: p.basename(path),
  sizeInBytes: 0,
  importedAt: DateTime(2026),
  outputDirectoryOverride: outputOverride,
  metadata: duration == null ? null : VideoMetadata(duration: duration),
);

class _FakeVideoEncodeRepository implements VideoEncodeRepository {
  final outputPaths = <String>[];

  @override
  Future<void> cancelActiveEncode() async {}

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

class _BlockingVideoEncodeRepository implements VideoEncodeRepository {
  final _controller = StreamController<EncodeProgress>();
  int cancelCount = 0;

  void add(EncodeProgress progress) => _controller.add(progress);

  @override
  Future<void> cancelActiveEncode() async {
    cancelCount++;
  }

  @override
  Stream<EncodeProgress> encode({
    required String inputPath,
    required String outputPath,
    required EncodeSettings settings,
    required Duration totalDuration,
    DateTime? creationDate,
  }) => _controller.stream;

  @override
  Future<bool> isFfmpegAvailable() async => true;
}
