import 'cli_result.dart';

abstract class CliToolRunner {
  Future<CliResult> run(
    String executable,
    List<String> args, {
    Duration timeout = const Duration(seconds: 30),
  });

  Future<bool> isAvailable(String executable);
}
