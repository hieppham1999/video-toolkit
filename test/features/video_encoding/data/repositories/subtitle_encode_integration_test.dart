import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/cli/bundled_binary_resolver.dart';
import 'package:video_toolkit/core/cli/cli_exception.dart';
import 'package:video_toolkit/core/cli/cli_result.dart';
import 'package:video_toolkit/core/cli/cli_tool_runner.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/fonts_loader/data/font_resolver.dart';
import 'package:video_toolkit/features/video_encoding/data/datasources/ffmpeg_datasource.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_progress.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/repositories/video_encode_repository_impl.dart';
import 'package:video_toolkit/features/video_metadata/data/datasources/ffprobe_datasource.dart';

/// Opt in with --dart-define=RUN_FFMPEG_TESTS=true. Paths may be overridden
/// with FFMPEG_PATH and FFPROBE_PATH for machines without the bundled tools.
void main() {
  const enabled = bool.fromEnvironment('RUN_FFMPEG_TESTS');
  const ffmpeg = String.fromEnvironment(
    'FFMPEG_PATH',
    defaultValue: 'assets/bin/ffmpeg/windows/ffmpeg.exe',
  );
  const ffprobe = String.fromEnvironment(
    'FFPROBE_PATH',
    defaultValue: 'assets/bin/ffmpeg/windows/ffprobe.exe',
  );
  const bitmapSample = String.fromEnvironment('BITMAP_SUBTITLE_SAMPLE');

  test(
    'failed subtitle conversion removes partial output and reports the error',
    () async {
      GetIt.I.registerSingleton<AppLogger>(AppLogger(Logger(level: Level.off)));
      final temp = await Directory.systemTemp.createTemp(
        'video-toolkit-failure-',
      );
      addTearDown(() async {
        await temp.delete(recursive: true);
        await GetIt.I.reset();
      });
      final runner = _Runner(ffprobe);
      final ffmpeg = _FailingFfmpeg(runner);
      final repository = VideoEncodeRepositoryImpl(
        ffmpeg,
        _UnusedFontResolver(),
        FfprobeDatasource(runner),
      );
      final output = p.join(temp.path, 'output.mp4');
      await expectLater(
        repository
            .encode(
              inputPath: 'input.mkv',
              outputPath: output,
              totalDuration: const Duration(milliseconds: 1200),
              settings: const EncodeSettings(
                preserveSourceSubtitles: true,
                embedTimestampSubtitle: true,
              ),
            )
            .drain<void>(),
        throwsA(
          isA<ToolExecutionException>().having(
            (error) => error.stderr,
            'stderr',
            contains('bitmap'),
          ),
        ),
      );
      expect(ffmpeg.partialOutputWasWritten, isTrue);
      expect(await File(output).exists(), isFalse);
      expect(temp.listSync(), isEmpty);
    },
  );

  group('real FFmpeg subtitle encode', () {
    late Directory temp;
    late String source;
    late VideoEncodeRepositoryImpl repository;
    final runner = _Runner(ffprobe);

    setUpAll(() async {
      GetIt.I.registerSingleton<AppLogger>(AppLogger(Logger(level: Level.off)));
      temp = await Directory.systemTemp.createTemp('video-toolkit-subtitles-');
      source = p.join(temp.path, 'source.mkv');
      final first = p.join(temp.path, 'english.srt');
      final second = p.join(temp.path, 'vietnamese.srt');
      await File(
        first,
      ).writeAsString('1\n00:00:00,000 --> 00:00:01,200\nHello\n');
      await File(
        second,
      ).writeAsString('1\n00:00:00,000 --> 00:00:01,200\nXin chào\n');
      await _run(ffmpeg, [
        '-v',
        'error',
        '-f',
        'lavfi',
        '-i',
        'color=s=64x64:r=5',
        '-i',
        first,
        '-i',
        second,
        '-map',
        '0:v',
        '-map',
        '1:0',
        '-map',
        '2:0',
        '-t',
        '1.2',
        '-c:v',
        'libx264',
        '-c:s',
        'srt',
        '-metadata:s:s:0',
        'title=English',
        '-metadata:s:s:0',
        'language=eng',
        '-metadata:s:s:0',
        'handler_name=English',
        '-metadata:s:s:1',
        'title=Vietnamese',
        '-metadata:s:s:1',
        'language=vie',
        '-metadata:s:s:1',
        'handler_name=Vietnamese',
        '-disposition:s:0',
        'default',
        '-disposition:s:1',
        'forced',
        source,
      ]);
      repository = VideoEncodeRepositoryImpl(
        _Ffmpeg(ffmpeg, runner),
        _UnusedFontResolver(),
        FfprobeDatasource(runner),
      );
    });

    tearDownAll(() async {
      await temp.delete(recursive: true);
      await GetIt.I.reset();
    });

    test(
      'copies bitmap subtitles to MKV and rejects MP4/MOV without leftover output',
      () async {
        for (final extension in [
          OutputExtension.mp4,
          OutputExtension.mov,
          OutputExtension.mkv,
        ]) {
          final output = p.join(temp.path, 'bitmap.${extension.value}');
          final encode = repository
              .encode(
                inputPath: bitmapSample,
                outputPath: output,
                totalDuration: const Duration(milliseconds: 1200),
                creationDate: DateTime.utc(2026, 11, 17),
                settings: EncodeSettings(
                  outputExtension: extension,
                  preserveSourceSubtitles: true,
                  embedTimestampSubtitle: true,
                ),
              )
              .drain<void>();
          if (extension == OutputExtension.mkv) {
            await encode;
            final metadata = await FfprobeDatasource(runner).extract(output);
            expect(metadata!.subtitleTracks!.map((track) => track.codec), [
              'subrip',
              'hdmv_pgs_subtitle',
            ]);
          } else {
            await expectLater(encode, throwsA(isA<ToolExecutionException>()));
            expect(await File(output).exists(), isFalse);
          }
          expect(
            temp.listSync().where(
              (file) => p.basename(file.path).contains('.part'),
            ),
            isEmpty,
          );
        }
      },
      skip: bitmapSample.isEmpty,
    );

    for (final extension in [
      OutputExtension.mp4,
      OutputExtension.mov,
      OutputExtension.mkv,
    ]) {
      for (final preserve in [false, true]) {
        for (final timestamp in [false, true]) {
          test('$extension preserve=$preserve timestamp=$timestamp', () async {
            final output = p.join(
              temp.path,
              '${extension.value}-$preserve-$timestamp.${extension.value}',
            );
            await repository
                .encode(
                  inputPath: source,
                  outputPath: output,
                  totalDuration: const Duration(milliseconds: 1200),
                  creationDate: DateTime.utc(2026, 11, 17),
                  settings: EncodeSettings(
                    outputExtension: extension,
                    preserveSourceSubtitles: preserve,
                    embedTimestampSubtitle: timestamp,
                  ),
                )
                .drain<void>();
            final metadata = await FfprobeDatasource(runner).extract(output);
            final tracks = metadata!.subtitleTracks!;
            expect(tracks, hasLength((preserve ? 2 : 0) + (timestamp ? 1 : 0)));
            if (timestamp) {
              expect(tracks.first.title, 'timestamp');
              expect(
                tracks.first.codec,
                extension == OutputExtension.mkv ? 'subrip' : 'mov_text',
              );
              if (preserve) expect(tracks.first.isDefault, isFalse);
            }
            if (preserve) {
              final originals = tracks.skip(timestamp ? 1 : 0).toList();
              expect(originals.map((track) => track.language), ['eng', 'vie']);
              expect(originals.map((track) => track.title), [
                'English',
                'Vietnamese',
              ]);
              expect(originals.first.isDefault, isTrue);
              // FFmpeg's MOV muxer loses the forced disposition; the UI warns
              // users to choose MP4/MKV when this flag must survive.
              expect(originals.last.isForced, extension != OutputExtension.mov);
              final result = await _run(ffmpeg, [
                '-v',
                'error',
                '-i',
                output,
                '-map',
                '0:s:${timestamp ? 2 : 1}',
                '-f',
                'srt',
                '-',
              ]);
              expect(result.stdout, contains('Xin chào'));
            }
            expect(
              temp.listSync().where(
                (file) => p.basename(file.path).contains('.part'),
              ),
              isEmpty,
            );
          });
        }
      }
    }
  }, skip: !enabled);
}

Future<ProcessResult> _run(String executable, List<String> args) async {
  final result = await Process.run(
    executable,
    args,
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  if (result.exitCode != 0) {
    throw ToolExecutionException(
      tool: executable,
      exitCode: result.exitCode,
      stderr: result.stderr as String,
    );
  }
  return result;
}

class _Runner implements CliToolRunner {
  _Runner(this.ffprobe);
  final String ffprobe;

  @override
  Future<bool> isAvailable(String executable) async => File(ffprobe).exists();

  @override
  Future<CliResult> run(
    String executable,
    List<String> args, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final result = await _run(ffprobe, args).timeout(timeout);
    return CliResult(
      stdout: result.stdout as String,
      stderr: result.stderr as String,
      exitCode: result.exitCode,
    );
  }
}

class _Ffmpeg extends FfmpegDatasource {
  _Ffmpeg(this.executable, CliToolRunner runner)
    : super(runner, BundledBinaryResolver());
  final String executable;

  @override
  Stream<EncodeProgress> encode({
    required String inputPath,
    required List<String> args,
    required Duration totalDuration,
  }) async* {
    await _run(executable, ['-v', 'error', ...args]);
    yield const EncodeProgress(percent: 1);
  }
}

class _UnusedFontResolver implements FontResolver {
  @override
  Future<String?> resolve(String? overlayFontFile) =>
      throw UnsupportedError('No overlays in this test');
}

class _FailingFfmpeg extends FfmpegDatasource {
  _FailingFfmpeg(CliToolRunner runner) : super(runner, BundledBinaryResolver());
  bool partialOutputWasWritten = false;

  @override
  Stream<EncodeProgress> encode({
    required String inputPath,
    required List<String> args,
    required Duration totalDuration,
  }) async* {
    await File(args.last).writeAsString('partial video');
    partialOutputWasWritten = true;
    throw const ToolExecutionException(
      tool: 'ffmpeg',
      exitCode: 1,
      stderr:
          'Subtitle encoding currently only possible from text to text or bitmap to bitmap',
    );
  }
}
