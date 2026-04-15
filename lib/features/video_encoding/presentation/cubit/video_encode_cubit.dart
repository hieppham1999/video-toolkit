import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_preset.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/repositories/video_encode_repository.dart';
import 'package:video_toolkit/presentation/base/base_cubit.dart';

import 'video_encode_state.dart';

@injectable
class VideoEncodeCubit extends BaseCubit<VideoEncodeState> {
  VideoEncodeCubit(this._repository) : super.normal(const VideoEncodeState());

  final VideoEncodeRepository _repository;
  StreamSubscription<void>? _encodeSub;

  void selectPreset(EncodePreset preset) {
    emitNormal(currentData.copyWith(selectedPreset: preset));
  }

  Future<void> startEncode({
    required String inputPath,
    required Duration totalDuration,
    required EncodeSettings settings,
    String? outputDir,
  }) async {
    await _encodeSub?.cancel();

    final dir = outputDir ?? p.dirname(inputPath);
    final baseName = p.basenameWithoutExtension(inputPath);
    final outputPath = p.join(
      dir,
      '${baseName}_encoded.${currentData.selectedPreset.extension}',
    );

    emitNormal(currentData.copyWith(
      status: EncodeStatus.encoding,
      inputPath: inputPath,
      outputPath: outputPath,
      errorMessage: null,
    ));

    _encodeSub = _repository
        .encode(
          inputPath: inputPath,
          preset: currentData.selectedPreset,
          totalDuration: totalDuration,
          settings: settings,
          outputDir: outputDir,
        )
        .listen(
          (progress) {
            emitNormal(currentData.copyWith(progress: progress));
          },
          onError: (Object e) {
            appLogger.e('Encode error: $e');
            emitNormal(currentData.copyWith(
              status: EncodeStatus.error,
              errorMessage: e.toString(),
            ));
          },
          onDone: () {
            if (currentData.status == EncodeStatus.encoding) {
              emitNormal(currentData.copyWith(status: EncodeStatus.done));
            }
          },
        );
  }

  void reset() {
    _encodeSub?.cancel();
    emitNormal(const VideoEncodeState());
  }

  @override
  Future<void> close() {
    _encodeSub?.cancel();
    return super.close();
  }
}
