import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/features/home/domain/queue_completion_action.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_state.dart';
import 'package:video_toolkit/widgets/app_dropdown.dart';
import 'package:video_toolkit/widgets/app_progress_bar.dart';

/// Bottom-of-screen progress strip summarising the current batch encode.
/// The action selector remains visible while the progress content hides idle.
class AppOverallProgressBar extends StatelessWidget {
  const AppOverallProgressBar({
    super.key,
    required this.encodeState,
    required this.queueCompletionAction,
    required this.onQueueCompletionActionChanged,
    this.onShowEncodeErrors,
  });

  final VideoEncodeState encodeState;
  final QueueCompletionAction queueCompletionAction;
  final ValueChanged<QueueCompletionAction> onQueueCompletionActionChanged;

  /// Called when the user taps the "failed" status to view error details.
  /// Only wired (and the status made tappable) when there are failures.
  final VoidCallback? onShowEncodeErrors;

  @override
  Widget build(BuildContext context) {
    final status = encodeState.status;

    final total = encodeState.totalFiles;
    final current = encodeState.currentIndex;
    final completed = encodeState.completedCount;
    final failed = encodeState.failures;
    final currentFileFraction = status == EncodeStatus.encoding
        ? encodeState.progress.percent
        : 0.0;
    final overallPercent = total > 0
        ? ((current + currentFileFraction) / total).clamp(0.0, 1.0)
        : 0.0;

    final isWindows = Platform.isWindows;

    // Resolve theme colors + styles per platform.
    final Color subtleText;
    final Color bgColor;
    final Color borderColor;
    final TextStyle? captionStyle;
    if (isWindows) {
      final theme = fluent.FluentTheme.of(context);
      subtleText = theme.resources.textFillColorSecondary;
      bgColor = theme.cardColor;
      borderColor = theme.resources.controlStrokeColorDefault;
      captionStyle = theme.typography.caption;
    } else {
      final theme = MacosTheme.of(context);
      final b = theme.brightness;
      subtleText = AppColors.textTertiary(b);
      bgColor = AppColors.surface(b);
      borderColor = AppColors.divider(b);
      captionStyle = theme.typography.caption1;
    }

    final String statusText;
    final Color statusColor;
    switch (status) {
      case EncodeStatus.encoding:
        statusText =
            'Encoding $current / $total'
            '${encodeState.progress.speed > 0 ? '  ·  ${encodeState.progress.speed.toStringAsFixed(1)}x' : ''}';
        statusColor = subtleText;
      case EncodeStatus.done:
        statusText = 'Done — $completed / $total completed';
        statusColor = AppColors.success;
      case EncodeStatus.error:
        statusText = '$completed completed, ${failed.length} failed';
        statusColor = AppColors.error;
      case EncodeStatus.idle:
        statusText = '';
        statusColor = subtleText;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: status == EncodeStatus.idle
                ? const SizedBox(height: 48)
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StatusLabel(
                                text: statusText,
                                style: (captionStyle ?? const TextStyle())
                                    .copyWith(color: statusColor),
                                onTap: status == EncodeStatus.error
                                    ? onShowEncodeErrors
                                    : null,
                              ),
                            ),
                            Text(
                              '${(overallPercent * 100).toStringAsFixed(0)}%',
                              style: captionStyle?.copyWith(color: subtleText),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: double.infinity,
                          child: AppProgressBar(percent: overallPercent),
                        ),
                      ],
                    ),
                  ),
          ),
          Container(width: 1, height: 32, color: borderColor),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: AppDropdown<QueueCompletionAction>(
                key: const Key('queue-completion-action-picker'),
                label: Languages.translate.afterQueue,
                value: queueCompletionAction,
                items: QueueCompletionAction.values,
                itemLabel: _actionLabel,
                onChanged: onQueueCompletionActionChanged,
                mainAxisSize: MainAxisSize.min,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _actionLabel(QueueCompletionAction action) {
    final l10n = Languages.translate;
    return switch (action) {
      QueueCompletionAction.none => l10n.queueActionNone,
      QueueCompletionAction.shutdown => l10n.queueActionShutdown,
      QueueCompletionAction.restart => l10n.queueActionRestart,
      QueueCompletionAction.sleep => l10n.queueActionSleep,
    };
  }
}

/// Status text that becomes a clickable affordance (underline + pointer cursor)
/// when [onTap] is provided — used to reopen the error details dialog.
class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.text, required this.style, this.onTap});

  final String text;
  final TextStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      style: onTap != null
          ? style.copyWith(decoration: TextDecoration.underline)
          : style,
    );

    if (onTap == null) return label;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: label,
      ),
    );
  }
}
