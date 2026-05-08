enum CliTool {
  ffmpeg('ffmpeg'),
  ffprobe('ffprobe', jsonArgs: ['-print_format', 'json']),
  exiftool('exiftool', jsonArgs: ['-j']);

  const CliTool(this.binaryName, {this.jsonArgs = const <String>[]});

  final String binaryName;

  /// Extra arg tokens the tool needs to produce JSON output. Empty if the
  /// tool has no native JSON mode (e.g. ffmpeg). Auto-injected by the
  /// controller when the user picks the JSON output format, and stripped
  /// on the way back if already present so we don't duplicate.
  final List<String> jsonArgs;
}
