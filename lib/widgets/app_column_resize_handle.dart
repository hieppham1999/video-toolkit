import 'package:flutter/widgets.dart';

/// Thin vertical drag handle used between table columns. [width] should
/// match the sibling gap spacing used in the table layout.
class AppColumnResizeHandle extends StatelessWidget {
  const AppColumnResizeHandle({
    super.key,
    required this.dividerColor,
    required this.onDrag,
    this.width = 8.0,
  });

  final Color dividerColor;
  final ValueChanged<double> onDrag;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) => onDrag(d.delta.dx),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: SizedBox(
          width: width,
          height: double.infinity,
          child: Center(
            child: Container(width: 1, height: 16, color: dividerColor),
          ),
        ),
      ),
    );
  }
}
