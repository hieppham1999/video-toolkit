import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_metadata/data/models/video_metadata.dart';

part 'generated/video_file.freezed.dart';

@freezed
abstract class VideoFile with _$VideoFile {
  const factory VideoFile({
    required String path,
    required String name,
    required int sizeInBytes,
    required DateTime importedAt,
    VideoMetadata? metadata,
    /// Per-file encode settings override. Null = use global settings.
    EncodeSettings? overrideSettings,
    /// Preset id last selected in the per-file settings dialog.
    /// Null = file follows the globally selected preset.
    String? appliedPresetId,
  }) = _VideoFile;
}
