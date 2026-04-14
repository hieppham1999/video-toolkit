import 'package:video_toolkit/generated/l10n/app_localizations.dart';
import 'package:video_toolkit/core/navigation/app_navigator.dart';

class Languages {
  Languages._();

  static final Languages _instance = Languages._();

  /// Access the singleton instance
  static Languages get instance => _instance;

  /// Access the current [AppLocalizations] instance
  static AppLocalizations get translate =>
      AppLocalizations.of(NavigatorKey.key.currentContext!)!;
}