import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/features/home/domain/queue_completion_action.dart';

Future<bool> showAppPowerActionCountdownDialog({
  required BuildContext context,
  required QueueCompletionAction action,
  String? logPath,
  int seconds = 30,
}) async {
  final dialog = _PowerActionCountdownDialog(
    action: action,
    logPath: logPath,
    initialSeconds: seconds,
  );
  if (Platform.isWindows) {
    final result = await fluent.showDialog<bool>(
      context: context,
      builder: (_) => dialog,
    );
    return result ?? false;
  }
  final result = await showMacosAlertDialog<bool>(
    context: context,
    builder: (_) => dialog,
  );
  return result ?? false;
}

class _PowerActionCountdownDialog extends StatefulWidget {
  const _PowerActionCountdownDialog({
    required this.action,
    required this.logPath,
    required this.initialSeconds,
  });

  final QueueCompletionAction action;
  final String? logPath;
  final int initialSeconds;

  @override
  State<_PowerActionCountdownDialog> createState() =>
      _PowerActionCountdownDialogState();
}

class _PowerActionCountdownDialogState
    extends State<_PowerActionCountdownDialog> {
  Timer? _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        _timer?.cancel();
        Navigator.of(context).pop(true);
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _actionLabel() {
    final l10n = Languages.translate;
    return switch (widget.action) {
      QueueCompletionAction.none => l10n.queueActionNone,
      QueueCompletionAction.shutdown => l10n.queueActionShutdown,
      QueueCompletionAction.restart => l10n.queueActionRestart,
      QueueCompletionAction.sleep => l10n.queueActionSleep,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    if (Platform.isWindows) {
      final theme = fluent.FluentTheme.of(context);
      return fluent.ContentDialog(
        title: Row(
          children: [
            const fluent.Icon(fluent.FluentIcons.power_button),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.powerCountdownTitle,
                style: theme.typography.subtitle,
              ),
            ),
          ],
        ),
        content: _DialogMessage(
          message: l10n.powerCountdownMessage(
            _actionLabel(),
            _remainingSeconds,
          ),
          logPath: widget.logPath,
          bodyStyle: theme.typography.body ?? const TextStyle(),
          captionStyle: theme.typography.caption ?? const TextStyle(),
        ),
        actions: [
          fluent.Button(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: theme.typography.body),
          ),
          fluent.FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.executeNow, style: theme.typography.body),
          ),
        ],
      );
    }

    final theme = MacosTheme.of(context);
    return MacosAlertDialog(
      appIcon: const MacosIcon(CupertinoIcons.power, size: 56),
      title: Text(l10n.powerCountdownTitle, style: theme.typography.title3),
      message: _DialogMessage(
        message: l10n.powerCountdownMessage(_actionLabel(), _remainingSeconds),
        logPath: widget.logPath,
        bodyStyle: theme.typography.body,
        captionStyle: theme.typography.caption1,
      ),
      primaryButton: PushButton(
        controlSize: ControlSize.large,
        onPressed: () => Navigator.of(context).pop(true),
        child: Text(l10n.executeNow, style: theme.typography.body),
      ),
      secondaryButton: PushButton(
        controlSize: ControlSize.large,
        secondary: true,
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(l10n.cancel, style: theme.typography.body),
      ),
    );
  }
}

class _DialogMessage extends StatelessWidget {
  const _DialogMessage({
    required this.message,
    required this.logPath,
    required this.bodyStyle,
    required this.captionStyle,
  });

  final String message;
  final String? logPath;
  final TextStyle bodyStyle;
  final TextStyle captionStyle;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(message, textAlign: TextAlign.center, style: bodyStyle),
        if (logPath != null) ...[
          const SizedBox(height: 12),
          Text(l10n.powerCountdownLogPath(logPath!), style: captionStyle),
        ],
      ],
    );
  }
}
