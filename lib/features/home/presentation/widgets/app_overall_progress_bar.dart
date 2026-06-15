import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_state.dart';
import 'package:video_toolkit/widgets/app_progress_bar.dart';

/// Bottom-of-screen progress strip summarising the current batch encode.
/// Hidden when idle; colours + progress bar control adapt per platform.
class AppOverallProgressBar extends StatelessWidget {
  const AppOverallProgressBar({
    super.key,
    required this.encodeState,
    this.onShowEncodeErrors,
  });

  final VideoEncodeState encodeState;

  /// Called when the user taps the "failed" status to view error details.
  /// Only wired (and the status made tappable) when there are failures.
  final VoidCallback? onShowEncodeErrors;

  @override
  Widget build(BuildContext context) {
    final status = encodeState.status;
    if (status == EncodeStatus.idle) return const SizedBox.shrink();

    final total = encodeState.totalFiles;
    final current = encodeState.currentIndex;
    final completed = encodeState.completedCount;
    final failed = encodeState.failures;
    final currentFileFraction =
        status == EncodeStatus.encoding ? encodeState.progress.percent : 0.0;
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
        statusText = 'Encoding $current / $total'
            '${encodeState.progress.speed > 0 ? '  ·  ${encodeState.progress.speed.toStringAsFixed(1)}x' : ''}';
        statusColor = subtleText;
      case EncodeStatus.done:
        statusText = 'Done — $completed / $total completed';
        statusColor = AppColors.success;
      case EncodeStatus.error:
        statusText = '$completed completed, ${failed.length} failed';
        statusColor = AppColors.error;
      case EncodeStatus.idle:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatusLabel(
                  text: statusText,
                  style: (captionStyle ?? const TextStyle()).copyWith(color: statusColor),
                  // Tappable only when there are failures to inspect.
                  onTap: status == EncodeStatus.error ? onShowEncodeErrors : null,
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
    );
  }
}

/// Status text that becomes a clickable affordance (underline + pointer cursor)
/// when [onTap] is provided — used to reopen the error details dialog.
class _StatusLabel extends StatelessWidget {
  const _StatusLabel({
    required this.text,
    required this.style,
    this.onTap,
  });

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
