import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/core/navigation/app_navigator.dart';
import 'package:video_toolkit/features/app_settings/presentation/widgets/app_output_directory_dialog.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/output_directory_settings.dart';
import 'package:video_toolkit/generated/l10n/app_localizations.dart';
import 'package:video_toolkit/widgets/app_button.dart';

void main() {
  testWidgets('per-file dialog saves null while inheriting global output', (
    tester,
  ) async {
    OutputDirectorySettings? saved = const OutputDirectorySettings(
      mode: OutputDirectoryMode.custom,
      customPath: '/not-saved',
    );
    await tester.pumpWidget(
      _TestApp(
        onOpen: (context) => showAppOutputDirectoryDialog(
          context: context,
          globalSettings: const OutputDirectorySettings(),
          isPerFile: true,
          sampleInputPath: '/videos/video.mp4',
          sampleEncodeSettings: const EncodeSettings(),
          onSave: (value) => saved = value,
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Use global output directory'), findsOneWidget);
    expect(find.text('Same as source file'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(saved, isNull);
  });

  testWidgets('global dialog blocks an empty custom directory', (tester) async {
    var saveCount = 0;
    await tester.pumpWidget(
      _TestApp(
        onOpen: (context) => showAppOutputDirectoryDialog(
          context: context,
          globalSettings: const OutputDirectorySettings(
            mode: OutputDirectoryMode.custom,
          ),
          isPerFile: false,
          sampleInputPath: '/videos/video.mp4',
          sampleEncodeSettings: const EncodeSettings(),
          onSave: (_) => saveCount++,
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(
      find.text('Choose a custom output directory before saving.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(saveCount, 0);
    expect(find.text('Output directory'), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.onOpen});

  final ValueChanged<BuildContext> onOpen;

  @override
  Widget build(BuildContext context) {
    final home = Builder(
      builder: (context) => Center(
        child: AppButton(
          onPressed: () => onOpen(context),
          child: const Text('Open', style: TextStyle()),
        ),
      ),
    );
    if (Platform.isWindows) {
      return fluent.FluentApp(
        navigatorKey: NavigatorKey.key,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      );
    }
    return MacosApp(
      navigatorKey: NavigatorKey.key,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MacosScaffold(children: [ContentArea(builder: (_, _) => home)]),
    );
  }
}
