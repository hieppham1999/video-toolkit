import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_encoding/data/datasources/user_settings_datasource.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_preset.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/output_directory_settings.dart';
import 'package:video_toolkit/features/video_metadata/data/repositories/video_metadata_repository.dart';
import 'package:video_toolkit/features/video_metadata/data/models/video_metadata.dart';
import 'package:video_toolkit/app/base/base_cubit.dart';

import '../../data/models/video_file.dart';
import '../../data/datasources/video_queue_datasource.dart';
import 'video_import_state.dart';

@lazySingleton
class VideoImportCubit extends BaseCubit<VideoImportState> {
  VideoImportCubit(
    this._metadataRepository,
    this._userSettings,
    this._videoQueue,
  ) : super.normal(const VideoImportState()) {
    _loadPersistedSettings();
    _restoreQueue();
  }

  final VideoMetadataRepository _metadataRepository;
  final UserSettingsDatasource _userSettings;
  final VideoQueueDatasource _videoQueue;

  Future<void> _loadPersistedSettings() async {
    final persisted = await _userSettings.load();
    final initialSettings =
        persisted?.encodeSettings ?? kBuiltInPresets.first.settings;
    emitNormal(currentData.copyWith(encodeSettings: initialSettings));
  }

  Future<void> _restoreQueue() async {
    final items = await _videoQueue.load();
    if (items.isEmpty || isClosed) return;
    addFiles(items.map((item) => item.path).toList(), persist: false);
    final byPath = {for (final item in items) item.path: item};
    final restored = currentData.files.map((file) {
      final item = byPath[file.path];
      return item == null
          ? file
          : file.copyWith(
              overrideSettings: item.overrideSettings,
              appliedPresetId: item.appliedPresetId,
              outputDirectoryOverride: item.outputDirectoryOverride,
            );
    }).toList();
    emitNormal(currentData.copyWith(files: restored));
    _persistQueue();
  }

  static const _videoExtensions = {
    '.mp4',
    '.mov',
    '.avi',
    '.mkv',
    '.wmv',
    '.flv',
    '.webm',
    '.m4v',
    '.ts',
    '.mts',
  };

  void addFiles(List<String> paths, {bool persist = true}) {
    final existing = currentData.files.map((f) => f.path).toSet();

    final newFiles = paths
        .where(
          (path) => _videoExtensions.contains(p.extension(path).toLowerCase()),
        )
        .where((path) => !existing.contains(path))
        .map((path) {
          final file = File(path);
          return VideoFile(
            path: path,
            name: p.basename(path),
            sizeInBytes: file.existsSync() ? file.lengthSync() : 0,
            importedAt: DateTime.now(),
            // Populate the Windows filesystem creation timestamp immediately
            // so filename previews do not wait for asynchronous CLI metadata.
            // The source is provisional, so do not label it _FILEDATE yet.
            // Metadata extraction will replace it and set the flag only when
            // no embedded creation date can be extracted.
            metadata: _initialFileCreateMetadata(file),
          );
        })
        .toList();

    if (newFiles.isEmpty) return;
    emitNormal(
      currentData.copyWith(files: [...currentData.files, ...newFiles]),
    );
    if (persist) _persistQueue();

    for (final f in newFiles) {
      _loadMetadata(f.path);
    }
  }

  VideoMetadata? _initialFileCreateMetadata(File file) {
    if (!Platform.isWindows || !file.existsSync()) return null;
    try {
      return VideoMetadata(creationDate: file.statSync().changed);
    } catch (_) {
      return null;
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
      appLogger.i(
        'VideoImportCubit: loaded metadata for $path (creationDate: ${metadata.creationDate})',
      );
    } catch (e) {
      appLogger.w('VideoImportCubit: metadata extraction failed for $path: $e');
    }
  }

  void removeFile(String path) {
    emitNormal(
      currentData.copyWith(
        files: currentData.files.where((f) => f.path != path).toList(),
        selectedFilePath: currentData.selectedFilePath == path
            ? null
            : currentData.selectedFilePath,
      ),
    );
    _persistQueue();
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
    emitNormal(
      currentData.copyWith(
        files: currentData.files.map((f) {
          if (f.path == path) {
            return f.copyWith(
              overrideSettings: settings,
              appliedPresetId: settings == null ? null : presetId,
            );
          }
          return f;
        }).toList(),
      ),
    );
    _persistQueue();
  }

  void updateFileOutputDirectory(
    String path,
    OutputDirectorySettings? settings,
  ) {
    emitNormal(
      currentData.copyWith(
        files: currentData.files.map((f) {
          if (f.path == path) {
            return f.copyWith(outputDirectoryOverride: settings);
          }
          return f;
        }).toList(),
      ),
    );
    _persistQueue();
  }

  void moveFile(String path, int delta) {
    final from = currentData.files.indexWhere((file) => file.path == path);
    if (from < 0) return;
    final to = (from + delta).clamp(0, currentData.files.length - 1);
    if (from == to) return;
    final files = [...currentData.files];
    final item = files.removeAt(from);
    files.insert(to, item);
    emitNormal(currentData.copyWith(files: files));
    _persistQueue();
  }

  void setDragging(bool value) {
    emitNormal(currentData.copyWith(isDragging: value));
  }

  void clearAll() {
    emitNormal(currentData.copyWith(files: [], selectedFilePath: null));
    _persistQueue();
  }

  void _persistQueue() {
    unawaited(_videoQueue.save(currentData.files));
  }
}
