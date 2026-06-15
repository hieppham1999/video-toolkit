import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/app/base/app_state.dart';
import 'package:video_toolkit/app/injection.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/widgets/app_error_dialog.dart';
import 'package:video_toolkit/features/app_settings/presentation/cubit/app_setting_cubit.dart';
import 'package:video_toolkit/features/app_settings/presentation/cubit/app_setting_state.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/preset_cubit.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/preset_state.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_cubit.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_state.dart';
import 'package:video_toolkit/app/base/bloc_state_builder.dart';

import '../cubit/preview_cubit.dart';
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
  final _importCubit = getIt<VideoImportCubit>();
  final _encodeCubit = getIt<VideoEncodeCubit>();
  final _presetCubit = getIt<PresetCubit>();
  final _previewCubit = getIt<PreviewCubit>();
  final _appSettingCubit = getIt<AppSettingCubit>();

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
    _importCubit.addFiles(paths);
  }

  void _onFilesDropped(List<String> paths) {
    _importCubit.addFiles(paths);
  }

  void _onDragStateChanged(bool isDragging) {
    _importCubit.setDragging(isDragging);
  }

  void _onRemoveFile(String path) {
    _importCubit.removeFile(path);
    _resetEncodeIfEmpty();
  }

  void _onClearAll() {
    _importCubit.clearAll();
    _resetEncodeIfEmpty();
  }

  void _resetEncodeIfEmpty() {
    if (_importCubit.currentData.files.isEmpty &&
        _encodeCubit.currentData.status != EncodeStatus.encoding) {
      _encodeCubit.reset();
    }
  }

  void _onDividerDrag(double dy) {
    setState(() {
      _previewFraction = (_previewFraction + dy).clamp(_minFraction, _maxFraction);
    });
  }

  void _onSelectVideo(String path) {
    _importCubit.selectVideo(path);
  }

  void _onSaveEncodeSettings(EncodeSettings settings) {
    _importCubit.updateEncodeSettings(settings);
  }

  void _onUpdateFileSettings(
    String path,
    EncodeSettings? settings,
    String? presetId,
  ) {
    _importCubit.updateFileSettings(path, settings, presetId);
  }

  void _onStart() {
    final importState = _importCubit.currentData;
    if (importState.files.isEmpty) return;

    _encodeCubit.startBatchEncode(
      files: importState.files,
      globalSettings: importState.encodeSettings,
      outputDirectory: _appSettingCubit.currentData.outputDirectory,
    );
  }

  void _onStop() {
    _encodeCubit.stop();
  }

  /// Builds a combined per-file error report and shows it in a copyable dialog.
  void _showEncodeErrors(BuildContext context, VideoEncodeState s) {
    if (s.failures.isEmpty) return;
    final l10n = Languages.translate;
    final details = s.failures
        .map((f) => '=== ${p.basename(f.filePath)} ===\n${f.message}')
        .join('\n\n');
    showAppErrorDialog(
      context: context,
      title: l10n.encodeErrorsTitle,
      message: l10n.encodeErrorsSummary(s.failures.length),
      details: details,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoEncodeCubit, CubitState<VideoEncodeState>>(
      bloc: _encodeCubit,
      listenWhen: (prev, cur) =>
          prev.data.status != EncodeStatus.error &&
          cur.data.status == EncodeStatus.error,
      listener: (context, state) => _showEncodeErrors(context, state.data),
      child: CubitStateBuilder<VideoImportState>(
        cubit: _importCubit,
      builder: (context, importState) {
        final selectedFile = importState.selectedFilePath != null
            ? importState.files.where((f) => f.path == importState.selectedFilePath).firstOrNull
            : null;

        final effectiveSettings =
            selectedFile?.overrideSettings ?? importState.encodeSettings;
        _previewCubit.requestStaticFrame(selectedFile, effectiveSettings);

        return CubitStateBuilder<VideoEncodeState>(
          cubit: _encodeCubit,
          builder: (context, encodeState) {
            final isEncoding = encodeState.status == EncodeStatus.encoding;

            return CubitStateBuilder<AppSettingState>(
              cubit: _appSettingCubit,
              builder: (context, appSettingState) {
                return CubitStateBuilder<PresetState>(
              cubit: _presetCubit,
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
                  outputDirectory: appSettingState.outputDirectory,
                  encodeState: encodeState,
                  currentPresetName: selectedPreset?.name,
                  isPresetModified: isPresetModified,
                  presets: presetState.presets,
                  globalSelectedPresetId: presetState.selectedId,
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
                  onShowEncodeErrors: encodeState.failures.isEmpty
                      ? null
                      : () => _showEncodeErrors(context, encodeState),
                );

                if (Platform.isWindows) return WindowsHomeRenderer(data: viewData);
                return MacosHomeRenderer(data: viewData);
              },
            );
              },
            );
          },
        );
      },
      ),
    );
  }
}
