import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/injection.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_cubit.dart';
import 'package:video_toolkit/features/video_import/data/models/video_file.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_state.dart';
import 'package:video_toolkit/presentation/base/bloc_state_builder.dart';
import 'package:path/path.dart' as p;

class MacosEncodePage extends StatelessWidget {
  const MacosEncodePage({
    super.key,
    required this.filePath,
    required this.totalDuration,
  });

  final String filePath;
  final Duration totalDuration;

  @override
  Widget build(BuildContext context) {
    return CubitStateBuilder<VideoEncodeState>(
      cubit: getIt<VideoEncodeCubit>(),
      builder: (context, state) {
        return MacosScaffold(
          toolBar: ToolBar(
            title: const Text('Encode Video'),
            titleWidth: 200,
            leading: MacosBackButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          children: [
            ContentArea(
              builder: (context, _) {
                return Center(
                  child: SizedBox(
                    width: 520,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // File info
                        _FileInfoCard(
                          fileName: p.basename(filePath),
                          duration: totalDuration,
                        ),
                        const SizedBox(height: 24),

                        // Action / Progress
                        _EncodeAction(
                          state: state,
                          onStart: () {
                            getIt<VideoEncodeCubit>().startBatchEncode(
                              files: [VideoFile(path: filePath, name: filePath.split('/').last, sizeInBytes: 0, importedAt: DateTime.now())],
                              globalSettings: const EncodeSettings(),
                            );
                          },
                          onReset: () {
                            getIt<VideoEncodeCubit>().reset();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _FileInfoCard extends StatelessWidget {
  const _FileInfoCard({required this.fileName, required this.duration});

  final String fileName;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.canvasColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider(theme.brightness)),
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
                Text(fileName, style: theme.typography.headline),
                const SizedBox(height: 4),
                Text(
                  _formatDuration(duration),
                  style: theme.typography.caption1.copyWith(
                    color: AppColors.textSecondary(theme.brightness),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

class _EncodeAction extends StatelessWidget {
  const _EncodeAction({
    required this.state,
    required this.onStart,
    required this.onReset,
  });

  final VideoEncodeState state;
  final VoidCallback onStart;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);

    return switch (state.status) {
      EncodeStatus.idle => PushButton(
          controlSize: ControlSize.large,
          onPressed: onStart,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.play_fill, size: 14),
              SizedBox(width: 8),
              Text('Start Encode'),
            ],
          ),
        ),
      EncodeStatus.encoding => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CupertinoActivityIndicator(radius: 8),
                const SizedBox(width: 8),
                Text(
                  'Encoding... ${(state.progress.percent * 100).toStringAsFixed(1)}%',
                  style: theme.typography.headline,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ProgressBar(value: state.progress.percent * 100),
            const SizedBox(height: 8),
            Text(
              _progressDetail(state),
              style: theme.typography.caption1.copyWith(
                color: AppColors.textSecondary(theme.brightness),
              ),
            ),
          ],
        ),
      EncodeStatus.done => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const MacosIcon(CupertinoIcons.checkmark_circle_fill,
                    color: CupertinoColors.systemGreen),
                const SizedBox(width: 8),
                Text('Encode complete!', style: theme.typography.headline),
              ],
            ),
            if (state.outputPath != null) ...[
              const SizedBox(height: 4),
              Text(
                state.outputPath!,
                style: theme.typography.caption1.copyWith(
                  color: AppColors.textSecondary(theme.brightness),
                ),
              ),
            ],
            const SizedBox(height: 16),
            PushButton(
              controlSize: ControlSize.large,
              secondary: true,
              onPressed: onReset,
              child: const Text('Encode Another'),
            ),
          ],
        ),
      EncodeStatus.error => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const MacosIcon(CupertinoIcons.xmark_circle_fill,
                    color: CupertinoColors.systemRed),
                const SizedBox(width: 8),
                Text('Encode failed', style: theme.typography.headline),
              ],
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                state.errorMessage!,
                style: theme.typography.caption1.copyWith(
                  color: CupertinoColors.systemRed,
                ),
              ),
            ],
            const SizedBox(height: 16),
            PushButton(
              controlSize: ControlSize.large,
              secondary: true,
              onPressed: onReset,
              child: const Text('Try Again'),
            ),
          ],
        ),
    };
  }

  String _progressDetail(VideoEncodeState state) {
    final parts = <String>[];
    if (state.progress.fps > 0) {
      parts.add('${state.progress.fps.toStringAsFixed(0)} fps');
    }
    if (state.progress.speed > 0) {
      parts.add('${state.progress.speed.toStringAsFixed(1)}x speed');
    }
    if (state.progress.estimatedRemaining != null) {
      final rem = state.progress.estimatedRemaining!;
      final m = rem.inMinutes.remainder(60);
      final s = rem.inSeconds.remainder(60);
      parts.add('~${m}m ${s}s remaining');
    }
    return parts.join('  ·  ');
  }
}
