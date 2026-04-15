import 'dart:io';

import 'package:flutter/widgets.dart';

import 'macos/macos_encode_page.dart';
import 'windows/windows_encode_page.dart';

class EncodePage extends StatelessWidget {
  const EncodePage({
    super.key,
    required this.filePath,
    required this.totalDuration,
  });

  final String filePath;
  final Duration totalDuration;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return WindowsEncodePage(
        filePath: filePath,
        totalDuration: totalDuration,
      );
    }
    return MacosEncodePage(
      filePath: filePath,
      totalDuration: totalDuration,
    );
  }
}
