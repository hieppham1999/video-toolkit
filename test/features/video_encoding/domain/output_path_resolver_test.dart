import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/output_directory_settings.dart';
import 'package:video_toolkit/features/video_encoding/domain/output_path_resolver.dart';

void main() {
  test('resolves source, sanitized subfolder, and custom directories', () {
    final input = p.join('source', 'clips', 'video.mp4');

    expect(
      OutputPathResolver.resolveDir(
        inputPath: input,
        settings: const OutputDirectorySettings(),
      ),
      p.join('source', 'clips'),
    );
    expect(
      OutputPathResolver.resolveDir(
        inputPath: input,
        settings: const OutputDirectorySettings(
          subfolderEnabled: true,
          subfolderName: r' rendered/clips ',
        ),
      ),
      p.join('source', 'clips', 'rendered_clips'),
    );
    expect(
      OutputPathResolver.resolveDir(
        inputPath: input,
        settings: const OutputDirectorySettings(
          mode: OutputDirectoryMode.custom,
          customPath: 'exports',
        ),
      ),
      'exports',
    );
  });

  test('resolves the complete output path from encode settings', () {
    final input = p.join('source', 'my-video.mov');
    final result = OutputPathResolver.resolvePath(
      inputPath: input,
      encodeSettings: const EncodeSettings(
        outputNameTemplate: '{name}_small',
        outputExtension: OutputExtension.mkv,
      ),
      directorySettings: const OutputDirectorySettings(
        subfolderEnabled: true,
        subfolderName: 'encoded',
      ),
    );

    expect(result, p.join('source', 'encoded', 'my-video_small.mkv'));
  });

  test('reserves numbered paths for existing and in-batch collisions', () {
    final temp = Directory.systemTemp.createTempSync('video-toolkit-output-');
    addTearDown(() => temp.deleteSync(recursive: true));
    final desired = p.join(temp.path, 'video.mp4');
    File(desired).writeAsStringSync('existing');
    final reserved = <String>{};

    final first = OutputPathResolver.reserveAvailablePath(
      desired,
      reservedPaths: reserved,
    );
    final second = OutputPathResolver.reserveAvailablePath(
      desired,
      reservedPaths: reserved,
    );

    expect(first, p.join(temp.path, 'video (1).mp4'));
    expect(second, p.join(temp.path, 'video (2).mp4'));
  });

  test('validates custom and enabled subfolder destinations', () {
    expect(
      const OutputDirectorySettings(mode: OutputDirectoryMode.custom).isValid,
      isFalse,
    );
    expect(
      const OutputDirectorySettings(
        subfolderEnabled: true,
        subfolderName: '   ',
      ).isValid,
      isFalse,
    );
    expect(
      const OutputDirectorySettings(
        mode: OutputDirectoryMode.custom,
        customPath: '/exports',
      ).isValid,
      isTrue,
    );
  });
}
