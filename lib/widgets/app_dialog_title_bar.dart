import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';

/// Cross-platform dialog title bar.
///
/// Owns its own drag state and close action — no callbacks to wire up:
/// - Close (macOS red traffic light / Windows `X`) pops the enclosing route
///   via `Navigator.of(context).pop()`.
/// - When [child] is set on macOS the widget ALSO wraps the whole thing in
///   a `MacosSheet`, then (if [draggable]) wraps that sheet in a
///   `Transform.translate` so drag moves the entire window rather than just
///   its inner contents. On Windows the title bar is slotted directly into
///   `ContentDialog.title`, so [child] / [draggable] / [insetPadding] are
///   ignored there.
class AppDialogTitleBar extends StatefulWidget {
  const AppDialogTitleBar({
    super.key,
    required this.title,
    this.trailing,
    this.child,
    this.draggable = false,
    this.insetPadding,
    this.shrinkWrap = false,
  });

  final Widget title;
  final Widget? trailing;

  /// macOS only: body rendered below the title bar, wrapped in `MacosSheet`.
  /// Leave `null` on Windows (use `ContentDialog.content` instead).
  final Widget? child;

  /// macOS only: enables drag-to-move on the title bar's empty area + reset
  /// on double-tap / yellow / green traffic lights.
  final bool draggable;

  /// macOS only: forwarded to `MacosSheet.insetPadding` when [child] is set.
  final EdgeInsets? insetPadding;

  /// macOS only: when true, the inner `Column` uses `MainAxisSize.min` and
  /// doesn't `Expanded`-wrap [child] — the sheet shrinks vertically to fit
  /// content. Use for simple settings-style dialogs. Defaults to false
  /// (sheet fills available height, child is `Expanded`).
  final bool shrinkWrap;

  @override
  State<AppDialogTitleBar> createState() => _AppDialogTitleBarState();
}

class _AppDialogTitleBarState extends State<AppDialogTitleBar> {
  Offset _dragOffset = Offset.zero;

  void _close() => Navigator.of(context).pop();

  void _dragBy(Offset delta) => setState(() => _dragOffset += delta);

  void _resetDrag() => setState(() => _dragOffset = Offset.zero);

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return _FluentTitleBar(
        title: widget.title,
        trailing: widget.trailing,
        onClose: _close,
      );
    }

    final bar = _MacosTitleBar(
      title: widget.title,
      trailing: widget.trailing,
      draggable: widget.draggable,
      onClose: _close,
      onResetDrag: _resetDrag,
      onDrag: _dragBy,
    );

    if (widget.child == null) return bar;

    // Wrap body in a MacosSheet so that — when [draggable] is true — the
    // enclosing Transform moves the whole sheet (window chrome + content),
    // not just the content inside a sheet that stays pinned.
    final sheet = MacosSheet(
      insetPadding: widget.insetPadding,
      child: Column(
        mainAxisSize:
            widget.shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          bar,
          if (widget.shrinkWrap) widget.child! else Expanded(child: widget.child!),
        ],
      ),
    );

    if (widget.draggable) {
      return Transform.translate(offset: _dragOffset, child: sheet);
    }
    return sheet;
  }
}

class _MacosTitleBar extends StatelessWidget {
  const _MacosTitleBar({
    required this.title,
    required this.trailing,
    required this.draggable,
    required this.onClose,
    required this.onResetDrag,
    required this.onDrag,
  });

  final Widget title;
  final Widget? trailing;
  final bool draggable;
  final VoidCallback onClose;
  final VoidCallback onResetDrag;
  final ValueChanged<Offset> onDrag;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final b = theme.brightness;

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle(b),
        border: Border(bottom: BorderSide(color: AppColors.divider(b))),
      ),
      // Stack so the title can be absolutely centered to the full bar width
      // regardless of traffic lights / trailing widths. Layers bottom→top:
      //   1. drag-detector fill (so empty gutters receive pan/double-tap)
      //   2. centered title (IgnorePointer — text doesn't swallow drag)
      //   3. Row with traffic lights on the left, trailing on the right
      //      (buttons still receive their own taps)
      child: Stack(
        children: [
          if (draggable)
            Positioned.fill(
              child: MouseRegion(
                cursor: SystemMouseCursors.move,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (d) => onDrag(d.delta),
                  onDoubleTap: onResetDrag,
                ),
              ),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: DefaultTextStyle(
                  style: theme.typography.title3,
                  child: title,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Row(
              children: [
                const SizedBox(width: 10),
                _TrafficLightButton(
                  color: AppColors.trafficRedLight,
                  borderColor: AppColors.trafficRedDark,
                  icon: CupertinoIcons.xmark,
                  onTap: onClose,
                ),
                const SizedBox(width: 8),
                _TrafficLightButton(
                  color: AppColors.trafficYellowLight,
                  borderColor: AppColors.trafficYellowDark,
                  icon: CupertinoIcons.minus,
                  onTap: draggable ? onResetDrag : () {},
                ),
                const SizedBox(width: 8),
                _TrafficLightButton(
                  color: AppColors.trafficGreenLight,
                  borderColor: AppColors.trafficGreenDark,
                  icon: CupertinoIcons.fullscreen,
                  onTap: draggable ? onResetDrag : () {},
                ),
                const Spacer(),
                if (trailing != null) trailing!,
                const SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FluentTitleBar extends StatelessWidget {
  const _FluentTitleBar({
    required this.title,
    required this.trailing,
    required this.onClose,
  });

  final Widget title;
  final Widget? trailing;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(color: theme.resources.cardStrokeColorDefault),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          DefaultTextStyle(
            style: theme.typography.bodyStrong ?? const TextStyle(),
            child: title,
          ),
          const Spacer(),
          if (trailing != null) trailing!,
          const SizedBox(width: 8),
          fluent.IconButton(
            icon: const fluent.Icon(fluent.FluentIcons.chrome_close, size: 12),
            onPressed: onClose,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TrafficLightButton extends StatefulWidget {
  const _TrafficLightButton({
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.onTap,
  });

  final Color color;
  final Color borderColor;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_TrafficLightButton> createState() => _TrafficLightButtonState();
}

class _TrafficLightButtonState extends State<_TrafficLightButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            border: Border.all(color: widget.borderColor, width: 0.5),
          ),
          alignment: Alignment.center,
          child: _hovered
              ? Icon(widget.icon, size: 8, color: AppColors.overlayIconShadow)
              : null,
        ),
      ),
    );
  }
}
