import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/features/cli_tools/presentation/widgets/macos/macos_cli_tools_sheet.dart';
import 'package:video_toolkit/features/cli_tools/presentation/widgets/windows/windows_cli_tools_dialog.dart';

/// Opens the CLI Tools dialog for the given video [inputPath].
Future<void> showCliToolsDialog(BuildContext context, String inputPath) {
  if (Platform.isWindows) {
    return fluent.showDialog<void>(
      context: context,
      builder: (ctx) => WindowsCliToolsDialog(
        inputPath: inputPath,
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }
  return showMacosSheet<void>(
    context: context,
    builder: (ctx) => MacosCliToolsSheet(
      inputPath: inputPath,
      onClose: () => Navigator.of(ctx).pop(),
    ),
  );
}
