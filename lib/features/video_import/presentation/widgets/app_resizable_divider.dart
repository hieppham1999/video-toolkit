import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';

/// Horizontal draggable divider used to resize stacked panes. Reports
/// vertical drag delta via [onDrag].
class AppResizableDivider extends StatelessWidget {
  const AppResizableDivider({super.key, required this.onDrag});

  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    final Color dividerColor;
    if (Platform.isWindows) {
      dividerColor = fluent.FluentTheme.of(context).resources.controlStrokeColorDefault;
    } else {
      dividerColor = AppColors.divider(MacosTheme.of(context).brightness);
    }

    return GestureDetector(
      onVerticalDragUpdate: (d) => onDrag(d.delta.dy),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: Container(
          height: 6,
          color: dividerColor.withValues(alpha: 0.3),
          child: Center(
            child: Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: dividerColor,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
