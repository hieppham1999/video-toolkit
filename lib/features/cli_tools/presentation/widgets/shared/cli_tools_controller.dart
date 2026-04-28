import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:video_toolkit/core/cli/bundled_binary_resolver.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/cli_tools/data/cli_presets_data.dart';
import 'package:video_toolkit/features/cli_tools/domain/cli_preset.dart';
import 'package:video_toolkit/features/cli_tools/domain/cli_tool.dart';

enum CliOutputFormat { raw, json }

/// Shared state for the CLI Tools dialog on both macOS and Windows.
///
/// Owns:
/// - the currently selected tool (ffmpeg/ffprobe/exiftool)
/// - the editable args text (tool name + input path are rendered separately
///   as read-only segments by the view, never part of [argsController])
/// - output lines streamed from the running process (stdout + stderr merged)
/// - the active [Process] handle so Stop can kill it
class CliToolsController extends ChangeNotifier {
  CliToolsController({
    required this.inputPath,
    required BundledBinaryResolver resolver,
  }) : _resolver = resolver {
    argsController = TextEditingController();
    outputScrollController = ScrollController();
    _applyDefaultPresetForTool();
  }

  final String inputPath;
  final BundledBinaryResolver _resolver;

  late final TextEditingController argsController;
  late final ScrollController outputScrollController;

  CliTool tool = CliTool.exiftool;
  CliPreset? selectedPreset;

  final List<String> _output = <String>[];
  List<String> get output => List.unmodifiable(_output);

  /// The resolved command line for the most recent (or currently running)
  /// execution, shaped like `ffprobe -v quiet -show_streams /path/to/file`.
  /// Shown in its own header row with a copy button, separate from the
  /// stdout/stderr panel.
  String? _commandLine;
  String? get commandLine => _commandLine;

  /// Prospective command shown for copying. While a run is in flight, shows
  /// the exact command currently executing (includes any auto-injected JSON
  /// flag); otherwise reflects the current tool + edited args + format.
  String get previewCommandLine {
    if (_isRunning && _commandLine != null) return _commandLine!;
    final args = _buildFinalArgs();
    return '${tool.binaryName} ${args.map(_quoteIfNeeded).join(' ')}';
  }

  /// Resolve the current UI state into a `Process.start`-ready arg list,
  /// including the `{input}` substitution and the JSON flag when applicable.
  List<String> _buildFinalArgs() {
    final userArgs = _tokenizeArgs(argsController.text);
    final presetArgs = selectedPreset?.args;
    final baseArgs =
        (presetArgs != null && _matchesPresetShape(userArgs, presetArgs))
            ? presetArgs
                .map((a) => a == CliPreset.inputPlaceholder ? inputPath : a)
                .toList()
            : <String>[...userArgs, inputPath];
    return _injectJsonArgs(baseArgs);
  }

  /// Prepend [CliTool.jsonArgs] when JSON output is requested and the tool
  /// supports it, unless those tokens are already present. Prepending
  /// matters for ffprobe where `-print_format json` is a format directive,
  /// while exiftool's `-j` can go anywhere.
  List<String> _injectJsonArgs(List<String> args) {
    if (outputFormat != CliOutputFormat.json) return args;
    final flag = tool.jsonArgs;
    if (flag.isEmpty) return args;
    // Skip injection if any of the flag's tokens already appears.
    if (args.contains(flag.first)) return args;
    return [...flag, ...args];
  }

  CliOutputFormat outputFormat = CliOutputFormat.raw;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  int? _exitCode;
  int? get exitCode => _exitCode;

  Process? _activeProcess;
  StreamSubscription<String>? _stdoutSub;
  StreamSubscription<String>? _stderrSub;

  /// Plain output text joined with newlines (raw stdout/stderr stream).
  String get rawOutputText => _output.join('\n');

  /// [rawOutputText] pretty-printed when [outputFormat] is json and the raw
  /// text parses as JSON; otherwise returns [rawOutputText] unchanged.
  String get formattedOutputText {
    if (outputFormat != CliOutputFormat.json) return rawOutputText;
    final raw = rawOutputText.trim();
    if (raw.isEmpty) return rawOutputText;
    try {
      final decoded = jsonDecode(raw);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return rawOutputText;
    }
  }

  void setOutputFormat(CliOutputFormat v) {
    if (outputFormat == v) return;
    outputFormat = v;
    notifyListeners();
  }

  List<CliPreset> get presets => kBuiltInPresets[tool] ?? const [];

  void setTool(CliTool v) {
    if (tool == v) return;
    tool = v;
    selectedPreset = null;
    _applyDefaultPresetForTool();
    notifyListeners();
  }

  void _applyDefaultPresetForTool() {
    final list = presets;
    if (list.isEmpty) {
      argsController.text = '';
      return;
    }
    applyPreset(list.first);
  }

  void applyPreset(CliPreset preset) {
    selectedPreset = preset;
    argsController.text = _renderArgsForDisplay(preset.args);
    notifyListeners();
  }

  /// Build the arg string shown in the editor. Strips the `{input}` token —
  /// the file path is rendered as a separate read-only chip in the view.
  String _renderArgsForDisplay(List<String> args) {
    return args
        .where((a) => a != CliPreset.inputPlaceholder)
        .map(_quoteIfNeeded)
        .join(' ');
  }

  String _quoteIfNeeded(String token) {
    if (token.isEmpty) return '""';
    if (token.contains(' ') || token.contains('"')) {
      final escaped = token.replaceAll('"', r'\"');
      return '"$escaped"';
    }
    return token;
  }

  /// Tokenize the user-edited args string into a `Process.start`-style
  /// arg list, respecting simple double-quoted segments.
  List<String> _tokenizeArgs(String raw) {
    final result = <String>[];
    final buf = StringBuffer();
    var inQuotes = false;
    var escape = false;
    for (final ch in raw.runes) {
      final c = String.fromCharCode(ch);
      if (escape) {
        buf.write(c);
        escape = false;
        continue;
      }
      if (c == r'\') {
        escape = true;
        continue;
      }
      if (c == '"') {
        inQuotes = !inQuotes;
        continue;
      }
      if (!inQuotes && (c == ' ' || c == '\t' || c == '\n')) {
        if (buf.isNotEmpty) {
          result.add(buf.toString());
          buf.clear();
        }
        continue;
      }
      buf.write(c);
    }
    if (buf.isNotEmpty) result.add(buf.toString());
    return result;
  }

  void clearOutput() {
    _output.clear();
    _exitCode = null;
    notifyListeners();
  }

  Future<void> execute() async {
    if (_isRunning) return;

    final binaryPath = await _resolver.resolve(tool.binaryName);
    if (binaryPath == null) {
      _output
        ..clear()
        ..add('[error] binary not found: ${tool.binaryName}');
      notifyListeners();
      return;
    }

    final finalArgs = _buildFinalArgs();

    _output.clear();
    _exitCode = null;
    _commandLine =
        '${tool.binaryName} ${finalArgs.map(_quoteIfNeeded).join(' ')}';
    _isRunning = true;
    notifyListeners();

    appLogger.d('CliTools: $binaryPath ${finalArgs.join(' ')}');

    try {
      final process = await Process.start(binaryPath, finalArgs);
      _activeProcess = process;

      final stdoutDone = Completer<void>();
      final stderrDone = Completer<void>();

      _stdoutSub = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          _output.add(line);
          notifyListeners();
          _autoScroll();
        },
        onDone: () {
          if (!stdoutDone.isCompleted) stdoutDone.complete();
        },
        onError: (Object e) {
          if (!stdoutDone.isCompleted) stdoutDone.complete();
        },
        cancelOnError: false,
      );
      _stderrSub = process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          _output.add(line);
          notifyListeners();
          _autoScroll();
        },
        onDone: () {
          if (!stderrDone.isCompleted) stderrDone.complete();
        },
        onError: (Object e) {
          if (!stderrDone.isCompleted) stderrDone.complete();
        },
        cancelOnError: false,
      );

      final code = await process.exitCode;
      await Future.wait([stdoutDone.future, stderrDone.future]);
      _exitCode = code;
    } catch (e) {
      _output.add('[error] $e');
    } finally {
      _isRunning = false;
      _activeProcess = null;
      await _stdoutSub?.cancel();
      await _stderrSub?.cancel();
      _stdoutSub = null;
      _stderrSub = null;
      notifyListeners();
      _autoScroll();
    }
  }

  /// True when the user-edited args look like they still come from [preset]
  /// (same non-`{input}` tokens in the same order). Lets us keep the
  /// placeholder's position when building the command.
  bool _matchesPresetShape(List<String> userArgs, List<String> presetArgs) {
    final withoutPlaceholder =
        presetArgs.where((a) => a != CliPreset.inputPlaceholder).toList();
    if (withoutPlaceholder.length != userArgs.length) return false;
    for (var i = 0; i < userArgs.length; i++) {
      if (userArgs[i] != withoutPlaceholder[i]) return false;
    }
    return true;
  }

  void stop() {
    final p = _activeProcess;
    if (p == null) return;
    p.kill(ProcessSignal.sigterm);
  }

  void _autoScroll() {
    if (!outputScrollController.hasClients) return;
    // Jump on next frame — lines may not be laid out yet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!outputScrollController.hasClients) return;
      outputScrollController
          .jumpTo(outputScrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    stop();
    _stdoutSub?.cancel();
    _stderrSub?.cancel();
    argsController.dispose();
    outputScrollController.dispose();
    super.dispose();
  }
}
