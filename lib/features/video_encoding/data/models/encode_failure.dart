import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/encode_failure.freezed.dart';

/// A single file that failed to encode, with the raw error detail (ffmpeg
/// stderr / exception text) so it can be surfaced to the user and copied.
@freezed
abstract class EncodeFailure with _$EncodeFailure {
  const factory EncodeFailure({
    required String filePath,
    required String message,
  }) = _EncodeFailure;
}
