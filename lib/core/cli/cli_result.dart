import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/cli_result.freezed.dart';

@freezed
abstract class CliResult with _$CliResult {
  const CliResult._();

  const factory CliResult({
    required String stdout,
    required String stderr,
    required int exitCode,
  }) = _CliResult;

  bool get isSuccess => exitCode == 0;
}
