import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/navigation/app_navigator.dart';
import 'package:video_toolkit/features/home/data/models/video_file.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/domain/encode_preflight_validator.dart';
import 'package:video_toolkit/generated/l10n/app_localizations.dart';

void main() {
  testWidgets('rejects unavailable FFmpeg and empty inputs before encoding', (
    tester,
  ) async {
    await tester.pumpWidget(const _TestApp());
    final temp = Directory.systemTemp.createTempSync(
      'video-toolkit-preflight-',
    );
    addTearDown(() => temp.deleteSync(recursive: true));
    final input = File(p.join(temp.path, 'empty.mp4'))..createSync();
    final video = _video(input.path);
    final outputPaths = {video.path: p.join(temp.path, 'output.mp4')};
    final validator = EncodePreflightValidator();

    final missingTool = (await tester.runAsync(
      () => validator.validate(
        files: [video],
        outputPaths: outputPaths,
        settingsFor: (_) => const EncodeSettings(),
        ffmpegAvailable: false,
      ),
    ))!;
    expect(missingTool.single.message, contains('FFmpeg'));

    final emptyInput = (await tester.runAsync(
      () => validator.validate(
        files: [video],
        outputPaths: outputPaths,
        settingsFor: (_) => const EncodeSettings(),
        ffmpegAvailable: true,
      ),
    ))!;
    expect(emptyInput.single.message, contains('empty'));
  });

  testWidgets('accepts a readable input and writable output directory', (
    tester,
  ) async {
    await tester.pumpWidget(const _TestApp());
    final temp = Directory.systemTemp.createTempSync(
      'video-toolkit-preflight-',
    );
    addTearDown(() => temp.deleteSync(recursive: true));
    final input = File(p.join(temp.path, 'input.mp4'))..writeAsStringSync('x');
    final outputDir = p.join(temp.path, 'new-output');
    final video = _video(input.path);

    final failures = (await tester.runAsync(
      () => EncodePreflightValidator().validate(
        files: [video],
        outputPaths: {video.path: p.join(outputDir, 'output.mp4')},
        settingsFor: (_) => const EncodeSettings(),
        ffmpegAvailable: true,
      ),
    ))!;

    expect(failures, isEmpty);
  });
}

VideoFile _video(String path) => VideoFile(
  path: path,
  name: p.basename(path),
  sizeInBytes: File(path).lengthSync(),
  importedAt: DateTime(2026),
);

class _TestApp extends StatelessWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: NavigatorKey.key,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const SizedBox(),
  );
}
