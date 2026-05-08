import 'package:video_toolkit/features/cli_tools/domain/cli_tool.dart';

/// A built-in preset command for a given CLI tool.
///
/// [args] is the arg list as passed to `Process.start` — already tokenized
/// so shell-quoting is never needed. The special token `{input}` is replaced
/// with the video file path at execution time.
class CliPreset {
  const CliPreset({
    required this.tool,
    required this.label,
    required this.args,
  });

  final CliTool tool;
  final String label;
  final List<String> args;

  static const String inputPlaceholder = '{input}';
}
