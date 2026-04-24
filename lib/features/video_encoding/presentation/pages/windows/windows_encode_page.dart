import 'package:fluent_ui/fluent_ui.dart';
import 'package:video_toolkit/app/injection.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_cubit.dart';
import 'package:video_toolkit/features/home/data/models/video_file.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_state.dart';
import 'package:video_toolkit/app/base/bloc_state_builder.dart';
import 'package:path/path.dart' as p;

class WindowsEncodePage extends StatelessWidget {
  const WindowsEncodePage({
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
        return ScaffoldPage(
          header: PageHeader(
            title: const Text('Encode Video'),
            commandBar: IconButton(
              icon: const Icon(FluentIcons.back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          content: Center(
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
                        files: [VideoFile(path: filePath, name: filePath.split(r'\').last, sizeInBytes: 0, importedAt: DateTime.now())],
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
          ),
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
    final theme = FluentTheme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(FluentIcons.video, size: 32, color: theme.accentColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fileName, style: theme.typography.bodyStrong),
                  const SizedBox(height: 4),
                  Text(
                    _formatDuration(duration),
                    style: theme.typography.caption?.copyWith(
                      color: theme.resources.textFillColorSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    final theme = FluentTheme.of(context);

    return switch (state.status) {
      EncodeStatus.idle => FilledButton(
          onPressed: onStart,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.play, size: 14),
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
                const ProgressRing(strokeWidth: 3),
                const SizedBox(width: 8),
                Text(
                  'Encoding... ${(state.progress.percent * 100).toStringAsFixed(1)}%',
                  style: theme.typography.bodyStrong,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ProgressBar(value: state.progress.percent * 100),
            const SizedBox(height: 8),
            Text(
              _progressDetail(state),
              style: theme.typography.caption?.copyWith(
                color: theme.resources.textFillColorSecondary,
              ),
            ),
          ],
        ),
      EncodeStatus.done => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(FluentIcons.check_mark, color: Colors.green),
                const SizedBox(width: 8),
                Text('Encode complete!', style: theme.typography.bodyStrong),
              ],
            ),
            if (state.outputPath != null) ...[
              const SizedBox(height: 4),
              Text(
                state.outputPath!,
                style: theme.typography.caption?.copyWith(
                  color: theme.resources.textFillColorSecondary,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Button(onPressed: onReset, child: const Text('Encode Another')),
          ],
        ),
      EncodeStatus.error => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(FluentIcons.error_badge, color: Colors.red),
                const SizedBox(width: 8),
                Text('Encode failed', style: theme.typography.bodyStrong),
              ],
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                state.errorMessage!,
                style: theme.typography.caption?.copyWith(
                  color: Colors.red,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Button(onPressed: onReset, child: const Text('Try Again')),
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
