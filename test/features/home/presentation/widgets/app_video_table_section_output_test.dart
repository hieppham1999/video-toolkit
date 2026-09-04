import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/core/navigation/app_navigator.dart';
import 'package:video_toolkit/features/home/data/models/video_file.dart';
import 'package:video_toolkit/features/home/presentation/widgets/app_video_table_section.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/output_directory_settings.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_state.dart';
import 'package:video_toolkit/generated/l10n/app_localizations.dart';

void main() {
  testWidgets('output action sits beside settings and locks while encoding', (
    tester,
  ) async {
    const path = '/videos/video.mp4';
    final file = VideoFile(
      path: path,
      name: 'video.mp4',
      sizeInBytes: 100,
      importedAt: DateTime(2026),
    );

    Widget table(VideoEncodeState encodeState) => SizedBox(
      width: 1200,
      height: 300,
      child: AppVideoTableSection(
        files: [file],
        globalSettings: const EncodeSettings(),
        outputDirectory: const OutputDirectorySettings(),
        selectedFilePath: null,
        encodeState: encodeState,
        presets: const [],
        globalSelectedPresetId: null,
        onSelect: (_) {},
        onRemove: (_) {},
        onRemoveAll: () {},
        onOpenFileSettings: (_) {},
        onUpdateFileOutputDirectory: (_, _) {},
      ),
    );

    await tester.pumpWidget(
      _TestApp(
        child: table(
          const VideoEncodeState(
            status: EncodeStatus.done,
            currentIndex: 1,
            totalFiles: 1,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final settings = find.byKey(const ValueKey('video-settings-$path'));
    final output = find.byKey(const ValueKey('video-output-$path'));
    final remove = find.byKey(const ValueKey('video-remove-$path'));
    expect(settings, findsOneWidget);
    expect(output, findsOneWidget);
    expect(remove, findsOneWidget);
    expect(
      tester.getCenter(settings).dx,
      lessThan(tester.getCenter(output).dx),
    );
    expect(tester.getCenter(output).dx, lessThan(tester.getCenter(remove).dx));

    await tester.pumpWidget(
      _TestApp(
        child: table(
          const VideoEncodeState(status: EncodeStatus.encoding, totalFiles: 1),
        ),
      ),
    );
    await tester.pump();

    expect(settings, findsNothing);
    expect(output, findsNothing);
    expect(remove, findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return fluent.FluentApp(
        navigatorKey: NavigatorKey.key,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(child: child),
      );
    }
    return MacosApp(
      navigatorKey: NavigatorKey.key,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Center(child: child),
    );
  }
}
