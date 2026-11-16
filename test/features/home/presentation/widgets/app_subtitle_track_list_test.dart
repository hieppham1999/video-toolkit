import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/core/navigation/app_navigator.dart';
import 'package:video_toolkit/features/home/presentation/widgets/app_subtitle_track_list.dart';
import 'package:video_toolkit/features/video_metadata/data/models/video_metadata.dart';
import 'package:video_toolkit/generated/l10n/app_localizations.dart';

void main() {
  testWidgets('updates tracks and distinguishes unavailable from empty', (
    tester,
  ) async {
    Future<void> show(List<SubtitleTrack>? tracks) async {
      await tester.pumpWidget(_TestApp(tracks: tracks));
      await tester.pumpAndSettle();
    }

    await show(null);
    expect(
      find.text('Subtitle information is not available yet'),
      findsOneWidget,
    );
    expect(find.text('No subtitle tracks'), findsNothing);

    await show(const []);
    expect(find.text('Subtitle tracks (0)'), findsOneWidget);
    expect(find.text('No subtitle tracks'), findsOneWidget);

    await show(const [
      SubtitleTrack(
        index: 2,
        title: 'English',
        language: 'eng',
        codec: 'subrip',
        isDefault: true,
      ),
      SubtitleTrack(index: 3, language: 'und', isForced: true),
    ]);
    expect(find.text('Subtitle tracks (2)'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('eng'), findsOneWidget);
    expect(find.text('subrip'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Forced'), findsOneWidget);
    expect(find.text('Subtitle 2'), findsOneWidget);
    expect(find.text('Unknown language'), findsOneWidget);
    expect(find.text('Unknown codec'), findsOneWidget);

    await show(const [SubtitleTrack(index: 1, title: 'Other video')]);
    expect(find.text('Other video'), findsOneWidget);
    expect(find.text('English'), findsNothing);
    expect(find.text('Forced'), findsNothing);
  });

  testWidgets('long track lists fit a narrow scrolling metadata column', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        tracks: List.generate(
          30,
          (i) => SubtitleTrack(
            index: i,
            title: 'A long subtitle track name $i',
            language: 'vie',
            codec: 'hdmv_pgs_subtitle',
            isDefault: true,
            isForced: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('subtitle-track-29')),
      200,
    );
    expect(find.text('A long subtitle track name 29'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders Vietnamese fallback labels', (tester) async {
    await tester.pumpWidget(
      const _TestApp(
        locale: Locale('vi'),
        tracks: [SubtitleTrack(index: 1, isDefault: true, isForced: true)],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Các track subtitle (1)'), findsOneWidget);
    expect(find.text('Chưa rõ ngôn ngữ'), findsOneWidget);
    expect(find.text('Mặc định'), findsOneWidget);
    expect(find.text('Bắt buộc'), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.tracks, this.locale = const Locale('en')});
  final List<SubtitleTrack>? tracks;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: SizedBox(
        width: 220,
        height: 180,
        child: SingleChildScrollView(
          child: AppSubtitleTrackList(tracks: tracks),
        ),
      ),
    );
    if (Platform.isWindows) {
      return fluent.FluentApp(
        navigatorKey: NavigatorKey.key,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      );
    }
    return MacosApp(
      navigatorKey: NavigatorKey.key,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}
