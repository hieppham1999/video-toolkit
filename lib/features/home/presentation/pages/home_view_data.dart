import 'package:flutter/widgets.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/output_directory_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/settings_preset.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_state.dart';
import 'package:video_toolkit/features/home/data/models/video_file.dart';

/// All the data and callbacks a platform-specific home renderer needs.
/// The renderer is pure UI — zero logic, zero cubit access.
class HomeViewData {
  const HomeViewData({
    required this.files,
    required this.isDragging,
    required this.previewFraction,
    required this.selectedFile,
    required this.encodeSettings,
    required this.outputDirectory,
    required this.encodeState,
    required this.currentPresetName,
    required this.isPresetModified,
    required this.presets,
    required this.globalSelectedPresetId,
    required this.onPickFiles,
    required this.onSelectVideo,
    required this.onSaveEncodeSettings,
    required this.onUpdateFileSettings,
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
  final OutputDirectorySettings outputDirectory;
  final VideoEncodeState encodeState;
  /// Name of the currently selected preset, null if no preset is selected.
  final String? currentPresetName;
  /// True when current [encodeSettings] differ from the selected preset's saved settings.
  final bool isPresetModified;
  /// All available presets (built-in + user). Used by the video table to look up
  /// the preset assigned to each row.
  final List<SettingsPreset> presets;
  /// Globally selected preset id (used as fallback when a file has no per-file
  /// preset selection of its own).
  final String? globalSelectedPresetId;

  // ── Callbacks ──
  final VoidCallback onPickFiles;
  final ValueChanged<String> onSelectVideo;
  final ValueChanged<EncodeSettings> onSaveEncodeSettings;
  /// (filePath, settings, presetId) — null settings = reset to global; presetId
  /// is the preset selected in the per-file dialog at save time.
  final void Function(
    String path,
    EncodeSettings? settings,
    String? presetId,
  ) onUpdateFileSettings;
  final ValueChanged<List<String>> onFilesDropped;
  final ValueChanged<bool> onDragStateChanged;
  final ValueChanged<String> onRemoveFile;
  final VoidCallback onClearAll;
  final ValueChanged<double> onDividerDrag;
  final VoidCallback? onStart;
  final VoidCallback? onStop;

  bool get hasFiles => files.isNotEmpty;
  bool get isEncoding => encodeState.status == EncodeStatus.encoding;
}
