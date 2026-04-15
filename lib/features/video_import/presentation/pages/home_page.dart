import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
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
  }

  void _onClearAll() {
    context.read<VideoImportCubit>().clearAll();
  }

  void _onDividerDrag(double dy) {
    setState(() {
      // We need the total height to compute the fraction delta.
      // Since LayoutBuilder is inside the renderer, pass raw dy
      // and let it be applied relative to total height.
      _previewFraction = (_previewFraction + dy).clamp(_minFraction, _maxFraction);
    });
  }

  void _onSelectVideo(String path) {
    context.read<VideoImportCubit>().selectVideo(path);
  }

  void _onSaveEncodeSettings(EncodeSettings settings) {
    context.read<VideoImportCubit>().updateEncodeSettings(settings);
  }

  @override
  Widget build(BuildContext context) {
    return CubitStateBuilder<VideoImportState>(
      cubit: context.read<VideoImportCubit>(),
      builder: (context, state) {
        final selectedFile = state.selectedFilePath != null
            ? state.files.where((f) => f.path == state.selectedFilePath).firstOrNull
            : null;

        final viewData = HomeViewData(
          files: state.files,
          isDragging: state.isDragging,
          previewFraction: _previewFraction,
          selectedFile: selectedFile,
          encodeSettings: state.encodeSettings,
          onPickFiles: _pickFiles,
          onSelectVideo: _onSelectVideo,
          onSaveEncodeSettings: _onSaveEncodeSettings,
          onFilesDropped: _onFilesDropped,
          onDragStateChanged: _onDragStateChanged,
          onRemoveFile: _onRemoveFile,
          onClearAll: _onClearAll,
          onDividerDrag: _onDividerDrag,
          onStart: state.files.isEmpty ? null : () { /* TODO: start encode */ },
          onStop: null,
          // onEncodeSettings removed — renderer opens dialog and calls onSaveEncodeSettings
        );

        if (Platform.isWindows) return WindowsHomeRenderer(data: viewData);
        return MacosHomeRenderer(data: viewData);
      },
    );
  }
}
