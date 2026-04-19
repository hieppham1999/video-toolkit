import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Converts a ffmpeg-compatible color string to a Flutter [Color].
/// Accepts: named colors (white, black, red...), `#RRGGBB`, `#RRGGBBAA`,
/// `0xRRGGBB`, `RRGGBB`. Returns [Colors.white] on parse failure.
Color parseColor(String value) {
  final lower = value.trim().toLowerCase();
  final named = _namedColors[lower];
  if (named != null) return named;

  var s = lower.replaceAll('#', '').replaceAll('0x', '');
  // Strip alpha suffix like 'black@0.5' — caller handles named+alpha form elsewhere.
  final atIndex = s.indexOf('@');
  if (atIndex >= 0) s = s.substring(0, atIndex);

  try {
    if (s.length == 6) s = 'FF$s';
    if (s.length == 8) return Color(int.parse(s, radix: 16));
  } catch (_) {}
  return Colors.white;
}

/// Converts a Flutter [Color] to a ffmpeg hex string `#RRGGBB` (no alpha).
String colorToHex(Color color) {
  int toByte(double c) => (c * 255).round().clamp(0, 255);
  final r = toByte(color.r).toRadixString(16).padLeft(2, '0');
  final g = toByte(color.g).toRadixString(16).padLeft(2, '0');
  final b = toByte(color.b).toRadixString(16).padLeft(2, '0');
  return '#$r$g$b'.toUpperCase();
}

const _namedColors = <String, Color>{
  'white': Color(0xFFFFFFFF),
  'black': Color(0xFF000000),
  'red': Color(0xFFFF0000),
  'green': Color(0xFF00FF00),
  'blue': Color(0xFF0000FF),
  'yellow': Color(0xFFFFFF00),
  'cyan': Color(0xFF00FFFF),
  'magenta': Color(0xFFFF00FF),
  'gray': Color(0xFF808080),
  'orange': Color(0xFFFFA500),
};

/// Shows a color picker dialog and returns the selected color as `#RRGGBB`,
/// or null if cancelled.
Future<String?> pickColor(BuildContext context, {required String initial}) async {
  final initialColor = parseColor(initial);
  Color current = initialColor;

  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Pick a color'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: initialColor,
          onColorChanged: (c) => current = c,
          enableAlpha: false,
          labelTypes: const [],
          pickerAreaHeightPercent: 0.7,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(colorToHex(current)),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

/// A clickable color swatch button. Shows the current color as a filled
/// rectangle; tapping opens a picker dialog.
class ColorPickerButton extends StatelessWidget {
  const ColorPickerButton({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 80,
    this.height = 28,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = parseColor(value);
    final isDark = color.computeLuminance() < 0.5;
    return GestureDetector(
      onTap: () async {
        final picked = await pickColor(context, initial: value);
        if (picked != null) onChanged(picked);
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0x33000000)),
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
