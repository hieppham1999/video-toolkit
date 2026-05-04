import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';

/// Draggable divider for resizing adjacent panes. Works in both orientations:
/// - [Axis.horizontal] → a horizontal line that resizes stacked (top/bottom) panes
///   via vertical drag.
/// - [Axis.vertical] → a vertical line that resizes side-by-side (left/right) panes
///   via horizontal drag.
///
/// [onDrag] receives the delta along the drag axis (dy for horizontal, dx for vertical).
class AppResizableDivider extends StatelessWidget {
  const AppResizableDivider({
    super.key,
    required this.onDrag,
    this.axis = Axis.horizontal,
  });

  final ValueChanged<double> onDrag;
  final Axis axis;

  static const double _thickness = 6;
  static const double _handleLong = 36;
  static const double _handleShort = 3;

  @override
  Widget build(BuildContext context) {
    final Color dividerColor;
    if (Platform.isWindows) {
      dividerColor = fluent.FluentTheme.of(context).resources.controlStrokeColorDefault;
    } else {
      dividerColor = AppColors.divider(MacosTheme.of(context).brightness);
    }

    final isHorizontal = axis == Axis.horizontal;
    final cursor = isHorizontal ? SystemMouseCursors.resizeRow : SystemMouseCursors.resizeColumn;

    final handle = Container(
      width: isHorizontal ? _handleLong : _handleShort,
      height: isHorizontal ? _handleShort : _handleLong,
      decoration: BoxDecoration(
        color: dividerColor,
        borderRadius: BorderRadius.circular(_handleShort / 2),
      ),
    );

    final body = Container(
      width: isHorizontal ? null : _thickness,
      height: isHorizontal ? _thickness : null,
      color: dividerColor.withValues(alpha: 0.3),
      child: Center(child: handle),
    );

    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: isHorizontal ? (d) => onDrag(d.delta.dy) : null,
        onHorizontalDragUpdate: isHorizontal ? null : (d) => onDrag(d.delta.dx),
        child: body,
      ),
    );
  }
}
