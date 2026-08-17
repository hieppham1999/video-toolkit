import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';

/// Shows a cross-platform success dialog.
Future<void> showAppSuccessDialog({
  required BuildContext context,
  required String title,
  required String message,
}) {
  if (Platform.isWindows) {
    return fluent.showDialog<void>(
      context: context,
      builder: (_) => _FluentSuccessDialog(title: title, message: message),
    );
  }
  return showMacosAlertDialog<void>(
    context: context,
    builder: (_) => _MacosSuccessDialog(title: title, message: message),
  );
}

class _MacosSuccessDialog extends StatelessWidget {
  const _MacosSuccessDialog({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final theme = MacosTheme.of(context);
    return MacosAlertDialog(
      appIcon: const MacosIcon(
        CupertinoIcons.check_mark_circled,
        size: 56,
        color: AppColors.success,
      ),
      title: Text(title, style: theme.typography.title3),
      message: Text(
        message,
        style: theme.typography.body,
        textAlign: TextAlign.center,
      ),
      primaryButton: PushButton(
        controlSize: ControlSize.large,
        onPressed: () => Navigator.of(context).pop(),
        child: Text(l10n.close),
      ),
    );
  }
}

class _FluentSuccessDialog extends StatelessWidget {
  const _FluentSuccessDialog({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final theme = fluent.FluentTheme.of(context);
    return fluent.ContentDialog(
      title: Row(
        children: [
          const fluent.Icon(
            fluent.FluentIcons.check_mark,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: theme.typography.subtitle)),
        ],
      ),
      content: Text(message, style: theme.typography.body),
      actions: [
        fluent.FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}
