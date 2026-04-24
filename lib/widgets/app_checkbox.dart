import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      final theme = fluent.FluentTheme.of(context);
      return fluent.Checkbox(
        checked: value,
        onChanged: enabled ? (v) => onChanged(v ?? false) : null,
        content: label == null
            ? null
            : DefaultTextStyle(
                style: theme.typography.body ?? const TextStyle(),
                child: label!,
              ),
      );
    }
    final theme = MacosTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => onChanged(!value) : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MacosCheckboxDot(checked: value, theme: theme),
            if (label != null) ...[
              const SizedBox(width: 6),
              DefaultTextStyle(style: theme.typography.body, child: label!),
            ],
          ],
        ),
      ),
    );
  }
}

class _MacosCheckboxDot extends StatelessWidget {
  const _MacosCheckboxDot({required this.checked, required this.theme});

  final bool checked;
  final MacosThemeData theme;

  @override
  Widget build(BuildContext context) {
    final accent = theme.primaryColor;
    final border = theme.brightness == Brightness.dark
        ? const Color(0xFF6E6E6E)
        : const Color(0xFFB4B4B4);
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: checked ? accent : (theme.brightness == Brightness.dark
            ? const Color(0xFF2D2D2D)
            : const Color(0xFFFFFFFF)),
        border: Border.all(color: checked ? accent : border, width: 1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: checked
          ? const Center(
              child: Icon(
                CupertinoIcons.checkmark,
                size: 12,
                color: Color(0xFFFFFFFF),
              ),
            )
          : null,
    );
  }
}
