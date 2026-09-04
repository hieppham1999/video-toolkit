import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

/// Cross-platform labeled text field. The inner controller is owned so the
/// cursor position survives external [value] updates (e.g. bidirectional
/// linking on the Sizing tab).
class AppField extends StatelessWidget {
  const AppField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.enabled = true,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return _FluentField(
        label: label,
        value: value,
        onChanged: onChanged,
        hint: hint,
        enabled: enabled,
      );
    }
    return _MacosField(
      label: label,
      value: value,
      onChanged: onChanged,
      hint: hint,
      enabled: enabled,
    );
  }
}

class _MacosField extends StatefulWidget {
  const _MacosField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    required this.enabled,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final bool enabled;

  @override
  State<_MacosField> createState() => _MacosFieldState();
}

class _MacosFieldState extends State<_MacosField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _MacosField old) {
    super.didUpdateWidget(old);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(widget.label, style: theme.typography.body),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: MacosTextField(
            controller: _controller,
            placeholder: widget.hint,
            onChanged: widget.onChanged,
            enabled: widget.enabled,
          ),
        ),
      ],
    );
  }
}

class _FluentField extends StatefulWidget {
  const _FluentField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    required this.enabled,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final bool enabled;

  @override
  State<_FluentField> createState() => _FluentFieldState();
}

class _FluentFieldState extends State<_FluentField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _FluentField old) {
    super.didUpdateWidget(old);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(widget.label, style: theme.typography.body),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: fluent.TextBox(
            controller: _controller,
            placeholder: widget.hint,
            onChanged: widget.onChanged,
            enabled: widget.enabled,
          ),
        ),
      ],
    );
  }
}
