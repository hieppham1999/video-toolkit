import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:video_toolkit/core/cli/bundled_binary_resolver.dart';
import 'package:video_toolkit/core/cli/cli_result.dart';
import 'package:video_toolkit/core/cli/cli_tool_runner.dart';
import 'package:video_toolkit/features/video_encoding/data/datasources/ffmpeg_datasource.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';

void main() {
  setUpAll(() {
    GetIt.I.registerSingleton<AppLogger>(AppLogger(Logger(level: Level.off)));
  });
  tearDownAll(GetIt.I.reset);

  test('selects a hardware encoder only after a successful probe', () async {
    final expected = Platform.isMacOS ? 'h264_videotoolbox' : 'h264_nvenc';
    final runner = _CapabilityRunner(expected, probeSucceeds: true);
    final datasource = FfmpegDatasource(runner, BundledBinaryResolver());

    final encoder = await datasource.resolveVideoEncoder(
      VideoEncoder.h264,
      EncoderMode.auto,
    );

    expect(encoder, expected);
    expect(runner.probedEncoders, [expected]);
  });

  test('falls back to software when the hardware probe fails', () async {
    final compiled = Platform.isMacOS ? 'hevc_videotoolbox' : 'hevc_nvenc';
    final datasource = FfmpegDatasource(
      _CapabilityRunner(compiled, probeSucceeds: false),
      BundledBinaryResolver(),
    );

    final encoder = await datasource.resolveVideoEncoder(
      VideoEncoder.h265,
      EncoderMode.hardware,
    );

    expect(encoder, VideoEncoder.h265.value);
  });
}

class _CapabilityRunner implements CliToolRunner {
  _CapabilityRunner(this.compiledEncoder, {required this.probeSucceeds});

  final String compiledEncoder;
  final bool probeSucceeds;
  final probedEncoders = <String>[];

  @override
  Future<bool> isAvailable(String executable) async => true;

  @override
  Future<CliResult> run(
    String executable,
    List<String> args, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (args.contains('-encoders')) {
      return CliResult(
        stdout: ' V....D $compiledEncoder test encoder',
        stderr: '',
        exitCode: 0,
      );
    }
    final codecIndex = args.indexOf('-c:v');
    if (codecIndex >= 0) probedEncoders.add(args[codecIndex + 1]);
    return CliResult(stdout: '', stderr: '', exitCode: probeSucceeds ? 0 : 1);
  }
}
