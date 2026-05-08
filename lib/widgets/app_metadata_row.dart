import 'package:flutter/widgets.dart';

/// A `label  value` row used in the preview metadata list. Fixed-width
/// label column keeps values aligned across rows. Platform-agnostic —
/// callers supply their own [TextStyle]s.
class AppMetadataRow extends StatelessWidget {
  const AppMetadataRow({
    super.key,
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
    this.labelWidth = 120,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: labelWidth, child: Text(label, style: labelStyle)),
        Expanded(
          child: Text(value, style: valueStyle, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
