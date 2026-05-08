import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';

import '../../data/models/video_file.dart';

part 'generated/video_import_state.freezed.dart';

@freezed
abstract class VideoImportState with _$VideoImportState {
  const factory VideoImportState({
    @Default([]) List<VideoFile> files,
    @Default(false) bool isDragging,
    @Default(null) String? selectedFilePath,
    @Default(EncodeSettings()) EncodeSettings encodeSettings,
  }) = _VideoImportState;
}
