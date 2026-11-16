import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/core/theme/app_colors.dart';
import 'package:video_toolkit/features/video_metadata/data/models/video_metadata.dart';

/// The same track list is used by both home renderers.
class AppSubtitleTrackList extends StatelessWidget {
  const AppSubtitleTrackList({super.key, required this.tracks});

  final List<SubtitleTrack>? tracks;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final TextStyle body;
    final TextStyle heading;
    final TextStyle subtle;
    if (Platform.isWindows) {
      final theme = fluent.FluentTheme.of(context);
      body = theme.typography.body ?? DefaultTextStyle.of(context).style;
      heading = theme.typography.bodyStrong ?? body;
      subtle = body.copyWith(color: theme.resources.textFillColorSecondary);
    } else {
      final theme = MacosTheme.of(context);
      body = theme.typography.body;
      heading = theme.typography.headline;
      subtle = body.copyWith(color: AppColors.textSecondary(theme.brightness));
    }

    final items = tracks;
    if (items == null) {
      return Text(l10n.subtitleTracksUnavailable, style: subtle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.subtitleTracks(items.length), style: heading),
        const SizedBox(height: 8),
        if (items.isEmpty) Text(l10n.noSubtitleTracks, style: subtle),
        for (var i = 0; i < items.length; i++)
          Padding(
            key: ValueKey('subtitle-track-${items[i].index}'),
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nonEmpty(items[i].title) ?? l10n.subtitleTrackName(i + 1),
                  style: body,
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    Text(
                      _language(items[i].language) ??
                          l10n.subtitleLanguageUnknown,
                      style: subtle,
                    ),
                    Text(
                      _nonEmpty(items[i].codec) ?? l10n.subtitleCodecUnknown,
                      style: subtle,
                    ),
                    if (items[i].isDefault)
                      Text(l10n.subtitleDefault, style: subtle),
                    if (items[i].isForced)
                      Text(l10n.subtitleForced, style: subtle),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  String? _nonEmpty(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }

  String? _language(String? value) {
    final language = _nonEmpty(value);
    return language == 'und' ? null : language;
  }
}
