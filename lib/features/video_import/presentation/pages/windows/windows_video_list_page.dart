import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/presentation/base/bloc_state_builder.dart';

import '../../../../../core/utils/file_size_formatter.dart';
import '../../../data/models/video_file.dart';
import '../../cubit/video_import_cubit.dart';
import '../../cubit/video_import_state.dart';

class WindowsVideoListPage extends StatelessWidget {
  const WindowsVideoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CubitStateBuilder<VideoImportState>(
      cubit: context.read<VideoImportCubit>(),
      builder: (context, state) {
        return ScaffoldPage(
          header: PageHeader(
            title: Text(Languages.translate.videoList),
            commandBar: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Button(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Row(
                    children: [
                      const Icon(FluentIcons.add, size: 14),
                      const SizedBox(width: 6),
                      Text(Languages.translate.addVideo),
                    ],
                  ),
                ),
                if (state.files.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Button(
                    onPressed: () => _confirmClearAll(context),
                    child: Row(
                      children: [
                        const Icon(FluentIcons.delete, size: 14),
                        const SizedBox(width: 6),
                        Text(Languages.translate.clearAll),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          content: state.files.isEmpty
              ? Center(child: Text(Languages.translate.noVideos))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.files.length,
                  itemBuilder: (context, index) {
                    final file = state.files[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _VideoListItem(
                        file: file,
                        onDelete: () =>
                            context.read<VideoImportCubit>().removeFile(file.path),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => ContentDialog(
        title: Text(Languages.translate.clearAll),
        content: Text(Languages.translate.clearAllConfirmMessage),
        actions: [
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(Languages.translate.cancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<VideoImportCubit>().clearAll();
              Navigator.of(context)
                ..pop()
                ..pop();
            },
            child: Text(Languages.translate.delete),
          ),
        ],
      ),
    );
  }
}

class _VideoListItem extends StatelessWidget {
  const _VideoListItem({required this.file, required this.onDelete});

  final VideoFile file;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(FluentIcons.video, size: 32, color: theme.accentColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: theme.typography.bodyStrong,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${FileSizeFormatter.format(file.sizeInBytes)}  ·  ${_formatDate(file.importedAt)}',
                    style: theme.typography.caption?.copyWith(
                      color: theme.resources.textFillColorSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(FluentIcons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year}  $h:$m';
  }
}
