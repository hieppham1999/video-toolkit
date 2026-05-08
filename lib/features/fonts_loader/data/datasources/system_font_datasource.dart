import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/fonts_loader/data/models/font_info.dart';

/// Scans OS font directories for installed fonts.
@lazySingleton
class SystemFontDatasource {
  static const _fontExtensions = {'.ttf', '.otf', '.ttc'};

  Future<List<FontInfo>> list() async {
    final dirs = _fontDirectories();
    final seen = <String>{};
    final fonts = <FontInfo>[];

    for (final dir in dirs) {
      if (!dir.existsSync()) continue;
      try {
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is! File) continue;
          final ext = p.extension(entity.path).toLowerCase();
          if (!_fontExtensions.contains(ext)) continue;
          final key = p.basenameWithoutExtension(entity.path).toLowerCase();
          if (!seen.add(key)) continue;
          fonts.add(FontInfo(
            name: _prettyName(entity.path),
            path: entity.path,
          ));
        }
      } catch (e) {
        appLogger.w('SystemFontDatasource: failed to scan ${dir.path}: $e');
      }
    }

    fonts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return fonts;
  }

  List<Directory> _fontDirectories() {
    if (Platform.isMacOS) {
      final home = Platform.environment['HOME'] ?? '';
      return [
        Directory('/System/Library/Fonts'),
        Directory('/Library/Fonts'),
        if (home.isNotEmpty) Directory(p.join(home, 'Library', 'Fonts')),
      ];
    }
    if (Platform.isWindows) {
      final sysRoot = Platform.environment['SystemRoot'] ?? r'C:\Windows';
      final localAppData = Platform.environment['LOCALAPPDATA'];
      return [
        Directory(p.join(sysRoot, 'Fonts')),
        if (localAppData != null)
          Directory(p.join(localAppData, 'Microsoft', 'Windows', 'Fonts')),
      ];
    }
    return const [];
  }

  String _prettyName(String path) {
    final base = p.basenameWithoutExtension(path);
    return base.replaceAll('_', ' ').replaceAll('-', ' ').trim();
  }
}
