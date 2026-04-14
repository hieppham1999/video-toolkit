import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/presentation/base/bloc_state_builder.dart';

import '../../../../../core/navigation/app_navigator.dart';
import '../../../../../core/navigation/app_routes.dart';
import '../../cubit/video_import_cubit.dart';
import '../../cubit/video_import_state.dart';

class WindowsImportPage extends StatelessWidget {
  const WindowsImportPage({super.key});

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
    return ScaffoldPage(
      header: const PageHeader(title: Text('Video Toolkit')),
      content: CubitStateBuilder<VideoImportState>(
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
            child: _DropZone(
              isDragging: state.isDragging,
              onPickFiles: () => _pickFiles(context),
            ),
          );
        },
      ),
    );
  }
}

class _DropZone extends StatelessWidget {
  const _DropZone({required this.isDragging, required this.onPickFiles});

  final bool isDragging;
  final VoidCallback onPickFiles;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final accent = theme.accentColor;

    return SizedBox.expand(
      child: ColoredBox(
        color: theme.micaBackgroundColor,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 480,
            height: 320,
            decoration: BoxDecoration(
              color: isDragging ? accent.withValues(alpha: 0.08) : theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDragging
                    ? accent
                    : theme.resources.controlStrokeColorDefault,
                width: isDragging ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FluentIcons.video,
                  size: 64,
                  color: isDragging
                      ? accent
                      : theme.resources.textFillColorSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  isDragging
                      ? Languages.translate.dropFilesHere
                      : Languages.translate.dragDropInstructions,
                  style: theme.typography.subtitle,
                ),
                const SizedBox(height: 8),
                Text(
                  Languages.translate.supportedFormats,
                  style: theme.typography.caption?.copyWith(
                    color: theme.resources.textFillColorSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(Languages.translate.or, style: theme.typography.body),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onPickFiles,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.add, size: 16),
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
