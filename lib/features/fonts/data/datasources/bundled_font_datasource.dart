import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/fonts/data/models/font_info.dart';

/// Loads bundled fonts from `assets/fonts/` and extracts them to a writable
/// path so ffmpeg can reference them via `fontfile=`.
@lazySingleton
class BundledFontDatasource {
  static const _assetPrefix = 'assets/fonts/';
  static const _fontExtensions = {'.ttf', '.otf', '.ttc'};

  Future<List<FontInfo>> list() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final keys = manifest.listAssets().where((k) {
        if (!k.startsWith(_assetPrefix)) return false;
        final ext = p.extension(k).toLowerCase();
        return _fontExtensions.contains(ext);
      }).toList();

      if (keys.isEmpty) return const [];

      final fonts = <FontInfo>[];
      for (final key in keys) {
        final extractedPath = await _extractToCache(key);
        if (extractedPath == null) continue;
        fonts.add(FontInfo(
          name: _prettyName(key),
          path: extractedPath,
          isBundled: true,
        ));
      }
      fonts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return fonts;
    } catch (e) {
      appLogger.w('BundledFontDatasource: failed to load bundled fonts: $e');
      return const [];
    }
  }

  Future<String?> _extractToCache(String assetKey) async {
    try {
      final data = await rootBundle.load(assetKey);
      final targetDir = await _targetDirectory();
      final fileName = p.basename(assetKey);
      final targetPath = p.join(targetDir.path, fileName);
      final targetFile = File(targetPath);

      if (targetFile.existsSync() &&
          targetFile.lengthSync() == data.lengthInBytes) {
        return targetPath;
      }

      await targetFile.create(recursive: true);
      await targetFile.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      appLogger.i('BundledFontDatasource: extracted $fileName to $targetPath');
      return targetPath;
    } catch (e) {
      appLogger.w('BundledFontDatasource: extraction failed for $assetKey: $e');
      return null;
    }
  }

  Future<Directory> _targetDirectory() async {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    final dir = Directory(p.join(home, '.video_toolkit', 'fonts'));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _prettyName(String assetKey) {
    final base = p.basenameWithoutExtension(assetKey);
    return base.replaceAll('_', ' ').replaceAll('-', ' ').trim();
  }
}
