import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/home/data/models/video_file.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/output_directory_settings.dart';

class PersistedVideoQueueItem {
  const PersistedVideoQueueItem({
    required this.path,
    this.overrideSettings,
    this.appliedPresetId,
    this.outputDirectoryOverride,
  });

  final String path;
  final EncodeSettings? overrideSettings;
  final String? appliedPresetId;
  final OutputDirectorySettings? outputDirectoryOverride;

  factory PersistedVideoQueueItem.fromJson(Map<String, dynamic> json) {
    final settingsJson = json['overrideSettings'];
    final outputJson = json['outputDirectoryOverride'];
    return PersistedVideoQueueItem(
      path: json['path'] as String,
      overrideSettings: settingsJson is Map<String, dynamic>
          ? EncodeSettings.fromJson(settingsJson)
          : null,
      appliedPresetId: json['appliedPresetId'] as String?,
      outputDirectoryOverride: outputJson is Map<String, dynamic>
          ? OutputDirectorySettings.fromJson(outputJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'path': path,
    if (overrideSettings != null)
      'overrideSettings': overrideSettings!.toJson(),
    if (appliedPresetId != null) 'appliedPresetId': appliedPresetId,
    if (outputDirectoryOverride != null)
      'outputDirectoryOverride': outputDirectoryOverride!.toJson(),
  };
}

/// Persists the pending queue separately from app preferences so a large list
/// can be restored after an app restart without bloating user_settings.json.
@lazySingleton
class VideoQueueDatasource {
  Future<File> _file() async {
    final support = await getApplicationSupportDirectory();
    return File(p.join(support.path, 'video_queue.json'));
  }

  Future<List<PersistedVideoQueueItem>> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return const [];
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return const [];
      final items = <PersistedVideoQueueItem>[];
      for (final value in decoded) {
        try {
          if (value is Map<String, dynamic>) {
            final item = PersistedVideoQueueItem.fromJson(value);
            if (File(item.path).existsSync()) items.add(item);
          }
        } catch (e) {
          appLogger.w('VideoQueueDatasource: skipped invalid item: $e');
        }
      }
      return items;
    } catch (e) {
      appLogger.w('VideoQueueDatasource: load failed: $e');
      return const [];
    }
  }

  Future<void> save(List<VideoFile> files) async {
    try {
      final file = await _file();
      await file.parent.create(recursive: true);
      final items = files
          .map(
            (video) => PersistedVideoQueueItem(
              path: video.path,
              overrideSettings: video.overrideSettings,
              appliedPresetId: video.appliedPresetId,
              outputDirectoryOverride: video.outputDirectoryOverride,
            ).toJson(),
          )
          .toList();
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(items),
      );
    } catch (e) {
      appLogger.w('VideoQueueDatasource: save failed: $e');
    }
  }
}
