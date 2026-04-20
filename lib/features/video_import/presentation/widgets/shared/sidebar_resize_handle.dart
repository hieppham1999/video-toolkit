import 'package:flutter/widgets.dart';

/// Vertical drag handle used between the preset sidebar and content area.
/// Shared by both platforms — only the 1px line color differs.
class SidebarResizeHandle extends StatelessWidget {
  const SidebarResizeHandle({
    super.key,
    required this.onDragDelta,
    required this.lineColor,
  });

  final ValueChanged<double> onDragDelta;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (d) => onDragDelta(d.delta.dx),
        child: SizedBox(
          width: 12,
          child: Center(child: Container(width: 1, color: lineColor)),
        ),
      ),
    );
  }
}
