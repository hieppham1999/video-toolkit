import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_encoding/data/datasources/user_settings_datasource.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_preset.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_metadata/data/repositories/video_metadata_repository.dart';
import 'package:video_toolkit/app/base/base_cubit.dart';

import '../../data/models/video_file.dart';
import 'video_import_state.dart';

@lazySingleton
class VideoImportCubit extends BaseCubit<VideoImportState> {
  VideoImportCubit(this._metadataRepository, this._userSettings)
      : super.normal(const VideoImportState()) {
    _loadPersistedSettings();
  }

  final VideoMetadataRepository _metadataRepository;
  final UserSettingsDatasource _userSettings;

  Future<void> _loadPersistedSettings() async {
    final persisted = await _userSettings.load();
    final initialSettings =
        persisted?.encodeSettings ?? kBuiltInPresets.first.settings;
    emitNormal(currentData.copyWith(encodeSettings: initialSettings));
  }

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

    for (final f in newFiles) {
      _loadMetadata(f.path);
    }
  }

  Future<void> _loadMetadata(String path) async {
    try {
      final metadata = await _metadataRepository.extractMetadata(path);
      final idx = currentData.files.indexWhere((f) => f.path == path);
      if (idx == -1) return;
      final updated = [...currentData.files];
      updated[idx] = updated[idx].copyWith(metadata: metadata);
      emitNormal(currentData.copyWith(files: updated));
      appLogger.i('VideoImportCubit: loaded metadata for $path (creationDate: ${metadata.creationDate})');
    } catch (e) {
      appLogger.w('VideoImportCubit: metadata extraction failed for $path: $e');
    }
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
    _userSettings.saveEncodeSettings(settings);
  }

  void updateFileSettings(
    String path,
    EncodeSettings? settings,
    String? presetId,
  ) {
    emitNormal(currentData.copyWith(
      files: currentData.files.map((f) {
        if (f.path == path) {
          return f.copyWith(
            overrideSettings: settings,
            appliedPresetId: settings == null ? null : presetId,
          );
        }
        return f;
      }).toList(),
    ));
  }

  void setDragging(bool value) {
    emitNormal(currentData.copyWith(isDragging: value));
  }

  void clearAll() {
    emitNormal(currentData.copyWith(
      files: [],
      selectedFilePath: null,
    ));
  }
}
