import 'dart:io';

import 'package:path/path.dart' as p;

/// Reveals [path] in the OS-native file manager (Finder on macOS,
/// Explorer on Windows). If the file does not exist, falls back to
/// opening the parent directory. No-op on unsupported platforms.
Future<void> revealInOsFileManager(String path) async {
  final fileExists = File(path).existsSync();
  final dirExists = Directory(path).existsSync();

  if (!fileExists && !dirExists) {
    final parent = p.dirname(path);
    if (Directory(parent).existsSync()) {
      await _openDirectory(parent);
    }
    return;
  }

  if (Platform.isMacOS) {
    if (fileExists) {
      await Process.run('open', ['-R', path]);
    } else {
      await Process.run('open', [path]);
    }
  } else if (Platform.isWindows) {
    if (fileExists) {
      await Process.run('explorer.exe', ['/select,$path']);
    } else {
      await Process.run('explorer.exe', [path]);
    }
  }
}

Future<void> _openDirectory(String dir) async {
  if (Platform.isMacOS) {
    await Process.run('open', [dir]);
  } else if (Platform.isWindows) {
    await Process.run('explorer.exe', [dir]);
  }
}
