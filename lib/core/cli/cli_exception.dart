sealed class CliException implements Exception {
  const CliException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class ToolNotFoundException extends CliException {
  const ToolNotFoundException(String tool)
      : super('$tool not found. Please install it and ensure it is on your PATH.');
}

class ToolExecutionException extends CliException {
  const ToolExecutionException({
    required String tool,
    required this.exitCode,
    required this.stderr,
  }) : super('$tool exited with code $exitCode');

  final int exitCode;
  final String stderr;
}

class ToolTimeoutException extends CliException {
  ToolTimeoutException(String tool, Duration timeout)
      : super('$tool timed out after ${timeout.inSeconds}s');
}
