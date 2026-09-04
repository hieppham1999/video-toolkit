import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/core/navigation/app_navigator.dart';
import 'package:video_toolkit/features/home/domain/queue_completion_action.dart';
import 'package:video_toolkit/generated/l10n/app_localizations.dart';
import 'package:video_toolkit/widgets/app_power_action_countdown_dialog.dart';

void main() {
  testWidgets('countdown executes automatically when it reaches zero', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      _TestApp(
        child: Builder(
          builder: (context) => GestureDetector(
            onTap: () async {
              result = await showAppPowerActionCountdownDialog(
                context: context,
                action: QueueCompletionAction.shutdown,
                seconds: 2,
              );
            },
            child: const Text('open', style: TextStyle(fontSize: 14)),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    expect(find.text('Shut down in 2 seconds.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Shut down in 1 seconds.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(result, isTrue);
  });

  testWidgets('cancel closes the countdown without executing', (tester) async {
    bool? result;
    await tester.pumpWidget(
      _TestApp(
        child: Builder(
          builder: (context) => GestureDetector(
            onTap: () async {
              result = await showAppPowerActionCountdownDialog(
                context: context,
                action: QueueCompletionAction.restart,
                seconds: 30,
              );
            },
            child: const Text('open', style: TextStyle(fontSize: 14)),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('execute now skips the remaining countdown', (tester) async {
    bool? result;
    await tester.pumpWidget(
      _TestApp(
        child: Builder(
          builder: (context) => GestureDetector(
            onTap: () async {
              result = await showAppPowerActionCountdownDialog(
                context: context,
                action: QueueCompletionAction.sleep,
                seconds: 30,
              );
            },
            child: const Text('open', style: TextStyle(fontSize: 14)),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Execute now'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
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
