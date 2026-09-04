import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

/// Cross-platform labeled dropdown.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.enabled = true,
    this.mainAxisSize = MainAxisSize.max,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T> onChanged;
  final bool enabled;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return _FluentDropdown<T>(
        label: label,
        value: value,
        items: items,
        itemLabel: itemLabel,
        onChanged: onChanged,
        enabled: enabled,
        mainAxisSize: mainAxisSize,
      );
    }
    return _MacosDropdown<T>(
      label: label,
      value: value,
      items: items,
      itemLabel: itemLabel,
      onChanged: onChanged,
      enabled: enabled,
      mainAxisSize: mainAxisSize,
    );
  }
}

class _MacosDropdown<T> extends StatelessWidget {
  const _MacosDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    required this.enabled,
    required this.mainAxisSize,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T> onChanged;
  final bool enabled;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Row(
        mainAxisSize: mainAxisSize,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: theme.typography.body),
          ),
          const SizedBox(width: 8),
          MacosPopupButton<T>(
            value: value,
            onChanged: enabled ? (v) => onChanged(v as T) : null,
            items: items
                .map(
                  (e) =>
                      MacosPopupMenuItem(value: e, child: Text(itemLabel(e))),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FluentDropdown<T> extends StatelessWidget {
  const _FluentDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    required this.enabled,
    required this.mainAxisSize,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T> onChanged;
  final bool enabled;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Row(
        mainAxisSize: mainAxisSize,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: theme.typography.body),
          ),
          const SizedBox(width: 8),
          fluent.ComboBox<T>(
            value: value,
            onChanged: enabled ? (v) => onChanged(v as T) : null,
            items: items
                .map(
                  (e) =>
                      fluent.ComboBoxItem(value: e, child: Text(itemLabel(e))),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
