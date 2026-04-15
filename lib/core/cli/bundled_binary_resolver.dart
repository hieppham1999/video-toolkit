import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/utils/app_logger.dart';

/// Resolves bundled binary executables (e.g. ffmpeg) from the app bundle.
///
/// Resolution order:
/// 1. macOS app bundle: YourApp.app/Contents/Resources/bin/<name>
/// 2. Flutter asset extraction: rootBundle → ~/.video_toolkit/bin/<name>
@lazySingleton
class BundledBinaryResolver {
  final Map<String, String?> _cache = {};

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

  /// In development, ffmpeg lives at the project's assets directory.
  /// Resolve by walking up from the app executable to find the project root.
  String? _devAssetPath(String name) {
    try {
      final platform = Platform.isWindows ? 'windows' : 'macos';
      final ext = Platform.isWindows ? '.exe' : '';
      final execPath = Platform.resolvedExecutable;
      // Walk up from executable to find the project root containing pubspec.yaml
      var dir = Directory(p.dirname(execPath));
      for (var i = 0; i < 10; i++) {
        final candidate = File(p.join(dir.path, 'assets', 'bin', 'ffmpeg', platform, '$name$ext'));
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
    final platform = Platform.isWindows ? 'windows' : 'macos';
    final ext = Platform.isWindows ? '.exe' : '';
    final assetKey = 'assets/bin/ffmpeg/$platform/$name$ext';

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
