import 'dart:io';

import 'package:flutter/widgets.dart';

import 'macos/macos_import_page.dart';
import 'windows/windows_import_page.dart';

class ImportPage extends StatelessWidget {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) return const WindowsImportPage();
    return const MacosImportPage();
  }
}
