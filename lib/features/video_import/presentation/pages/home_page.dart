import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/preset_cubit.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/preset_state.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_cubit.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_state.dart';
import 'package:video_toolkit/presentation/base/bloc_state_builder.dart';

import '../cubit/video_import_cubit.dart';
import '../cubit/video_import_state.dart';
import 'home_view_data.dart';
import 'macos/macos_home_renderer.dart';
import 'windows/windows_home_renderer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _previewFraction = 0.6;
  static const _minFraction = 0.2;
  static const _maxFraction = 0.85;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    if (result == null || !mounted) return;
    final paths = result.paths.whereType<String>().toList();
    context.read<VideoImportCubit>().addFiles(paths);
  }

  void _onFilesDropped(List<String> paths) {
    context.read<VideoImportCubit>().addFiles(paths);
  }

  void _onDragStateChanged(bool isDragging) {
    context.read<VideoImportCubit>().setDragging(isDragging);
  }

  void _onRemoveFile(String path) {
    context.read<VideoImportCubit>().removeFile(path);
    _resetEncodeIfEmpty();
  }

  void _onClearAll() {
    context.read<VideoImportCubit>().clearAll();
    _resetEncodeIfEmpty();
  }

  void _resetEncodeIfEmpty() {
    final importCubit = context.read<VideoImportCubit>();
    final encodeCubit = context.read<VideoEncodeCubit>();
    if (importCubit.currentData.files.isEmpty &&
        encodeCubit.currentData.status != EncodeStatus.encoding) {
      encodeCubit.reset();
    }
  }

  void _onDividerDrag(double dy) {
    setState(() {
      _previewFraction = (_previewFraction + dy).clamp(_minFraction, _maxFraction);
    });
  }

  void _onSelectVideo(String path) {
    context.read<VideoImportCubit>().selectVideo(path);
  }

  void _onSaveEncodeSettings(EncodeSettings settings) {
    context.read<VideoImportCubit>().updateEncodeSettings(settings);
  }

  void _onUpdateFileSettings(String path, EncodeSettings? settings) {
    context.read<VideoImportCubit>().updateFileSettings(path, settings);
  }

  void _onStart() {
    final importState = context.read<VideoImportCubit>().currentData;
    if (importState.files.isEmpty) return;

    context.read<VideoEncodeCubit>().startBatchEncode(
      files: importState.files,
      globalSettings: importState.encodeSettings,
    );
  }

  void _onStop() {
    context.read<VideoEncodeCubit>().stop();
  }

  @override
  Widget build(BuildContext context) {
    return CubitStateBuilder<VideoImportState>(
      cubit: context.read<VideoImportCubit>(),
      builder: (context, importState) {
        final selectedFile = importState.selectedFilePath != null
            ? importState.files.where((f) => f.path == importState.selectedFilePath).firstOrNull
            : null;

        return CubitStateBuilder<VideoEncodeState>(
          cubit: context.read<VideoEncodeCubit>(),
          builder: (context, encodeState) {
            final isEncoding = encodeState.status == EncodeStatus.encoding;

            return CubitStateBuilder<PresetState>(
              cubit: context.read<PresetCubit>(),
              builder: (context, presetState) {
                final selectedPreset = presetState.selectedId == null
                    ? null
                    : presetState.presets
                        .where((p) => p.id == presetState.selectedId)
                        .firstOrNull;
                final isPresetModified = selectedPreset != null &&
                    selectedPreset.settings != importState.encodeSettings;

                final viewData = HomeViewData(
                  files: importState.files,
                  isDragging: importState.isDragging,
                  previewFraction: _previewFraction,
                  selectedFile: selectedFile,
                  encodeSettings: importState.encodeSettings,
                  encodeState: encodeState,
                  currentPresetName: selectedPreset?.name,
                  isPresetModified: isPresetModified,
                  onPickFiles: _pickFiles,
                  onSelectVideo: _onSelectVideo,
                  onSaveEncodeSettings: _onSaveEncodeSettings,
                  onUpdateFileSettings: _onUpdateFileSettings,
                  onFilesDropped: _onFilesDropped,
                  onDragStateChanged: _onDragStateChanged,
                  onRemoveFile: _onRemoveFile,
                  onClearAll: _onClearAll,
                  onDividerDrag: _onDividerDrag,
                  onStart: importState.files.isEmpty || isEncoding ? null : _onStart,
                  onStop: isEncoding ? _onStop : null,
                );

                if (Platform.isWindows) return WindowsHomeRenderer(data: viewData);
                return MacosHomeRenderer(data: viewData);
              },
            );
          },
        );
      },
    );
  }
}
