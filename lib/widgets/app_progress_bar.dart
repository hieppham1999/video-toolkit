import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

/// Cross-platform progress bar. [percent] is a fraction in 0..1.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final value = percent * 100;
    if (Platform.isWindows) {
      return fluent.ProgressBar(value: value);
    }
    return ProgressBar(value: value);
  }
}
