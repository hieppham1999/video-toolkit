import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/presentation/base/base_cubit.dart';

import '../../data/models/video_file.dart';
import 'video_import_state.dart';

class VideoImportCubit extends BaseCubit<VideoImportState> {
  VideoImportCubit() : super.normal(const VideoImportState());

  static const _videoExtensions = {
    '.mp4', '.mov', '.avi', '.mkv', '.wmv',
    '.flv', '.webm', '.m4v', '.ts', '.mts',
  };

  void addFiles(List<String> paths) {
    final existing = currentData.files.map((f) => f.path).toSet();

    final newFiles = paths
        .where((path) => _videoExtensions.contains(p.extension(path).toLowerCase()))
        .where((path) => !existing.contains(path))
        .map((path) {
          final file = File(path);
          return VideoFile(
            path: path,
            name: p.basename(path),
            sizeInBytes: file.existsSync() ? file.lengthSync() : 0,
            importedAt: DateTime.now(),
          );
        })
        .toList();

    if (newFiles.isEmpty) return;
    emitNormal(currentData.copyWith(files: [...currentData.files, ...newFiles]));
  }

  void removeFile(String path) {
    emitNormal(currentData.copyWith(
      files: currentData.files.where((f) => f.path != path).toList(),
      selectedFilePath: currentData.selectedFilePath == path ? null : currentData.selectedFilePath,
    ));
  }

  void selectVideo(String path) {
    final newPath = currentData.selectedFilePath == path ? null : path;
    emitNormal(currentData.copyWith(selectedFilePath: newPath));
  }

  void updateEncodeSettings(EncodeSettings settings) {
    emitNormal(currentData.copyWith(encodeSettings: settings));
  }

  void setDragging(bool value) {
    emitNormal(currentData.copyWith(isDragging: value));
  }

  void clearAll() {
    emitNormal(const VideoImportState());
  }
}
