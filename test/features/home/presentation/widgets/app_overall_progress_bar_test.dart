import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/core/navigation/app_navigator.dart';
import 'package:video_toolkit/features/home/domain/queue_completion_action.dart';
import 'package:video_toolkit/features/home/presentation/widgets/app_overall_progress_bar.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_state.dart';
import 'package:video_toolkit/generated/l10n/app_localizations.dart';

void main() {
  testWidgets('action picker remains visible and editable while idle', (
    tester,
  ) async {
    var selected = QueueCompletionAction.none;
    await tester.pumpWidget(
      _TestApp(
        child: SizedBox(
          width: 1000,
          child: AppOverallProgressBar(
            encodeState: const VideoEncodeState(),
            queueCompletionAction: selected,
            onQueueCompletionActionChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('queue-completion-action-picker')),
      findsOneWidget,
    );
    expect(find.text('After queue'), findsOneWidget);
    expect(find.text('Do nothing'), findsOneWidget);

    await tester.tap(find.text('Do nothing'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shut down'));
    await tester.pumpAndSettle();

    expect(selected, QueueCompletionAction.shutdown);
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
      home: MacosScaffold(
        children: [ContentArea(builder: (_, _) => Center(child: child))],
      ),
    );
  }
}
