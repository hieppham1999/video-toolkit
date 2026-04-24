import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';

/// Single entry in [showAppContextMenu].
class AppContextMenuItem {
  const AppContextMenuItem({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
}

/// Shows a lightweight right-click context menu at [globalPosition].
/// Platform-neutral shell, theme-aware colors. Closes on outside tap or esc.
Future<void> showAppContextMenu({
  required BuildContext context,
  required Offset globalPosition,
  required List<AppContextMenuItem> items,
}) async {
  if (items.isEmpty) return;
  final overlay = Overlay.of(context);
  final isDark = Platform.isWindows
      ? fluent.FluentTheme.of(context).brightness == Brightness.dark
      : MacosTheme.of(context).brightness == Brightness.dark;

  final bg = isDark
      ? const Color(0xFF2E2E30)
      : const Color(0xFFFFFFFF);
  final border = isDark
      ? const Color(0x33FFFFFF)
      : const Color(0x22000000);
  final hoverBg = isDark
      ? const Color(0x22FFFFFF)
      : const Color(0x0D000000);
  final textColor = isDark ? CupertinoColors.white : CupertinoColors.black;

  late OverlayEntry entry;
  final completer = <bool>[];

  void close() {
    if (completer.isEmpty) {
      completer.add(true);
      entry.remove();
    }
  }

  entry = OverlayEntry(
    builder: (ctx) {
      final screenSize = MediaQuery.of(ctx).size;
      const menuWidth = 180.0;
      final itemHeight = 30.0;
      final menuHeight = items.length * itemHeight + 8;
      var left = globalPosition.dx;
      var top = globalPosition.dy;
      if (left + menuWidth > screenSize.width) left = screenSize.width - menuWidth - 4;
      if (top + menuHeight > screenSize.height) top = screenSize.height - menuHeight - 4;

      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: close,
              onSecondaryTap: close,
            ),
          ),
          Positioned(
            left: left,
            top: top,
            width: menuWidth,
            child: _MenuPanel(
              bg: bg,
              border: border,
              hoverBg: hoverBg,
              textColor: textColor,
              itemHeight: itemHeight,
              items: items,
              onSelected: (item) {
                close();
                item.onTap();
              },
            ),
          ),
        ],
      );
    },
  );

  overlay.insert(entry);
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({
    required this.bg,
    required this.border,
    required this.hoverBg,
    required this.textColor,
    required this.itemHeight,
    required this.items,
    required this.onSelected,
  });

  final Color bg;
  final Color border;
  final Color hoverBg;
  final Color textColor;
  final double itemHeight;
  final List<AppContextMenuItem> items;
  final ValueChanged<AppContextMenuItem> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0x33000000),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items
              .map(
                (it) => _MenuRow(
                  item: it,
                  height: itemHeight,
                  hoverBg: hoverBg,
                  textColor: it.isDestructive ? AppColors.error : textColor,
                  onTap: () => onSelected(it),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _MenuRow extends StatefulWidget {
  const _MenuRow({
    required this.item,
    required this.height,
    required this.hoverBg,
    required this.textColor,
    required this.onTap,
  });

  final AppContextMenuItem item;
  final double height;
  final Color hoverBg;
  final Color textColor;
  final VoidCallback onTap;

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final style = Platform.isWindows
        ? fluent.FluentTheme.of(context).typography.body
        : MacosTheme.of(context).typography.body;
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: _hovered ? widget.hoverBg : null,
          alignment: Alignment.centerLeft,
          child: Text(
            widget.item.label,
            style: (style ?? const TextStyle()).copyWith(color: widget.textColor),
          ),
        ),
      ),
    );
  }
}
