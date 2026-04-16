import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_progress.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/repositories/video_encode_repository.dart';
import 'package:video_toolkit/features/video_import/data/models/video_file.dart';
import 'package:video_toolkit/presentation/base/base_cubit.dart';

import 'video_encode_state.dart';

@injectable
class VideoEncodeCubit extends BaseCubit<VideoEncodeState> {
  VideoEncodeCubit(this._repository) : super.normal(const VideoEncodeState());

  final VideoEncodeRepository _repository;
  StreamSubscription<void>? _encodeSub;
  bool _cancelled = false;

  List<VideoFile> _queue = [];
  late EncodeSettings _globalSettings;

  /// Start encoding all [files] sequentially.
  /// Each file uses its own [overrideSettings] if set, otherwise [globalSettings].
  Future<void> startBatchEncode({
    required List<VideoFile> files,
    required EncodeSettings globalSettings,
  }) async {
    if (files.isEmpty) return;
    await _encodeSub?.cancel();

    _queue = List.of(files);
    _globalSettings = globalSettings;
    _cancelled = false;

    emitNormal(currentData.copyWith(
      status: EncodeStatus.encoding,
      totalFiles: files.length,
      currentIndex: 0,
      completedCount: 0,
      failedFiles: [],
      errorMessage: null,
    ));

    await _encodeNext();
  }

  Future<void> _encodeNext() async {
    final index = currentData.currentIndex;
    if (_cancelled || index >= _queue.length) {
      _finish();
      return;
    }

    final file = _queue[index];
    final settings = file.overrideSettings ?? _globalSettings;
    final dir = p.dirname(file.path);
    final baseName = p.basenameWithoutExtension(file.path);
    final outputPath = p.join(dir, '${baseName}_encoded.${settings.outputExtension.value}');

    emitNormal(currentData.copyWith(
      currentFilePath: file.path,
      outputPath: outputPath,
      progress: const EncodeProgress(),
    ));

    final completer = Completer<bool>();

    _encodeSub = _repository
        .encode(
          inputPath: file.path,
          settings: settings,
          totalDuration: file.metadata?.duration ?? Duration.zero,
          creationDate: file.metadata?.creationDate,
        )
        .listen(
          (progress) {
            emitNormal(currentData.copyWith(progress: progress));
          },
          onError: (Object e) {
            appLogger.e('Encode error for ${file.name}: $e');
            completer.complete(false);
          },
          onDone: () {
            if (!completer.isCompleted) completer.complete(true);
          },
        );

    final success = await completer.future;

    if (_cancelled) return;

    emitNormal(currentData.copyWith(
      currentIndex: index + 1,
      completedCount: success ? currentData.completedCount + 1 : currentData.completedCount,
      failedFiles: success ? currentData.failedFiles : [...currentData.failedFiles, file.name],
    ));

    await _encodeNext();
  }

  void _finish() {
    final failed = currentData.failedFiles;
    emitNormal(currentData.copyWith(
      status: _cancelled
          ? EncodeStatus.idle
          : failed.isEmpty
              ? EncodeStatus.done
              : EncodeStatus.error,
      errorMessage: failed.isNotEmpty
          ? '${failed.length} file(s) failed: ${failed.join(', ')}'
          : null,
      currentFilePath: null,
    ));
  }

  void stop() {
    _cancelled = true;
    _encodeSub?.cancel();
    _finish();
  }

  void reset() {
    _encodeSub?.cancel();
    _cancelled = false;
    _queue = [];
    emitNormal(const VideoEncodeState());
  }

  @override
  Future<void> close() {
    _encodeSub?.cancel();
    return super.close();
  }
}
