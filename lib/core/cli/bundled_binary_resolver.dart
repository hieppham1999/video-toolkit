import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/utils/app_logger.dart';

/// Resolves bundled binary executables (e.g. ffmpeg, exiftool) from the app bundle.
///
/// Resolution order:
/// 1. Platform app bundle (prod): macOS `.app/Contents/Resources/bin/<name>`,
///    Windows `data/bin/<name>.exe`.
/// 2. Dev assets: walk up from executable to find `assets/bin/<folder>/<platform>/<name><ext>`.
/// 3. Flutter asset extraction (single-file tools only, e.g. ffmpeg/ffprobe).
///    Multi-file tools like exiftool (needs sibling `lib/`) must be shipped via
///    steps 1 or 2 — asset extraction is skipped for them.
@lazySingleton
class BundledBinaryResolver {
  final Map<String, String?> _cache = {};

  /// Maps tool executable name → assets subfolder.
  /// ffmpeg and ffprobe share `assets/bin/ffmpeg/`; exiftool has its own folder.
  static const _toolFolder = {
    'ffmpeg': 'ffmpeg',
    'ffprobe': 'ffmpeg',
    'exiftool': 'exiftool',
  };

  /// Tools that cannot be extracted from Flutter assets at runtime because
  /// they depend on sibling files/folders (e.g. exiftool's `lib/`).
  static const _singleFileExtractable = {'ffmpeg', 'ffprobe'};

  Future<String?> resolve(String name) async {
    if (_cache.containsKey(name)) return _cache[name];

    final path = await _resolve(name);
    _cache[name] = path;
    return path;
  }

  Future<String?> _resolve(String name) async {
    // 1. Check platform-specific app bundle path
    final bundlePath = _appBundlePath(name);
    if (bundlePath != null && File(bundlePath).existsSync()) {
      appLogger.d('BundledBinaryResolver: found $name in app bundle at $bundlePath');
      return bundlePath;
    }

    // 2. Check source project assets (development mode)
    final devPath = _devAssetPath(name);
    if (devPath != null && File(devPath).existsSync()) {
      appLogger.d('BundledBinaryResolver: found $name in dev assets at $devPath');
      return devPath;
    }

    // 3. Try Flutter asset extraction as last resort
    return _extractFromAssets(name);
  }

  /// In development, bundled tools live under the project's assets directory.
  /// Resolve by walking up from the app executable to find the project root.
  String? _devAssetPath(String name) {
    try {
      final folder = _toolFolder[name];
      if (folder == null) return null;
      final platform = Platform.isWindows ? 'windows' : 'macos';
      final ext = Platform.isWindows ? '.exe' : '';
      final execPath = Platform.resolvedExecutable;
      var dir = Directory(p.dirname(execPath));
      for (var i = 0; i < 10; i++) {
        final candidate = File(p.join(dir.path, 'assets', 'bin', folder, platform, '$name$ext'));
        if (candidate.existsSync()) return candidate.path;
        final parent = dir.parent;
        if (parent.path == dir.path) break;
        dir = parent;
      }
    } catch (_) {}
    return null;
  }

  /// Resolve path relative to the running app bundle.
  ///
  /// macOS: YourApp.app/Contents/MacOS/YourApp
  ///      → YourApp.app/Contents/Resources/bin/ffmpeg
  ///
  /// Windows: your_app/video_toolkit.exe
  ///        → your_app/data/bin/ffmpeg.exe
  String? _appBundlePath(String name) {
    try {
      final execPath = Platform.resolvedExecutable;
      final ext = Platform.isWindows ? '.exe' : '';

      if (Platform.isMacOS) {
        final contentsDir = p.dirname(p.dirname(execPath));
        return p.join(contentsDir, 'Resources', 'bin', name);
      }

      if (Platform.isWindows) {
        final execDir = p.dirname(execPath);
        return p.join(execDir, 'data', 'bin', '$name$ext');
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _extractFromAssets(String name) async {
    if (!_singleFileExtractable.contains(name)) {
      appLogger.d('BundledBinaryResolver: $name is not single-file extractable, skipping');
      return null;
    }
    final folder = _toolFolder[name];
    if (folder == null) return null;
    final platform = Platform.isWindows ? 'windows' : 'macos';
    final ext = Platform.isWindows ? '.exe' : '';
    final assetKey = 'assets/bin/$folder/$platform/$name$ext';

    try {
      final data = await rootBundle.load(assetKey);
      final targetDir = await _targetDirectory();
      final targetPath = p.join(targetDir.path, name);
      final targetFile = File(targetPath);

      // Skip extraction if already extracted and same size
      if (targetFile.existsSync() &&
          targetFile.lengthSync() == data.lengthInBytes) {
        appLogger.d('BundledBinaryResolver: $name already extracted at $targetPath');
        return targetPath;
      }

      await targetFile.create(recursive: true);
      await targetFile.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );

      if (!Platform.isWindows) {
        await Process.run('chmod', ['+x', targetPath]);
      }

      appLogger.i('BundledBinaryResolver: extracted $name to $targetPath');
      return targetPath;
    } catch (e) {
      appLogger.w('BundledBinaryResolver: asset extraction failed for $name: $e');
      return null;
    }
  }

  Future<Directory> _targetDirectory() async {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    final dir = Directory(p.join(home, '.video_toolkit', 'bin'));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
