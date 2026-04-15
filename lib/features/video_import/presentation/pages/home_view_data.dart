import 'package:flutter/widgets.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_import/data/models/video_file.dart';

/// All the data and callbacks a platform-specific home renderer needs.
/// The renderer is pure UI — zero logic, zero cubit access.
class HomeViewData {
  const HomeViewData({
    required this.files,
    required this.isDragging,
    required this.previewFraction,
    required this.selectedFile,
    required this.encodeSettings,
    required this.onPickFiles,
    required this.onSelectVideo,
    required this.onSaveEncodeSettings,
    required this.onFilesDropped,
    required this.onDragStateChanged,
    required this.onRemoveFile,
    required this.onClearAll,
    required this.onDividerDrag,
    required this.onStart,
    required this.onStop,
  });

  // ── State ──
  final List<VideoFile> files;
  final bool isDragging;
  final double previewFraction;
  final VideoFile? selectedFile;
  final EncodeSettings encodeSettings;

  // ── Callbacks ──
  final VoidCallback onPickFiles;
  final ValueChanged<String> onSelectVideo;
  final ValueChanged<EncodeSettings> onSaveEncodeSettings;
  final ValueChanged<List<String>> onFilesDropped;
  final ValueChanged<bool> onDragStateChanged;
  final ValueChanged<String> onRemoveFile;
  final VoidCallback onClearAll;
  final ValueChanged<double> onDividerDrag;
  final VoidCallback? onStart;
  final VoidCallback? onStop;

  bool get hasFiles => files.isNotEmpty;
}
