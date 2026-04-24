import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

/// Cross-platform label + two side-by-side text fields separated by a
/// character (e.g. `W × H` or `N : D`).
class AppTwinField extends StatelessWidget {
  const AppTwinField({
    super.key,
    required this.label,
    required this.separator,
    required this.leftValue,
    required this.rightValue,
    required this.onLeftChanged,
    required this.onRightChanged,
    this.leftHint,
    this.rightHint,
  });

  final String label;
  final String separator;
  final String leftValue;
  final String rightValue;
  final ValueChanged<String> onLeftChanged;
  final ValueChanged<String> onRightChanged;
  final String? leftHint;
  final String? rightHint;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return _FluentTwinField(
        label: label,
        separator: separator,
        leftValue: leftValue,
        rightValue: rightValue,
        leftHint: leftHint,
        rightHint: rightHint,
        onLeftChanged: onLeftChanged,
        onRightChanged: onRightChanged,
      );
    }
    return _MacosTwinField(
      label: label,
      separator: separator,
      leftValue: leftValue,
      rightValue: rightValue,
      leftHint: leftHint,
      rightHint: rightHint,
      onLeftChanged: onLeftChanged,
      onRightChanged: onRightChanged,
    );
  }
}

class _MacosTwinField extends StatelessWidget {
  const _MacosTwinField({
    required this.label,
    required this.separator,
    required this.leftValue,
    required this.rightValue,
    required this.onLeftChanged,
    required this.onRightChanged,
    this.leftHint,
    this.rightHint,
  });

  final String label;
  final String separator;
  final String leftValue;
  final String rightValue;
  final ValueChanged<String> onLeftChanged;
  final ValueChanged<String> onRightChanged;
  final String? leftHint;
  final String? rightHint;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: theme.typography.body)),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: _InlineMacosField(
            value: leftValue,
            onChanged: onLeftChanged,
            hint: leftHint,
          ),
        ),
        SizedBox(
          width: 24,
          child: Center(child: Text(separator, style: theme.typography.body)),
        ),
        SizedBox(
          width: 90,
          child: _InlineMacosField(
            value: rightValue,
            onChanged: onRightChanged,
            hint: rightHint,
          ),
        ),
      ],
    );
  }
}

class _InlineMacosField extends StatefulWidget {
  const _InlineMacosField({
    required this.value,
    required this.onChanged,
    this.hint,
  });
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;

  @override
  State<_InlineMacosField> createState() => _InlineMacosFieldState();
}

class _InlineMacosFieldState extends State<_InlineMacosField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _InlineMacosField old) {
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
    return MacosTextField(
      controller: _controller,
      placeholder: widget.hint,
      onChanged: widget.onChanged,
    );
  }
}

class _FluentTwinField extends StatelessWidget {
  const _FluentTwinField({
    required this.label,
    required this.separator,
    required this.leftValue,
    required this.rightValue,
    required this.onLeftChanged,
    required this.onRightChanged,
    this.leftHint,
    this.rightHint,
  });

  final String label;
  final String separator;
  final String leftValue;
  final String rightValue;
  final ValueChanged<String> onLeftChanged;
  final ValueChanged<String> onRightChanged;
  final String? leftHint;
  final String? rightHint;

  @override
  Widget build(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: theme.typography.body)),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: _InlineFluentField(
            value: leftValue,
            onChanged: onLeftChanged,
            hint: leftHint,
          ),
        ),
        SizedBox(
          width: 24,
          child: Center(child: Text(separator, style: theme.typography.body)),
        ),
        SizedBox(
          width: 90,
          child: _InlineFluentField(
            value: rightValue,
            onChanged: onRightChanged,
            hint: rightHint,
          ),
        ),
      ],
    );
  }
}

class _InlineFluentField extends StatefulWidget {
  const _InlineFluentField({
    required this.value,
    required this.onChanged,
    this.hint,
  });
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;

  @override
  State<_InlineFluentField> createState() => _InlineFluentFieldState();
}

class _InlineFluentFieldState extends State<_InlineFluentField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _InlineFluentField old) {
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
    return fluent.TextBox(
      controller: _controller,
      placeholder: widget.hint,
      onChanged: widget.onChanged,
    );
  }
}
