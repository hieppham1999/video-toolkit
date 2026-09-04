import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/utils/filename_template.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/output_directory_settings.dart';

/// Resolves the directory where an encoded output file should be written,
/// based on the user's [OutputDirectorySettings].
class OutputPathResolver {
  const OutputPathResolver._();

  static String resolveDir({
    required String inputPath,
    required OutputDirectorySettings settings,
  }) {
    final inputDir = inputPath.isEmpty ? '' : p.dirname(inputPath);
    switch (settings.mode) {
      case OutputDirectoryMode.sameAsSource:
        if (settings.subfolderEnabled) {
          final sub = _sanitizeSegment(settings.subfolderName);
          if (sub.isNotEmpty) return p.join(inputDir, sub);
        }
        return inputDir;
      case OutputDirectoryMode.custom:
        final custom = settings.customPath;
        if (custom != null && custom.trim().isNotEmpty) return custom;
        return inputDir;
    }
  }

  static String resolvePath({
    required String inputPath,
    required EncodeSettings encodeSettings,
    required OutputDirectorySettings directorySettings,
    DateTime? creationDate,
    bool creationDateFromFileSystem = false,
    String? detectedTimezoneOffset,
  }) {
    final baseName = p.basenameWithoutExtension(inputPath);
    final outputName = FilenameTemplate.apply(
      encodeSettings.outputNameTemplate,
      originalName: baseName,
      creationDate: creationDate,
      creationDateFromFileSystem: creationDateFromFileSystem,
      sourceTimezoneOffset:
          encodeSettings.sourceTimezoneOffset ?? detectedTimezoneOffset,
    );
    final directory = resolveDir(
      inputPath: inputPath,
      settings: directorySettings,
    );
    return p.join(
      directory,
      '$outputName.${encodeSettings.outputExtension.value}',
    );
  }

  /// Returns the first non-existing path by appending ` (n)` before the file
  /// extension. [reservedPaths] prevents collisions between files planned in
  /// the same batch and is updated with the returned path.
  static String reserveAvailablePath(
    String desiredPath, {
    required Set<String> reservedPaths,
  }) {
    var candidate = desiredPath;
    var suffix = 1;
    while (_exists(candidate) ||
        reservedPaths.contains(_comparisonKey(candidate))) {
      final extension = p.extension(desiredPath);
      final stem = p.basenameWithoutExtension(desiredPath);
      candidate = p.join(p.dirname(desiredPath), '$stem ($suffix)$extension');
      suffix++;
    }
    reservedPaths.add(_comparisonKey(candidate));
    return candidate;
  }

  /// Strips path separators and trims so a sub-folder name can't escape the
  /// input directory or contain leading/trailing whitespace.
  static String _sanitizeSegment(String name) =>
      name.replaceAll(RegExp(r'[\\/]+'), '_').trim();

  static bool _exists(String path) {
    try {
      return FileSystemEntity.typeSync(path, followLinks: false) !=
          FileSystemEntityType.notFound;
    } catch (_) {
      // Treat an inaccessible path as occupied so the planner never risks
      // overwriting an entry it could not inspect.
      return true;
    }
  }

  static String _comparisonKey(String path) {
    final normalized = p.normalize(p.absolute(path));
    return Platform.isWindows || Platform.isMacOS
        ? normalized.toLowerCase()
        : normalized;
  }
}
