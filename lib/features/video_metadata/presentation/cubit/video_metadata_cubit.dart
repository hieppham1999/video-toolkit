import 'package:injectable/injectable.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_import/data/models/video_file.dart';
import 'package:video_toolkit/features/video_metadata/data/repositories/video_metadata_repository.dart';
import 'package:video_toolkit/presentation/base/base_cubit.dart';

import 'video_metadata_state.dart';

@lazySingleton
class VideoMetadataCubit extends BaseCubit<VideoMetadataState> {
  VideoMetadataCubit(this._repository) : super.normal(const VideoMetadataState());

  final VideoMetadataRepository _repository;

  Future<void> checkToolAvailability() async {
    final results = await Future.wait([
      _repository.isExiftoolAvailable(),
      _repository.isFfprobeAvailable(),
    ]);
    emitNormal(currentData.copyWith(
      isExiftoolAvailable: results[0],
      isFfprobeAvailable: results[1],
    ));
  }

  Future<void> loadMetadata(String filePath) async {
    if (currentData.loadingPaths.contains(filePath)) return;

    emitNormal(currentData.copyWith(
      loadingPaths: {...currentData.loadingPaths, filePath},
    ));

    try {
      final metadata = await _repository.extractMetadata(filePath);
      emitNormal(currentData.copyWith(
        metadataByPath: {...currentData.metadataByPath, filePath: metadata},
        loadingPaths: currentData.loadingPaths.difference({filePath}),
      ));
    } catch (e) {
      appLogger.e('Failed to load metadata for $filePath: $e');
      emitNormal(currentData.copyWith(
        loadingPaths: currentData.loadingPaths.difference({filePath}),
      ));
    }
  }

  Future<void> loadMetadataForAll(List<VideoFile> files) async {
    await Future.wait(
      files
          .where((f) => !currentData.metadataByPath.containsKey(f.path))
          .map((f) => loadMetadata(f.path)),
    );
  }
}
