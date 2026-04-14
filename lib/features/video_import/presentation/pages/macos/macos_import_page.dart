import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/presentation/base/bloc_state_builder.dart';

import '../../../../../core/navigation/app_navigator.dart';
import '../../../../../core/navigation/app_routes.dart';
import '../../cubit/video_import_cubit.dart';
import '../../cubit/video_import_state.dart';

class MacosImportPage extends StatelessWidget {
  const MacosImportPage({super.key});

  Future<void> _pickFiles(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    if (result == null || !context.mounted) return;

    final paths = result.paths.whereType<String>().toList();
    final cubit = context.read<VideoImportCubit>();
    final prevCount = cubit.currentData.files.length;
    cubit.addFiles(paths);
    if (cubit.currentData.files.length > prevCount && context.mounted) {
      _navigateToList();
    }
  }

  void _navigateToList() {
    NavController.pushNamed(const VideoListRoute());
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: const ToolBar(
        title: Text('Video Toolkit'),
        titleWidth: 150,
      ),
      children: [
        ContentArea(
          builder: (context, _) {
            return CubitStateBuilder<VideoImportState>(
              cubit: context.read<VideoImportCubit>(),
              builder: (context, state) {
                return DropTarget(
                  onDragDone: (details) {
                    final paths = details.files.map((f) => f.path).toList();
                    final cubit = context.read<VideoImportCubit>();
                    final prevCount = cubit.currentData.files.length;
                    cubit.addFiles(paths);
                    if (cubit.currentData.files.length > prevCount) {
                      _navigateToList();
                    }
                  },
                  onDragEntered: (_) =>
                      context.read<VideoImportCubit>().setDragging(true),
                  onDragExited: (_) =>
                      context.read<VideoImportCubit>().setDragging(false),
                  child: _MacosDropZone(
                    isDragging: state.isDragging,
                    onPickFiles: () => _pickFiles(context),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _MacosDropZone extends StatelessWidget {
  const _MacosDropZone({required this.isDragging, required this.onPickFiles});

  final bool isDragging;
  final VoidCallback onPickFiles;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final accent = theme.primaryColor;

    return SizedBox.expand(
      child: ColoredBox(
        color: theme.canvasColor,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 480,
            height: 320,
            decoration: BoxDecoration(
              color: isDragging
                  ? accent.withValues(alpha: 0.08)
                  : MacosColors.windowBackgroundColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDragging ? accent : MacosColors.separatorColor,
                width: isDragging ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.film,
                  size: 64,
                  color: isDragging ? accent : MacosColors.secondaryLabelColor,
                ),
                const SizedBox(height: 16),
                Text(
                  isDragging
                      ? Languages.translate.dropFilesHere
                      : Languages.translate.dragDropInstructions,
                  style: theme.typography.title2,
                ),
                const SizedBox(height: 8),
                Text(
                  Languages.translate.supportedFormats,
                  style: theme.typography.caption1.copyWith(
                    color: MacosColors.secondaryLabelColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(Languages.translate.or, style: theme.typography.subheadline),
                const SizedBox(height: 16),
                PushButton(
                  controlSize: ControlSize.large,
                  onPressed: onPickFiles,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.add, size: 16),
                      const SizedBox(width: 8),
                      Text(Languages.translate.selectVideoFiles),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
