import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';

/// Shows a cross-platform error dialog with copyable [details].
///
/// - macOS: `MacosAlertDialog`
/// - Windows: `ContentDialog`
///
/// Reusable for any error — pass a [title], an optional short [message], and
/// the full [details] text (e.g. ffmpeg stderr) shown in a scrollable,
/// selectable box with a Copy button.
Future<void> showAppErrorDialog({
  required BuildContext context,
  required String title,
  String? message,
  required String details,
}) {
  if (Platform.isWindows) {
    return fluent.showDialog<void>(
      context: context,
      builder: (_) =>
          _FluentErrorDialog(title: title, message: message, details: details),
    );
  }
  return showMacosAlertDialog<void>(
    context: context,
    builder: (_) =>
        _MacosErrorDialog(title: title, message: message, details: details),
  );
}

class _MacosErrorDialog extends StatefulWidget {
  const _MacosErrorDialog({
    required this.title,
    required this.message,
    required this.details,
  });

  final String title;
  final String? message;
  final String details;

  @override
  State<_MacosErrorDialog> createState() => _MacosErrorDialogState();
}

class _MacosErrorDialogState extends State<_MacosErrorDialog> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.details));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final theme = MacosTheme.of(context);
    return MacosAlertDialog(
      appIcon: const MacosIcon(
        CupertinoIcons.exclamationmark_triangle_fill,
        size: 56,
        color: AppColors.error,
      ),
      title: Text(widget.title, style: theme.typography.title3),
      message: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.message != null) ...[
            Text(
              widget.message!,
              style: theme.typography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
          const _DetailsLabel(),
          const SizedBox(height: 6),
          _DetailsBox(details: widget.details),
        ],
      ),
      primaryButton: PushButton(
        controlSize: ControlSize.large,
        onPressed: () => Navigator.of(context).pop(),
        child: Text(l10n.close),
      ),
      secondaryButton: PushButton(
        controlSize: ControlSize.large,
        secondary: true,
        onPressed: _copy,
        child: Text(_copied ? l10n.copied : l10n.copy),
      ),
    );
  }
}

class _FluentErrorDialog extends StatefulWidget {
  const _FluentErrorDialog({
    required this.title,
    required this.message,
    required this.details,
  });

  final String title;
  final String? message;
  final String details;

  @override
  State<_FluentErrorDialog> createState() => _FluentErrorDialogState();
}

class _FluentErrorDialogState extends State<_FluentErrorDialog> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.details));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final theme = fluent.FluentTheme.of(context);
    return fluent.ContentDialog(
      constraints: const BoxConstraints(maxWidth: 520),
      title: Row(
        children: [
          const fluent.Icon(
            fluent.FluentIcons.error_badge,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(widget.title, style: theme.typography.subtitle)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.message != null) ...[
            Text(widget.message!, style: theme.typography.body),
            const SizedBox(height: 12),
          ],
          const _DetailsLabel(),
          const SizedBox(height: 6),
          _DetailsBox(details: widget.details),
        ],
      ),
      actions: [
        fluent.Button(
          onPressed: _copy,
          child: Text(_copied ? l10n.copied : l10n.copy),
        ),
        fluent.FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}

/// Small "Details" caption above the error box.
class _DetailsLabel extends StatelessWidget {
  const _DetailsLabel();

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final Brightness b;
    final TextStyle base;
    if (Platform.isWindows) {
      final t = fluent.FluentTheme.of(context);
      b = t.brightness;
      base = t.typography.caption ?? const TextStyle();
    } else {
      final t = MacosTheme.of(context);
      b = t.brightness;
      base = t.typography.caption1;
    }
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        l10n.errorDetails,
        style: base.copyWith(color: AppColors.textTertiary(b)),
      ),
    );
  }
}

/// Scrollable, selectable monospace box holding the full error text.
class _DetailsBox extends StatelessWidget {
  const _DetailsBox({required this.details});

  final String details;

  @override
  Widget build(BuildContext context) {
    final Brightness b;
    final TextStyle base;
    if (Platform.isWindows) {
      final t = fluent.FluentTheme.of(context);
      b = t.brightness;
      base = t.typography.caption ?? const TextStyle();
    } else {
      final t = MacosTheme.of(context);
      b = t.brightness;
      base = t.typography.caption1;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle(b),
        border: Border.all(color: AppColors.divider(b)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: SingleChildScrollView(
          child: SelectableText(
            details,
            style: base.copyWith(
              fontFamily: 'monospace',
              color: AppColors.textSecondary(b),
            ),
          ),
        ),
      ),
    );
  }
}
