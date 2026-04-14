import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/presentation/base/bloc_state_builder.dart';

import '../../../../../core/utils/file_size_formatter.dart';
import '../../../data/models/video_file.dart';
import '../../cubit/video_import_cubit.dart';
import '../../cubit/video_import_state.dart';

class MacosVideoListPage extends StatelessWidget {
  const MacosVideoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CubitStateBuilder<VideoImportState>(
      cubit: context.read<VideoImportCubit>(),
      builder: (context, state) {
        return MacosScaffold(
          toolBar: ToolBar(
            title: Text(Languages.translate.videoList),
            titleWidth: 200,
            leading: MacosBackButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              ToolBarIconButton(
                label: Languages.translate.addVideo,
                icon: const MacosIcon(CupertinoIcons.add_circled),
                onPressed: () => Navigator.of(context).pop(),
                showLabel: true,
              ),
              if (state.files.isNotEmpty)
                ToolBarIconButton(
                  label: Languages.translate.clearAll,
                  icon: const MacosIcon(CupertinoIcons.trash),
                  onPressed: () => _confirmClearAll(context),
                  showLabel: true,
                ),
            ],
          ),
          children: [
            ContentArea(
              builder: (context, scrollController) {
                if (state.files.isEmpty) {
                  return Center(child: Text(Languages.translate.noVideos));
                }
                return ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.files.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final file = state.files[index];
                    return _MacosVideoListItem(
                      file: file,
                      onDelete: () =>
                          context.read<VideoImportCubit>().removeFile(file.path),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmClearAll(BuildContext context) {
    showMacosAlertDialog<void>(
      context: context,
      builder: (_) => MacosAlertDialog(
        appIcon: const MacosIcon(CupertinoIcons.film, size: 56),
        title: Text(Languages.translate.clearAll),
        message: Text(Languages.translate.clearAllConfirmMessage),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () {
            context.read<VideoImportCubit>().clearAll();
            Navigator.of(context)
              ..pop()
              ..pop();
          },
          child: Text(Languages.translate.delete),
        ),
        secondaryButton: PushButton(
          controlSize: ControlSize.large,
          secondary: true,
          onPressed: () => Navigator.of(context).pop(),
          child: Text(Languages.translate.cancel),
        ),
      ),
    );
  }
}

class _MacosVideoListItem extends StatelessWidget {
  const _MacosVideoListItem({required this.file, required this.onDelete});

  final VideoFile file;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.canvasColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MacosColors.separatorColor),
      ),
      child: Row(
        children: [
          MacosIcon(
            CupertinoIcons.film,
            size: 32,
            color: theme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: theme.typography.headline,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${FileSizeFormatter.format(file.sizeInBytes)}  ·  ${_formatDate(file.importedAt)}',
                  style: theme.typography.caption1.copyWith(
                    color: MacosColors.secondaryLabelColor,
                  ),
                ),
              ],
            ),
          ),
          MacosIconButton(
            icon: const MacosIcon(CupertinoIcons.trash, size: 16),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year}  $h:$m';
  }
}
