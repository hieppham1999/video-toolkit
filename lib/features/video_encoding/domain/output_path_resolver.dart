import 'package:path/path.dart' as p;
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

  /// Strips path separators and trims so a sub-folder name can't escape the
  /// input directory or contain leading/trailing whitespace.
  static String _sanitizeSegment(String name) =>
      name.replaceAll(RegExp(r'[\\/]+'), '_').trim();
}
