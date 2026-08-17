import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/app/base/app_state.dart';
import 'package:video_toolkit/app/injection.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/notifications/app_notification_service.dart';
import 'package:video_toolkit/core/system/system_power_service.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/widgets/app_error_dialog.dart';
import 'package:video_toolkit/widgets/app_power_action_countdown_dialog.dart';
import 'package:video_toolkit/widgets/app_success_dialog.dart';
import 'package:video_toolkit/features/app_settings/presentation/cubit/app_setting_cubit.dart';
import 'package:video_toolkit/features/app_settings/presentation/cubit/app_setting_state.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/datasources/encode_failure_log_writer.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/preset_cubit.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/preset_state.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_cubit.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_state.dart';
import 'package:video_toolkit/app/base/bloc_state_builder.dart';

import '../cubit/preview_cubit.dart';
import '../cubit/video_import_cubit.dart';
import '../cubit/video_import_state.dart';
import '../../domain/queue_completion_action.dart';
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
  final _systemPowerService = getIt<SystemPowerService>();
  final _failureLogWriter = getIt<EncodeFailureLogWriter>();

  QueueCompletionAction _queueCompletionAction = QueueCompletionAction.none;
  DateTime? _batchStartedAt;
  String? _lastFailureLogPath;

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
      _previewFraction = (_previewFraction + dy).clamp(
        _minFraction,
        _maxFraction,
      );
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

    _batchStartedAt = DateTime.now();
    _lastFailureLogPath = null;
    _encodeCubit.startBatchEncode(
      files: importState.files,
      globalSettings: importState.encodeSettings,
      outputDirectory: _appSettingCubit.currentData.outputDirectory,
    );
  }

  void _onStop() {
    setState(() {
      _queueCompletionAction = QueueCompletionAction.none;
      _batchStartedAt = null;
    });
    _encodeCubit.stop();
  }

  void _onQueueCompletionActionChanged(QueueCompletionAction action) {
    setState(() => _queueCompletionAction = action);
  }

  /// Builds a combined per-file error report and shows it in a copyable dialog.
  void _showEncodeErrors(
    BuildContext context,
    VideoEncodeState s, {
    String? logPath,
  }) {
    if (s.failures.isEmpty) return;
    final l10n = Languages.translate;
    var details = s.failures
        .map((f) => '=== ${p.basename(f.filePath)} ===\n${f.message}')
        .join('\n\n');
    if (logPath != null) {
      details = '${l10n.failureLogSavedAt(logPath)}\n\n$details';
    }
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
          (prev.data.status != EncodeStatus.error &&
              cur.data.status == EncodeStatus.error) ||
          (prev.data.status != EncodeStatus.done &&
              cur.data.status == EncodeStatus.done),
      listener: (context, state) =>
          unawaited(_handleEncodeFinished(context, state.data)),
      child: CubitStateBuilder<VideoImportState>(
        cubit: _importCubit,
        builder: (context, importState) {
          final selectedFile = importState.selectedFilePath != null
              ? importState.files
                    .where((f) => f.path == importState.selectedFilePath)
                    .firstOrNull
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
                      final isPresetModified =
                          selectedPreset != null &&
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
                        queueCompletionAction: _queueCompletionAction,
                        onPickFiles: _pickFiles,
                        onSelectVideo: _onSelectVideo,
                        onSaveEncodeSettings: _onSaveEncodeSettings,
                        onUpdateFileSettings: _onUpdateFileSettings,
                        onFilesDropped: _onFilesDropped,
                        onDragStateChanged: _onDragStateChanged,
                        onRemoveFile: _onRemoveFile,
                        onClearAll: _onClearAll,
                        onDividerDrag: _onDividerDrag,
                        onStart: importState.files.isEmpty || isEncoding
                            ? null
                            : _onStart,
                        onStop: isEncoding ? _onStop : null,
                        onQueueCompletionActionChanged:
                            _onQueueCompletionActionChanged,
                        onShowEncodeErrors: encodeState.failures.isEmpty
                            ? null
                            : () => _showEncodeErrors(
                                context,
                                encodeState,
                                logPath: _lastFailureLogPath,
                              ),
                      );

                      if (Platform.isWindows) {
                        return WindowsHomeRenderer(data: viewData);
                      }
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

  Future<void> _handleEncodeFinished(
    BuildContext context,
    VideoEncodeState state,
  ) async {
    final finishedAt = DateTime.now();
    final startedAt = _batchStartedAt ?? finishedAt;
    final action = _queueCompletionAction;

    if (mounted) {
      setState(() {
        _queueCompletionAction = QueueCompletionAction.none;
        _batchStartedAt = null;
      });
    }

    String? logPath;
    try {
      logPath = await _failureLogWriter.update(
        startedAt: startedAt,
        finishedAt: finishedAt,
        totalFiles: state.totalFiles,
        completedCount: state.completedCount,
        failures: state.failures,
        action: action,
      );
      if (mounted) {
        setState(() => _lastFailureLogPath = logPath);
      }
    } catch (error, stackTrace) {
      appLogger.e(
        'Unable to update the latest encode error log',
        error,
        stackTrace,
      );
      if (!mounted || !context.mounted) return;
      final l10n = Languages.translate;
      showAppErrorDialog(
        context: context,
        title: l10n.failureLogUpdateFailedTitle,
        message: l10n.failureLogUpdateFailedMessage,
        details: '$error\n\n$stackTrace',
      );
      return;
    }

    if (!mounted || !context.mounted) return;
    if (action == QueueCompletionAction.none) {
      _showEncodeResult(context, state, logPath: logPath);
      return;
    }

    final shouldExecute = await showAppPowerActionCountdownDialog(
      context: context,
      action: action,
      logPath: logPath,
    );
    if (!mounted || !context.mounted) return;

    if (!shouldExecute) {
      _showEncodeResult(context, state, logPath: logPath);
      return;
    }

    try {
      await _systemPowerService.execute(action);
    } catch (error, stackTrace) {
      appLogger.e('System power action failed', error, stackTrace);
      if (!mounted || !context.mounted) return;
      final l10n = Languages.translate;
      showAppErrorDialog(
        context: context,
        title: l10n.powerActionFailedTitle,
        message: l10n.powerActionFailedMessage,
        details: '$error\n\n$stackTrace',
      );
    }
  }

  void _showEncodeResult(
    BuildContext context,
    VideoEncodeState state, {
    String? logPath,
  }) {
    if (state.status == EncodeStatus.done) {
      _showEncodeCompleted(context, state);
    } else if (state.status == EncodeStatus.error) {
      _showEncodeErrors(context, state, logPath: logPath);
    }
  }

  void _showEncodeCompleted(BuildContext context, VideoEncodeState state) {
    final l10n = Languages.translate;
    final title = l10n.encodeCompletedTitle;
    final message = l10n.encodeCompletedSummary(state.completedCount);

    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      showAppSuccessDialog(context: context, title: title, message: message);
      return;
    }

    AppNotificationService.show(title: title, message: message);
  }
}
