import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_state.dart';

/// Bottom-of-screen progress strip summarising the current batch encode.
/// Hidden when idle; colours + progress bar control adapt per platform.
class AppOverallProgressBar extends StatelessWidget {
  const AppOverallProgressBar({super.key, required this.encodeState});

  final VideoEncodeState encodeState;

  @override
  Widget build(BuildContext context) {
    final status = encodeState.status;
    if (status == EncodeStatus.idle) return const SizedBox.shrink();

    final total = encodeState.totalFiles;
    final current = encodeState.currentIndex;
    final completed = encodeState.completedCount;
    final failed = encodeState.failedFiles;
    final overallPercent = total > 0 ? current / total : 0.0;

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
      final isDark = theme.brightness == Brightness.dark;
      subtleText = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
      bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
      borderColor = isDark ? const Color(0xFF38383A) : const Color(0xFFD1D1D6);
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
        statusColor = const Color(0xFF34C759);
      case EncodeStatus.error:
        statusText = '$completed completed, ${failed.length} failed';
        statusColor = const Color(0xFFFF3B30);
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
                child: Text(
                  statusText,
                  style: (captionStyle ?? const TextStyle()).copyWith(color: statusColor),
                ),
              ),
              Text(
                '${(overallPercent * 100).toStringAsFixed(0)}%',
                style: captionStyle?.copyWith(color: subtleText),
              ),
            ],
          ),
          const SizedBox(height: 4),
          isWindows
              ? fluent.ProgressBar(value: overallPercent * 100)
              : ProgressBar(value: overallPercent * 100),
        ],
      ),
    );
  }
}
