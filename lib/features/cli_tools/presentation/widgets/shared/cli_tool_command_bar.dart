import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart' show Tooltip;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/theme/app_colors.dart';

/// Row of: [tool-name chip] [editable args field] [input-file chip].
///
/// The tool name and input path are rendered as read-only chips, so keyboard
/// edits can only touch the middle segment. This matches the UX requirement
/// that "tool keyword and file cannot be changed".
class CliToolCommandBar extends StatelessWidget {
  const CliToolCommandBar({
    super.key,
    required this.toolName,
    required this.inputPath,
    required this.argsController,
    required this.enabled,
  });

  final String toolName;
  final String inputPath;
  final TextEditingController argsController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return _FluentCommandBar(
        toolName: toolName,
        inputPath: inputPath,
        argsController: argsController,
        enabled: enabled,
      );
    }
    return _MacosCommandBar(
      toolName: toolName,
      inputPath: inputPath,
      argsController: argsController,
      enabled: enabled,
    );
  }
}

class _MacosCommandBar extends StatelessWidget {
  const _MacosCommandBar({
    required this.toolName,
    required this.inputPath,
    required this.argsController,
    required this.enabled,
  });

  final String toolName;
  final String inputPath;
  final TextEditingController argsController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final b = theme.brightness;
    final chipBg = AppColors.surfaceElevated(b);
    final chipFg = AppColors.textPrimary(b);
    final mono = TextStyle(
      fontFamily: 'monospace',
      fontSize: 13,
      color: chipFg,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _chip(bg: chipBg, child: Text(toolName, style: mono)),
        const SizedBox(width: 6),
        Expanded(
          child: MacosTextField(
            controller: argsController,
            enabled: enabled,
            maxLines: 4,
            minLines: 1,
            style: mono,
            placeholder: '',
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: inputPath,
          child: _chip(
            bg: chipBg,
            child: Text(p.basename(inputPath), style: mono),
          ),
        ),
      ],
    );
  }

  Widget _chip({required Color bg, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}

class _FluentCommandBar extends StatelessWidget {
  const _FluentCommandBar({
    required this.toolName,
    required this.inputPath,
    required this.argsController,
    required this.enabled,
  });

  final String toolName;
  final String inputPath;
  final TextEditingController argsController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    final chipBg = theme.resources.controlFillColorSecondary;
    final fg = theme.resources.textFillColorPrimary;
    final mono = TextStyle(fontFamily: 'monospace', fontSize: 13, color: fg);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.resources.cardStrokeColorDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _chip(bg: chipBg, child: Text(toolName, style: mono)),
          const SizedBox(width: 6),
          Expanded(
            child: fluent.TextBox(
              controller: argsController,
              enabled: enabled,
              maxLines: 4,
              minLines: 1,
              style: mono,
            ),
          ),
          const SizedBox(width: 6),
          fluent.Tooltip(
            message: inputPath,
            child: _chip(
              bg: chipBg,
              child: Text(p.basename(inputPath), style: mono),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({required Color bg, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}
