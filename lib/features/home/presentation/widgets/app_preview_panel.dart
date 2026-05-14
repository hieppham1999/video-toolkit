import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/features/home/presentation/cubit/preview_state.dart';

class AppPreviewPanel extends StatelessWidget {
  const AppPreviewPanel({super.key, required this.state});

  final PreviewState state;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) return _FluentPreviewPanel(state: state);
    return _MacosPreviewPanel(state: state);
  }
}

class _MacosPreviewPanel extends StatelessWidget {
  const _MacosPreviewPanel({required this.state});

  final PreviewState state;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final b = theme.brightness;
    final subtleText = AppColors.textTertiary(b);
    final borderColor = AppColors.divider(b);

    return _PreviewShell(
      borderColor: borderColor,
      badgeColor: AppColors.error,
      badgeTextStyle: theme.typography.caption1.copyWith(
        color: const Color(0xFFFFFFFF),
        fontWeight: FontWeight.w600,
      ),
      captionStyle: theme.typography.caption1.copyWith(color: subtleText),
      placeholder: _PlaceholderContent(
        icon: MacosIcon(CupertinoIcons.film, size: 64, color: subtleText),
        label: _labelText(state),
        captionStyle: theme.typography.caption1.copyWith(color: subtleText),
      ),
      loadingIndicator: const ProgressCircle(),
      state: state,
    );
  }
}

class _FluentPreviewPanel extends StatelessWidget {
  const _FluentPreviewPanel({required this.state});

  final PreviewState state;

  @override
  Widget build(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    final subtleText = theme.resources.textFillColorSecondary;
    final borderColor = theme.resources.controlStrokeColorDefault;

    return _PreviewShell(
      borderColor: borderColor,
      badgeColor: AppColors.error,
      badgeTextStyle: theme.typography.caption!.copyWith(
        color: const Color(0xFFFFFFFF),
        fontWeight: FontWeight.w600,
      ),
      captionStyle: theme.typography.caption!.copyWith(color: subtleText),
      placeholder: _PlaceholderContent(
        icon: Icon(fluent.FluentIcons.video, size: 64, color: subtleText),
        label: _labelText(state),
        captionStyle: theme.typography.caption!.copyWith(color: subtleText),
      ),
      loadingIndicator: const fluent.ProgressRing(),
      state: state,
    );
  }
}

/// Shared layout used by both platform variants. Stateless — looks at the
/// [PreviewState] to decide which inner widget to show (image / loading /
/// placeholder) and overlays a LIVE badge when [PreviewState.isLive].
class _PreviewShell extends StatelessWidget {
  const _PreviewShell({
    required this.state,
    required this.placeholder,
    required this.loadingIndicator,
    required this.borderColor,
    required this.badgeColor,
    required this.badgeTextStyle,
    required this.captionStyle,
  });

  final PreviewState state;
  final Widget placeholder;
  final Widget loadingIndicator;
  final Color borderColor;
  final Color badgeColor;
  final TextStyle badgeTextStyle;
  final TextStyle captionStyle;

  @override
  Widget build(BuildContext context) {
    final framePath = state.framePath;
    Widget body;
    if (framePath != null && File(framePath).existsSync()) {
      body = _SmoothFileImage(
        path: framePath,
        revision: state.frameRevision,
        fallback: state.isLoading
            ? Center(child: loadingIndicator)
            : Center(child: placeholder),
      );
    } else if (state.isLoading) {
      body = Center(child: loadingIndicator);
    } else {
      body = Center(child: placeholder);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          body,
          if (state.isLive)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  Languages.translate.previewLiveBadge,
                  style: badgeTextStyle,
                ),
              ),
            ),
          if (state.errorMessage != null && framePath == null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Center(
                child: Text(
                  Languages.translate.previewFrameError,
                  style: captionStyle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent({
    required this.icon,
    required this.label,
    required this.captionStyle,
  });

  final Widget icon;
  final String label;
  final TextStyle captionStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: 8),
        Text(label, style: captionStyle),
      ],
    );
  }
}

/// Loads a [File] image without the black flash that occurs when the
/// underlying [Image] widget is rebuilt with a new key. The next frame is
/// decoded off-screen; the previously displayed frame stays visible until the
/// new one is ready, then we swap atomically.
class _SmoothFileImage extends StatefulWidget {
  const _SmoothFileImage({
    required this.path,
    required this.revision,
    required this.fallback,
  });

  final String path;
  final int revision;
  final Widget fallback;

  @override
  State<_SmoothFileImage> createState() => _SmoothFileImageState();
}

class _SmoothFileImageState extends State<_SmoothFileImage> {
  ImageProvider? _displayed;
  ImageStream? _pendingStream;
  ImageStreamListener? _pendingListener;

  @override
  void initState() {
    super.initState();
    _loadNext();
  }

  @override
  void didUpdateWidget(_SmoothFileImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path ||
        oldWidget.revision != widget.revision) {
      _loadNext();
    }
  }

  @override
  void dispose() {
    _detachPending();
    super.dispose();
  }

  void _detachPending() {
    if (_pendingStream != null && _pendingListener != null) {
      _pendingStream!.removeListener(_pendingListener!);
    }
    _pendingStream = null;
    _pendingListener = null;
  }

  void _loadNext() {
    _detachPending();
    final next = FileImage(File(widget.path));
    // File at this path may have been overwritten — drop any cached decode.
    next.evict().whenComplete(() {
      if (!mounted) return;
      final stream = next.resolve(ImageConfiguration.empty);
      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, _) {
          if (!mounted) return;
          if (_pendingListener == listener) {
            stream.removeListener(listener);
            _pendingStream = null;
            _pendingListener = null;
            setState(() => _displayed = next);
          }
        },
        onError: (e, st) {
          if (_pendingListener == listener) {
            stream.removeListener(listener);
            _pendingStream = null;
            _pendingListener = null;
          }
        },
      );
      _pendingStream = stream;
      _pendingListener = listener;
      stream.addListener(listener);
    });
  }

  @override
  Widget build(BuildContext context) {
    final image = _displayed;
    if (image == null) return widget.fallback;
    return Image(image: image, fit: BoxFit.contain, gaplessPlayback: true);
  }
}

String _labelText(PreviewState state) {
  if (state.isLoading) return Languages.translate.previewLoadingFrame;
  return Languages.translate.previewNoSelection;
}
