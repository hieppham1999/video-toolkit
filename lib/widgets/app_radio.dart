import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

class AppRadio<T> extends StatelessWidget {
  const AppRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
  });

  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final Widget? label;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    final control = Platform.isWindows
        ? _FluentRadioDot(selected: selected)
        : MacosRadioButton<T>(
            value: value,
            groupValue: groupValue,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          );

    final labelStyle = Platform.isWindows
        ? fluent.FluentTheme.of(context).typography.body
        : MacosTheme.of(context).typography.body;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          control,
          if (label != null) ...[
            const SizedBox(width: 6),
            DefaultTextStyle(style: labelStyle ?? const TextStyle(), child: label!),
          ],
        ],
      ),
    );
  }
}

class _FluentRadioDot extends StatelessWidget {
  const _FluentRadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    final accent = theme.accentColor.defaultBrushFor(theme.brightness);
    final border = theme.resources.controlStrongStrokeColorDefault;
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? accent : border, width: 2),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                ),
              ),
            )
          : null,
    );
  }
}
